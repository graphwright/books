---
title: "The Typed Graph: Naming, Knowing, and Trusting Machine Knowledge"
author: "Will Ware"
date: "2026"
publisher: "Graphwright Publications"
rights: "CC BY 4.0"
lang: en
---

## Foreword: A Manifesto for Machine Knowledge

`\markboth{Foreword}{Foreword}`{=latex}

High-stakes reasoning requires things, not strings.

Similarity is not identity. Retrieval is not reasoning.

The LLM is the extraction and language layer. The graph is the reasoning
substrate. Conflating those two roles is where most systems go wrong.

RDF got the atoms right. It left the chemistry uncontrolled.

A typed graph fixes the chemistry: a finite, closed vocabulary of entity
types and predicates, each predicate with declared subject and object types.
What falls outside the vocabulary is inexpressible, not merely discouraged.
Category errors become detectable. Subtypes inherit constraints.

Canonical IDs connect the graph to the edifice of human knowledge. Two
sources that agree on an ID agree on a referent. Multi-hop causal reasoning
becomes possible when identity is unambiguous.

Provenance makes uncertainty composable. Inspectability makes correction
possible.

This is the minimum standard. Not a guarantee of truth -- a guarantee that
truth is pursuable.

---

## Preface

This book makes a single argument: that a graph of knowledge becomes
trustworthy in proportion to how precisely it is typed.

Type systems in programming languages were originally invented as tools for
mathematical proof. They migrated into compilers not because mathematicians
demanded it but because programmers kept making the same classes of mistakes --
mistakes that a formal vocabulary of types makes structurally inexpressible.
The same logic applies to graphs. A graph with a closed vocabulary of entity
types and predicates, each predicate with a declared type signature, can
reject a category error at write time rather than propagating it silently
through every downstream query.

The Sherlock Holmes corpus is the primary worked example. Holmes is chosen
deliberately: the stories contain disguises, false identities, unreliable
narration, and time-shifted revelations. These stress-test a typed graph in
ways a clean, well-curated corpus does not. Medical literature is the second
domain -- structurally different, higher stakes, and anchored to established
external ontologies.

The book proceeds from abstract to concrete: a formal mathematical definition,
a language-agnostic schema notation, a Python implementation, and then the
services that make the graph operational at scale. Readers who work in other
languages can engage fully with the first three parts and understand exactly
what they would need to build.

---

# Part I: The Case for Typed Graphs

*The Sherlock Holmes corpus is the running example throughout this book.
It is introduced in Chapter 1 and carried forward continuously -- not
re-introduced at each chapter. A reader arriving at Part III already knows
the Holmes schema.*

## Chapter 1: Why Typed Graphs

`\chaptermark{Why Typed Graphs}`{=latex}

### The Stakes

Machine reasoning is being deployed in medicine, law, and civil engineering --
domains where a hallucination in a reasoning chain is a misdiagnosis, a missed
precedent, or a structural failure. In those domains, provenance and
traceability are not features. They are the minimum conditions under which
automated reasoning can be trusted at all.

The cost of a hallucination in these domains is not a wrong answer on a quiz.
It is a patient given the wrong drug, a contract interpreted against the
client's interests, a load-bearing calculation that passed review because no
one could trace the inference to its source. You cannot accept "good enough"
results. You need to be able to explain the system's reasoning in terms that
a domain expert can verify and dispute. A user must be able to ask "why that
answer?" and get back something trustworthy.

The question this book addresses is: what does it take for machine reasoning
to be trustworthy in these domains? The answer is not a better model. It is
better structure. A typed graph with provenance is that structure.

### From RAG to Graph RAG to Typed Graphs

RAG -- retrieval-augmented generation\index{retrieval-augmented generation} --
works by embedding text passages as vectors and retrieving them by cosine
similarity. This is useful for quick lookups that you intend to verify manually
afterward: closer to a Google search than to a reasoning engine.

What RAG cannot give you is identity. It cannot tell you that this thing *is*
that thing -- that "tumor" and "neoplasm" refer to the same biological entity,
or that the drug mentioned in one paper is the same compound studied in another.
It cannot give you cause and effect: that this compound *caused* that reaction,
or that this gene variant *predicts* that outcome. There is no principled way
to compose similarity scores into a compound confidence: a cosine similarity
chain gives you nothing comparable to "three hops at 0.9 confidence each give
you 0.73." The arithmetic is undefined.

Graph RAG\index{Graph RAG} is not just better RAG. It is a different epistemic
commitment. The LLM serves as the extraction and natural-language interface
layer; the graph is the reasoning substrate. Those two roles require different
tools, and conflating them is where most systems go wrong.

The remaining gap even in Graph RAG systems is this: where did this edge come
from? Is this triple even well-formed? A typed graph answers both questions by
building guardrails into the structure itself, not bolting them on afterward.
Every edge carries its source. Every triple has been checked against a declared
vocabulary of types and predicates. The graph cannot contain what it cannot
express.

### The Reasoning Layer Is Not the Extraction Layer

A typed graph does not require a large language model to operate -- only to
build. The extraction layer is where LLMs earn their role: reading unstructured
text and producing structured claims. Once those claims are in the graph, the
reasoning substrate is simple, fast, and auditable: breadth-first traversal
over well-organized typed data.

This separation matters for more than architectural cleanliness. It means the
graph is future-proof in a way that an LLM-integrated system is not. The
extraction technology will change. It is changing now and will continue to
change. The model that extracts claims today will be replaced by a better
one tomorrow. But the graph -- if it is typed, if it has canonical IDs, if
it has provenance -- remains the stable substrate. You can re-extract from
the same corpus with a better model, compare the new triples against the old,
and update selectively without discarding accumulated reasoning.

The clearest illustration of this principle is a demonstration that has
nothing to do with LLMs at all. A graph built from the Sherlock Holmes
stories, running on a Raspberry Pi, can answer questions about the stories
using pure breadth-first search -- no cloud, no model, no API call. Which
characters knew each other? What locations are connected to a particular
case? Who had motive and opportunity in "The Adventure of the Abbey Grange"?
The graph traversal answers these questions by following typed edges from
node to node, returning the path as an auditable chain of evidence.

*[Placeholder: The Raspberry Pi demonstration -- full BFS traversal of the
Holmes graph, solving a mystery as a worked example, is planned as a
companion artifact to this book. The implementation uses SQLite with the
rusqlite crate in Rust, cross-compiled for aarch64. The demo will be
published alongside Chapter 3.]*

That demonstration is not a curiosity. It is an existence proof. A graph
organized by typed structure, canonical identity, and provenance supports
real reasoning without any of the machinery people associate with modern AI.
The machinery is for building the graph, not for using it. This is
future-proof reasoning infrastructure, not an LLM wrapper.

### Type Systems and Category Errors

The everyday intuition about types is the apples-and-oranges warning: you
can't compare them. But that intuition undersells what type systems actually
do. Dimensional analysis in physics is a better model. Meters plus seconds is
not merely wrong -- it is undefined. The operation has no coherent meaning.
The type system does not give you a low score for trying; it tells you the
question itself is malformed.

A typed graph extends this principle to knowledge claims. Consider the
assertion "aspirin treats BRCA1." The predicate `treats` has domain `[Drug]`
and range `[Disease]`. Aspirin is a Drug -- that is fine. But BRCA1 is a Gene,
not a Disease. The assertion is not a contested empirical claim. It is a type
mismatch, the knowledge equivalent of "meters plus seconds." A typed graph
rejects it at write time, before it enters the graph and before it can
propagate into downstream queries.

This matters most at scale. A knowledge graph built by hand, from a small
corpus, by a careful engineer, may stay coherent without mechanical
enforcement -- the engineer notices when something looks wrong. A knowledge
graph built by an extraction pipeline processing thousands of documents
cannot rely on human review at insertion time. The pipeline will produce
malformed triples. The only question is whether those triples are rejected
immediately or stored and discovered later, after they have joined the graph
and influenced derived facts.

The schema of a typed graph is a contract in the compiler sense: not
documentation about what the graph is supposed to contain, but a
machine-checkable constraint that governs every write. A predicate defined
with domain `[Drug]` and range `[Disease]` is not advice. It is a gate.
Any proposed triple that presents a non-Drug as the subject or a non-Disease
as the object is rejected at write time, unconditionally. There is no later
cleanup step that might or might not run.

### A Brief Intellectual History of Type Systems

The notion of a type system originates not in programming but in mathematical
logic, as a response to a crisis. In 1901, Bertrand Russell\index{Russell, Bertrand}
discovered that naive set theory -- the system Frege had used to ground
arithmetic -- contains a contradiction now known as Russell's paradox\index{Russell's paradox}.
The set of all sets that do not contain themselves: does it contain itself?
Either answer leads to a contradiction. Frege's edifice collapsed.

Russell's own remedy was the theory of types\index{type theory}. The key move was to
stratify mathematical objects into levels -- individuals, sets of individuals,
sets of sets of individuals -- and to forbid any statement that mixed levels.
The paradox dissolved because the set that caused it tried to contain itself,
which crossed a level boundary the type system prohibited. Bad mathematics
became not just false but syntactically unformable.

Alonzo Church's lambda calculus\index{lambda calculus} developed a formal system for
computation in the 1930s, and its typed variant introduced function types:
a function from integers to booleans is a different kind of thing from a
function from booleans to integers, and applying one where the other is
expected is a type error. The Curry-Howard correspondence\index{Curry-Howard correspondence}
later revealed that typed lambda calculus and constructive logic are
essentially the same thing: programs are proofs, types are propositions,
and a type-correct program is a valid proof. The compiler became a theorem
checker.

Types migrated into programming languages through a series of increasingly
practical forms. Algol 60 had typed variables. Pascal enforced types strictly
and was influential in making explicit typing a pedagogical norm. ML introduced
*inferred* types: the programmer need not annotate every variable, because the
compiler can deduce the types from how values are used. This was a revelation
-- you got the safety guarantees without the annotation overhead.

Haskell and OCaml extended this to algebraic data types\index{algebraic data types} and
parametric polymorphism, making it possible to express "a list of things of
any type" without sacrificing the ability to check that you only put integers
into a list of integers. The slogan that emerged from this tradition was
"make illegal states unrepresentable"\index{illegal states unrepresentable}: design your types
so that a program that compiles cannot reach an invalid state. Null pointer
exceptions are impossible in a language that has no null. Buffer overflows
are impossible in a language whose type system tracks array bounds.

