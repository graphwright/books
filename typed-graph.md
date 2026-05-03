# A formal definition of a typed graph

**Link:** [https://claude.ai/chat/e5826e0e-bed8-4b5c-b266-01294545393f](https://claude.ai/chat/e5826e0e-bed8-4b5c-b266-01294545393f)  

**The formal structure**

A typed graph G is a tuple (`V`, `E`, `T_V`, `T_E`) where:

- **T_V** is a finite set of *entity types* (the schema: `Person`, `Location`, `Moment`, ...)
- **T_E** is a finite set of *predicate types* (the schema: `located_at`, `knows_at`, `possesses`, ...)
- **V** is a set of *entity instances*, each assigned to exactly one type in `T_V`
- **E** is a set of *directed edge instances*, each assigned to exactly one type in `T_E`

Each predicate type p ∈ `T_E` carries:
- `dom(p)` ⊆ `T_V` — permitted subject entity types
- `ran(p)` ⊆ `T_V` — permitted object entity types
- A POJO field schema (the provenance/metadata fields)
- Optionally: *axioms* (see below)

The validity constraint: for every edge instance e = (v₁, v₂) with type p, we require type(v₁) ∈ dom(p) and type(v₂) ∈ ran(p).

---

**Predicate is to edge as class is to instance**.

The predicate carries the schema and the semantic rules. The edge carries the
data. Metadata (`confidence`, `known_to`, `epistemic_status`) lives on edges, never
on predicates. This is precisely what eliminates the need for reification — in
RDF you reify because statements are atomic and you can't hang metadata on
them; here edges are first-class objects with fields.

---

*Directionality.* Edges are ordered pairs (subject, object). This is implicit
in domain/range but worth making explicit — some predicates are symmetric
(`married_to`), most are not. Symmetry is one of the axioms below.

*Cardinality.* Each predicate type can optionally declare:

- Functional: each subject has at most one object (a Person has at most one `true_identity`)
- Inverse-functional: each object has at most one subject
- Many-to-many (the default): unconstrained

*The graph itself is a named, versioned object.* Particularly relevant once you have multiple stories or multiple domains — the graph has provenance too.

*Entities also have instances vs. types* — you had this right, just worth stating explicitly to complete the symmetry. The POJO fields live on entity instances, and entity types define the schema.

---

**Axioms: "magical behavior" on predicates**

This is where predicates earn behavior beyond pure data. Examples in ascending
complexity:

*Symmetry*: `married_to(A, B) ⟹ married_to(B, A)`. Any query engine or
inference pass can materialize the reverse edge automatically.

*Transitivity*: `located_in(A, B) ∧ located_in(B, C) ⟹ located_in(A, C)`. Lets
you ask "is the photograph in London?" by traversing room → building → street →
city.

*Inverse declaration*: `contains` is the inverse of `contained_by`. Write one,
get the other. This is structural, not inferential.

*Functional constraint*: `has_true_identity` is functional — a validator raises
if you try to add a second `has_true_identity` edge from the same subject. This
is the domain/range enforcement's sibling.

*Inference rules* (the most powerful): `believes(Agent, X, M) ∧ contradicts(X, Y) ⟹ false_belief(Agent, Y, M)`.
These are essentially Horn clauses that BFS-QL could evaluate. This is where
the mystery reasoning actually happens — not in the data, but in the predicate
axioms applied to the data.

The medical schema's `contradicted_by` list is a degenerate case of this — it's
storing the *output* of a contradiction rule rather than the rule itself.
Better to store the rule on the predicate type and derive contradiction edges
on query.

---

**Pydantic enforcement of domain and range?**

The key obstacle is that Pydantic validates a single object in isolation, but domain/range validation requires knowing the type of the entities at both ends of an edge — which are referenced by ID, not by value.

The cleanest solution: **encode entity type in the ID prefix**.

```python
entity_id="person:holmes"
entity_id="location:briony_lodge"
entity_id="moment:m03"
```

Then each edge class declares its constraints as class variables and validates against the prefix:

```python
class BaseMysteryRelationship(BaseModel):
    subject_id: str
    object_id: str
    
    # Subclasses override these
    allowed_subject_prefixes: ClassVar[frozenset[str]] = frozenset()
    allowed_object_prefixes: ClassVar[frozenset[str]] = frozenset()
    
    @model_validator(mode="after")
    def enforce_domain_and_range(self):
        if self.allowed_subject_prefixes:
            prefix = self.subject_id.split(":")[0]
            if prefix not in self.allowed_subject_prefixes:
                raise ValueError(
                    f"{type(self).__name__} subject must be one of "
                    f"{self.allowed_subject_prefixes}, got '{prefix}'"
                )
        if self.allowed_object_prefixes:
            prefix = self.object_id.split(":")[0]
            if prefix not in self.allowed_object_prefixes:
                raise ValueError(
                    f"{type(self).__name__} object must be one of "
                    f"{self.allowed_object_prefixes}, got '{prefix}'"
                )
        return self


class PossessesAt(BaseMysteryRelationship):
    """A Person possesses a PhysicalObject as of a given Moment."""
    allowed_subject_prefixes: ClassVar[frozenset[str]] = frozenset({"person"})
    allowed_object_prefixes: ClassVar[frozenset[str]] = frozenset({"object"})
    
    at_moment: str  # moment:xxx
    confidence: float = Field(ge=0.0, le=1.0, default=1.0)
    known_to: list[str] = Field(default_factory=list)
    epistemic_status: Literal["ground_truth", "believed", "false_belief"] = "ground_truth"
```

This gives you eager, self-contained, zero-lookup domain/range validation at
ingestion time. The cost is that your ID generation discipline has to be
airtight — the prefix *is* the type assertion.

---

To summarize the complete definition cleanly: a typed graph is a schema (`T_V`,
`T_E` with domain, range, cardinality, and axioms per type) paired with an
instance graph (`V`, `E` satisfying the schema constraints), where metadata
lives on instances and semantics live on types. The avoiding-reification
insight follows directly: because edge instances are first-class objects with
fields, there is nothing a reified statement node could express that an
annotated edge cannot.
