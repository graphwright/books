# The Typed Graph

This file defines the typed graph precisely,
establishes vocabulary, states hard rules, and lists explicit non-goals.
When in doubt, check against this file before generating code, prose, or
schema definitions. Suitable for inclusion in a CLAUDE.md file.

---

## Formal Definition

A typed graph G is a 7-tuple $(T_V,\ T_E,\ \Phi,\ V,\ E,\ \tau_V,\ \tau_E)$ where:

### Schema layer (types) -- fixed at graph-design time

- $T_V$ -- finite set of **entity types**
- $T_E$ -- finite set of **predicate types**
- $\Phi: T_V \cup T_E \to \text{FieldSchema}$ -- assigns a POJO field schema to each type
- For each $p \in T_E$:
  - $\text{dom}(p) \subseteq T_V$ -- permitted subject entity types
  - $\text{ran}(p) \subseteq T_V$ -- permitted object entity types
  - $\text{Tr}(p) \subseteq \text{Trait}$ -- finite set of semantic traits

### Instance layer -- populated at ingestion or reasoning time

- $V$ -- set of **entity instances**
- $E \subseteq V \times T_E \times V$ -- set of directed, typed **edge instances** (triples)
- $\tau_V: V \to T_V$ -- type assignment for entities
- $\tau_E: E \to T_E$ -- induced by the middle element of each edge triple

### Validity constraints

1. **Domain/range**: $\forall (v_1,\ p,\ v_2) \in E:\ \tau_V(v_1) \in \text{dom}(p)\ \land\ \tau_V(v_2) \in \text{ran}(p)$
2. **Schema conformance**: each $v \in V$ carries fields satisfying $\Phi(\tau_V(v))$; each $e \in E$ carries fields satisfying $\Phi(p_e)$

### Trait vocabulary

