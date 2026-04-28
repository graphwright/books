# The Typed Graph -- Outline
## Naming, Knowing, and Trusting Machine Knowledge
### Graphwright Publications

---

## Foreword: A Manifesto for Machine Knowledge

*This foreword appears in all three volumes of the Graphwright series.*

High-stakes reasoning requires things, not strings.

Similarity is not identity. Retrieval is not reasoning.

The LLM is the extraction and language layer. The graph is the reasoning
substrate. Conflating those two roles is where most systems go wrong.

RDF got the atoms right. It left the chemistry uncontrolled.

A typed graph fixes the chemistry: a finite, closed vocabulary of entity
types and predicates, each predicate with declared domain and range. What
falls outside the vocabulary is inexpressible, not merely discouraged.
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

The two companion volumes -- *Knowledge Graphs from Unstructured Text* and
*BFS-QL* -- both depend on canonical identity and a typed graph schema, but
neither has room to fully explain them. This book is that explanation. It is
about the infrastructure that makes a knowledge graph trustworthy: the service
that ensures every entity is placed, every claim is sourced, every type
constraint is enforced, and every merge is auditable.

The argument has three interlocking parts. First: canonical identity is the
foundation -- every entity must be named unambiguously before anything else is
possible, and that naming anchors the graph to an epistemic commons built by
expert communities over decades. Second: the graph must be typed -- a finite
ontology of entity types and predicates, each predicate with a declared domain
and range, makes certain classes of error structurally inexpressible rather
than merely discouraged. Third: typing is what makes provenance a guarantee
rather than a convention -- when the schema knows what a well-formed claim looks
like, it can enforce that every claim carries its warrant.

Together these form a complete epistemology for machine-readable knowledge:
naming (canonical identity), knowing (typed schema), and trusting (structural
provenance). None of the three is sufficient alone.

---

## Part I: The Typed Graph

### Chapter 1: What a Typed Graph Is

- **Beyond the Triple** -- RDF stores (subject, predicate, object) triples with
  no constraints on what subject, predicate, or object may be; a typed graph
  adds a finite enum of entity types and a finite vocabulary of predicates, each
  predicate with a declared domain (allowed subject types) and range (allowed
  object types).
- **The Ontology as Contract** -- The schema is not documentation; it is a
  machine-checkable contract governing every edge; contracts can be enforced,
  documents cannot.
- **Finite vs. Open-World** -- RDF/OWL operate under the open-world assumption:
  if something is not asserted, it might still be true; a typed graph is
  closed-world: predicates outside the schema do not exist; this is the source
  of its expressive power, not a limitation.
- **Category Error Detection** -- With domain and range declared, the system
  can reject "aspirin treats BRCA1" at write time, not discover the mistake
  at query time; structural validity is separable from factual correctness.
- **Subtype Hierarchies** -- Entity types can form a DAG (not necessarily a
  tree); a predicate whose domain includes `Animal` implicitly covers `Dog`;
  the hierarchy lives in the schema, not in the graph.
- **`PredicateSpec` and `EntityType`** -- Concrete representation: entity types
  as a Python enum, predicates as frozen Pydantic models carrying domain, range,
  and optional flags (`is_functional`, `negation_of`); the domain spec is the
  single source of truth for all of this.

### Chapter 2: The Sherlock Domain

- **Why Holmes** -- The stories have deliberate epistemic complexity: disguises,
  false identities, unreliable narration, time-shifted revelations; these
  stress-test a typed graph in ways a clean biomedical corpus does not.
- **Entity Types for the Holmes Corpus** -- `Person`, `Location`, `Object`,
  `Event`, and two provisional types specific to this domain: `Moment` and
  `ConfidenceLevel`.
- **`Moment`: Time-Scoped Knowability** -- Some assertions in Holmes are true
  but not yet knowable at a given point in the narrative; "Watson did not know
  Holmes was alive until the moment of his return" -- the fact is true, but its
  knowability is time-scoped; `Moment` is the entity type that anchors this;
  it is not a universal type, it is scaffolding this corpus needs.
- **`ConfidenceLevel`: Epistemic Status** -- Holmes operates on inference, not
  certainty; a `ConfidenceLevel` entity marks how much to trust a claim in
  the graph; again, domain-specific provisional scaffolding, not a general-purpose
  type.
