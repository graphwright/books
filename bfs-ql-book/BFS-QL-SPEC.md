# BFS-QL Language Specification

BFS-QL is a graph query protocol designed for LLM consumption. It exposes a
knowledge graph as four MCP tools with a simple, flat query format. The LLM
never writes SPARQL or Cypher. It traverses the graph by calling tools with
natural-language seeds and structured filters, and receives subgraphs shaped
for context-window efficiency.

---

## The Four Tools

### `describe_schema()`

Returns a human-readable description of the graph, available entity types and
predicates (where enumerable), and a recommended workflow telling the LLM how
to orient itself to this particular graph.

**Arguments:** none

**Returns:**

```json
{
  "graph_description": "A knowledge graph of biomedical literature...",
  "comprehensive": true,
  "entity_types": ["Disease", "Drug", "Gene", "Protein", "Symptom", "Publication"],
  "predicates": ["TREATS", "INHIBITS", "ENCODES", "ASSOCIATED_WITH", "CAUSES"],
  "next_steps": "Call describe_schema() first, then search_entities() to resolve names to IDs, then bfs_query() starting at max_hops=1. Use the entity_types and predicates lists above as valid filter values."
}
```

**Fields:**

| Field | Description |
|-------|-------------|
| `graph_description` | Human-readable summary of what this graph contains. |
| `comprehensive` | Boolean. `true` means `entity_types` and `predicates` are complete and exhaustive. `false` means the graph is too large or open-world to enumerate fully — treat the lists as a sample only. |
| `entity_types` | List of entity type strings valid for use in `bfs_query` `node_types`. May be empty if the backend cannot enumerate them. |
| `predicates` | List of predicate strings valid for use in `bfs_query` `predicates`. May be empty if the backend cannot enumerate them. |
| `next_steps` | Backend-authored natural language instructions for how an LLM should orient itself to this graph. Varies by graph size and nature. Always follow these instructions in preference to any generic default workflow. |

When `comprehensive` is `false`, the `next_steps` will typically
direct the LLM to skip straight to `search_entities` and a 1-hop `bfs_query`,
then use the `schema_summary` in the result to discover available types and
predicates. The backend knows its own data best and the workflow text reflects
that.

---

### `search_entities(query)`

Resolves a natural-language name or alias to one or more canonical entity IDs.
Always call this before `bfs_query` if you do not already have a canonical ID.

**Arguments:**

| Field   | Required | Description                              |
|---------|----------|------------------------------------------|
| `query` | Yes      | Name, alias, or partial name to look up  |

**Returns:** array of `EntityStub`

```json
[
  { "id": "MeSH:D003480", "label": "Cushing Syndrome", "entity_type": "Disease" },
  { "id": "MeSH:D047748", "label": "Cushing Disease",  "entity_type": "Disease" }
]
```

If the graph uses vector similarity for search, results are ranked by semantic
closeness to the query string. If it uses a full-text index, results are ranked
by text match score. Either way, inspect the results before choosing a seed ID
— common names are often ambiguous.

---

### `bfs_query(seeds, max_hops, node_types, predicates, topology_only)`

Performs a breadth-first search from one or more seed entities and returns the
resulting subgraph. Filters control the *detail level* of items in the
subgraph, not which items are included. Non-matching nodes and edges always
appear as lightweight stubs so the LLM sees an accurate picture of the graph's
topology.

**Arguments:**

| Field           | Required | Description |
|-----------------|----------|-------------|
| `seeds`         | Yes      | Array of one or more canonical entity IDs. All seeds are expanded simultaneously; the result is the union of their neighborhoods. |
| `max_hops`      | Yes      | Maximum graph distance from any seed. Values of 1–3 are typical; larger values may return very large subgraphs. |
| `node_types`    | No       | Array of entity type names. Matching nodes receive full metadata; non-matching nodes appear as stubs. Omit to receive full data on all nodes. |
| `predicates`    | No       | Array of predicate names. Matching edges receive full metadata including provenance; non-matching edges appear as stubs. Omit to receive full data on all edges. |
| `topology_only` | No       | Boolean (default false). When true, suppresses all metadata: every node is returned as a bare `{id, entity_type}` stub and every edge as a bare `{subject, predicate, object}` triple. Overrides `node_types` and `predicates`. Use this as the first query on a large or unfamiliar graph to survey structure cheaply before requesting metadata. |

