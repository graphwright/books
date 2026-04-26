# The Typed Graph -- Outline
## Naming, Knowing, and Trusting Machine Knowledge
### Graphwright Publications

---

## Foreword: A Manifesto for Machine Knowledge

*This foreword appears in all three volumes of the Graphwright series.*

- High-stakes machine reasoning --
  domains like law, medicine, buildings and bridges,
  when mistakes are made, lives and livelihoods are threatened
- When the cost of a hallucination is a misdiagnosis or a collapsed
  bridge, you can't accept "good enough" LLM results, you need the
  ability to explain its reasoning in terms a domain expert can
  verify and dispute
- A user needs to be able to ask "why that answer" and get back
  something trustworthy -- typed graphs with provenance make that
  possible
- We need "things not strings" -- make statements about real
  things in the world, don't just look for string similarity
- Identity, causality, consequential reasoning -- be able to
  reason about cause and effect, consequences, recognize when
  two mentions refer to the same thing
  
### RAG vs Graph-RAG

- Associating embeddings by cosine similarity is useful for
  quick google-style lookups which you'll confirm manually
  after the fact
- You don't get identity (this thing *is* that thing)
- You don't get cause-and-effect (this thing *caused* that thing)
- Graph-RAG isn't just better RAG, it's a different epistemic
  commitment

  - LLMs are the extraction and natural-language interface
    layer
  - The graph is the reasoning substrate

### RDF gets many things right

- RDF got the atoms right, left the chemistry uncontrolled

  - Triple as atomic unit of knowledge -- brilliant, keep this
  - URIs as IDs -- brilliant, keep this too
  - Querying (SPARQL) -- very good, want some version of this
  - OWL2 reasoning -- good direction, not far enough, not
    enough enforcement

- No entity types so little context about a thing other than
  OWL2 triples
- Predicates are unrestricted -> no category error detection
- Garbage in, garbage out

### Typed Graphs

- Fixed set (like an enum) of entity types
- Fixed set of predicates
- Each predicate has a "domain" (fixed set of allowed entity
  types for the subject) and "range" (fixed set of allowed
  entity types for the object)
- Easy detection of category errors

  - Assertion `aspirin treats BRCA1` is rejected because...
  - `treats` predicate has domain `[Drug]`, range `[Disease]`
  - `aspirin` is a `Drug` -> okay
  - `BRCA1` is a `Gene`, not a `Disease` -> violation

- Many (most?) entities in the typed graph have canonical IDs
  which enable seamless graph traversal (multi-hop reasoning)
  across sources

### Canonical IDs and Authoritative Ontologies

- Many domains have official ontologies (medicine has several,
  for diseases, genes, drugs, organisms...) -- known, respected,
  carefully curated over years/decades/centuries
- Authoritative ontologies (AOs) enable reasoning across sources
  by ensuring that mentions reference the same real-world thing
- AOs provide a way to assign official IDs to things
- AOs connect IDs to the knowledge that humanity has collected and
  curated over centuries
- Problems to solve: synonyms and deduplication, how to extract
  mentions from unstructured text, building and maintaining
  provenance

### What we win with typed graphs

- Causal chains become tractable

  - Each step is auditable
  - Errors can be localized
  - Not buried in a similarity score

- Provenance tracking enables appropriate caveats: three hops at
  0.9 confidence each gives you 0.73 -- you can show that math --
  a cosine similarity chain gives you nothing
- Reasoning is as easy as breadth-first search on a graph with
  canonical IDs where node identity is unambiguous across sources
- Uncertainty -- represented with numerical confidence score
- Source -- represented by linking a claim to the source paper

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

## Part I: The Problem of Identity

### Chapter 1: What Is Canonical Identity and Why Does It Matter?

- **The Same Thing, Many Names** -- One drug appears as "desmopressin", "DDAVP",
  "1-deamino-8-D-arginine vasopressin", and RxNorm:3251; without resolution,
  these are four unconnected nodes in a graph that should be one.
- **Identity Is Load-Bearing** -- Canonical entities with canonical IDs are what
  separate a useful graph from sophisticated extraction; everything else is in
  service of identity.