- **Predicates Constructed by Hand** -- Extractions in this part are done
  manually from canonical story passages; the point is graph structure and
  schema design, not pipeline mechanics; the pipeline comes in Book Two.
- **A Worked Schema** -- The Holmes `domain_spec.py` written out in full:
  entity type enum, predicate list with domain/range, the two provisional types
  with their rationale documented.

### Chapter 3: What the Schema Enforces

- **Valid and Invalid Triples in the Holmes Graph** -- Concrete examples of
  assertions accepted and rejected, and why; the schema as a filter at write
  time.
- **Provisional Types as First-Class Citizens** -- `Moment` and `ConfidenceLevel`
  are flagged provisional in the schema; they carry full type constraints while
  flagged; flagging records that the domain designers are not yet certain these
  are the right abstractions.
- **What the Schema Cannot Enforce** -- Structural validity is not factual
  correctness; a well-typed claim can be wrong; the schema closes the
  vocabulary, it does not adjudicate the world.
- **The Closed-World Payoff** -- Because the predicate vocabulary is finite,
  "this predicate does not appear in the graph" means something: either the
  relationship does not exist or the corpus does not assert it; the ambiguity
  is explicit, not silent.

---

## Part II: Canonical IDs and Authoritative Ontologies

### Chapter 4: What an Authoritative Ontology Is

- **Strings vs. Things** -- Two mentions of "Holmes" in different passages are
  the same entity; without a canonical ID, the graph has two nodes where there
  should be one; canonical IDs are the mechanism for "this thing *is* that thing."
- **What an AO Provides** -- A stable identifier, a canonical name, known
  synonyms, and (often) a position in a taxonomic or relational structure;
  anchoring to an AO means inheriting all of that for free.
- **URIs as Stable Referents** -- The Wikipedia/Wikidata model: a URL is a
  globally unique, dereferenceable identifier for a thing; two graphs that
  anchor to the same URI agree on the referent without any coordination.
- **Domains Without Official AOs** -- Medicine has MeSH, RxNorm, HGNC, UniProt;
  the Holmes corpus has no official ontology; this is the common case for
  non-scientific domains; the system must handle both.

### Chapter 5: The Baker Street Wiki as Domain AO

- **Assessment of Fitness** -- Coverage (does it have an entry for every named
  entity in the stories?), stability (are URLs permanent?), URL structure
  (are URLs clean enough to use as IDs?); the Baker Street Wiki
  (bakerstreet.fandom.com) assessed on all three.
- **Using Wiki Page URLs as Canonical IDs** -- A Holmes entity gets the URL of
  its Baker Street Wiki page as its canonical ID; no external service needed;
  the AO is a static resource the domain service can query.
- **Synonym Resolution via the AO** -- "Holmes," "Sherlock," "Mr. Holmes,"
  "the detective" all resolve to the same canonical ID; the wiki's redirect
  structure and alias lists do this work.
- **Entities the Wiki Doesn't Cover** -- Minor characters, invented objects,
  unnamed locations; these become provisional entities with locally minted IDs;
  the system continues to function.

### Chapter 6: Deduplication and Provenance

- **Deduplication as Graph Hygiene** -- The same entity appearing under multiple
  surface forms is the most common source of graph corruption; deduplication is
  not a cleanup step, it is a structural requirement.
- **The Lookup Chain** -- Multi-stage resolution: exact match against AO,
  fuzzy match (rapidfuzz), embedding similarity (pgvector); each stage handles
  what the prior stage cannot; the chain is ordered by cost, not by sophistication.
  *Why this ordering:* exact match is free and definitive; fuzzy match catches
  abbreviations and typos cheaply; embedding similarity is expensive and reserved
  for semantic equivalence that string methods miss.
- **Provisional Entities** -- When no AO match exists, mint a local ID and flag
  it provisional; provisional IDs are valid graph nodes; relationships
  referencing them are valid; promotion later does not require re-ingestion.
  *Why provisional rather than blocking:* the graph must be functional before all
  identities are known; blocking on unresolved entities would stall ingestion.
- **Provenance: Linking Every Triple to Its Source** -- Every edge in the Holmes
  graph carries a pointer to the passage it was extracted from (story title,
  chapter, paragraph); this is not optional metadata, it is a structural
  requirement; a claim without a source is not a claim, it is a rumor.
