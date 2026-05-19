# The Typed Graph -- Outline
## Naming, Knowing, and Trusting Machine Knowledge
### Graphwright Publications

---

## Foreword: A Manifesto for Machine Knowledge

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

## Part I: The Case for Typed Graphs

*The Sherlock Holmes corpus is the running example throughout this book.
It is introduced in Chapter 1 and carried forward continuously -- not
re-introduced at each chapter. A reader arriving at Part III already knows
the Holmes schema.*

### Chapter 1: Why Typed Graphs

**The Stakes**
- Law, medicine, civil engineering: domains where errors cost lives and
  livelihoods
- The question: what does it take for machine reasoning to be trustworthy
  in these domains?
- The failure mode: retrieval systems that can't say where an answer came
  from or whether the underlying claim is well-formed

**From RAG to Graph RAG to Typed Graphs**
- Cosine similarity retrieval: powerful but opaque; no provenance, no
  structure, no error-checking
- Graph RAG: multi-hop reasoning becomes possible once knowledge has
  structure
- The remaining gap: where did this edge come from? is this triple even
  well-formed?
- The typed graph: guardrails built into the structure itself, not bolted
  on afterward

**The Reasoning Layer Is Not the Extraction Layer**
- A typed graph does not require an LLM to operate -- only to build
- BFS on well-organized typed data is intrinsically useful regardless of
  how the data got there
- As extraction technology evolves (and it will), the graph remains the
  stable substrate
- The Raspberry Pi demonstration: pure BFS traversal, no cloud, no model,
  answers a Sherlock Holmes question from a locally stored graph
- This is future-proof reasoning infrastructure, not an LLM wrapper

**Type Systems and Category Errors**
- The everyday intuition: apples and oranges; you can't compare them
- Dimensional analysis in physics: meters + seconds is not merely wrong,
  it is undefined -- the operation has no coherent meaning
- Type systems in programming: the compiler catches category errors before
  runtime, not after
- What a category error looks like in a graph: a triple that violates a
  predicate's type signature
- "City treats Doctor" is a category error; "Aspirin treats Headache" is not
- Predicates as two-argument functions: treats(subject: Drug, object: Disease)
  -- the same concept as a function signature, applied to declared relationships

**A Brief Intellectual History of Type Systems**
- Origins in mathematical logic: Russell's paradox, type theory as the remedy
- Church's lambda calculus; the Curry-Howard correspondence (programs are proofs)
- Types migrate into languages: Algol, Pascal, ML -- the compiler as enforcer
- Algebraic types in Haskell and OCaml: making illegal states unrepresentable
- Rust: ownership types encode resource safety at compile time
- The general arc: from runtime crashes to compile-time guarantees
- Mathematical types: dimensions in R, dtypes in NumPy -- types on data, not
  just code
- The through-line: a type system is a formal bet that certain errors cannot
  occur; the bet is enforced by the structure, not by discipline

**An Informal Definition of the Typed Graph**
- A graph with a finite, closed vocabulary of entity types
- Each predicate has a declared type signature: which subject types and object
  types it connects
- What falls outside the vocabulary is inexpressible, not merely discouraged
- A brief tour of the seven components before the formalism arrives
- Closed-world vs. open-world: in this model, absence means something

### Chapter 2: The Formal Definition

- Why formalism? Math is the most precise language for specifying exactly what
  a typed graph is and is not
- Acknowledging that programmers find math off-putting -- and why the rigor
  is worth it anyway; the definition is short
- The seven-tuple $(T_V,\ T_E,\ \Phi,\ V,\ E,\ \tau_V,\ \tau_E)$ --
  each component named and motivated
  - $T_V$: finite set of entity types
  - $T_E$: finite set of predicate types
  - $\Phi$: field schema assignment for each type
  - For each predicate: subject types, object types, trait set
  - $V$: entity instances; $E$: directed typed edge instances
  - $\tau_V$, $\tau_E$: type assignment functions