- **The Epistemic Commons** -- Authority identifiers (MeSH, RxNorm, HGNC,
  UniProt) are not just unique keys; they are pointers into accumulated
  community knowledge -- definitions, taxonomic placement, known relationships --
  built over decades. Anchoring to them means the graph inherits that epistemic
  structure.
- **A Located Fact** -- The difference between a fact and a located fact: one
  that can be reasoned about, connected across sources, and trusted because the
  community that defined it is known.
- **What the Identity Server Does** -- Canonical ID assignment, provisional
  entity management, synonym detection, merge decisions, and promotion; the
  service that answers "what is this thing, really?"
- **Not Tied to a Storage Shape** -- Canonical identity is a requirement of
  faithful data representation, not of any particular physical schema; the graph
  is the running example, but the argument applies equally to relational
  warehouses, document stores, and lakehouses.

### Chapter 2: The Scale of the Problem

- **Multiplicity at Corpus Scale** -- A single entity across hundreds of papers
  generates dozens of surface forms; manual deduplication does not scale.
- **Sources of Variation** -- Abbreviations, synonyms, misspellings, alternate
  nomenclatures, cross-language variants, and evolving terminology.
- **Why Simple String Matching Fails** -- Exact match misses synonyms; fuzzy
  match produces false positives; neither handles semantic equivalence.
- **The Lookup Chain** -- Multi-stage resolution (exact → fuzzy → embedding)
  balances cost, speed, and accuracy; each stage handles what the prior stage
  cannot.
- **Provisional Entities** -- Not all entities resolve immediately; the system
  must be functional before all identities are known; provisional status enables
  this without sacrificing graph integrity.

### Chapter 3: The Epistemic Commons

- **Authorities as Infrastructure** -- MeSH, HGNC, RxNorm, UniProt, ChEMBL,
  Wikidata: decades of community investment in shared identity; the identity
  server is a client of this infrastructure, not a replacement for it.
- **What You Inherit When You Anchor** -- Taxonomic position, known synonyms,
  relationships to adjacent concepts, community consensus on definition; the
  identifier carries this for free.
- **Cross-Domain Composition** -- When two graphs anchor to the same authorities,
  entities bridge automatically; this is the foundation of multi-graph reasoning
  (developed fully in *BFS-QL*, Part IV).
- **Domains Without Authorities** -- Not every domain has a MeSH; the identity
  server must degrade gracefully to embedding-based resolution when no authority
  exists.
- **The Governance Argument** -- Open authorities (MeSH, UniProt) vs. proprietary
  ones; the choice of authority is an ethical and practical decision, not just
  a technical one.
- **From Commons to Ontology** -- The epistemic commons is community agreement
  made explicit; the typed graph schema is that agreement made computational;
  the finite predicate set with domain and range constraints is the ontology
  instantiated as an engineering artifact.

---

## Part II: The Typed Graph

### Chapter 4: What a Typed Graph Is

- **Beyond the Triple** -- An untyped graph stores (subject, predicate, object)
  triples with no constraints; a typed graph declares a finite set of entity
  types and a finite vocabulary of predicates, each with a domain (the set of
  entity types that may appear as subject) and a range (the set that may appear
  as object).
- **The Ontology as Contract** -- The schema is not documentation; it is a
  machine-checkable contract that governs every edge in the graph; the
  distinction matters because a contract can be enforced and a document cannot.
- **PredicateSpec and EntityType** -- A concrete representation: entity types
  as an enum, predicates as frozen Pydantic models carrying domain, range,
  and optionally a negation pair and a functional flag; the domain spec is the
  single source of truth.
- **Where the Ontology Comes From** -- The schema is not invented by the
  engineer; it is derived from the epistemic commons; MeSH's category
  hierarchy, RxNorm's drug-disease relationships, HGNC's gene-protein
  associations all have implicit types; the ontology makes them explicit.
- **Finite vs. Open-World** -- The typed graph is a closed-world artifact:
  predicates outside the schema do not exist; this is the source of its
  expressive power and the key difference from RDF/OWL open-world assumptions.

### Chapter 5: The Domain Service and the Schema