- **What `Moment` Enables for Provenance** -- A provenance record can include
  the `Moment` at which the assertion became knowable; "Holmes is alive" is
  true throughout *The Final Problem* but not knowable to Watson until
  *The Adventure of the Empty House*; the graph records both.

---

## Part III: The Identity Service

### Chapter 7: The Problem the Identity Service Solves

- **Extraction Produces Mentions, Not Entities** -- The extraction pipeline
  yields strings; the graph needs nodes with canonical IDs; the identity service
  is the bridge.
- **Why a Service, Not a Library** -- Multiple pipeline workers running in
  parallel must not mint duplicate IDs for the same entity; a service with a
  database and advisory locking is the standard solution to concurrent writes;
  a library cannot enforce cross-process uniqueness.
- **The Identity Service as a Black Box to the Pipeline** -- The pipeline
  sends (mention string, entity type) and receives a canonical ID; it does not
  know or care about the lookup chain, the AO, or the deduplication logic.

### Chapter 8: Architecture and Design Rationale

- **Domain-Agnostic Core** -- The deduplication state machine, the lookup chain
  orchestration, idempotency guarantees, Postgres locking, and pgvector
  similarity search are all domain-independent; they live in the base server.
  *Why:* a base server that ships without domain knowledge can be reused across
  domains without modification; domain logic that leaks into the core creates
  maintenance debt.
- **The Plugin Contract** -- The domain service implements four endpoints the
  base server calls: authority lookup, synonym criteria, survivor selection,
  confidence weighting.
  *Why four and not more or fewer:* these are the four decisions that vary by
  domain; everything else is mechanics; keeping the surface small makes the
  contract auditable and the domain service easy to implement.
- **Advisory Locking in Postgres** -- Concurrent resolve requests for the same
  mention must not produce two canonical IDs; Postgres advisory locks provide
  per-entity mutual exclusion without a separate lock service.
  *Why advisory locks rather than transactions:* the operation spans multiple
  queries (lookup, insert-if-missing, return ID); a single transaction would
  hold locks too long under load; advisory locks are scoped to the logical
  operation.
- **Entity Lifecycle: Three Statuses** -- Provisional (unresolved), canonical
  (authority-anchored), merged (absorbed into another entity); transitions are
  one-way and logged.
  *Why immutable status transitions:* a merged entity that could be un-merged
  would invalidate every edge that referenced the survivor; immutability makes
  the provenance audit trail trustworthy.
- **Idempotency** -- All operations are safe to retry; ingestion pipelines
  fail and restart; an identity service that produces different results on retry
  corrupts the graph.
  *Why idempotency is non-negotiable:* distributed systems fail; the choice is
  between idempotent operations and a graph that requires manual repair after
  every failure.
- **Caching** -- Two layers: an LRU cache in the identity server keyed on
  `(mention, entity_type)` for resolved IDs; a long-TTL cache in the domain
  service for AO API responses.
  *Why two layers:* the identity server cache avoids redundant lookups within
  a run; the domain service cache avoids hitting external APIs for the same
  entity repeatedly across runs; `compute-confidence` is not cached because
  its inputs vary per call and the computation is cheap.

### Chapter 9: The Identity Service HTTP Interface

- **`POST /resolve`** -- Given (mention, entity_type), return canonical ID;
  the primary operation; runs the full lookup chain.
  *Why POST:* the operation has side effects (minting provisional IDs, updating
  the synonym table); GET would be misleading.
- **`POST /promote`** -- Elevate a provisional entity to canonical when evidence
  threshold is met; caller supplies the canonical ID to assign.
  *Why caller-supplied ID:* the domain service, not the identity server, knows
  which authority ID to use; the identity server records the transition.
- **`POST /merge`** -- Declare two entities the same; survivor selection picks
  the canonical record; provenance from both is preserved.
  *Why an explicit merge operation rather than automatic deduplication:* merges
  are irreversible; requiring an explicit call means a human or a high-confidence
  rule triggered it, not a fuzzy match that was close but wrong.
- **`GET /entity/{id}`** -- Retrieve full entity record including status, all
  known surface forms, provenance, and confidence.
- **`GET /schema`** -- Return the domain spec as JSON; the base server calls
  this at startup to load predicate vocabulary and type constraints.
  *Why served by the domain service, not the identity server:* the schema is
  domain knowledge; the identity server is domain-agnostic; the schema travels
  with the domain service.