- Validity constraints: subject/object type conformance; schema conformance
- Trait vocabulary: Symmetric, Transitive, Functional, InverseFunctional,
  Inverse(p'), Rule(φ ⇒ ψ) -- what each means, why it belongs to the
  predicate type rather than to any edge instance
- A worked example: a small Holmes graph verified against the definition
  - One valid triple shown as an instance of each component
  - One invalid triple and where in the definition it fails
- What the formal definition does not guarantee: structural well-formedness
  is not factual correctness; a well-typed claim can still be wrong

---

## Part II: The Schema

*The schema is the bridge between the mathematical definition and running
code. Chapter 3 presents it in a language-agnostic notation; Chapter 4
shows one concrete realization in Python. The same Holmes schema appears
in both chapters so the relationship is explicit.*

### Chapter 3: The Schema Definition Language

- Why language-agnostic? The typed graph concept is independent of Python,
  Rust, or TypeScript; the same schema document should be usable in all of them
- The schema document as a language: YAML as the notation
- Precedent: Protocol Buffers, Thrift, GraphQL SDL -- write the schema once,
  generate bindings for each language; the difference here is that the schema
  is a graph vocabulary, not a message format
- The Holmes schema written out in full:
  - `node_types` -- the entity type vocabulary
  - `edge_types` -- the predicate vocabulary, each with `subject_types`,
    `object_types`, and optional traits
  - `trait_groups` -- temporal, epistemic, provenance properties; which apply
    to nodes, which to edges
- Walking through each section as a direct instance of the seven-tuple components
- Valid and invalid triples demonstrated against the schema
- What the schema enforces vs. what it deliberately leaves open: factual
  correctness is outside the contract
- The closed-world payoff: "this predicate does not appear" means something;
  the ambiguity is explicit, not silent
- Provisional types: flagged in the schema; they carry full constraints while
  flagged; the flag records that the domain designers are not yet certain
  these are the right abstractions

### Chapter 4: A Python Binding

- The schema document is the source of truth; Python is one materialization of it
- `NodeType` and `EdgeType` as `StrEnum` base classes with no members; domain
  schemas subclass these to add their vocabulary
- Why empty base enums? `isinstance` checks, mypy type narrowing, and
  `GraphSchema` can store the enum class itself rather than a frozenset of strings
- `BaseEntity` and `BaseRelationship`: frozen Pydantic models, abstract
  `get_entity_type()` and `get_edge_type()`
- `DomainSchema`: the abstract class a domain implements; what it must declare
- `PredicateConstraint`: the Python representation of a predicate's type signature
- Why frozen Pydantic? Immutability as a structural principle, not a style
  preference; edge instances are facts, not mutable records
- `HolmesNodeType`, `HolmesEdgeType`, `HolmesDomain`: the Holmes schema
  in Python, derived visibly from the YAML in Chapter 3
- Domain-specific edge subclasses: adding typed fields for provenance, evidence,
  epistemic status; the base carries structural fields, the subclass adds semantic ones
- Running valid and invalid triples against the Python implementation; the same
  examples from Chapter 3 produce the expected results

---

## Part III: Domains in Practice

*Two worked domains that differ structurally: Holmes, a narrative/epistemic
domain with deliberate uncertainty; medical literature, a high-stakes domain
with established external ontologies and evidence grading. The contrast
demonstrates what the schema language handles uniformly and what varies
by domain.*

### Chapter 5: Medical Literature -- A Second Domain

- Why medicine as the second domain: high stakes, well-established ontologies,
  structurally different from Holmes in ways that test the schema language's
  generality
- UMLS, MeSH, RxNorm, HGNC, UniProt: authoritative ontologies as canonical
  ID sources; what each covers
- The medlit schema: entity types (Disease, Drug, Gene, Protein, ...),
  predicate vocabulary, predicate constraints
- Evidence and provenance as first-class fields on edges -- required by the
  domain, not optional metadata; a medical claim without a citation is not
  a claim
- `EvidenceLevel`, `AssertionType`: domain-specific enums that extend the
  base layer without modifying it
- Comparing Holmes and medlit: entity types differ, predicate vocabularies
  differ, evidence requirements differ; the schema language, `BaseEntity`,
  `BaseRelationship`, and `DomainSchema` are identical
- The schema language earns its generality by handling both without
  modification

---

## Part IV: Canonical Identity  *(rough -- fill in later)*

### Chapter 6: Strings vs. Things

- Two mentions of "Holmes" in different passages are the same entity; without
  a canonical ID, the graph has two nodes where there should be one
- What an authoritative ontology provides: stable identifier, canonical name,
  known synonyms, position in a taxonomic structure; anchoring to one means
  inheriting all of that
- URIs as stable referents: the Wikipedia/Wikidata model; two graphs that
  anchor to the same URI agree on the referent without coordination
- Domains without official AOs: medicine has MeSH, RxNorm, HGNC, UniProt;
  the Holmes corpus has no official ontology; the common case for non-scientific
  domains; the system must handle both
- The Baker Street Wiki as domain AO: assessed on coverage, stability, and
  URL structure; wiki page URLs as canonical IDs
- Synonym resolution via the AO: redirect structure and alias lists
- Entities the wiki doesn't cover: provisional entities with locally minted IDs;
  the graph continues to function

### Chapter 7: The Identity Server

- Extraction produces mentions, not entities; the identity server is the bridge
- Why a service, not a library: concurrent writes, cross-process uniqueness
- Entity lifecycle: provisional → canonical → merged; transitions are one-way
  and logged; immutable transitions make the provenance audit trail trustworthy
- The lookup chain: exact match, fuzzy (rapidfuzz), embedding similarity
  (pgvector) -- ordered by cost, not by sophistication
- Provisional entities: valid graph nodes while unresolved; promotion later
  does not require re-ingestion
- Advisory locking in Postgres: per-entity mutual exclusion without a separate
  lock service; why advisory locks rather than transactions
- Idempotency: all operations safe to retry; a service that produces different
  results on retry corrupts the graph
- Caching: LRU cache in the identity server; long-TTL cache in the domain
  service for AO API responses
- The identity server HTTP interface: `/resolve`, `/promote`, `/merge`,
  `/entity/{id}`, `/schema`

### Chapter 8: The Domain Service

- What the domain service owns: entity type enum, predicate list, AO lookup
  logic, synonym thresholds, survivor selection, confidence weights; all
  domain-specific, none of it in the base server
- Python as the spec language: the domain spec is a module, not a config
  file; it can express logic, it is testable, it round-trips to JSON
- The Holmes `domain_spec.py` written out in full
- The plugin contract: four endpoints the base server calls -- authority
  lookup, synonym criteria, survivor selection, confidence weighting;
  these are the four decisions that vary by domain; everything else is mechanics
- The domain service HTTP interface: `/resolve-authority`, `/select-survivor`,
  `/compute-confidence`, `/synonym-criteria`, `/schema`
- When the ontology changes: deprecate rather than delete; tightened
  constraints produce migration items; the domain spec carries a version field

### Chapter 9: Validation and the Graph Linter

- Two enforcement points: insertion-time validation and post-hoc linting;
  both roles are worth having
- Why a separate linter: audits data that predates stricter constraints;
  catches cross-edge consistency issues invisible at single-write time;
  acts as a CI gate on ingestion batches
- What the linter checks: predicate vocabulary violations, subject/object type
  violations, missing provenance, unresolvable canonical IDs, unacknowledged
  contradictions; each check derived from the domain spec at runtime
- Violation structure: typed, structured records with severity (ERROR /
  WARNING / INFO), affected edge or entity, suggested remediation; JSONL output
- Conflict records as first-class data: when the linter finds a contradiction
  it emits a conflict record; the graph is richer for containing the dispute;
  contradiction is information, not failure
- The linter as a compiler pass for the graph

---

## Part V: Trustworthiness

### Chapter 10: Provenance as Architecture

- Provenance is not optional: in high-stakes domains, every claim must be
  traceable to its source; this is a structural requirement, not a feature
- What a provenance record contains: source document, passage locator,
  extraction method, confidence, timestamp; the full audit trail for any claim
- Confidence is computed, not assigned: evidence quality (how strong is the
  source?) and evidence count (how many independent sources agree?);
  the domain service supplies the weight table; the base server aggregates
- Multi-source claims: independent agreement strengthens confidence;
  the identity server aggregates evidence and computes a defensible composite
- Typed provenance: because predicates are finite and typed, provenance
  completeness is checkable; the schema defines what "complete" means, so
  incompleteness is detectable

### Chapter 11: Making Bad Ideas Inexpressible

- Hilbert's dream: a formal system where false or meaningless statements could
  not be constructed; Gödel showed this is impossible for mathematics in general
- For a domain-constrained typed graph it is achievable: the finite predicate
  set is the boundary Hilbert wanted
- What becomes inexpressible: type-layer violations (wrong entity type for a
  predicate's signature); identity-layer violations (edges to unresolvable IDs);
  provenance-layer violations (claims without a source); consistency-layer
  violations (contradictions without a conflict record)
- The functional programming analogy: ML, Haskell, and Rust enforce "make
  illegal states unrepresentable"; invariants live in the type system, not in
  runtime checks; a typed graph applies the same principle to assertions
- Gödel's honest boundary: the typed graph enforces structural well-formedness,
  not factual correctness; a well-typed, well-sourced edge can still be wrong;
  this is not a defect, it is the honest limit of what formal structure can
  guarantee

---

## Closing

### Chapter 12: Bias, Limits, and Responsibility

- What the graph cannot know: coverage gaps create false negatives; absence
  of evidence is not evidence of absence; the system cannot correct for what
  was never ingested
- Bias encoded at scale: selection bias, language bias, and recency bias
  propagate into the graph and are amplified by confidence weighting;
  the builder is responsible for knowing this
- Structural well-formedness is not factual correctness: the graph records
  disputes, it does not adjudicate them; the schema is a filter, not a judge
- Capability is not bounded by intent: a system that encodes the architecture
  of expertise enables inferences its builders did not anticipate; structure
  supports inference; inference does not respect intended-use-case boundaries
- The builder's responsibility: honesty about coverage limits; infrastructure
  for verification; consideration of foreseeable misuse; trustworthiness is an
  ongoing commitment, not a one-time design choice
- Who owns the graph: open vs. proprietary carries consequences for the commons;
  GenBank (open, shaped a field) vs. contested clinical trial data; the
  governance question is worth answering before it is decided for you

### Chapter 13: What This Makes Possible

- The typed schema and canonical identity are connective tissue: without
  canonical identity the graph is a collection of strings; without the typed
  schema, a collection of untyped triples; without provenance, a collection
  of unsigned assertions
- Cross-domain reasoning: shared canonical IDs let two graphs built from
  different sources compose automatically; the typed schema ensures the
  composition is structurally coherent
- Grounding LLM inference: typed, provenance-tracked claims from the graph
  rather than training-data recall; the difference in reliability is
  qualitative, not quantitative
- Hypothesis generation: traverse the graph to surface candidates that no
  single source asserts but that follow from combining multiple sources;
  the graph narrows the space of possibilities for human evaluation
- An invitation: the epistemic commons was built over decades for human use;
  the typed graph makes it available to machines in a form that carries its
  own warrant; that is not a small thing

---

## Appendix A: Formal Definition Reference

Quick-reference card for the seven-tuple $(T_V,\ T_E,\ \Phi,\ V,\ E,\ \tau_V,\ \tau_E)$,
validity constraints, and trait vocabulary. Suitable for use alongside
later chapters without re-reading Chapter 2.

## Appendix B: Non-Goals

What this model is not, and why the distinction matters:

- **Not RDF/OWL.** In RDF, predicates are URIs and are themselves nodes; the
  graph is a flat set of triples with no first-class edge objects. OWL adds
  description logic and open-world assumption. This model is a closed-world
  property graph with typed, field-bearing edge instances. The distinction
  matters especially for reification: RDF requires it, this model eliminates it.
- **Not Neo4j's informal property graph.** Neo4j allows arbitrary key-value
  properties on edges without schema enforcement. This model requires a declared
  field schema and enforced subject/object type constraints.
- **Not an entity-relationship diagram.** ER diagrams are a database design
  tool. This is a runtime knowledge representation with provenance, epistemic
  scope, and trait-based inference semantics.
- **Not a general ontology language.** This model does not support open-world
  reasoning, class hierarchies, disjointness axioms, or the full OWL trait
  vocabulary. If a use case seems to require full description logic, that is
  scope creep.

## Appendix C: The Holmes Schema Reference

Full Holmes schema in both YAML (schema definition language) and Python
(kgschema binding): entity types, predicates with type signatures, traits,
and rationale for provisional types. Canonical reference for code examples
throughout the book.