- **What the Domain Provides** -- Authority lookup logic, synonym thresholds,
  survivor selection rules, evidence quality weights, and the ontology itself;
  all domain-specific, none of it in the base server.
- **Evidence Quality Weighting** -- Confidence scores computed from evidence type
  (RCT, meta-analysis, cohort, case report); the domain provides the weight
  table; the base server provides the aggregation primitive.
- **Authority Lookup** -- Which APIs to consult, in what order, with what
  fallbacks; the domain service owns this entirely.
- **Survivor Selection** -- When two provisional entities are merged, which
  record wins; domain rules vary (prefer authority ID over provisional, prefer
  more evidence, prefer more recent).
- **The Schema as a Runtime Artifact** -- The ontology ships as part of the
  domain service; the base identity server queries it at startup; predicate
  validation, type checking, and conflict detection are all driven by the
  schema at runtime, not hardcoded.
- **Implementing the Domain Service** -- A worked example in Python using FastAPI
  and Pydantic; the medlit biomedical domain as the reference implementation.

### Chapter 6: The Base Identity Server and Caching

- **Domain-Agnostic Core** -- Deduplication logic, the provisional/canonical/merged
  state machine, the lookup chain, idempotency guarantees, Postgres locking,
  pgvector similarity search; none of this is domain-specific.
- **The Plugin Contract** -- Four hooks the domain must implement: authority
  lookup, synonym criteria, survivor selection, confidence weighting; the base
  server calls these and does not care what they do.
- **Separation of Concerns** -- The base server owns the mechanics; the domain
  owns the semantics; neither bleeds into the other.
- **The Docker Image** -- The base server ships as a standalone Docker image with
  a stub domain service; swap in a real domain service for production; the
  identity server is a general-purpose microservice.
- **The HTTP Interface to the Domain Service** -- Five endpoints: `POST
  /resolve-authority`, `POST /select-survivor`, `POST /compute-confidence`,
  `GET /synonym-criteria`, `GET /schema`; the domain service can be implemented
  in any language.
- **Caching** -- The lookup chain makes multiple external API calls per entity;
  without caching, large-corpus ingestion is slow and expensive. Two layers:
  an LRU cache in the identity server keyed on `(mention, entity_type)`, and a
  long-TTL cache in the domain service for authority API responses. `compute-confidence`
  is not cached (cheap arithmetic, variable input). Identity server, domain
  service, and Postgres co-located on the same docker-compose network.

### Chapter 7: Entity Lifecycle

- **Three Statuses** -- Provisional (unresolved), canonical (authority-anchored),
  merged (absorbed into another entity); status rules govern all transitions.
- **Promotion** -- Provisional entities accumulate evidence; when a promotion
  threshold is met (configurable per domain), they become canonical.
- **Merging** -- Two entities determined to be the same; survivor selection
  produces one canonical record; provenance from both is preserved.
- **Provenance-Derived Entities** -- Papers, authors, and citations from document
  metadata are more reliable than extracted entities; they enter as canonical
  directly.
- **Idempotency** -- All operations must be safe to retry; mechanisms for resolve,
  promote, merge, and on_entity_added; ingestion pipelines fail and restart.
- **Type Constraints Across the Lifecycle** -- Entity type is assigned at
  creation and immutable; merging is only permitted between entities of the same
  type; type mismatches surface at promotion time, not at query time.
- **When the Ontology Changes** -- Deprecated predicates are flagged, not
  silently deleted; tightened domain/range constraints produce migration items
  distinguished by schema version from original errors; predicate renaming is
  deprecate-old plus introduce-new with an explicit migration script; the domain
  spec carries a version field so the linter can separate "was valid when
  written" from "valid now"; ontology evolution follows the same rule as
  everything else: make the state visible, not silent.

---

## Part III: Integration

### Chapter 8: Identity During Extraction

- **The Ingestion Pipeline's View** -- The pipeline calls the identity server as
  a black box: "here is a mention and an entity type, give me a canonical ID";
  the pipeline does not know or care about the lookup chain.
- **The Ingest Stage** -- After extraction, the ingest stage resolves each
  mention to a canonical ID; relationships are stored with canonical IDs, not
  raw mention strings; predicate type is validated against the schema at ingest
  time.