---

## Part IV: The Domain Service

### Chapter 10: `domain_spec.py` as the Single Source of Truth

- **What the Domain Service Owns** -- The entity type enum, the predicate list
  with domain/range, the AO lookup logic, the synonym thresholds, the survivor
  selection rules, the confidence weight table; all domain-specific, none of it
  in the base server.
- **Python as the Spec Language** -- The domain spec is a Python module, not a
  config file; it can express logic (not just data), it is testable, and it
  round-trips to JSON for the `GET /schema` endpoint.
  *Why not YAML or JSON:* config files cannot express the validation logic that
  makes the spec useful; a Python module can define the enum, the Pydantic
  models, and the validation functions in one place.
- **The Holmes Domain Spec Written Out** -- Full `domain_spec.py` for the Holmes
  corpus: `EntityType` enum including `Moment` and `ConfidenceLevel` flagged
  provisional, all predicates with domain/range, the AO configuration pointing
  to the Baker Street Wiki.

### Chapter 11: The Domain Service HTTP Interface

- **`POST /resolve-authority`** -- Given (mention, entity_type), query the AO
  and return a canonical ID if found, or null if not.
  *Why the domain service owns this:* which AO to query, in what order, with
  what fallbacks is entirely domain knowledge; the base server has no opinion.
- **`POST /select-survivor`** -- Given two entity records, return the one that
  should survive a merge.
  *Why a POST with full records rather than just IDs:* the survivor selection
  rule may depend on evidence count, confidence, or source type -- fields that
  live on the record, not inferable from the ID alone.