**Query shape:**

```json
{
  "seeds": ["MeSH:D003480"],
  "max_hops": 2,
  "node_types": ["Drug", "Gene"],
  "predicates": ["TREATS", "INHIBITS"],
  "topology_only": false
}
```

**Returns:** `BfsResult` — see Response Format below. Always includes a
`schema_summary` field summarising the entity types and predicates actually
found in this subgraph, regardless of filters applied.

---

### `describe_entity(id)`

Retrieves full metadata for a single entity by canonical ID. Use this when
`bfs_query` returns a stub and you want the full record for that node.

**Arguments:**

| Field | Required | Description         |
|-------|----------|---------------------|
| `id`  | Yes      | Canonical entity ID |

**Returns:** full node metadata as a flat dict, same shape as a full node in
`bfs_query` results.

---

## Query Format

The BFS-QL query object is flat. Filters are top-level arrays, not nested
objects. This minimizes token overhead and reduces structural errors in
LLM-generated queries.

```json
{
  "seeds":         ["<entity_id>", ...],
  "max_hops":      <int, 1–5>,
  "node_types":    ["<type>", ...],
  "predicates":    ["<predicate>", ...],
  "topology_only": <bool, default false>
}
```

`node_types` and `predicates` are both optional. Omitting either means "return
full data for all nodes" or "return full data for all edges" respectively.
Omitting both is appropriate for small subgraphs or debugging but will produce
large responses on dense neighborhoods.

`topology_only=true` overrides both filters and returns the pure structural
skeleton with no metadata at all. Response sizes for a 2-hop traversal over
a moderately connected graph: ~110K characters with full metadata, ~57K with
provenance stripped, ~14K with `topology_only=true`. The recommended first
move on any large or unfamiliar graph is `topology_only=true` at `max_hops=2`,
followed by selective `describe_entity` calls on nodes of interest.

---

## Response Format

```json
{
  "seeds":      ["<entity_id>", ...],
  "max_hops":   2,
  "node_count": <int>,
  "edge_count": <int>,
  "nodes":      [...],
  "edges":      [...],
  "schema_summary": {
    "entity_types_found": ["Disease", "Drug", "Gene"],
    "predicates_found":   ["TREATS", "INHIBITS", "ASSOCIATED_WITH"]
  }
}
```

`schema_summary` reflects what was actually present in this subgraph, not the
full graph schema. It is always populated regardless of filters — even a
`topology_only` query includes it. For open-world backends (e.g. a SPARQL
endpoint) where `describe_schema` returns `comprehensive: false`, this is the
primary mechanism by which the LLM discovers valid `node_types` and `predicates`
values for follow-up queries: run a 1-hop `bfs_query` from a seed of interest
and read the `schema_summary` from the result.

### Full Node

A node whose `entity_type` matches `node_types` (or when no filter is
specified) includes all available metadata:

```json
{
  "id":           "PUB:PMC2386281",
  "entity_type":  "Publication",
  "title":        "The Diagnosis of Cushing's Syndrome",
  "canonical_id": "PMID:18493314",
  "year":         2008,
  "journal":      "Reviews in Endocrine and Metabolic Disorders",
  "authors":      ["Stewart PM"],
  "abstract_snippet": "..."
}
```

### Stub Node

A node that does not match `node_types` appears with identity only:

```json
{
  "id":          "PERSON:67890",
  "entity_type": "Person"
}
```

### Full Edge

An edge whose `predicate` matches `predicates` (or when no filter is specified)
includes provenance and metadata:

```json
{
  "subject":   "DRUG:rxnorm:41493",
  "predicate": "TREATS",
  "object":    "MeSH:D003480",
  "confidence": 0.91,
  "provenance": [
    {
      "source_doc":    "PMC2386281",
      "section":       "Results",
      "evidence":      "Ketoconazole significantly reduced urinary cortisol in all patients.",
      "method":        "llm_extraction",
      "evidence_type": "clinical_trial"
    }
  ]
}
```