- **Handling Provisional Entities in the Pipeline** -- Provisional IDs are valid
  graph nodes; relationships referencing them are valid; promotion later does
  not require re-ingestion.
- **Vocabulary Pass and Identity** -- The optional vocabulary-building pass
  produces a shared terminology that can seed the identity server before
  per-document ingestion begins; reduces provisional entity count.
- **Failure and Recovery** -- What happens when the identity server is unavailable
  mid-run; checkpoint design for resumable ingestion.

### Chapter 9: Identity During Querying

- **`search_entities` and the Identity Server** -- BFS-QL's `search_entities`
  tool resolves a natural-language name to a canonical ID; this is an identity
  server operation exposed through the query layer.
- **Embedding-Based Search at Query Time** -- The identity server owns the
  embeddings; the query layer asks for a canonical ID given a string; the
  embedding model, vector dimensions, and distance metric are invisible to the
  caller.
- **Cross-Graph Composition** -- When two graphs share canonical authorities,
  an entity in one graph is the same node as the corresponding entity in the
  other; the identity server makes this automatic.
- **Query-Time Synonym Expansion** -- Given a canonical ID, the identity server
  can return all known surface forms; useful for building query interfaces that
  accept natural language.
- **Provenance at Query Time** -- The query layer can ask "show me evidence" for
  any claim; the identity server's provenance records are the answer.
- **Type-Aware Traversal** -- The BFS-QL compiler knows the range type of each
  predicate; it can predict what entity type it will land on before executing
  a hop, enabling static type-checking of queries and predicate-specific index
  use.

---

## Part IV: Trustworthiness

### Chapter 10: Provenance as Architecture

- **Provenance Is Not Optional** -- In high-stakes domains, every claim must be
  traceable to its source; this is not a feature, it is a constraint.
- **What Provenance Records** -- Paper ID, section type, paragraph index,
  extraction method, confidence, study type; the full audit trail for any claim.
- **Provenance-Derived Confidence** -- Confidence is computed from evidence
  quality, not manually assigned; objective, consistent, filterable, aligned
  with evidence-based medicine.
- **Multi-Source Claims** -- The same relationship appearing in multiple papers
  is stronger than one appearing once; the identity server aggregates evidence
  across sources and computes a defensible composite confidence.
- **Auditability** -- Every merge, every promotion, every confidence update is
  logged; the graph's epistemic state at any point in time can be reconstructed.
- **Typed Provenance** -- Because predicates are finite and typed, provenance
  can be a contract: every edge of a known predicate type carries a provenance
  record, enforced at the schema level; completeness is checkable because the
  schema defines what "complete" means.

### Chapter 11: Making Bad Ideas Inexpressible

- **Hilbert's Dream** -- David Hilbert hoped for a formal system in which false
  or meaningless statements could not be constructed -- where bad mathematics
  would be inexpressible, not merely discouraged. Gödel showed this was
  impossible for mathematics in general. For a domain-constrained typed graph,
  however, we can actually have it: the finite predicate set is the boundary
  Hilbert wanted.
- **What Becomes Inexpressible** -- A taxonomy of things the typed schema
  structurally refuses to represent:
  - *Type layer*: edges where subject or object entity type violates the
    predicate's domain or range; predicates outside the finite vocabulary
  - *Identity layer*: edges whose subject or object is an unresolvable
    canonical ID; claims about things that cannot be named
  - *Provenance layer*: assertions without a source; claims whose extraction
    method is undeclared; the undifferentiated provenance bag that untyped
    systems permit
  - *Consistency layer*: contradictory assertions that coexist without a
    conflict record; disagreement that is unacknowledged rather than resolved
- **The Functional Programming Analogy** -- Type systems in ML, Haskell, and
  Rust enforce "make illegal states unrepresentable": invariants live in the
  type system, not in runtime checks. A typed knowledge graph applies the same
  principle to assertions: "make unwarranted assertions unrepresentable." If
  the schema compiles, these particular things cannot go wrong.