- **`POST /compute-confidence`** -- Given a list of evidence records, return a
  composite confidence score.
  *Why the domain service computes this:* the weight table (how much to trust
  an eyewitness account vs. a newspaper report vs. Holmes's own deduction) is
  domain knowledge; the base server provides the aggregation call, the domain
  service provides the weights.
- **`GET /synonym-criteria`** -- Return the thresholds and rules the identity
  server should use when deciding whether two mentions are synonyms.
  *Why a GET:* this is configuration, not a stateful operation; it changes only
  when the domain spec changes; the identity server fetches it at startup.
- **`GET /schema`** -- Serve the full domain spec as JSON.
  *Why this belongs here:* the schema is part of the domain service's contract
  with the base server and with the graph linter; centralizing it here means
  one source of truth.

### Chapter 12: Validation and the Lifecycle

- **How a Proposed Triple Is Accepted or Rejected** -- Walk through the
  validation pipeline: entity type check, predicate vocabulary check,
  domain/range check, provenance completeness check; each gate and its rationale.
- **Type Constraints Across the Entity Lifecycle** -- Entity type is assigned
  at creation and immutable; merging is only permitted between entities of the
  same type; type mismatches surface at promotion time.
  *Why immutable types:* if an entity's type could change, every edge incident
  to it would need re-validation; immutability makes type checking a one-time
  cost at creation.
- **When the Ontology Changes** -- Deprecated predicates are flagged, not
  deleted; tightened constraints produce migration items; predicate renaming is
  deprecate-old plus introduce-new with an explicit migration script; the domain
  spec carries a version field.
  *Why deprecate rather than delete:* existing edges referencing a deleted
  predicate become uninterpretable; deprecation keeps the audit trail intact
  while signaling that new edges should not use the old predicate.

---

## Part V: Trustworthiness

### Chapter 13: Provenance as Architecture

- **Provenance Is Not Optional** -- In high-stakes domains, every claim must be
  traceable to its source; this is a structural requirement, not a feature.
- **What a Provenance Record Contains** -- Source document, passage locator,
  extraction method, confidence, timestamp; the full audit trail for any claim.
- **Confidence Is Computed, Not Assigned** -- Confidence derives from evidence
  quality (how strong is the source?) and evidence count (how many independent
  sources agree?); the domain service supplies the weight table; the base server
  aggregates; neither guesses.
- **Multi-Source Claims** -- The same relationship appearing in multiple
  independent sources is stronger than one appearing once; the identity server
  aggregates evidence and computes a defensible composite confidence.
- **Typed Provenance** -- Because predicates are finite and typed, provenance
  completeness is checkable: every edge of a known predicate type must carry a
  provenance record; the schema defines what "complete" means, so incompleteness
  is detectable.

### Chapter 14: Making Bad Ideas Inexpressible

- **Hilbert's Dream** -- Hilbert wanted a formal system where false or
  meaningless statements could not be constructed. Gödel showed this is
  impossible for mathematics in general. For a domain-constrained typed graph
  it is achievable: the finite predicate set is the boundary Hilbert wanted.
- **What Becomes Inexpressible** -- Type-layer violations (wrong entity type
  for a predicate's domain/range); identity-layer violations (edges to
  unresolvable IDs); provenance-layer violations (claims without a source);
  consistency-layer violations (contradictions without a conflict record).
- **The Functional Programming Analogy** -- ML, Haskell, and Rust enforce
  "make illegal states unrepresentable"; invariants live in the type system,
  not in runtime checks; a typed graph applies the same principle to assertions.
- **The Limits: Gödel's Revenge** -- The typed graph enforces structural
  well-formedness, not factual correctness; a well-typed, well-sourced edge
  can still be wrong; this is not a defect, it is the honest boundary of what
  formal structure can guarantee.

### Chapter 15: The Graph Linter

- **Two Enforcement Points** -- The insertion path enforces constraints at write
  time; the linter audits the graph independently, after the fact; Unix
  philosophy: do one thing well, compose with everything else; both roles are
  worth having.
- **What the Linter Checks** -- Predicate vocabulary violations, domain/range
  violations, missing provenance, unresolvable canonical IDs, unacknowledged
  contradictions; each check derived from the domain spec at runtime, not
  hardcoded; adding a predicate to the spec automatically extends lint coverage.
- **Violation Structure** -- Each violation is a typed, structured record:
  violation type, severity (ERROR / WARNING / INFO), affected edge or entity,
  human-readable message, suggested remediation; output is JSONL for piping
  into dashboards or CI.
- **The Linter in CI** -- An ingestion batch linted before it lands; violations
  above a severity threshold fail the batch; the linter is a compiler pass
  for the graph.
- **Conflict Records as First-Class Data** -- When the linter finds a
  contradiction, it does not reject the edge; it emits a conflict record;
  the graph is richer for containing the dispute; contradiction is information,
  not failure.

### Chapter 16: Bias, Limits, and Responsibility

- **What the Graph Cannot Know** -- Coverage gaps create false negatives;
  absence of evidence is not evidence of absence; the system cannot correct
  for what was never ingested.
- **Bias Encoded at Scale** -- The corpus determines what the graph knows;
  selection bias, language bias, and recency bias propagate into the graph
  and are amplified by confidence weighting; the builder is responsible for
  knowing this.
- **What Typed Structure Cannot Guarantee** -- Structural well-formedness is
  not factual correctness; a well-typed, well-sourced claim can still be wrong;
  the graph records disputes, it does not adjudicate them.
- **Capability Is Not Bounded by Intent** -- A system that encodes the
  architecture of expertise enables inferences its builders didn't anticipate;
  structure supports inference; inference doesn't respect intended use case
  boundaries.
- **The Builder's Responsibility** -- Honesty about coverage limits;
  infrastructure for verification; consideration of foreseeable misuse;
  trustworthiness is an ongoing commitment, not a one-time design choice.
- **Who Owns the Graph** -- Open versus proprietary carries consequences for
  the commons; GenBank (open, shaped a field) vs. contested clinical trial data;
  the governance question is worth answering before it is decided for you.

### Chapter 17: What This Makes Possible

- **The Three-Book Arc** -- *Knowledge Graphs from Unstructured Text* gets
  knowledge in; this book makes it trustworthy; *BFS-QL* gets it out to an LLM;
  the identity server and typed schema are the connective tissue.
- **Cross-Domain Reasoning** -- Shared canonical IDs let two graphs built from
  different sources compose automatically; the typed schema ensures the
  composition is structurally coherent.
- **Grounding LLM Inference** -- Typed, provenance-tracked claims from the graph
  rather than training-data recall; the difference in reliability is qualitative,
  not quantitative.
- **Hypothesis Generation** -- Traverse the graph to surface candidates that no
  single source asserts but that follow from combining multiple sources; the
  graph narrows the space of possibilities for human evaluation.
- **An Invitation** -- The epistemic commons was built over decades for human
  use; the typed graph makes it available to machines in a form that carries its
  own warrant. That is not a small thing.