### Stub Edge

An edge that does not match `predicates` appears with topology only:

```json
{
  "subject":   "DRUG:rxnorm:41493",
  "predicate": "INTERACTS_WITH",
  "object":    "DRUG:rxnorm:88014"
}
```

---

## Design Properties

**Topology is always complete.** Filters control the detail level of nodes and
edges, not which ones appear. A stub node is not a missing node. Omitting
non-matching items entirely would produce a misleading picture of the graph —
the LLM would miss connections it didn't know to ask about.

**Stubs enable targeted follow-up.** When a stub appears in a result, the LLM
can call `describe_entity(stub.id)` to retrieve full metadata for that node, or
issue a new `bfs_query` seeded at that node to expand its neighborhood. The stub
is a navigational handle, not a dead end.

**Context-window awareness.** Full provenance on a well-supported edge can be
long. A two-hop neighborhood of a well-connected node without filters would
dominate the context window. `node_types` and `predicates` give the LLM precise
control over where that cost is paid.

**Multi-seed queries express relational questions.** Passing two or more seeds
asks "what do these entities have in common?" The BFS expands from all seeds
simultaneously and returns the union of their neighborhoods. Nodes reachable
from multiple seeds appear once, making shared connections directly visible
without a separate intersection query.

---

## Prompting Considerations

### Orienting the LLM to an unfamiliar graph

Include the following in the system prompt or tool preamble:

> This MCP server exposes a knowledge graph via BFS-QL. Before constructing
> queries, call `describe_schema()` to learn the available entity types and
> predicates. If you do not have a canonical entity ID, call
> `search_entities(query)` first. Use `bfs_query` to traverse the graph and
> `describe_entity(id)` to retrieve full details for any stub node.

### Recommended session workflow

Always call `describe_schema()` first and follow its `next_steps`
instructions. The workflow text is backend-authored and reflects the actual
nature of the graph. Generic defaults follow, but the backend's instructions
take precedence.

**Default workflow for graphs with `comprehensive: true`:**

1. Call `describe_schema()` to learn entity types and predicates.
2. Call `search_entities(name)` to resolve names to canonical IDs. Inspect
   results carefully — common names are often ambiguous.
3. Call `bfs_query(seeds, max_hops, node_types, predicates)` using the
   canonical IDs from step 2. Start with `max_hops: 1` and expand if needed.
4. Call `describe_entity(id)` on any stub node that warrants closer inspection.

**Default workflow for graphs with `comprehensive: false` (large or open-world graphs):**

1. Call `describe_schema()` to read the `next_steps` and
   `graph_description`. Do not rely on `entity_types` or `predicates` being
   complete.
2. Call `search_entities(name)` to find a canonical ID for your starting point.
3. Call `bfs_query` with `max_hops: 1` and no filters (or `topology_only: true`
   for very large graphs). Read the `schema_summary` in the result — this is
   your working vocabulary of types and predicates for this neighborhood.
4. Use the types and predicates from `schema_summary` to issue focused follow-up
   queries with `node_types` and `predicates` filters.
5. Call `describe_entity(id)` on any stub node that warrants closer inspection.

### Controlling response size

- On a large or unfamiliar graph, start with `topology_only: true` and
  `max_hops: 2`. This returns the complete structural skeleton at minimum
  token cost. Survey the shape, identify what matters, then drill in.
- Start with `max_hops: 1` when using full metadata. Only increase if the
  neighborhood at one hop is insufficient to answer the question.
- Specify `node_types` and `predicates` when you know which parts of the
  subgraph are relevant. Unfiltered queries over well-connected nodes can
  return hundreds of items.