- **What This Requires of the Ontology** -- Functional predicates (single-valued
  for a given subject), negation pairs (predicates that are logical opposites),
  and provenance completeness rules must be declared in the domain spec; the
  machinery is only as good as the ontology it enforces.
- **The Limits: Gödel's Revenge** -- The typed graph cannot enforce semantic
  correctness of the claims themselves -- only structural well-formedness. A
  well-typed edge can still be factually wrong. This is not a defect; it is
  the honest boundary of what formal structure can guarantee.

### Chapter 12: The Graph Linter

- **Linting as Explicit Epistemics** -- Unix philosophy: do one thing well,
  compose with everything else. The insertion path enforces schema constraints
  at write time; a complementary standalone linter audits the graph
  independently, after the fact. The two roles are separable and both are
  worth having.
- **What a Graph Linter Checks** -- Predicate vocabulary violations,
  domain/range violations, missing provenance, undeclared extraction method,
  unresolvable canonical IDs, unacknowledged contradictions; each check derived
  from the domain spec at runtime, not hardcoded; adding a predicate to the
  spec automatically adds lint coverage.
- **Violation Structure** -- Each violation is a typed, structured record:
  violation type, severity (ERROR / WARNING / INFO), affected edge or entity,
  human-readable message, suggested remediation. Output is JSONL so it pipes
  into dashboards, review queues, or CI.
- **Using a Graph Linter in CI** -- An ingestion batch linted before it lands;
  violations above a severity threshold fail the batch; the linter acts as a
  compiler pass that catches structural errors before they reach the graph.
- **The Ontology as the Rule Set** -- The linter has no hardcoded rules; the
  domain spec is the only source of truth. A worked sketch: the JSON
  serialization of a `PredicateSpec` and the lint rules it generates.
- **Conflict Records as First-Class Data** -- When contradictions are detected,
  the linter does not reject the edge; it emits a conflict record. The graph
  is richer for containing the dispute. Contradiction is information, not
  failure.

### Chapter 13: Bias, Limits, and Responsibility

- **What the Graph Cannot Know** -- Coverage gaps create false negatives;
  absence of evidence is not evidence of absence; the identity server cannot
  correct for what was never ingested.
- **Bias Encoded at Scale** -- The corpus determines what the graph knows;
  publication bias, language bias, and geographic bias propagate into the
  graph and are amplified by confidence weighting.
- **The Limits of Confidence Scores** -- Evidence quality weights are a model;
  a well-replicated observational finding may outweigh a single small RCT;
  the weights are a starting point, not the final word.
- **What Typed Structure Cannot Guarantee** -- Structural well-formedness is
  not factual correctness; a well-typed, well-sourced claim can still be wrong;
  the graph does not adjudicate scientific disputes, it records them.
- **The Builder's Responsibility** -- Honesty about coverage limits,
  infrastructure for verification, and consideration of foreseeable misuse;
  trustworthiness is an ongoing commitment, not a one-time design choice.
- **Credit, Priority, and Provenance** -- When machines surface connections,
  credit attribution and scientific priority depend on provenance tracking;
  technical choices about schema design have ethical implications for how
  credit flows and disputes are recorded.
- **Who Owns the Graph** -- Open versus proprietary carries consequences for
  the scientific commons; mirrors GenBank (open, shaped a field) vs. clinical
  trial data (contested); governance question worth thinking about before it's
  decided for you.
- **Capability Is Not Bounded by Intent** -- A system that encodes the
  architecture of expertise enables inferences its builders didn't anticipate;
  structure supports inference; inference doesn't respect intended use case
  boundaries.
- **Dual Use at Graph Scale** -- The same facts support both beneficial and
  harmful applications; responsible practice requires access control,
  provenance transparency, logging, and auditability.
- **The Epistemic Responsibility of the Builder** -- Builders owe honesty
  about what the system is and isn't; provenance and confidence infrastructure
  for verification; the builder is a stakeholder, not just an implementer.

### Chapter 14: What This Makes Possible

- **The Three-Book Arc** -- Book 1 (*Knowledge Graphs from Unstructured Text*)
  gets knowledge in; this book makes it trustworthy; Book 2 (*BFS-QL*) gets it
  out to an LLM; the identity server and typed schema are the connective tissue.