$$\text{Trait} ::= \text{Symmetric} \mid \text{Transitive} \mid \text{Functional} \mid \text{InverseFunctional} \mid \text{Inverse}(p') \mid \text{Rule}(\phi \Rightarrow \psi)$$

Examples:
- `located_in` carries $\text{Tr}(p) = \{\text{Transitive}\}$
- `married_to` carries $\text{Tr}(p) = \{\text{Symmetric}\}$
- `has_true_identity` carries $\text{Tr}(p) = \{\text{Functional}\}$
- `contains` carries $\text{Tr}(p) = \{\text{Inverse}(\texttt{contained\\_by})\}$

---

## Vocabulary

Use these terms consistently throughout the book. Do not treat them as synonyms.

| Term | Definition |
|---|---|
| **Entity type** | A member of $T_V$. Defines a class of entities: the schema of fields they carry and their permitted roles in edges. Example: `Person`, `Location`, `Moment`. |
| **Predicate type** | A member of $T_E$. Defines a class of edges: their field schema, domain, range, and traits. Example: `located_at`, `knows_at`, `possesses`. |
| **Entity instance** | A member of $V$. A concrete node in the graph with a type in $T_V$ and data fields. Example: a specific `Person` node for Sherlock Holmes. |
| **Edge instance** | A member of $E$. A concrete directed triple $(v_1, p, v_2)$ with a type in $T_E$ and data fields. The thing that carries metadata. |
| **Field schema** | The POJO-like declaration of named fields and their types for a given entity type or predicate type. Defined by $\Phi$. Enforced by Pydantic. |
| **Domain** | $\text{dom}(p)$ -- the set of entity types permitted in the subject role for predicate $p$. |
| **Range** | $\text{ran}(p)$ -- the set of entity types permitted in the object role for predicate $p$. |
| **Trait** | A declarative semantic property of a predicate type. Member of $\text{Tr}(p)$. Belongs to the schema, not to any edge instance. |
| **Schema** | The tuple $(T_V,\ T_E,\ \Phi)$ together with domain, range, and trait declarations. Fixed at graph-design time. |
| **Instance graph** | The tuple $(V,\ E,\ \tau_V,\ \tau_E)$. Populated at ingestion or reasoning time. |
| **Reification** | The anti-pattern of turning a statement into a node in order to annotate it. This model eliminates the need for reification because edge instances are first-class objects with fields. |

### Terms to avoid or use carefully

- **Relationship** -- always use this to mean edge instance, never a predicate type.
- **Node** -- informal synonym for entity instance. Acceptable in casual prose but not in definitions.
- **Property** -- overloaded; could mean a field on an instance or a trait on a predicate type. Be explicit.
- **Axiom** -- not used in this model. The formal-logic connotation is misleading. Use **trait** instead.

---

## Hard Rules

These rules follow from the formal definition. They must not be violated in
code examples, schema designs, or explanatory prose.

**R1. Traits belong to predicate types, never to edge instances.**
A predicate either has `Transitive` or it doesn't. That is part of what the
predicate *means*. An individual edge instance cannot be transitive or
non-transitive -- that distinction belongs to its type.

**R2. Metadata fields belong to edge instances, never to predicate types.**
Provenance, confidence, timestamps, known_to, epistemic_status -- all of these
are facts about a particular assertion. They live on the edge instance. The
predicate type defines which fields are permitted (via $\Phi$), but carries no
values itself.

**R3. Edges are directed triples, not annotated pairs.**
An edge instance is $(v_1, p, v_2)$ where $p \in T_E$. The predicate type is
part of the edge's identity, not an annotation on an untyped link. This is
what makes domain/range validation possible at construction time.

**R4. Domain and range are sets of entity types, not entity instances.**
$\text{dom}(p) \subseteq T_V$, not $\subseteq V$. You constrain which *kinds*
of things may appear as subject or object, not which specific things.

**R5. Schema is fixed; instances are populated.**
Nothing discovered during ingestion changes $T_V$, $T_E$, $\Phi$, domain,
range, or traits. If a new entity type seems necessary mid-ingestion, that is
a schema design problem, not an ingestion problem.

**R6. Entity IDs encode type.**
Use prefixed IDs of the form `entitytype:identifier` (e.g., `person:holmes`,
`location:briony_lodge`, `moment:m03`). The prefix is a type assertion and is
the basis for Pydantic domain/range validation at construction time. ID
generation discipline is not optional.

**R7. Pydantic models for edge instances are frozen.**
Use `model_config = ConfigDict(frozen=True)`. Edge instances are facts; they
should not be mutated after construction.

---

## Pydantic Enforcement Pattern

Domain and range constraints are enforced at construction time via prefixed IDs
and a `model_validator`. This pattern must be followed consistently:

```python
from __future__ import annotations
from typing import ClassVar, Literal
from pydantic import BaseModel, Field, model_validator, ConfigDict


class BaseTypedRelationship(BaseModel):
    model_config = ConfigDict(frozen=True)

    subject_id: str
    object_id: str

    # Subclasses declare these as ClassVar -- they are schema, not instance data
    allowed_subject_prefixes: ClassVar[frozenset[str]] = frozenset()
    allowed_object_prefixes: ClassVar[frozenset[str]] = frozenset()

    @model_validator(mode="after")
    def enforce_domain_and_range(self) -> BaseTypedRelationship:
        if self.allowed_subject_prefixes:
            prefix = self.subject_id.split(":")[0]
            if prefix not in self.allowed_subject_prefixes:
                raise ValueError(
                    f"{type(self).__name__} subject must be one of "
                    f"{self.allowed_subject_prefixes!r}, got {prefix!r}"
                )
        if self.allowed_object_prefixes:
            prefix = self.object_id.split(":")[0]
            if prefix not in self.allowed_object_prefixes:
                raise ValueError(
                    f"{type(self).__name__} object must be one of "
                    f"{self.allowed_object_prefixes!r}, got {prefix!r}"
                )
        return self


class PossessesAt(BaseTypedRelationship):
    """A Person possesses a PhysicalObject as of a given Moment."""
    allowed_subject_prefixes: ClassVar[frozenset[str]] = frozenset({"person"})
    allowed_object_prefixes: ClassVar[frozenset[str]] = frozenset({"object"})

    at_moment: str  # moment:xxx
    confidence: float = Field(ge=0.0, le=1.0, default=1.0)
    known_to: frozenset[str] = frozenset()
    epistemic_status: Literal[
        "ground_truth", "believed", "false_belief", "inferred"
    ] = "ground_truth"
```

---

## Non-Goals

These are explicitly *not* what this model is. Do not reach for patterns from
these systems when designing or explaining schema.

**Not RDF / OWL.**
In RDF, predicates are URIs and are themselves nodes; the graph is a flat set
of triples with no first-class edge objects. OWL adds description logic
semantics and open-world assumption. This model is a closed-world property
graph with typed, field-bearing edge instances. The distinction matters
especially for reification: RDF requires it, this model eliminates it.

**Not Neo4j's informal property graph.**
Neo4j allows arbitrary key-value properties on edges without schema
enforcement. This model requires a declared field schema ($\Phi$) and
enforced domain/range constraints. The structure is similar but the discipline
is different.

**Not an entity-relationship diagram.**
ER diagrams are a database design tool. This is a runtime knowledge
representation with provenance, epistemic scope, and trait-based inference
semantics. The superficial similarity (boxes and arrows) should not be used as
an explanatory frame.

**Not a general ontology language.**
This model does not support open-world reasoning, class hierarchies,
disjointness axioms, or the full OWL trait vocabulary. Traits are a small,
fixed set of declarative properties. If a use case seems to require full
description logic, that is scope creep.

---

## Current Domain: Holmes Corpus

The worked example for Book 3 uses the Sherlock Holmes canon as domain.

- **Ontology authority**: Baker Street Wiki (https://bakerstreet.fandom.com)
- **Schema construction method**: inductive -- built by annotating stories, not
  pre-designed
- **Primary stories**: "A Scandal in Bohemia", "The Speckled Band"
- **Provisional entity types**: `Person`, `Location`, `Object`, `Document`,
  `Moment`, `Event`, `Disguise`, `Plan`
- **Epistemic fields on edge instances**: `known_to`, `from_moment`,
  `ground_truth`, `epistemic_status`

The Holmes schema must satisfy all hard rules above. If a design decision for
the Holmes domain seems to require violating a rule, that is a signal to
revisit the decision, not to bend the rule.