Rust\index{Rust} pushed this further with ownership types\index{ownership types}: a type system that
tracks not just what kind of data a value holds, but who owns it and for how
long. Use-after-free, double-free, and data races are type errors in Rust.
The compiler refuses to produce a program that could commit them.

The through-line across this history is a bet: that certain classes of error
can be made structurally inexpressible -- not caught at runtime, not
documented in a README, but impossible to form in the first place. Each step
in this history is a new domain where that bet has been placed and won.

A typed graph places the same bet on knowledge claims. Certain classes of
claim -- ones that violate the type signature of a predicate, ones that
reference entities the graph has no record of, ones that lack a required
provenance field -- become inexpressible. Not unlikely, not low-confidence,
not flagged for review. Inexpressible. The schema is the type system. The
insertion gate is the compiler pass. Chapter 11 develops this analogy fully.

### An Informal Definition of the Typed Graph

Before the formal definition in Chapter 2, it is worth touring the components
informally. A typed graph has six properties that together distinguish it from
a plain property graph and from RDF.

**A finite, closed vocabulary of entity types.** Every node in the graph is
classified as exactly one kind of thing, drawn from a list that is defined in
advance and cannot be extended at write time. A node is a `Person` or a
`Location` or a `Drug` -- not an untyped blob of properties, and not a URI
that could mean anything.

**A finite, closed vocabulary of predicates.** Every edge in the graph is
labeled with a predicate drawn from a declared list. A predicate that does
not appear in the schema does not exist. An assertion that uses an undeclared
predicate is not stored as an unknown fact -- it is a type error.

**Type signatures on predicates.** Each predicate declares its domain (the
set of entity types allowed as its subject) and its range (the set allowed
as its object). These are enforced at write time.

**Canonical IDs.** Every entity node is identified by a stable identifier
drawn from an external authoritative source where one exists. Two extractions
that refer to the same real-world entity resolve to the same node.

**Provenance on every edge.** Every edge carries a reference to the source
that supports it: the document, the passage, the extraction method. An edge
without provenance is not a weak claim -- it is a malformed record.

**The closed-world assumption.** Absence of an edge between two entities is
informative. If the predicate exists and no edge of that predicate connects
these two entities, that means something -- either the relationship does not
hold, or the corpus does not assert it. The distinction is explicit rather
than silent.

The Resource Description Framework (RDF)\index{RDF} got the foundational atoms
right: the triple as the atomic unit of knowledge, URIs as stable referents,
the basic idea of linked data. What RDF left uncontrolled is what can appear
in each position of the triple. Any URI can be a subject, any URI can be a
predicate, any URI or literal can be an object. There are no entity types.
Predicates carry no type signatures. The result is a system with no gate
on the vocabulary: category errors are not detectable, they are merely
possible.

A property graph\index{property graph} -- the model used by Neo4j\index{Neo4j} and similar
systems -- treats relationships as first-class citizens. An edge has a type,
a start node, an end node, and a set of properties. Provenance, confidence,
and evidence ride on the edge where they belong, without the reification
gymnastics RDF requires. But property graphs historically left the
enforcement of types and predicate signatures to application code. The
schema, if one exists, is documentation, not a gate.

The typed graph is the synthesis: first-class edges with typed nodes,
constrained predicates, canonical IDs, and provenance -- all enforced by
the structure itself.

The Holmes corpus is this book's primary witness. Holmes is chosen
deliberately: the stories contain disguises, unreliable narrators, and
revelations that retroactively reinterpret earlier facts. A Holmes graph
needs to represent not just what happened, but who knew what and when.
These requirements push the schema in ways a clean scientific corpus does
not, which makes Holmes a better stress test than a well-curated dataset
where everything is labeled and nobody lies. Chapter 2 introduces the
Holmes schema formally; Chapter 3 presents it in full as a YAML document.

---

## Chapter 2: The Formal Definition

`\chaptermark{The Formal Definition}`{=latex}

### Why Formalism

Informal descriptions of a typed graph are useful for building intuition.
They are not sufficient for specifying exactly what a typed graph is and
is not -- for determining, unambiguously, whether a given triple is valid,
whether a given schema is self-consistent, or whether two graphs built by
different teams against the same specification are interoperable.

Mathematics is the most precise language available for these questions.
This chapter provides a formal definition that is short enough to hold in
working memory and precise enough to resolve any question about conformance.
Programmers who find mathematical notation off-putting are invited to read
it anyway. The definition is seven components long. The rigor pays for
itself in every downstream chapter that can say "this is what Chapter 2
calls $T_E$" rather than re-explaining the concept.

### The Seven-Tuple

A typed graph is a seven-tuple $(T_V,\ T_E,\ \Phi,\ V,\ E,\ \tau_V,\ \tau_E)$
where:

- $T_V$ is a finite set of **entity types** (the vertex type vocabulary).
  Example: $T_V = \{\texttt{Person}, \texttt{Location}, \texttt{Object}, \texttt{Event}\}$.

- $T_E$ is a finite set of **predicate types** (the edge type vocabulary).
  Example: $T_E = \{\texttt{associated\_with}, \texttt{disguised\_as}, \texttt{occurred\_at}\}$.

- $\Phi$ is a **field schema assignment**: for each type $t \in T_V \cup T_E$,
  $\Phi(t)$ specifies the fields (names and value types) that instances of $t$
  must carry. For entity types these might include a canonical ID field and a
  provenance timestamp; for predicate types they include a source citation and
  confidence score.

- For each $p \in T_E$: a non-empty set $\text{dom}(p) \subseteq T_V$ of
  **permitted subject types**, a non-empty set $\text{rng}(p) \subseteq T_V$
  of **permitted object types**, and a (possibly empty) **trait set**
  $\text{Tr}(p)$ drawn from the trait vocabulary defined below.

- $V$ is a set of **entity instances**, each a record conforming to
  $\Phi(\tau_V(v))$ for its assigned type.

- $E \subseteq V \times T_E \times V$ is a set of **directed typed edge
  instances**. Each edge $(u, p, v)$ pairs a subject entity, a predicate type,
  and an object entity, and carries a record conforming to $\Phi(p)$.

- $\tau_V : V \to T_V$ assigns a type to each entity instance.

- $\tau_E : E \to T_E$ is the edge type projection (the predicate label of
  each edge; this is already encoded in the edge tuple but named explicitly
  for use in validity constraints).

**Validity constraints.** A typed graph $(T_V, T_E, \Phi, V, E, \tau_V, \tau_E)$
is *valid* if and only if, for every edge $(u, p, v) \in E$:

1. $\tau_V(u) \in \text{dom}(p)$ \ \ (subject type conforms to predicate domain)
2. $\tau_V(v) \in \text{rng}(p)$ \ \ (object type conforms to predicate range)
3. the fields of $u$, $(u,p,v)$, and $v$ each conform to the corresponding
   $\Phi$ specification

**Subtype hierarchies.** $T_V$ may be equipped with a partial order $\leq$
(a DAG) representing subtype relationships. The validity constraint is then
generalized: $\tau_V(u) \leq t$ for some $t \in \text{dom}(p)$. The leaf
types in the DAG are the types assigned to individual entities; supertypes
appear only in predicate domain/range declarations. This means adding a new
leaf subtype automatically inherits all predicate permissions of its
supertypes, without any change to the predicate definitions.

### Trait Vocabulary

Each predicate type carries a set of **traits** that declare additional
semantic properties, enabling inference beyond simple edge traversal.