- **Cross-Domain Reasoning** -- Shared canonical IDs enable a graph built from
  biomedical literature to compose with a graph built from clinical trial data,
  a drug database, and a genomics resource; the typed schema ensures the
  composition is structurally coherent.
- **Democratization and Its Limits** -- Building remains resource-intensive, but
  the structural view the graph provides could be democratized; technology
  enables it, policy and incentive will decide whether it happens.
- **Grounding LLM Inference** -- Give the model typed, provenance-tracked claims
  from the graph rather than asking it to reason from training data; the
  difference in reliability is qualitative, not just quantitative.
- **Hypothesis Generation** -- Traverse the graph to surface candidates
  (drug-disease pairs, structural analogies) that no single paper asserts but
  that follow from combining multiple sources; the graph narrows the space of
  possibilities for human evaluation.
- **The Robot Scientist, Revisited** -- Adam and Eve were limited by the
  extraction bottleneck; that bottleneck is now broken; the typed graph with
  structural provenance is what makes the resulting knowledge trustworthy enough
  to reason over.
- **An Invitation** -- The epistemic commons -- MeSH, HGNC, RxNorm, UniProt --
  was built over decades for human use; the typed graph makes it available to
  machines in a form that carries its own warrant. That is not a small thing.

---

## Appendix A: Identity Server Specification

The complete specification for the base identity server and domain plugin
contract.

- **Abstract Interface** -- Python ABC defining `resolve`, `promote`,
  `find_synonyms`, `merge`, and `on_entity_added` with full docstrings and
  contracts.
- **Domain Plugin HTTP Contract** -- OpenAPI spec for the five domain service
  endpoints (adding `GET /schema`); request and response schemas in Pydantic.
- **Entity Status Rules** -- Complete state machine: provisional → canonical,
  provisional → merged, canonical → merged; invariants and transition guards.
- **Idempotency Contract** -- Safe-to-retry guarantees for each operation;
  mechanisms (advisory locks, upsert semantics, idempotency keys).
- **Postgres Schema** -- Tables for entities, synonyms, provenance, merge
  history, promotion log, and conflict records; index strategy for pgvector
  similarity search.
- **Caching Contract** -- What is cached, at which layer, with what TTL; what
  must not be cached and why.

## Appendix B: The Domain Spec Schema

The structure of a domain spec and how the typed graph machinery derives its
behavior from it.

- **EntityType Enum** -- How entity types are declared; the closed-world
  constraint; why an enum and not a string.
- **PredicateSpec** -- Fields: name, domain (frozenset of EntityType), range
  (frozenset of EntityType), description, is_functional, negation_of;
  annotated example from the medlit biomedical domain.
- **JSON Serialization** -- The wire format for the domain spec served at `GET
  /schema`; what the base identity server does with it at startup.
- **Deriving Lint Rules** -- How `kglint` generates its rule set from a domain
  spec at runtime; the mapping from PredicateSpec fields to ViolationType
  checks.
- **Conflict Record Schema** -- Fields: edge_id_a, edge_id_b, conflict_type
  (FUNCTIONAL / NEGATION_PAIR / CONFIDENCE_DIVERGENCE), resolved, resolution
  note; how conflict records are stored and queried.

## Appendix C: Reference Implementation Notes

Implementation guidance for the medlit biomedical domain service and
Postgres-backed identity server.

- **Postgres-Backed Identity Server** -- Locking strategies per operation,
  pgvector synonym detection, multi-replica deployment safety.
- **medlit Domain Service** -- FastAPI implementation of the five plugin
  endpoints; PubMed/MeSH/RxNorm/HGNC authority lookup; study type weight table;
  medlit domain spec as a worked example.
- **Authority Lookup Chain** -- Exact match against authority API, fuzzy match
  via rapidfuzz, embedding similarity via pgvector; fallback behavior when
  no authority exists.
- **Docker Compose Setup** -- Identity server, domain service, Postgres, Redis
  (authority cache) as a compose stack; environment variables, volume mounts,
  health checks.
- **Confidence Aggregation** -- Implementation of multi-source confidence
  computation; worked example with three papers of different study types.
