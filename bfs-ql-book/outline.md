# BFS-QL: A Graph Query Protocol for Language Models
## Book Outline — Graphwright Publications

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

The knowledge is in the graph. The LLM can't get to it. This is a book about
the missing interface.

*Knowledge Graphs from Unstructured Text* is about getting knowledge in. This
book is about getting knowledge out — specifically, out in a form a language
model can actually use. Readers who have an existing graph (a Wikidata endpoint,
a corporate triple store, a Neo4j instance) can start here. Readers building
from scratch should read that book first.

---

# Part I: The Interface Problem

## Chapter 1: Graphs Are Hard for Language Models

The promise of Graph RAG vs. the reality. LLMs that reason brilliantly over
retrieved prose fall apart when handed a graph API. SPARQL and Cypher are
human authorship tools — precise, expressive, and practically unusable by a
language model on anything non-trivial. The interface matters as much as the
graph itself. What a good interface looks like is not obvious, and this book
is the argument for one specific answer.

The context window as a scarce resource with a cost structure. The
transformer architecture (Vaswani et al., 2017) introduced the fundamental
constraint: attention is O(n²) in sequence length. Everything that follows —
prompt engineering, context extension research, retrieval strategies — flows
from that architectural fact. Doubling context roughly quadruples compute.
Every token has a cost paid by every other token. This is not a hardware
limitation that will eventually go away.

The "lost in the middle" finding (Liu et al., 2023): LLM performance on
retrieval tasks degrades sharply for information positioned in the middle of
long contexts. A large unfiltered graph dump doesn't just waste tokens — it
actively degrades reasoning. The design response isn't "give the model more
context" but "give the model the right context."

The memory hierarchy analogy. In the 1960s–70s, when RAM was scarce,
computer architects developed the cache hierarchy because you couldn't afford
to treat all memory equally. Denning's working set theory (1968) formalized
the question: what is the minimum set of pages a process needs in memory to
run efficiently? The context window is a working set problem. What does the
LLM actually need to reason about this graph? BFS-QL's stubs-not-omissions
design is a cache-locality-aware answer: topology always present, full data
only where the cost is justified.

## Chapter 2: Why Not SPARQL?

The natural first answer — let the LLM write the query — and why it fails
systematically. Hallucinated predicates, wrong URI prefixes, syntactically
valid but semantically broken queries. The failure modes are not random; they
follow from how LLMs work and how SPARQL is structured. The same argument
applies to Cypher. This is not a criticism of SPARQL or Cypher as query
languages — they are excellent for their intended purpose. The problem is
that LLMs are not their intended user.

Why RAG doesn't close the gap. RAG (Lewis et al., 2020) was the first serious
attempt to work around context constraints by being selective about what goes
in. The insight was right. But document retrieval for graphs hits a
fundamental mismatch: relevance in a graph is structural, not semantic. The
most important node for answering a question might be two hops away with no
direct semantic similarity to the query. Vector similarity retrieval finds
things that sound like the question. BFS finds things that are connected to
what you know. Conflating these two operations is where Graph RAG goes wrong
in practice.

## Chapter 3: The Right Abstraction

BFS as the natural primitive for LLM-driven graph exploration. Why traversal,
not querying, is the operation that fits how LLMs reason: start with something
you know, expand outward, ask follow-up questions. The two orthogonal concerns:
topology (what's in the subgraph) and presentation (what data each item
carries). Why stubs matter — omitting non-matching nodes produces a misleading
picture of the graph; lightweight placeholders preserve topology without
consuming context.

The RISC/CISC argument. Complex Instruction Set Computing gave programmers
many powerful operations; Reduced Instruction Set Computing gave them fewer,
simpler ones and let the compiler optimize. The RISC argument won in practice:
simpler instructions, consistently fast, composable, outperformed a large
surface area that was hard to reason about uniformly. BFS-QL's five-tool
surface is a RISC argument. SPARQL is CISC — powerful, expressive, and
practically unusable by a model generating it cold. Minimal surface area is
a principled design choice, not a limitation.