$$\text{Trait} ::= \text{Symmetric} \mid \text{Transitive} \mid \text{Functional} \mid \text{InverseFunctional} \mid \text{Inverse}(p') \mid \text{Rule}(\phi \Rightarrow \psi)$$

The named traits are shorthand for universally quantified logical formulas:

| Trait | Implicit rule |
|---|---|
| $\text{Symmetric}$ | $(x, p, y) \Rightarrow (y, p, x)$ |
| $\text{Transitive}$ | $(x, p, y) \wedge (y, p, z) \Rightarrow (x, p, z)$ |
| $\text{Functional}$ | $(x, p, y) \wedge (x, p, z) \Rightarrow y = z$ |
| $\text{InverseFunctional}$ | $(x, p, z) \wedge (y, p, z) \Rightarrow x = y$ |
| $\text{Inverse}(p')$ | $(x, p, y) \Rightarrow (y, p', x)$ |

Examples from the Holmes schema:
- `located_in` carries $\text{Tr}(p) = \{\text{Transitive}\}$
- `married_to` carries $\text{Tr}(p) = \{\text{Symmetric}\}$
- `has_true_identity` carries $\text{Tr}(p) = \{\text{Functional}\}$
- `contains` carries $\text{Tr}(p) = \{\text{Inverse}(\texttt{contained\_by})\}$

The final trait, $\text{Rule}(\phi \Rightarrow \psi)$, is the open-ended case:
an arbitrary Horn clause attached to a predicate type for situations that do
not reduce to any named pattern. For example, a `is_disguised_as` predicate
might carry:

$$\text{Rule}\bigl((x,\ \texttt{is\_disguised\_as},\ y) \wedge (y,\ \texttt{known\_to},\ z) \Rightarrow (x,\ \texttt{unknown\_to},\ z)\bigr)$$

The named traits are cheap to represent (an enum value) and exploitable
algorithmically during BFS. `Rule` requires a rule engine or Datalog-style
evaluator to fire, and its presence signals a heavier runtime commitment.
Tracking whether any schema actually uses `Rule` is worth doing.

### A Worked Example

*[Placeholder: This section will present a small Holmes graph -- five entity
instances and three edge instances -- verified component by component against
the seven-tuple definition. One valid triple will be shown as an instance of
each of $V$, $E$, $\tau_V$, and $\tau_E$. One invalid triple and the
specific validity constraint it fails will be shown. The Holmes schema used
here will be the same schema defined in full in Chapter 3.]*

### What the Formal Definition Does Not Guarantee

Structural well-formedness is not factual correctness. A well-typed, well-
provenance-tracked edge can still carry a false claim. Watson misremembers
an event. Holmes misidentifies a suspect. An extraction pipeline misreads a
passage. All of these produce triples that pass every validity constraint and
enter the graph as valid claims.

The schema is a filter, not a judge. What it guarantees is that the triples
reaching the stage of factual evaluation are the right *kind* of claim about
the right *kind* of entities: that subjects and objects are the correct
types, that predicates are drawn from an agreed vocabulary, and that the
question being asked is at least well-formed. Category errors never reach
the factual evaluation stage. Everything else does -- and whether it is
true is a question for domain experts, for replication across sources, and
for the confidence scores that aggregate evidence quality.

---

# Part II: The Schema

*The schema is the bridge between the mathematical definition and running
code. Chapter 3 presents it in a language-agnostic notation; Chapter 4
shows one concrete realization in Python. The same Holmes schema appears
in both chapters so the relationship is explicit.*

## Chapter 3: The Schema Definition Language

`\chaptermark{The Schema Definition Language}`{=latex}

### Why Language-Agnostic

The typed graph concept is independent of Python, Rust, or TypeScript. A
team building a Holmes graph in Rust and a team building a medical graph in
Python should be able to read each other's schemas without a translation
layer. The schema document is the source of truth; language-specific bindings
are derived from it.

This pattern has precedent. Protocol Buffers, Apache Thrift, and GraphQL SDL
all follow the same principle: write the schema once in a neutral notation,
generate or implement bindings for each target language. The difference here
is that the schema is a graph vocabulary -- a declaration of what kinds of
things exist and what kinds of relationships can hold between them -- rather
than a message format or a query interface. But the benefits of language
neutrality are the same: schema changes propagate to all bindings; bindings
can be tested against the canonical schema; teams can review schema design
without knowing each other's implementation language.

The notation used in this book is YAML. It is widely readable, supports
nested structure cleanly, and does not require a schema-definition language
of its own. The Holmes schema below can be read and understood by any
software engineer in any language.

### The Holmes Schema

*[Placeholder: The Holmes schema is being built inductively by annotating
stories rather than pre-designed. The schema below is a working draft,
sufficient to illustrate the structure; it will be extended as the corpus
annotation work in the companion repository progresses. The authoritative
version is maintained at* `graphwright.io/schemas/holmes`*.]*

```yaml
schema:
  name: holmes
  version: "0.3.0-draft"
  description: >
    Schema for the Sherlock Holmes canonical corpus (Conan Doyle, 60 stories).
    Built inductively from story annotation; provisional types are flagged.
  authoritative_ontology:
    name: Baker Street Wiki
    base_url: "https://bakerstreet.fandom.com/wiki/"
    id_pattern: "https://bakerstreet.fandom.com/wiki/{Article_Title}"

node_types:
  Person:
    description: A human character in the stories.
    canonical_id_source: baker_street_wiki
    fields:
      - name: canonical_id
        type: uri
        required: true
      - name: display_name
        type: string
        required: true
  Location:
    description: A physical place referenced in the stories.
    canonical_id_source: baker_street_wiki
    fields:
      - name: canonical_id
        type: uri
        required: true
      - name: display_name
        type: string
        required: true
  Object:
    description: A significant physical object.
    canonical_id_source: baker_street_wiki
    fields:
      - name: canonical_id
        type: uri
        required: true
  Event:
    description: A discrete occurrence within a story.
    fields:
      - name: story_id
        type: string
        required: true
      - name: description
        type: string
        required: true
  Moment:
    description: >
      A named point in the epistemic timeline of the narrative: the point
      at which a particular assertion became knowable to a particular narrator.
      Provisional: may be refactored or absorbed as the schema matures.
    provisional: true
    fields:
      - name: story_id
        type: string
        required: true
      - name: label
        type: string
        required: true

edge_types:
  associated_with:
    description: Person is habitually connected to a location.
    subject_types: [Person]
    object_types: [Location]
    provenance_required: true

  disguised_as:
    description: Person adopted the appearance or identity of another.
    subject_types: [Person]
    object_types: [Person]
    provenance_required: true

  knows:
    description: Person has an acquaintance or professional relationship with another.
    subject_types: [Person]
    object_types: [Person]
    traits: [Symmetric]
    provenance_required: true

  located_in:
    description: A location is situated within another location.
    subject_types: [Location]
    object_types: [Location]
    traits: [Transitive]
    provenance_required: false

  occurred_at:
    description: Event is anchored to a narrative moment in time.
    subject_types: [Event]
    object_types: [Moment]
    provenance_required: true

  known_to_watson_at:
    description: >
      Event became part of Watson's knowledge at this narrative moment.
      Distinct from occurred_at: an event may have happened earlier than
      Watson learned of it.
    subject_types: [Event]
    object_types: [Moment]
    provenance_required: true

  involves:
    description: Event involves a person as a participant.
    subject_types: [Event]
    object_types: [Person]
    provenance_required: true

  has_true_identity:
    description: >
      Person's presented identity conceals their actual identity.
      Functional: a person has at most one true identity.
    subject_types: [Person]
    object_types: [Person]
    traits: [Functional]
    provenance_required: true

trait_groups:
  epistemic:
    description: Fields tracking what is known and by whom.
    applies_to: [edges]
    fields:
      - name: narrator_confidence
        type: float
        range: [0.0, 1.0]
        description: Holmes's/Watson's expressed certainty at time of narration.
  provenance:
    description: Source tracing fields required on all evidential edges.
    applies_to: [edges]
    fields:
      - name: story_id
        type: string
        required: true
      - name: paragraph_index
        type: integer
        required: true
      - name: extraction_method
        type: string
        required: true
      - name: extraction_confidence
        type: float
        range: [0.0, 1.0]
        required: true
```

### Walking Through the Schema

Each section of the schema document corresponds directly to components of the
seven-tuple from Chapter 2. `node_types` is $T_V$. `edge_types` is $T_E$,
with each entry also specifying $\text{dom}(p)$, $\text{rng}(p)$, and
$\text{Tr}(p)$. `trait_groups` specifies field schema requirements that
become part of $\Phi$.

The `occurred_at` and `known_to_watson_at` predicates are worth pausing on.
A single event in Holmes's world has two temporal anchors: when it happened,
and when Watson came to know it. In "The Adventure of the Empty House,"
Holmes reveals he survived Reichenbach Falls and has been in hiding for
three years. The event (Holmes's survival) happened during "The Final
Problem." Watson's knowledge of it dates to "The Empty House." A schema
that tracks only one of these cannot represent the epistemic structure of
the corpus honestly. Both predicates reference the provisional `Moment`
type, which is the entity that names the specific narrative point of
anchoring.

### What the Schema Enforces vs. What It Leaves Open

The schema enforces structural well-formedness: which entity types exist,
which predicates exist, what type combinations are valid, and what fields
are required. It does not enforce factual correctness. A claim can pass
every schema constraint and still be wrong.

The closed-world payoff is that absence is informative. If `disguised_as`
does not appear between two Person entities, that means something -- either
no disguise relationship holds, or the corpus has not asserted one. This
ambiguity is explicit rather than silent. A query can distinguish "no
relationship found" from "relationship not expressible in this schema."

Provisional types carry full constraints while flagged. The `provisional`
flag is a signal to schema designers -- "we are not yet certain this
abstraction is right" -- not a relaxation of enforcement. The flag records
uncertainty about the schema's own design, which is honest and useful, and
which the formal definition in Chapter 2 carries cleanly.

---

## Chapter 4: A Python Binding

`\chaptermark{A Python Binding}`{=latex}

### The Schema Document as Source of Truth

The YAML schema of Chapter 3 is the source of truth. A Python binding is
one materialization of it: a set of Python classes and enumerations that
enforce the same constraints in code, with the benefit of IDE type checking,
mypy narrowing, and `isinstance` guards at runtime. Other language bindings
are possible and structurally identical; the YAML schema is what makes them
interoperable.

### `NodeType` and `EdgeType` as `StrEnum`

Entity types and predicate types are represented as Python enumerations
subclassing `StrEnum`. The base classes are empty; domain schemas subclass
these to add their vocabulary.

```python
from enum import StrEnum

class NodeType(StrEnum):
    """Base class for all entity type enumerations."""

class EdgeType(StrEnum):
    """Base class for all predicate type enumerations."""

class HolmesNodeType(NodeType):
    PERSON = "Person"
    LOCATION = "Location"
    OBJECT = "Object"
    EVENT = "Event"
    MOMENT = "Moment"  # provisional

class HolmesEdgeType(EdgeType):
    ASSOCIATED_WITH = "associated_with"
    DISGUISED_AS = "disguised_as"
    KNOWS = "knows"
    LOCATED_IN = "located_in"
    OCCURRED_AT = "occurred_at"
    KNOWN_TO_WATSON_AT = "known_to_watson_at"
    INVOLVES = "involves"
    HAS_TRUE_IDENTITY = "has_true_identity"
```

Using empty base enums is not arbitrary. `isinstance(t, NodeType)` works as
a runtime guard on any entity type from any domain schema. mypy narrows
`HolmesNodeType` correctly as a subtype of `NodeType`. `GraphSchema` can
store the enum class itself -- `type[NodeType]` -- rather than a frozenset
of strings, enabling class-level dispatch. The empty base is load-bearing.

### `BaseEntity` and `BaseRelationship`

```python
from abc import abstractmethod
from pydantic import BaseModel

class BaseEntity(BaseModel, frozen=True):
    entity_id: str
    display_name: str

    @abstractmethod
    def get_entity_type(self) -> NodeType: ...

class BaseRelationship(BaseModel, frozen=True):
    subject_id: str
    object_id: str
    story_id: str
    paragraph_index: int
    extraction_method: str
    extraction_confidence: float

    @abstractmethod
    def get_edge_type(self) -> EdgeType: ...
```

Models are `frozen=True`. This is not a style preference. Edge instances
are facts -- structured claims about the world sourced to a specific passage.
Facts should not be mutable records. A `BaseRelationship` that can be
mutated after construction can have its provenance fields changed after
ingestion, which would silently corrupt the audit trail. Frozen models make
this structurally impossible.

### `PredicateConstraint` and `GraphSchema`

```python
from pydantic import BaseModel, Field
from typing import FrozenSet, Optional

class Trait(StrEnum):
    SYMMETRIC = "Symmetric"
    TRANSITIVE = "Transitive"
    FUNCTIONAL = "Functional"
    INVERSE_FUNCTIONAL = "InverseFunctional"

class PredicateConstraint(BaseModel, frozen=True):
    name: str = Field(description="Predicate identifier")
    domain: FrozenSet[NodeType] = Field(description="Allowed subject types")
    range: FrozenSet[NodeType] = Field(description="Allowed object types")
    description: str = Field(description="Human-readable definition")
    traits: FrozenSet[Trait] = Field(default_factory=frozenset)
    is_functional: bool = Field(default=False)
    inverse_of: Optional[str] = Field(default=None)
    provisional: bool = Field(default=False)

class GraphSchema(BaseModel, frozen=True):
    node_type_cls: type[NodeType]
    edge_type_cls: type[EdgeType]
    predicates: FrozenSet[PredicateConstraint]
    provisional_types: FrozenSet[NodeType] = Field(default_factory=frozenset)

    def validate_triple(
        self,
        subject_type: NodeType,
        predicate: str,
        object_type: NodeType,
    ) -> None:
        constraint = next(
            (p for p in self.predicates if p.name == predicate), None
        )
        if constraint is None:
            raise ValueError(f"Unknown predicate: {predicate!r}")
        if subject_type not in constraint.domain:
            raise TypeError(
                f"Subject type {subject_type!r} not in domain of {predicate!r}"
            )
        if object_type not in constraint.range:
            raise TypeError(
                f"Object type {object_type!r} not in range of {predicate!r}"
            )
```

### The Holmes Schema in Python

```python
PROVISIONAL_NODE_TYPES = frozenset({HolmesNodeType.MOMENT})

HOLMES_PREDICATES = frozenset({
    PredicateConstraint(
        name="associated_with",
        domain=frozenset({HolmesNodeType.PERSON}),
        range=frozenset({HolmesNodeType.LOCATION}),
        description="Person is habitually connected to location.",
    ),
    PredicateConstraint(
        name="disguised_as",
        domain=frozenset({HolmesNodeType.PERSON}),
        range=frozenset({HolmesNodeType.PERSON}),
        description="Person adopted the appearance or identity of another.",
    ),
    PredicateConstraint(
        name="knows",
        domain=frozenset({HolmesNodeType.PERSON}),
        range=frozenset({HolmesNodeType.PERSON}),
        description="Person has an acquaintance or professional relationship.",
        traits=frozenset({Trait.SYMMETRIC}),
    ),
    PredicateConstraint(
        name="located_in",
        domain=frozenset({HolmesNodeType.LOCATION}),
        range=frozenset({HolmesNodeType.LOCATION}),
        description="A location situated within another location.",
        traits=frozenset({Trait.TRANSITIVE}),
    ),
    PredicateConstraint(
        name="occurred_at",
        domain=frozenset({HolmesNodeType.EVENT}),
        range=frozenset({HolmesNodeType.MOMENT}),
        description="Event is anchored to a narrative moment.",
    ),
    PredicateConstraint(
        name="known_to_watson_at",
        domain=frozenset({HolmesNodeType.EVENT}),
        range=frozenset({HolmesNodeType.MOMENT}),
        description=(
            "Event became part of Watson's knowledge at this narrative moment. "
            "Distinct from occurred_at."
        ),
    ),
    PredicateConstraint(
        name="involves",
        domain=frozenset({HolmesNodeType.EVENT}),
        range=frozenset({HolmesNodeType.PERSON}),
        description="Event involves a person as a participant.",
    ),
    PredicateConstraint(
        name="has_true_identity",
        domain=frozenset({HolmesNodeType.PERSON}),
        range=frozenset({HolmesNodeType.PERSON}),
        description="Person's presented identity conceals their actual identity.",
        traits=frozenset({Trait.FUNCTIONAL}),
        is_functional=True,
    ),
})

HOLMES_SCHEMA = GraphSchema(
    node_type_cls=HolmesNodeType,
    edge_type_cls=HolmesEdgeType,
    predicates=HOLMES_PREDICATES,
    provisional_types=PROVISIONAL_NODE_TYPES,
)
```

The relationship between this Python code and the YAML schema in Chapter 3
is one of derived equivalence. The names, domain/range declarations, and
traits match exactly. A reader who wants to verify that the Python binding
correctly materializes the YAML schema can check each field against the
corresponding YAML entry. The YAML is the spec; the Python is the
implementation; the correspondence is explicit and verifiable.

*[Placeholder: Domain-specific edge subclasses adding typed provenance
fields -- story_id, paragraph_index, extraction_method,
extraction_confidence on each relationship subclass -- and a demonstration
of running valid and invalid triples against `HOLMES_SCHEMA.validate_triple`
will appear in the companion repository before publication.]*

---

# Part III: Domains in Practice

*Two worked domains that differ structurally: Holmes, a narrative/epistemic
domain with deliberate uncertainty; medical literature, a high-stakes domain
with established external ontologies and evidence grading. The contrast
demonstrates what the schema language handles uniformly and what varies
by domain.*

## Chapter 5: Medical Literature -- A Second Domain

`\chaptermark{Medical Literature}`{=latex}

### Why Medicine as the Second Domain

Medicine is the right second domain for reasons that Holmes alone cannot
demonstrate. Where the Holmes corpus is a closed literary universe with a
fan-maintained wiki as its authority, medical literature has established
authoritative ontologies built by large professional communities over
decades. Where Holmes's epistemic complexity comes from narrative structure
and deliberate misdirection, medicine's complexity comes from genuine
scientific uncertainty, hierarchical disease classification, and evidence
grading that must be first-class in the schema.

The two domains test the schema language's generality. If the same
`GraphSchema` machinery -- the same `NodeType`, `EdgeType`, `PredicateConstraint`,
and `GraphSchema` classes -- can handle both without modification, the
machinery earns its abstraction. If it cannot, the abstraction is
undersized. This chapter makes that case.

### Authoritative Ontologies in Medicine

Medicine has several authoritative ontologies, each covering a different
aspect of the domain.

**MeSH** (Medical Subject Headings)\index{MeSH} is maintained by the National Library
of Medicine and has been the standard vocabulary for biomedical literature
indexing since 1963. It covers diseases, drugs, biological processes, and
anatomical structures, and its hierarchical structure encodes relationships
among concepts that would otherwise have to be extracted from text. A disease
entity anchored to MeSH:D003480 (Cushing Syndrome\index{Cushing syndrome}) inherits
the MeSH tree's knowledge that it is a subtype of Adrenal Cortex Diseases,
which is a subtype of Endocrine System Diseases. It inherits MeSH-recorded
synonyms: "Hypercortisolism," "Adrenal Cortex Hyperfunction." It inherits
cross-references to ICD-10-CM\index{ICD-10-CM} codes. None of this must be extracted
from the corpus -- anchoring makes it available.

**HGNC** (HUGO Gene Nomenclature Committee)\index{HGNC} maintains official symbols and
names for human genes. When a paper from 1987 uses a gene name that was
superseded in 1995, HGNC records both names and the relationship between
them. The resolution system can resolve the old name to the current symbol
without any domain-specific logic.

**RxNorm**\index{RxNorm}, maintained by the National Library of Medicine, provides
normalized names for clinical drugs. A node anchored to RxNorm:3251 inherits
the accumulated judgment of the biomedical community about what desmopressin
is, what it does, and how it relates to everything else they have named.

**UniProt**\index{UniProt} maintains the authoritative database for protein sequences
and functional information. **NCBI Taxonomy**\index{NCBI Taxonomy} is the taxonomic
hierarchy backing GenBank\index{GenBank}, RefSeq\index{RefSeq}, and related resources -- the
shared hierarchy most biomedical pipelines assume when classifying organisms.

These authorities share a key property: they were built to solve the same
problem a typed graph must solve, at the level of a single domain, by a
community of experts who needed shared identity to communicate. A graph
that anchors to them is not just assigning unique keys -- it is connecting
entities to the epistemic commons that expert communities have assembled
over decades.

### The Medlit Schema

```yaml
schema:
  name: medlit
  version: "1.2.0"
  description: >
    Schema for biomedical literature. Entity types anchored to
    MeSH, HGNC, RxNorm, and UniProt.

node_types:
  Disease:
    canonical_id_source: mesh
    fields:
      - name: mesh_id
        type: string
        required: true
  Drug:
    canonical_id_source: rxnorm
    fields:
      - name: rxnorm_id
        type: string
        required: true
  Gene:
    canonical_id_source: hgnc
    fields:
      - name: hgnc_id
        type: string
        required: true
  Protein:
    canonical_id_source: uniprot
    fields:
      - name: uniprot_id
        type: string
        required: true
  BiologicalProcess:
    canonical_id_source: mesh

edge_types:
  treats:
    description: Drug is used therapeutically to manage the disease.
    subject_types: [Drug]
    object_types: [Disease]
    provenance_required: true
    evidence_required: true

  inhibits:
    description: Subject suppresses the activity of the object.
    subject_types: [Drug, Gene]
    object_types: [Gene, BiologicalProcess]
    provenance_required: true
    inverse_of: activates

  activates:
    description: Subject enhances the activity of the object.
    subject_types: [Drug, Gene]
    object_types: [Gene, BiologicalProcess]
    provenance_required: true
    inverse_of: inhibits

  associated_with:
    description: Gene variant is statistically associated with disease.
    subject_types: [Gene]
    object_types: [Disease]
    provenance_required: true
    evidence_required: true

  encodes:
    description: Gene encodes the given protein.
    subject_types: [Gene]
    object_types: [Protein]
    traits: [Functional]

trait_groups:
  evidence:
    description: Evidence grading fields for medical claims.
    applies_to: [edges]
    fields:
      - name: evidence_level
        type: enum
        values: [meta_analysis, rct, cohort, case_control,
                 observational, review, case_report]
        required: true
      - name: assertion_type
        type: enum
        values: [positive, negative, uncertain]
        required: true
  provenance:
    description: Source tracing for all evidential edges.
    applies_to: [edges]
    fields:
      - name: paper_id
        type: string
        required: true
      - name: section_type
        type: string
        required: true
      - name: paragraph_index
        type: integer
        required: true
      - name: extraction_method
        type: string
        required: true
      - name: extraction_confidence
        type: float
        required: true
```

### Evidence as First-Class Structure

Medical claims are not all equally strong. A randomized controlled trial is
stronger evidence for a drug-disease relationship than a single case report.
A result section is stronger than a discussion section. These distinctions
are not metadata that might optionally be attached to an edge -- they are
part of what a medical claim *is*. A claim without evidence grading is not
a weaker medical claim; it is not a medical claim at all.

The schema reflects this by requiring `evidence_level` and `assertion_type`
on edges that carry the `evidence` trait group. An edge of predicate `treats`
without these fields fails the provenance completeness check at insertion
time. There is no way to insert a medical claim and defer its evidence
grading to a cleanup pass.

This is the same principle as provenance in the Holmes schema, but more
explicit about what "complete provenance" means per predicate. The Holmes
schema requires story_id and paragraph_index. The medlit schema requires
those plus evidence_level and assertion_type. What counts as a complete
provenance record is per-predicate knowledge that the schema encodes and
the insertion gate enforces.

### Comparing Holmes and Medlit

The comparison makes the schema language's generality concrete. Entity
types differ: `Person`, `Location`, `Moment` in Holmes; `Disease`, `Drug`,
`Gene`, `Protein` in medlit. Predicate vocabularies differ: `disguised_as`,
`knows`, `has_true_identity` in Holmes; `treats`, `inhibits`, `activates`
in medlit. Evidence requirements differ: narrative passage locators in
Holmes; evidence_level and assertion_type in medlit.

What is identical: `NodeType`, `EdgeType`, `PredicateConstraint`,
`GraphSchema`, `BaseEntity`, `BaseRelationship`, `frozen=True`, the seven-
tuple from Chapter 2, the trait vocabulary, the insertion validation logic,
and the linter rule derivation from Chapter 9. Neither domain required
modification to the base machinery. The machinery handles both without
knowing which domain it is serving.

That is not a coincidence. It is the consequence of having defined the
schema language against the formal definition in Chapter 2, which captures
the structure common to all typed graphs before any domain-specific detail
enters.

---

# Part IV: Canonical Identity

*This part covers the infrastructure that makes the graph's entities
unambiguous: the process of resolving mention strings to canonical IDs,
the service that enforces uniqueness across parallel workers, the domain
service that encodes domain-specific authority lookup and confidence
weighting, and the validation layer that enforces the schema at write time
and audits it after the fact. The architecture here is documented in
sufficient detail to implement; several sections are still being refined.*

## Chapter 6: Strings vs. Things

`\chaptermark{Strings vs. Things}`{=latex}

### Two Mentions, One Entity

Two passages in two different Holmes stories both mention "Holmes." In one,
Watson records that Holmes spent three days in disguise as an elderly Italian
priest. In another, a client addresses him directly as "Mr. Holmes." These
are the same person. A human reader does not deliberate about this.

A graph built from extracted mentions without identity resolution does
deliberate -- or rather, it does not deliberate at all, and that is the
problem. It creates a node for the string "Holmes," a node for "Mr. Holmes,"
possibly a node for "the detective," and stores relationships incident to
each. The three nodes are not connected. A query for everything the graph
knows about Sherlock Holmes returns a fraction of what was extracted, split
across nodes that the graph has no mechanism to join.

This is the strings-vs.-things\index{strings vs.\ things} problem. A string is a sequence of
characters. A thing is a real-world entity that strings can refer to, and
that multiple strings can refer to simultaneously. A knowledge graph that
operates at the level of strings is storing references to things without
storing the things themselves. Canonical identity\index{canonical identity} is the mechanism
that makes the transition.

### What an Authoritative Ontology Provides

An authoritative ontology\index{authoritative ontology} provides four things: a stable identifier
that does not change when the entity's preferred name changes; a canonical
name and known synonyms that the identity resolution system consults; a
position in a relational structure that the graph inherits on anchoring; and
community trust -- a human organization accountable for the data's quality
over time.

A canonical ID drawn from such an authority is not just a unique key. It is
a claim that this entity has been placed in the epistemic commons\index{epistemic commons} of its
domain -- named by people who know the domain, cross-referenced against
adjacent knowledge, and assigned a position in the community's shared
understanding. That placement is inherited by any graph that anchors to the
same identifier.

### URIs as Stable Referents

The cleanest implementation of this idea is the one the web already provides.
A URI is globally unique, syntactically unambiguous, and -- for the right
sources -- stable. Two systems that use the same URI for the same entity
agree on the referent without coordination.

Wikidata\index{Wikidata} exploits this directly. Every entity has a stable URI of the
form `https://www.wikidata.org/entity/Q{n}`. These URIs are dereferenceable,
stable, and broadly scoped. They cross-reference to identifiers in other
authoritative systems, making Wikidata a practical hub for navigating between
identifier spaces. Wikipedia article URLs serve a similar function: a system
that uses the Wikipedia URL for an entity as its canonical ID agrees on the
referent with any other system that does the same, without negotiation.

### Domains Without Official Authoritative Ontologies

Medicine, chemistry, and biology have mature authoritative ontologies built
over decades by large professional communities. Most domains do not. A graph
built over legal case law, historical correspondence, or literary fiction has
no MeSH to consult. The entities in those domains have not been enumerated by
any standards body.

This is not a reason to abandon canonical identity. It is a reason to be
clear about what "authoritative" means in each domain. In domains without
official ontologies, authority is assembled from whatever stable,
community-maintained resources exist. The assessment criteria are the same:
Does it cover the entities this graph needs? Are its identifiers stable? Is
there a community behind it with an interest in maintaining it?

### The Baker Street Wiki as Domain AO

The Baker Street Wiki\index{Baker Street Wiki} -- hosted at `bakerstreet.fandom.com` -- is the
most comprehensive publicly available reference for the Sherlock Holmes
canonical stories. Assessing it as an authoritative ontology requires three
criteria: coverage, stability, and identifier structure.

**Coverage** is strong for the canonical stories. Every named character of
any significance in the sixty stories has an article. Major locations --
Baker Street itself, Baskerville Hall, the Reichenbach Falls -- are
documented in detail. Significant objects have entries. Coverage thins for
truly minor figures: an unnamed constable who appears in a single scene, a
landlady mentioned once. These become provisional entities regardless of
which AO is chosen.

**Stability** is adequate. Fandom wikis do not guarantee identifier
permanence in the way Wikidata does, and the history of fan wikis includes
migrations and reorganizations. The Baker Street Wiki has been stable at
its current domain long enough to constitute a reasonable bet, and its
article titles -- which drive URL structure -- are unlikely to change for
entities as well-documented as Holmes, Watson, and Irene Adler. The risk
is manageable: the domain service can maintain a mapping from Baker Street
Wiki URLs to local identifiers, so that if a URL changes, the update is
made once and propagates automatically.

**Identifier structure** is clean. A Baker Street Wiki URL takes the form
`https://bakerstreet.fandom.com/wiki/{Article_Title}`, where the article
title is the canonical name with spaces encoded as underscores. The URL for
Sherlock Holmes is `https://bakerstreet.fandom.com/wiki/Sherlock_Holmes`.
No opaque database keys, no session parameters, no content-delivery
indirection. The identifier is the name, structured for machine consumption.

The practical consequence is that each Holmes entity in the graph is
assigned the URL of its Baker Street Wiki article as its canonical ID. The
domain service's authority lookup constructs a candidate URL from the mention
string and checks whether the article exists. The wiki's redirect structure
provides synonym resolution: a query for "Holmes" redirects to
"Sherlock\_Holmes," and the domain service follows the redirect.

### Provisional Entities

When the full lookup chain exhausts without a match, the identity server
does not block. It mints a provisional entity\index{provisional entity}: a new graph node with
a locally generated canonical ID, typed as specified by the extraction
pipeline, and flagged as provisional. Provisional entities are full graph
citizens -- full type constraints apply, edges can reference them, evidence
accumulates. Promotion to canonical status occurs when evidence reaches a
threshold or a later AO lookup succeeds. All edges referencing the old ID
are updated; the graph does not require re-ingestion.

The existence of provisional entities means the graph can be built
incrementally, with honest uncertainty, without stalling on entities that
cannot yet be resolved. The Holmes corpus has a finite entity population,
and most of it is well-covered by the Baker Street Wiki. The provisional
tail is small. But the architecture that handles it cleanly for Holmes
handles it equally well for a domain where the AO covers thirty percent of
the entities rather than ninety.

---

## Chapter 7: The Identity Server

`\chaptermark{The Identity Server}`{=latex}

### Extraction Produces Mentions, Not Entities

The extraction pipeline reads unstructured text and produces structured
output: subject, predicate, object, with the subject and object expressed
as mention strings. "Holmes" appears as a subject string. "Baker Street"
appears as an object string. These strings are not entities. They are
references to entities -- references that may be ambiguous, inconsistent
across passages, and duplicated across dozens of story chapters.

The graph needs nodes with canonical IDs. A node labeled "Holmes" and a
node labeled "Mr. Holmes" are, to the graph, two different things unless
something resolves them to the same identity. The extraction pipeline cannot
do this resolution: it processes one passage at a time and has no memory
of what it has already seen. The identity server\index{identity service} is the bridge.

### Why a Service, Not a Library

The obvious alternative to a service is a library. A library would work
correctly for a single-process pipeline running sequentially. It fails under
the conditions where knowledge graph construction actually operates.

Real ingestion pipelines run many workers in parallel. Worker A is processing
chapter three of *The Hound of the Baskervilles*\index{Hound of the Baskervilles, The};
worker B is processing chapter seven; both extract a mention of "Stapleton."
Without a shared service, both may mint a new provisional entity for
"Stapleton." The graph now has two provisional nodes for the same character,
and the deduplication problem the identity system was supposed to solve has
been re-created by the identity system itself.

A service with a database and advisory locking\index{advisory locking} solves this. When two
workers race to create "Stapleton," exactly one wins; the other receives the
same ID. Cross-process uniqueness is enforced by the service.

### Entity Lifecycle

Every entity has one of three statuses, and transitions are one-way.

**Provisional**\index{provisional entity}: Created from a mention that did not match any known
authority. Participates fully in the graph -- relationships reference it,
evidence accumulates -- but flagged as unanchored.

**Canonical**\index{canonical entity}: Anchored to an external authority. Promotion from
provisional to canonical happens when the lookup chain finds an authority
match, either at creation time or later as more surface forms accumulate.

**Merged**\index{merged entity}: Absorbed into another entity. Merged entities retain their
full history but are no longer active graph nodes. All relationships
referencing a merged entity transparently resolve to the survivor. Merged
status is terminal.

Status transitions are immutable by design. The provenance audit trail is
permanently trustworthy because every merge event is logged and its
consequences are stable.

### The Lookup Chain

The lookup chain\index{lookup chain} applies resolution strategies in order, stopping when a
match is found, ordered by cost.

**Exact match**: The mention string is looked up verbatim in the synonym
table. A single indexed database lookup. Handles all mentions that have been
seen before in exactly this form -- the majority of cases in a large corpus
being processed incrementally.

**Fuzzy match**: The mention string is compared against all known surface
forms using a string-similarity metric -- `rapidfuzz`\index{rapidfuzz} in the Graphwright
implementation, fast enough to scan a synonym table of tens of thousands of
entries in milliseconds. Handles abbreviations, misspellings, and minor
variations. "Sherlock Homes" resolves to Sherlock Holmes. A configurable
threshold prevents false positives.

**Embedding similarity**: The mention is embedded and compared against
stored surface form embeddings via `pgvector`\index{pgvector} approximate nearest neighbor
search. Catches semantic equivalence that string methods miss. Most
expensive; reserved for cases the cheaper methods cannot handle.

**Authority lookup**: The domain service's `/resolve-authority` endpoint
is called with the mention string and entity type. The domain service queries
the Baker Street Wiki or whatever authority is configured for this domain.
If successful, the canonical ID is added to the local synonym table for
exact-match resolution on all future encounters.

If all four stages fail, a provisional entity is minted. The chain is ordered
by cost, not sophistication. Embedding similarity is last because it is
expensive, not because it is less accurate. Running it on every mention would
be correct but wasteful.

### Advisory Locking in Postgres

Before creating a new entity, the base server acquires a Postgres\index{Postgres} advisory
lock keyed on the hash of `(mention, entity_type)`. The first worker acquires
the lock, checks for an existing entity, finds none, creates one, and releases
the lock. The second worker acquires the lock, checks for an existing entity,
finds the one the first worker just created, and returns its ID without
creating a duplicate.

Advisory locks are the right tool here rather than standard transactions
because the resolution operation spans multiple queries -- a lookup, possibly
an authority call, an insert, a cache update. Holding a transaction open
across all of that would serialize concurrency more than necessary. Advisory
locks scope the mutual exclusion to the logical operation and release as
soon as the entity ID is determined.

### Idempotency

The identity server is designed to be called many times with the same
arguments and produce the same result every time. Ingestion pipelines fail.
A worker crashes halfway through a chapter, the batch is retried, and the
identity server receives the same mentions it already processed. If the
server is not idempotent, the retry produces different entity IDs and the
graph is corrupted.

Idempotency is implemented at the database level, not in application logic.
Entity creation is an upsert on `(mention, entity_type)`. Merge is checked
against the merge log before executing. Every write operation follows the
same pattern. The service is safe to retry unconditionally.

### Caching

The base server keeps an LRU\index{LRU cache} cache keyed on `(mention, entity_type)` for
resolved IDs. A mention that has already been resolved returns its canonical
ID from memory without a database round-trip. The domain service keeps a
long-TTL cache for authority API responses, so that repeated lookups of the
same entity against the Baker Street Wiki do not generate redundant HTTP
requests across ingestion runs. The `compute-confidence` endpoint is
intentionally not cached: its inputs vary per call, the computation is
cheap, and caching would add consistency complexity for no measurable gain.

### The Identity Server HTTP Interface

`POST /resolve` is the primary operation. The caller supplies a mention
string and an entity type; the server returns a canonical ID. The operation
may mint a provisional entity -- that is a write, and it belongs on a POST.
The endpoint is idempotent: repeated calls with the same arguments return
the same ID.

`POST /promote` elevates a provisional entity to canonical status. The
caller supplies the provisional entity ID and the canonical ID to assign.
The caller supplies the canonical ID rather than the server computing it
because authority lookup is domain knowledge that lives in the domain
service. Responsibility stays where the knowledge lives. Promotion is logged.

`POST /merge` declares two entities to be the same. The server calls the
domain service's `/select-survivor` endpoint to determine which record
survives, redirects all relationships from the non-survivor to the survivor,
and marks the non-survivor as merged. Merge requires an explicit call rather
than happening automatically because merges are irreversible. A fuzzy match
that was close but wrong would corrupt the graph permanently if it triggered
an automatic merge.

`GET /entity/{id}` returns the full record for an entity: current status,
all known surface forms, the full provenance audit trail, composite
confidence, and -- if canonical -- the authority name and ID. For inspection
and debugging, not for the ingestion hot path.

`GET /schema` returns the domain spec as JSON. The server fetches this from
the domain service at startup and re-fetches it when the schema version
changes.

---

## Chapter 8: The Domain Service

`\chaptermark{The Domain Service}`{=latex}

### What the Domain Service Owns

The domain service is the boundary between the domain-agnostic identity
server and the actual knowledge of a specific domain. Everything that
varies from one deployment to the next lives here: the entity type
enumeration, the predicate list, the choice of which authoritative ontology
to consult, synonym thresholds, survivor selection logic, and confidence
weight tables.

Keeping domain knowledge out of the base server is not organizational
tidiness. It is what makes the system reusable. A base server containing no
domain assumptions can be deployed for a new domain by writing a new domain
service, not by modifying the core. Domain logic that leaks into the core
creates maintenance debt that compounds with every new deployment.

### Python as the Spec Language

The domain spec is a Python module named `domain_spec.py`\index{domain\_spec.py}, not a YAML or
JSON configuration file. The choice is deliberate. A configuration file can
express data. A Python module can express logic: it can define the entity
type enum, instantiate frozen Pydantic models for each predicate, declare
validation functions, and compute derived values -- all in the same file,
all testable with standard tooling, all readable by any Python developer.

The module round-trips to JSON for the `GET /schema` endpoint. The Python
module is the source of truth; the JSON is a derived representation for wire
transport. Changing the schema means editing `domain_spec.py`. There is one
place to look.

### The Plugin Contract

The domain service implements exactly four endpoints that the base server
calls:

`POST /resolve-authority` -- given a mention and entity type, query the
domain's authoritative ontology and return a canonical ID if found. For the
Holmes domain this queries the Baker Street Wiki.

`POST /select-survivor` -- given two entity records, return the one that
should survive a merge. For Holmes: prefer canonical over provisional; if
both are canonical, prefer the one with more evidence records; if equal,
prefer the older creation timestamp.

`POST /compute-confidence` -- given a list of evidence records, return a
composite confidence score. The domain service supplies the weights; the
base server handles the arithmetic.

`GET /synonym-criteria` -- return the thresholds the identity server should
use when deciding whether two mentions are synonyms. Supports per-entity-type
overrides: gene symbols in a biomedical corpus need high precision
(fuzzy threshold 0.95) to prevent "BRCA1" from matching "BRCA2."

Four endpoints, not more. These are the four decisions that vary by domain.
A small contract surface means the contract is auditable in five minutes and
the domain service is easy to test in isolation.

### When the Ontology Changes

The domain spec carries a version field. The identity server records which
schema version was active when each edge was ingested.

**Deprecated predicates** are flagged, not deleted. Edges using a deprecated
predicate are marked with a `deprecated_predicate` flag and routed to a
review queue. Actual removal is a deliberate, logged operation.

**Tightened constraints** produce migration items, not errors. An edge valid
under schema version 2.1 but violating version 2.3 is a migration item --
"this edge became malformed because the schema tightened" -- distinct from
an extraction error. The linter distinguishes between the two.

**Predicate renaming** follows the deprecate-old, introduce-new pattern, with
a migration script that moves existing edges and records the transformation
in the provenance record. The transformation is auditable after the fact.

---

## Chapter 9: Validation and the Graph Linter

`\chaptermark{Validation and the Graph Linter}`{=latex}

### Two Enforcement Points

The insertion path enforces constraints at write time: every triple that
enters the graph has passed a sequence of gates. The graph linter is a
separate tool that audits the graph after the fact.

The two enforcement points are complementary, not redundant. Insertion-time
checks protect against new violations. The linter catches cross-edge
consistency issues invisible at single-write time: a contradiction between
two edges inserted in separate pipeline runs, a provenance gap in data
that predates a stricter provenance requirement, an edge valid under an
older schema version now violating the current one. The linter also serves
as a CI gate on ingestion batches: run it before a batch lands and reject
the batch if violations exceed a threshold. This is the compiler-pass model
applied to graph data.

### How a Proposed Triple Is Accepted or Rejected

Every proposed triple passes through four gates, each asking a different
question.

**Entity type check**: does the subject ID correspond to a known entity, and
does that entity's type match the predicate's domain?

**Predicate vocabulary check**: is this predicate defined in the domain spec?
A predicate that does not appear in the spec does not exist. The triple is
not stored with a flag; it is rejected.

**Domain/range check**: do the subject and object entity types fall within
the predicate's declared domain and range? This is the gate that catches
category errors. The schema knows the domain and range; it does not need
to inspect the content of the entities.

**Provenance completeness check**: does the proposed triple carry a
provenance record, and does that record contain the required fields per
the domain spec? Required fields are per-predicate. An edge without a
required provenance field is not a weak claim -- it is a malformed record.

### What the Linter Checks

The linter's rule set is derived entirely from the domain spec at runtime.
There are no hardcoded rules. Every predicate's domain, range, provenance
requirement, `is_functional` flag, and `inverse_of` pairing generates checks
automatically. Adding a predicate to the spec automatically extends lint
coverage to it.

**Predicate vocabulary violations**: the graph contains an edge with a
predicate name not in the current spec.

**Domain/range violations**: an edge's subject or object entity type does
not satisfy the predicate's declared constraint.

**Provenance gaps**: an edge is missing a required provenance field.

**Unacknowledged contradictions**: two edges that logically conflict. For
`Functional` predicates, two different objects for the same subject. For
`inverse_of` predicate pairs, both `activates(A, B)` and `inhibits(A, B)`
existing between the same entity pair without a conflict record.

### Violation Structure

Each violation is a typed, structured record:

```json
{
  "violation_type": "DOMAIN_RANGE_MISMATCH",
  "severity": "ERROR",
  "edge_id": "edge_789",
  "subject_type": "Person",
  "predicate": "occurred_at",
  "object_type": "Location",
  "message": "Predicate 'occurred_at' requires object type 'Moment'; got 'Location'.",
  "remediation": "Check entity resolution for object node."
}
```

Severity levels are `ERROR`, `WARNING`, and `INFO`. Output is JSONL\index{JSONL}: one
JSON object per line. JSONL is composable without parsing overhead: pipe it
into a dashboard, filter by severity with `jq`, load it into a review queue,
fail a CI step if the error count exceeds a threshold.

### Conflict Records as First-Class Data

When the linter finds a contradiction, it emits a conflict record\index{conflict record}: a
structured object naming both edges, identifying the conflict type, and
recording whether the conflict has been acknowledged and resolved.

The graph is richer for containing the dispute than for suppressing it.
Contradiction is information, not failure. In a scientific corpus, genuine
disagreement between sources is common. In the Holmes corpus, a story may
contain a claim that a later story retcons. Representing these disputes
explicitly, as first-class records linked to the edges involved, allows the
graph to model the actual state of knowledge in the corpus -- including the
contested parts -- without sacrificing structural integrity.

---

# Part V: Trustworthiness

## Chapter 10: Provenance as Architecture

`\chaptermark{Provenance as Architecture}`{=latex}

### Provenance Is Not Optional

In high-stakes domains -- medicine, law, materials safety -- every claim in a
knowledge graph must be traceable to its source. This is not a feature that
can be added later. It is a structural requirement that shapes the data model,
the extraction output format, the ingest stage, the confidence aggregation
logic, and the query interface. Adding provenance to an existing graph means
touching every relationship record. Getting it right from the start costs
almost nothing. Getting it wrong costs a full re-extraction.

The phrase "architectural" is precise. Provenance that lives in a side table,
optional and sparsely populated, is not provenance in any meaningful sense --
it is an audit log that nobody reads. Provenance that is required by the
schema, enforced at insertion time, and checked by the linter is
architecture: a constraint the system upholds unconditionally, not a field
that well-intentioned engineers fill in when they remember to.

### What a Provenance Record Contains

A complete provenance record for a Holmes edge contains the story title and
publication date, the chapter and paragraph index pointing to the specific
passage, the extraction method (which model, which prompt version), and the
confidence assigned to that specific piece of evidence.

The passage locator is the most important field for human verification. It
is not sufficient to know that an edge came from *A Scandal in Bohemia*; the
reader who wants to verify the claim needs to find the sentence. A paragraph
index makes that possible. An extraction log that records only the document
is attributable but not traceable.

The extraction method field serves reproducibility. If a claim needs to be
re-extracted because the original extraction is suspected to be wrong, the
provenance record tells you which model and prompt produced it. You can re-
run with the same configuration, compare the output, and determine whether
the original extraction was an error or a correct reading of an ambiguous
passage.

### Confidence Is Computed, Not Assigned

Confidence scores on edges are not the opinion of the extraction model about
how certain it feels. They are computed values derived from evidence quality
and evidence count, using a weight table the domain service declares.

A single passage asserting that Holmes maintained lodgings at Baker Street
warrants a moderate confidence score. The same assertion appearing
independently in a dozen stories warrants a higher score -- not because the
later extractions are individually stronger, but because independent
corroboration is itself evidence. The identity server aggregates these via
`POST /compute-confidence`. The domain service supplies the weights; the
base server handles the arithmetic.

This matters for multi-hop reasoning. A chain of three inferences, each at
0.9 confidence, produces a chain confidence of 0.73 by simple multiplication.
That arithmetic is possible because each step's confidence is a computed
value with a defined meaning. A cosine similarity score cannot be composed
this way: it has no principled relationship to probability, and scores from
different steps cannot be multiplied to produce a meaningful compound value.

### Typed Provenance

Because predicates are finite and typed, provenance completeness is
checkable. The domain spec declares, per predicate, what a complete
provenance record must contain. The linter checks every edge of every
predicate type against that requirement. Incompleteness is not a silent gap
-- it is a detectable violation with a severity level and a remediation
suggestion.

An edge of predicate `disguised_as` might require a passage locator and an
extraction confidence. An edge of predicate `treats` in the medlit schema
requires those plus `evidence_level` and `assertion_type`. The requirements
are per-predicate because the nature of the claim determines what evidence
is needed to warrant it.

### Multi-Source Claims

When the same relationship appears in multiple independent passages, the
identity server aggregates the evidence. Five extractions of "Holmes
associated_with 221B Baker Street" from five different stories produce one
edge with five provenance records attached. The composite confidence is
computed from all five. The audit trail shows all five sources. A query that
asks for the evidence behind a claim returns a structured list: five stories,
five paragraphs, five extraction runs. The graph does not flatten this into
a single score and discard the detail. The detail is the trustworthiness.

---

## Chapter 11: Making Bad Ideas Inexpressible

`\chaptermark{Making Bad Ideas Inexpressible}`{=latex}

### Hilbert's Dream

At the turn of the twentieth century, David Hilbert\index{Hilbert, David} proposed a program for
mathematics: find a formal system in which every true statement could be
proved and, crucially, no false or meaningless statement could even be
constructed. He wanted a system where bad mathematics was not just
discouraged -- it was *inexpressible*.\index{inexpressible} Kurt Gödel\index{Gödel, Kurt} showed
in 1931 that this is impossible for mathematics in general: any sufficiently
powerful formal system is either incomplete or inconsistent.

For a domain-constrained typed graph, the situation is different. We are not
trying to represent all of human knowledge. We are trying to represent a
finite, agreed-upon set of claims about a specific domain -- Holmes stories,
biomedical literature, legal case law. In that narrower space, the boundary
Hilbert wanted is achievable. The finite predicate vocabulary is that
boundary. A predicate not in the schema does not exist. A type combination
violating a declared domain or range cannot be expressed. The constraint is
not a runtime check that fires when someone tries to insert bad data -- it
is a structural property of the system that makes certain data
unrepresentable in the first place.

### What Becomes Inexpressible

The typed graph makes four classes of error structurally inexpressible, one
at each layer of the architecture.

**Type-layer violations**: an edge whose subject or object entity type
violates the predicate's declared domain or range cannot be inserted.
"Aspirin treats BRCA1"\index{category error} -- a drug predicated against a gene using a
disease predicate -- is not a low-confidence claim in the graph. It is an
unrepresentable claim. The schema closes the vocabulary; what falls outside
it cannot be expressed.

**Identity-layer violations**: an edge referencing an entity ID the identity
server cannot resolve has no valid endpoint. The graph cannot contain a
relationship to a thing it has no record of. Provisional entities are valid
endpoints; truly unresolvable IDs are not.

**Provenance-layer violations**: the domain spec declares, per predicate,
what a complete provenance record must contain. An edge without a required
provenance field is not a weak claim -- it is a malformed record that fails
the insertion check. An unsigned assertion is not an assertion at all in a
system that treats sourcing as structural rather than optional.

**Consistency-layer violations**: a functional predicate can have at most
one object per subject. A predicate and its `inverse_of` pair cannot both
hold between the same entity pair without a conflict record acknowledging
the dispute. Unacknowledged contradiction -- two edges logically incompatible,
sitting silently in the graph -- is inexpressible.

### The Functional Programming Analogy

The slogan in statically typed functional programming is "make illegal states
unrepresentable."\index{illegal states unrepresentable} In ML\index{ML (programming language)},
Haskell\index{Haskell}, and Rust\index{Rust}, the type system is designed so that programs
entering invalid states cannot be written. The invariant is enforced by the
compiler, which refuses to produce a program that can reach the state at all.
A null pointer exception is impossible in a language that has no null. A
use-after-free error is impossible in a language whose ownership rules
prevent it.

A typed graph applies the same principle to knowledge claims. We do not write
runtime checks that fire when a bad triple is inserted and then clean up the
damage. We design a schema in which certain classes of bad triple cannot be
formed. The domain spec is the type system. The insertion validation is the
compiler pass. The graph that results from a successful insertion is, by
construction, free of type-layer and provenance-layer violations -- not
because we checked every edge after the fact, but because non-conforming
edges were never representable.

### Gödel's Honest Boundary

The typed graph enforces structural well-formedness.\index{structural well-formedness} It does not
enforce semantic correctness.\index{semantic correctness} A well-typed, well-sourced edge can
still carry a false claim. An extraction pipeline that misread a passage,
or a passage that was itself mistaken, can produce a triple that passes
every gate and enters the graph as a valid claim. The schema does not
adjudicate the world.

This is not a defect. It is the honest limit of what formal structure can
guarantee. The typed graph's job is to ensure that the claims it contains
are well-formed, traceable, and internally consistent -- that they are the
right *kind* of claim about the right *kind* of entities with a known
*source*. Whether those claims are true is a question for domain experts,
for replication across sources, for the confidence scores that aggregate
evidence quality. The graph provides the structure that makes verification
possible. It does not perform the verification itself.

Gödel's result was about the limits of formal systems as truth machines.
The typed graph does not aspire to be a truth machine. It aspires to be a
trustworthy container for claims that humans and machines can reason over,
verify, and dispute. That is a more modest goal, and it is achievable.

---

# Closing

## Chapter 12: Bias, Limits, and Responsibility

`\chaptermark{Bias, Limits, and Responsibility}`{=latex}

### What the Graph Cannot Know

A knowledge graph built from a corpus knows only what that corpus contains.
The Holmes stories were written by Arthur Conan Doyle between 1887 and 1927,
from a particular cultural vantage point, with particular narrative choices
about whose perspective is centered and whose is absent. The graph built from
those stories inherits those choices. Watson's view of events is
well-represented. Mrs. Hudson's\index{Hudson, Mrs.} is not.

This is not a problem specific to fiction. A biomedical knowledge graph
built from PubMed\index{PubMed} inherits the coverage biases of biomedical publishing:
English-language journals are overrepresented; negative results are
underrepresented; diseases that attract research funding are better covered
than diseases that do not. The identity server cannot correct for absences
it cannot see.

Coverage gaps create false negatives. A query returning no result for a
relationship does not mean the relationship does not hold -- it means the
corpus does not assert it. The distinction between "the relationship does
not hold" and "the corpus has not asserted it" requires active communication
to users of the graph. A system that presents silence as denial will mislead
the people who rely on it.

### Bias Encoded at Scale

Source biases propagate into the graph and are amplified by confidence
weighting. If the Holmes stories describe Holmes's deductions in more detail
than Watson's, the graph will have higher-confidence edges about Holmes's
mental states than about Watson's. This is a faithful representation of
what the corpus asserts. It is also a distortion of the underlying reality.

Transparency is the available remedy, not elimination. The provenance
architecture described in Chapter 10 makes the evidence distribution visible:
a query can retrieve not just a confidence score but the full list of source
passages and their individual confidence values. A user who sees that all
five supporting passages for a claim are from a single story, told from a
single character's perspective, can weigh that evidence accordingly. The
graph does not do the weighing. It provides the data that makes weighing
possible.

### Capability Is Not Bounded by Intent

A typed graph built for one purpose supports inferences its builders did not
anticipate, because structure supports inference and inference does not
respect the boundaries of intended use. A Holmes graph built to study
narrative structure can be queried to identify characters who are
systematically deceived. A medical graph built to support drug discovery
can be queried to identify precursor compounds for controlled substances.
A legal graph built to assist lawyers can be queried to identify patterns
in judicial decisions that correlate with demographic factors.

None of these are edge cases or failures. They follow directly from the
system working as designed. The system is more powerful than any particular
use case imagined for it, and that power does not turn off at the boundaries
of the intended use case.

### The Builder's Responsibility

Trustworthiness is not a one-time design choice. It is an ongoing commitment
that extends past the point of deployment.

Honesty about coverage limits means documenting what the corpus covers and
what it does not, and surfacing that documentation at query time rather than
burying it in a README. Infrastructure for verification means ensuring that
provenance records are complete, that confidence computations are
reproducible, and that the schema is legible to domain experts who need to
understand what the graph can and cannot express. Consideration of
foreseeable misuse means asking, before deployment, what traversals the
graph enables that were not intended, and whether access controls or audit
logging are warranted.

The identity server architecture provides the infrastructure for all of
this: every merge is logged, every promotion is logged, every confidence
computation is reproducible from the provenance records, and the schema is
a readable Python module rather than an opaque binary. The infrastructure
for verification is built in. Using it -- treating it as a commitment rather
than a compliance checkbox -- is the builder's responsibility.

### Who Owns the Graph

Open versus proprietary carries consequences for what the graph becomes and
who benefits from it. GenBank\index{GenBank}, the public repository of genetic sequences,
was built as a commons and shaped how molecular biology developed for
decades. Any researcher, anywhere, could query it. The field advanced
accordingly. Clinical trial data, by contrast, has often been held
proprietary by sponsors; the consequences for public health have been
documented and contested.

A comprehensive typed graph over a scientific domain is a significant
infrastructure investment, and whoever controls it controls what gets
synthesized, what gets surfaced, and how the schema evolves. These are not
neutral technical decisions. The governance question -- who owns the graph,
who can query it, who can extend the schema, who can audit the ingestion --
is worth answering deliberately before it is answered by default.

The technology is neutral on governance. The builder is not.

---

## Chapter 13: What This Makes Possible

`\chaptermark{What This Makes Possible}`{=latex}

### The Connective Tissue

The typed schema and canonical identity are connective tissue. The extraction
pipeline calls the identity server to resolve every mention to a canonical
ID before the claim enters the graph. The query layer relies on those
canonical IDs to traverse the graph without ambiguity. The schema enforced
at write time is the same schema the query layer uses to understand what a
result means.

Without canonical identity, the graph is a collection of strings. Without
the typed schema, a collection of untyped triples. Without provenance, a
collection of unsigned assertions. This book has been about what it takes
to have none of those problems.

### Cross-Domain Reasoning

Shared canonical IDs let two graphs built independently compose
automatically. A Holmes graph and a Victorian history graph, both anchoring
their `Location` entities to Wikidata\index{Wikidata} URIs, can be traversed as a single
graph: a query starting from Baker Street in the Holmes graph can follow an
edge to a Wikidata node and continue into the history graph without any
coordination between the teams that built each. The shared identifiers are
the bridge.

The typed schema ensures the composition is structurally coherent. When two
graphs share a predicate vocabulary -- or when the predicate vocabularies
have a declared mapping -- edges from one graph can be interpreted in the
context of the other. Cross-graph reasoning requires shared semantics, not
just shared IDs. The domain spec is where those semantics live.

This composability is not a designed feature of any single system. It is an
emergent property of the decision to anchor to shared authorities and declare
a typed schema. The epistemic commons was built over decades for human use.
The typed graph makes it available to machines in a form that carries its
own warrant.

### Grounding LLM Inference

The difference between asking an LLM to reason from its training data and
asking it to reason from a typed, provenance-tracked graph is qualitative,
not quantitative. Training data is a frozen snapshot of text compressed into
weights. It cannot be updated without retraining. Its sources cannot be
cited. Its confidence cannot be computed from evidence.

A graph provides all of these things. The system retrieves the relevant
subgraph -- entities and edges bearing on the question -- and injects it
into the model's context. The model reasons over that context. The answer
is grounded in retrieved claims with known sources, not in training-data
recall. When the graph is wrong, you fix the graph. You do not retrain the
model. When the model's answer is surprising, you can trace the reasoning
path through the graph edges and provenance records that informed it.

### Hypothesis Generation

A well-constructed typed graph supports a class of query impossible over
unstructured text: "what relationships exist between X and Y that no single
source asserts but that follow from combining multiple sources?"

In the Holmes corpus: Holmes knows Irene Adler\index{Adler, Irene} outmaneuvered him. Irene
Adler is associated with a particular case in a particular year. The case
involves a client whose later appearances are documented in other stories.
A traversal combining these facts can surface a connection between Holmes's
experience with Adler and his subsequent behavior in cases involving women
clients -- a connection no single story states but that follows from the
graph. The graph narrows the space of possibilities for a literary analyst
to evaluate.

In a scientific corpus, the same pattern generates drug-disease candidate
pairs, gene-pathway associations, and cross-trial comparisons that no single
paper asserts. These are candidate hypotheses, not established facts. The
graph does not decide which are worth pursuing. It surfaces candidates that
a human can filter, prioritize, and test.

### An Invitation

The epistemic commons -- MeSH, HGNC, RxNorm, UniProt, Wikidata, and the
dozens of domain-specific authorities that curated communities have built
over decades -- was built for human use. Researchers navigated it through
literature searches, reference lists, and expert consultation. The knowledge
was there. The access was slow.

The typed graph makes that commons available to machines in a form that
carries its own warrant: canonical IDs anchoring to the authorities, a
schema constraining what can be expressed, provenance tracing every claim
to its source. A machine traversing this graph is not pattern-matching over
text. It is reasoning over a structured representation of what expert
communities have established, with the ability to follow chains of evidence
and surface the sources behind every step.

That is not a small thing. The extraction bottleneck that prevented this
for fifty years is now broken. The infrastructure described in this book
is buildable today, with tools that exist, at a cost that is no longer
prohibitive.

---

## Appendix A: Formal Definition Reference

`\chaptermark{Formal Definition Reference}`{=latex}

Quick-reference card for the seven-tuple, validity constraints, and trait
vocabulary. Suitable for use alongside later chapters without re-reading
Chapter 2.

**The Seven-Tuple**

A typed graph is $(T_V,\ T_E,\ \Phi,\ V,\ E,\ \tau_V,\ \tau_E)$ where:

| Symbol | Name | Description |
|---|---|---|
| $T_V$ | Entity type vocabulary | Finite set of vertex types |
| $T_E$ | Predicate type vocabulary | Finite set of edge types |
| $\Phi$ | Field schema assignment | Per-type field requirements |
| $V$ | Entity instances | Typed vertex records |
| $E$ | Edge instances | Directed typed edges $(u, p, v) \in V \times T_E \times V$ |
| $\tau_V$ | Entity type function | $\tau_V : V \to T_V$ |
| $\tau_E$ | Edge type projection | Predicate label of each edge |

**Validity Constraints**

For every edge $(u, p, v) \in E$:

1. $\tau_V(u) \in \text{dom}(p)$
2. $\tau_V(v) \in \text{rng}(p)$
3. Fields of $u$, $(u,p,v)$, and $v$ conform to $\Phi$

With subtypes: replace set membership with $\tau_V(u) \leq t$ for some $t \in \text{dom}(p)$.

**Trait Vocabulary**

$$\text{Tr}(p) \subseteq \{\text{Symmetric},\ \text{Transitive},\ \text{Functional},\ \text{InverseFunctional},\ \text{Inverse}(p'),\ \text{Rule}(\phi \Rightarrow \psi)\}$$

| Trait | Rule |
|---|---|
| Symmetric | $(x,p,y) \Rightarrow (y,p,x)$ |
| Transitive | $(x,p,y) \wedge (y,p,z) \Rightarrow (x,p,z)$ |
| Functional | $(x,p,y) \wedge (x,p,z) \Rightarrow y=z$ |
| InverseFunctional | $(x,p,z) \wedge (y,p,z) \Rightarrow x=y$ |
| Inverse$(p')$ | $(x,p,y) \Rightarrow (y,p',x)$ |
| Rule$(\phi \Rightarrow \psi)$ | Arbitrary Horn clause |

---

## Appendix B: Non-Goals

What this model is not, and why the distinction matters.

**Not RDF/OWL.** In RDF, predicates are URIs and are themselves nodes; the
graph is a flat set of triples with no first-class edge objects. OWL adds
description logic and the open-world assumption. This model is a closed-world
property graph with typed, field-bearing edge instances. The distinction
matters especially for reification: RDF requires it, this model eliminates it.
An edge that carries provenance and confidence is a first-class object, not
a triple about a triple.

**Not Neo4j's informal property graph.** Neo4j allows arbitrary key-value
properties on edges without schema enforcement. This model requires a
declared field schema and enforced subject/object type constraints. The
schema is a contract, not documentation.

**Not an entity-relationship diagram.** ER diagrams are a database design
tool. This is a runtime knowledge representation with provenance, epistemic
scope, and trait-based inference semantics.

**Not a general ontology language.** This model does not support open-world
reasoning, class hierarchies, disjointness axioms, or the full OWL trait
vocabulary. If a use case seems to require full description logic, that is
scope creep. The power gained from the closed-world assumption is worth
more in high-stakes domains than the expressiveness surrendered.

---

## Appendix C: The Holmes Schema Reference

`\chaptermark{Holmes Schema Reference}`{=latex}

*[Placeholder: The Holmes schema is being built inductively by annotating
the Conan Doyle canonical corpus rather than pre-designed. The full schema
will be published here -- in both YAML (schema definition language) and
Python (kgschema binding) -- when sufficient annotation work has been
completed to stabilize the entity types and predicate vocabulary.*

*The working draft of the schema appears in Chapter 3 (YAML) and Chapter 4
(Python). The authoritative version in progress is maintained at
`graphwright.io/schemas/holmes` in the companion repository.*

*Entity types expected in the final schema: Person, Location, Object, Event,
Moment (provisional). Predicate vocabulary in progress includes:
associated\_with, disguised\_as, knows, located\_in, occurred\_at,
known\_to\_watson\_at, involves, has\_true\_identity, and others being
identified through story annotation. Rationale for provisional types and
annotation methodology will be documented here.]*