- For provenance-heavy questions (e.g. "how well-supported is this
  relationship?"), filter specifically to the predicate of interest so that
  full provenance is returned only where needed.

### Using multiple seeds

Pass multiple seeds when the question is relational:

```json
{
  "seeds":    ["MeSH:D003480", "MeSH:D049970"],
  "max_hops": 2,
  "node_types": ["Drug", "Gene"]
}
```

This retrieves drugs and genes connected to both entities within two hops,
surfacing shared mechanisms and co-treatments without a separate intersection
step.

### Schema injection vs. explicit discovery

Some BFS-QL servers inject valid `node_types` and `predicates` directly into
the `bfs_query` tool description at session start. When this is the case, the
LLM already knows the valid values and a `describe_schema()` call is optional.
For graphs with large schemas, or when the LLM needs to remind itself of
available types mid-session, call `describe_schema()` explicitly.

---

## Multi-Graph Sessions

A single LLM session can hold MCP connections to multiple BFS-QL servers
simultaneously. Each server exposes the same four tools; the LLM distinguishes
them by server name as configured in the MCP client.

A typical combination: one connection to an external linked-data resource such
as DBpedia (encyclopedic coverage, stable canonical IDs) and a second
connection to a kgraph-derived graph (domain-specific extractions, research
frontier, provenance-tracked relationships). The LLM can traverse both graphs
in the same conversation, using each for what it does best.

**Identity bridging.** When an entity in one graph shares a canonical ID with
an entity in another — for example, both graphs use MeSH terms for diseases or
HGNC symbols for genes — the LLM can bridge across them naturally: resolve a
name in one graph, use the canonical ID to look up the same entity in the
other. No special protocol support is required; shared canonical IDs are the
bridge.

When graphs use different ID schemes, identity bridging requires either a
manual mapping or a `search_entities` call in the second graph using the label
from the first. This is a limitation of the multi-graph approach: composability
is proportional to shared canonical identity. Graphs that both anchor to
established ontological authorities (MeSH, HGNC, RxNorm) compose naturally.
Graphs that mint their own IDs do not, without additional resolution work.

**Prompting for multi-graph sessions.** The system prompt should name both
servers and describe what each covers:

> You have two graph connections. `medlit-graph` contains extracted knowledge
> from recent biomedical literature, with provenance tracking back to source
> papers. `dbpedia` contains encyclopedic background knowledge across all
> domains. Both use MeSH terms for diseases and HGNC symbols for genes, so
> canonical IDs are shared. When researching a clinical question, use
> `medlit-graph` for recent findings and `dbpedia` for background context.

---

## Implementation Notes

The following are considerations for BFS-QL server implementors rather than
protocol users.

### Caching

Backends should be treated as read-only and static for caching purposes. The
BFS-QL server maintains an LRU cache keyed on `(backend_id, method, args)` at
the `GraphDbInterface` primitive level — not at the `bfs_query` level. This
means a repeated `edges_from` or `metadata_for_node` call within any BFS
traversal returns the cached result immediately with no round-trip to the
underlying store. All BFS-QL intelligence — traversal, stub/full filtering,
multi-seed union — benefits automatically from primitive-level caching.

Practical benefits: latency drops significantly for traversals that revisit
nodes (common in multi-hop BFS), and load on upstream endpoints is reduced —
important for public SPARQL endpoints that rate-limit automated traffic.

`entity_types()` and `predicates()` results should also be cached; these are
stable for the lifetime of a session and potentially across sessions.

### Schema Injection

At server startup or session initialization, the BFS-QL server may call
`db.entity_types()` and `db.predicates()` and inject the results into the
`bfs_query` tool description dynamically. FastMCP supports dynamic tool
descriptions. This is the preferred default for graphs with small schemas
(fewer than ~20 types and ~30 predicates). For larger schemas, omit injection
and rely on the `describe_schema()` tool.

### Backend Concurrency

The `GraphDbInterface` ABC makes no concurrency guarantees. Backends that issue
network calls (SPARQL, Postgres, Neo4j) are naturally I/O-bound and benefit
from async implementation. The BFS-QL engine should call primitive methods via
`asyncio` where the backend supports it, allowing concurrent `edges_from` /
`metadata_for_node` calls during BFS expansion.

### Context-Window Budget

Server implementations may optionally accept a `max_tokens` hint and truncate
or stub additional items when the estimated response size approaches the budget.
This is not part of the core protocol but is recommended for production
deployments against well-connected graphs where an unfiltered two-hop query
could return thousands of items.