The working set framing applied to graph data. Denning's working set theory
asked: what is the minimum a process needs in memory to run efficiently? The
BFS-QL query model asks the same question about context: what is the minimum
subgraph the LLM needs to answer this question? Stubs are the answer to that
question for nodes outside the filter — present in topology, absent in cost.
The `node_types` and `predicates` filters are the mechanism for declaring,
precisely, where the cost is worth paying.

The `topology_only` mode takes this to its logical endpoint: request the
complete structural skeleton — all nodes as bare IDs and types, all edges as
bare subject/predicate/object triples — with no metadata at all. A 2-hop
neighborhood of 84 nodes and 99 edges fits in ~14,000 characters this way,
versus ~110,000 for the same traversal with full metadata. The recommended
first move on an unfamiliar graph is `topology_only=True`, survey the shape,
then call `describe_entity` selectively on the nodes that matter. Topology
in fast memory; metadata paged in on demand.

A worked example in full. The medlit demo graph (36 PubMed papers on Cushing
disease) queried for desmopressin: orient with `describe_schema`, resolve
"desmopressin" to RxNorm:3251, survey 2-hop topology (84 nodes, 99 edges, 14K
chars), identify three traversal axes (Cushing's disease, cortisol, ACTH),
drill into `DBPedia:Cushing's_disease` with `describe_entity`. The model
concludes that desmopressin is primarily a diagnostic agent -- used in
stimulation tests to distinguish pituitary from ectopic ACTH sources -- a
structural inference not available from any single paper's text.

Canonical IDs and the epistemic commons. BFS-QL uses canonical IDs as the
fundamental unit of navigation; they are not just unique keys but pointers
into shared epistemic infrastructure built by expert communities over
decades. The full argument — what you inherit when you anchor, why it matters
for reasoning and trust — is in the companion volume *The Identity Server*.
The consequence for this book: shared canonical IDs are the bridges between
graphs, developed in Part IV.

---

# Part II: The Protocol

## Chapter 4: Five Tools

Design rationale for `describe_schema`, `search_entities`, `bfs_query`,
`describe_entity`, and `intersect_subgraphs`. The minimal surface area principle:
enough tools to answer any question, few enough that the LLM doesn't have to
reason about which to use.

The natural session workflow: orient (`describe_schema`) → resolve
(`search_entities`) → traverse (`bfs_query`) → drill down (`describe_entity`).
`intersect_subgraphs` answers intersection questions directly -- nodes within k
hops of every seed simultaneously -- which the four-tool union-based traversal
cannot handle reliably. Each tool does one thing. Together they cover the full
space of graph exploration.

## Chapter 5: `describe_schema` — Self-Orienting Graphs

The tool that makes BFS-QL self-describing. An LLM connecting to an unknown
graph — a private Fuseki instance, a domain-specific SPARQL endpoint, a
kgraph-derived Postgres store — needs to know what entity types and predicates
exist before it can construct a meaningful query. `describe_schema` answers
that question in one call.

Two delivery modes: explicit tool call (the LLM calls `describe_schema` at
session start) and dynamic injection (the BFS-QL server injects valid
`node_types` and `predicates` directly into the `bfs_query` tool description
at session initialization). The tradeoff: injection is zero-cost for the LLM
but bloats tool descriptions for large schemas; explicit calling is better for
schemas too large to embed. Both modes are supported; the server chooses based
on schema size.

## Chapter 6: The Query Model

Seeds, hops, `node_types`, `predicates`, `topology_only`. The flattened format
and why it matters — fewer nesting levels, fewer tokens, less for the model to
get wrong. Multi-seed queries as relational questions: "what do these two
entities have in common?" expressed in the same structure as a single-seed
query. Context-window awareness as a first-class design constraint: full
provenance and metadata are returned only where requested, so a two-hop
neighborhood of a well-connected node does not flood the context.

The `topology_only` parameter as the strict working-set mode: suppress all
metadata, return pure structural skeleton. Response size comparison:
~110K chars (full metadata) → ~57K (provenance stripped) → ~14K
(`topology_only`). The recommended query progression: topology survey first,
selective `describe_entity` calls second, targeted re-query with `node_types`
and `predicates` filters third.

## Chapter 7: MCP as the Delivery Mechanism

Why MCP is the right transport. The paste-a-URL workflow: provision an
endpoint, get an MCP link, paste it into Claude or Cursor, start querying.
What the protocol contract actually is — five tools with well-defined
signatures — and why it is general enough to span DBpedia and a private
hospital knowledge graph without the LLM knowing or caring about the
difference. MCP as an active contract between the graph and the model, not a
passive data pipe.

---

# Part III: Building a Backend

## Chapter 8: The GraphDbInterface ABC

Eight methods. Why the interface is deliberately primitive — basic graph
navigation only, with all traversal intelligence in the BFS-QL server. The
full interface:

- `search_entities(query)` → name/alias resolution
- `edges_from(entity_id)` → outgoing edges
- `edges_to(entity_id)` → incoming edges
- `get_node(entity_id)` → node identity and type
- `metadata_for_node(entity_id)` → full node metadata
- `metadata_for_edge(edge)` → full edge metadata including provenance
- `entity_types()` → list of valid node type names
- `predicates()` → list of valid predicate names

The caching layer (`CachedGraphDb`) wraps any backend transparently — backends
don't implement caching themselves. The cache operates at the primitive level
so all BFS-QL intelligence benefits automatically.

## Chapter 9: The SPARQL Backend

Connecting BFS-QL to any SPARQL 1.1 endpoint. URI normalization, prefix
mapping, `SELECT DISTINCT` queries for `entity_types` and `predicates`. The
public endpoints: DBpedia, Wikidata, UniProt, ChEMBL. Schema discovery and the
seed resolver — probing the endpoint to build the name-to-URI mapping that
makes `search_entities` work. Handling the variance across SPARQL
implementations (Fuseki, Virtuoso, GraphDB, Stardog, Neptune).

## Chapter 10: The Postgres/pgvector Backend

The natural backend for kgraph-derived graphs. `search_entities` via vector
similarity: embed the query string, run `ORDER BY embedding <=> $1 LIMIT k`
with cosine distance. Embedding model consistency between ingest and query time
— why this must be explicit metadata, not convention. `entity_types` and
`predicates` as cheap `SELECT DISTINCT` queries over the entities and
relationships tables. This backend is the bridge between the two books: kgraph
writes, BFS-QL reads.

## Chapter 11: The Neo4j Backend

Property graphs vs. RDF stores: what the distinction means for the interface.
`edges_from` and `edges_to` as natural Cypher traversals (`MATCH (n)-[r]->(m)`).
`search_entities` via Neo4j full-text index — the index must exist, unlike the
Postgres vector fallback. `entity_types` from node labels, `predicates` from
relationship types. The mapping initialization requirement: which node labels
correspond to entity types, which relationship types correspond to predicates
in the BFS-QL model.

## Chapter 12: Writing Your Own Backend

The eight-method contract as a complete specification. What "correct" means for
each method. A worked example: a JSON-LD REST API as a backend. What you get
for free once the eight methods are implemented — the full BFS-QL query
semantics including `describe_schema`, `bfs_query`, stub/full filtering,
multi-seed union, and LRU caching. The bar for a new backend is low; the
payoff is immediate.

---

# Part IV: The Bigger Picture

Every knowledge graph that uses canonical IDs correctly is automatically
composable with every other one that does the same — an emergent property of
anchoring to shared authorities. The companion volumes argue for canonical
identity as a quality concern (*Knowledge Graphs from Unstructured Text*) and
develop the full architecture for achieving it (*The Identity Server*). This
part is where that investment pays off: the LLM is the reasoner, BFS-QL is the
interface, and shared canonical IDs are the bridges between graphs.

## Chapter 13: Composing Graphs

Multiple MCP connections in a single LLM session. kgraph + DBpedia together:
the extracted research frontier alongside the encyclopedic backbone. What the
LLM sees — two sets of five tools, identically structured, differentiated only
by the server name — and how it navigates across them.

Identity bridging: when an entity in one graph shares a canonical ID with an
entity in another, the LLM can traverse the boundary without any special
protocol support. The shared ID is the bridge. When graphs use different ID
schemes, bridging requires either a manual mapping or a `search_entities` call
in the second graph using the label from the first. Composability is
proportional to shared canonical identity. This is not a limitation to work
around — it is an argument for getting canonical identity right from the start,
which the companion volume makes at length. Here, that argument pays off.

## Chapter 14: The Server Is Not the Point

BFS-QL as an active contract, not a passive data pipe. The MCP server is
infrastructure; the reasoning happens in the LLM. What this means for how you
think about the tool interface: it should be minimal, predictable, and easy to
describe. The serving layer exists to make the graph accessible; the graph is
the point. Assessing whether the graph is worth serving — whether extraction,
deduplication, and identity resolution are working correctly — is the job of
the diagnostic tools covered in *Knowledge Graphs from Unstructured Text*,
Chapter 9.

## Chapter 15: Open Source and the SaaS Layer

What the library gives you: a local, single-tenant MCP server against any
graph you control. What the hosted service adds: provisioning, multi-tenancy,
schema discovery for unknown endpoints, managed caching, private endpoint
support, uptime, and query accounting. The Elastic/MongoDB playbook: open
source the library, sell the managed service. Who self-hosts (developers,
researchers, organizations with existing infrastructure) and who doesn't
(everyone else). Why open source is the right call for the library — community
backends, credibility with skeptical technical audiences, the kgraph book as a
natural referral path.

## Chapter 16: What Comes Next

Multi-graph federation with shared identity resolution. Schema-aware query
optimization — using `entity_types` and `predicates` to prune BFS traversal
before it happens. Richer traversal primitives as LLM context windows grow and
models get better at structured reasoning. The interface contract as the stable
layer: backends and LLMs will both evolve; the eight-method ABC and five-tool
MCP interface are designed to remain stable as they do. What would have to
change about BFS-QL for it to become inadequate — and what that tells you
about the design choices made here.

---

## Appendix A: BFS-QL Reference

The complete query format, response format, and LLM prompt template. Migrated
and updated from *Knowledge Graphs from Unstructured Text* Appendix A, with the
flattened query format (`node_types` and `predicates` as top-level arrays) and
the addition of `describe_schema`.

## Appendix B: Technical Background

Short notes on the technical concepts this book's argument depends on, for
readers who want the foundation without tracking down the original papers.

**Quadratic attention cost.** The transformer architecture (Vaswani et al.,
2017) computes attention between every pair of tokens in the input sequence.
The cost is O(n²) in sequence length: doubling the context roughly quadruples
the compute. This is not a hardware limitation or an implementation detail —
it is structural to how self-attention works. Every token you put in the
context window imposes a cost on every other token. Longer contexts are not
just more expensive in proportion; they are more expensive per token. This is
why context-window efficiency is a design constraint rather than a
performance optimization.

**The working set.** Denning (1968) formalized the observation that a running
process does not need all of its memory simultaneously — it needs the subset
currently active in its computation, the "working set." Cache hierarchies are
designed around this: keep the working set in fast memory, page everything
else to slower storage. The analogy to LLM context is direct: the context
window is fast memory, expensive per byte, and the right design question is
not "how much can we fit?" but "what does the model actually need right now?"
BFS-QL's stub/full distinction is a working-set-aware answer to that question.

---

## Relationship to *Knowledge Graphs from Unstructured Text*

That book is about building the graph. This book is about serving it. The
`KGraphPostgresBackend` (Chapter 10) is the coupling point: kgraph writes
embeddings and entity records; BFS-QL reads them through the eight-method
interface. The two books can be read independently. Read together, in order,
they cover the full pipeline from raw text to a language model that can reason
over what that text contained.
