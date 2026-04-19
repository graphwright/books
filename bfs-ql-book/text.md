---
title: "BFS-QL: A Graph Query Protocol for Language Models"
author: "Graphwright Publications"
lang: en-US
---

## Foreword: A Manifesto for Machine Knowledge

`\markboth{Foreword}{Foreword}`{=latex}

*This foreword appears in all three volumes of the Graphwright series.*

We are now in an age of machine reasoning, and some of this reasoning is done
in high-stakes domains: medicine, law, engineering, spaceflight. Lives and
livelihoods can be affected by incorrect conclusions or decisions. The cost of
error is real and significant. LLMs are here, they are staying, and there is no
turning back the clock.

As we all know, LLMs have weaknesses. Their mastery of language syntax is
astonishing, but they don't understand "this refers to that," or "these two
things are the same." They have no persistent notion of identity. They do not
inhabit a world of things connected by relationships. They do not track logical
consequence from one step to the next.

They cannot reason across multiple causal steps because they cannot reliably
reason across a single causal step. They do not know what things *are* or how
they *behave*, only how they are *talked about*.

And so we build RAG (retrieval-augmented generation) systems, hoping to improve
the situation. We improve the LLM's focus on material that is more relevant,
more similar, better connected to sources of information, and it helps.

But we are still dealing with strings, not things.

We still cannot say "this refers to that," or "these two mentions refer to the
same entity." We still cannot follow a chain of causality or enforce a sequence
of logical steps. We retrieve passages, but we do not operate on meaning.

If RAG doesn't close the gap, what would?

- **Identity -- what are we talking about?**
  - Canonical IDs -- identifiers anchored in curated human knowledge (think Wikipedia)
  - Authoritative ontologies -- shared bodies of reference (think dictionaries, taxonomies)
  - Deduplication across sources -- recognizing that the same thing may be named
    in different ways ("tumor" vs "neoplasm")
  - A fixed set of entity types

- **Type -- which relationships are meaningful?**
  - A fixed set of predicates
  - Domain and range for each predicate -- constraints on which kinds of things
    can be related, so we do not assert things like "aspirin inhibits New York"
  - Structural validity -- a claim is valid if it is well-formed with respect to
    the graph's type system, independent of whether it is true or false

- **Provenance -- where did this claim come from?**
  - Source traceability
  - Evidence aggregation
  - Confidence grounded in origin

A system cannot reason reliably about the world unless it represents that world
with stable identities, constrained relationships, and explicit evidence.

Machine reasoning requires a data model, not just a model.

### The Typed Graph

When we build a knowledge graph where we

- fix the set of entity types and the set of predicates
- establish domain and range constraints for each predicate
- require that entities be assigned canonical IDs whenever possible
- preserve provenance information for all relationships

we are no longer dealing with strings, but with a structured representation of
the world. This is what we call a *typed graph*\index{typed graph}.

A typed graph does not guarantee that its conclusions are true. It guarantees
something more fundamental: that its claims are well-formed, grounded in
identifiable entities, and traceable to their sources.

Large classes of nonsense and hallucination are not corrected -- they are never
admitted into the system at all. Category errors are rejected. Ambiguous
references are resolved or made explicit. Unsupported claims are visible as such.

The result is a system whose outputs may still be wrong, but are always
inspectable, reproducible, and subject to correction.

That is the minimum standard for reasoning in high-stakes domains.

```
Unstructured Text
       |
       v
  Extraction (LLM)
       |
       v
  Mentions (strings)
       |
       v
  Identity Resolution
  -- canonical IDs
  -- deduplication
       |
       v
  Typed Graph
  -- entity types
  -- predicates
  -- domain/range
  -- provenance
       |
       v
  Queries / Traversals
       |
       v
  Machine Reasoning
  -- multi-step
  -- composable
  -- inspectable
```

---

## Preface

The knowledge is in the graph. The LLM can't get to it.

That is the problem this book solves. Structured knowledge graphs --
DBpedia, Wikidata, UniProt, domain-specific SPARQL endpoints, internal
Neo4j instances -- contain enormous amounts of curated, queryable knowledge.
Almost none of it is accessible to a language model in practice, because
the interfaces that exist were built for human authors, not machine reasoners.
SPARQL and Cypher are expressive and precise. They are also, for an LLM
trying to answer a question in real time, practically unusable on anything
non-trivial. The hallucinated predicates, wrong URI prefixes, and
syntactically valid but semantically broken queries are not bugs to be fixed.
They follow directly from how language models work and how those query
languages are structured. The interface is the problem.

This book is about the missing interface.


*Knowledge Graphs from Unstructured Text* is about getting knowledge in --
extracting entities, relationships, and provenance from raw documents and
assembling them into a queryable graph. This book is about getting knowledge
out, specifically, out in a form a language model can actually use. Readers
who have an existing graph -- a Wikidata endpoint, a corporate triple store,
a Neo4j instance, a kgraph-derived Postgres database -- can start here.
Readers building from scratch should read that book first.

The coupling point between the two books is a single Python class:
`KGraphPostgresBackend`. kgraph writes; BFS-QL reads. Together they cover
the full pipeline from raw text to a language model that can reason over
what that text contained.


There is a larger argument in this book that deserves to be stated upfront,
because it is easy to miss while working through the protocol details.

The canonical identifier authorities -- MeSH for diseases, RxNorm for drugs,
UniProt for proteins, HGNC for genes -- have existed for decades. They were
designed as identity resolution tools: a way for different databases,
research groups, and institutions to refer to the same entity without
ambiguity. They do that job well.

What nobody designed them for, and what this book argues they have quietly
become, is the interoperability layer for LLM reasoning across knowledge
sources. When two graphs both anchor their disease entities to MeSH terms,
an LLM holding connections to both graphs can traverse the boundary between
them without any special protocol support. The shared canonical ID is the
bridge. It was always the bridge. It just didn't matter until language models
needed to cross it.

This means every knowledge graph that uses canonical IDs correctly is
automatically composable with every other one that does the same. The
companion volume argues for canonical identity as a quality and provenance
concern -- get it right or your graph will be inconsistent and hard to
maintain. That argument is correct as far as it goes. But it understates the
stakes. Canonical identity is also a composition argument. Graphs that anchor
to established ontological authorities compose naturally with each other and
with the open linked-data ecosystem. Graphs that mint their own IDs are
islands.

The LLM is the reasoner. BFS-QL is the interface. Shared canonical IDs are
the bridges between graphs. All three pieces are available right now.


This book is organized in four parts. Part I makes the case that the
interface problem is real and that the natural first answers -- let the LLM
write SPARQL, wrap the graph in a document retriever -- do not solve it. Part
II specifies the BFS-QL protocol: six MCP tools, a flat query format, and
the design decisions behind them. Part III shows how to build a backend,
with worked implementations for SPARQL endpoints, Postgres/pgvector, and
Neo4j. Part IV zooms out to graph composition, the SaaS layer, and what
comes next.

The appendix contains the complete BFS-QL reference -- query format, response
format, and LLM prompt templates -- suitable for copying directly into
implementations.

# Part I: The Interface Problem

## Chapter 1: Graphs Are Hard for Language Models

`\chaptermark{Graphs Are Hard for Language Models}`{=latex}

In the summer of 2023, Microsoft Research published a paper called "From
Local to Global: A Graph RAG Approach to Query-Focused Summarization."
[@edge2024graphrag] The timing was perfect. The field had spent two years
watching retrieval-augmented generation -- RAG -- mature from an interesting
idea into production infrastructure, and the obvious next question was already
in the air: if retrieving text passages helps, what about retrieving structured
knowledge? A graph, after all, knows things that a pile of documents doesn't.
It knows what is connected to what. It knows the type of every connection. It
knows that two entities mentioned in separate papers are the same entity, and
it knows how they relate. Graph RAG promised to bring all of that to bear on
LLM reasoning.

The paper was well-executed and the results were real. Community indexes built
from document corpora outperformed naive RAG on certain kinds of global,
thematic questions. Developers read it and started building.

What happened next was instructive. The demos worked. The production
deployments were harder. Teams connecting LLMs to real graphs -- not
community indexes built for the purpose, but existing SPARQL endpoints,
corporate Neo4j instances, Wikidata, domain-specific triple stores -- ran
into a consistent set of problems that the paper hadn't addressed and that no
amount of prompt engineering reliably fixed. The models wrote queries that
were syntactically plausible but semantically broken. They hallucinated
predicate names. They got URI prefixes wrong. They produced SPARQL that
parsed but returned nothing, or returned the wrong thing, or timed out
against endpoints that weren't designed for the query shapes an LLM tends to
generate. The knowledge was in the graph. The LLM still couldn't reliably
get to it.

This chapter is about why. The problems teams encountered were not random,
and they were not going to be fixed by better prompting or a smarter model.
They followed from something more fundamental: the mismatch between how
graph query languages are structured and how language models actually work.
Understanding that mismatch is the first step toward designing around it.

### The Transformer and the Context Window\index{context window}\index{transformer architecture}

To understand why the interface problem is hard, it helps to understand one
architectural fact about the models at the center of it.

In 2017, a team at Google Brain published "Attention Is All You Need,"
[@vaswani2017attention] introducing the transformer architecture that
underlies every large language model in use today. The paper was not received
as a landmark at the time -- it was one of several strong results at that
year's NeurIPS, and its title, chosen with deliberate provocation, was
partly a bet that turned out to be right. Within a few years the
transformer had displaced essentially every competing architecture for
sequence modeling. The bet paid off.

The core mechanism is self-attention: every token in the input sequence
attends to every other token, producing a weighted representation of the
full context. This is what gives transformers their remarkable ability to
reason over long-range dependencies -- the token at position 500 can
directly influence the interpretation of the token at position 3, with no
information loss from distance. Previous architectures had struggled with
exactly this; the transformer solved it cleanly.

The cost is quadratic.\index{context window!quadratic cost} Self-attention
over a sequence of n tokens requires computing n² attention weights. Double
the sequence length and you quadruply the compute. This was understood from
the beginning and accepted as a reasonable tradeoff -- in 2017, nobody was
thinking about context windows of 100,000 tokens. The sequences being
modeled were sentences and short paragraphs. The quadratic cost was
manageable.

By 2023, context windows had grown from hundreds of tokens to tens of
thousands, and the quadratic cost had become a central engineering concern.
Researchers developed linear attention approximations, sparse attention
patterns, and sliding window schemes to push the boundary further. Context
windows continued to grow. But the fundamental constraint didn't go away --
it got managed, not eliminated. Every token in the context window still
imposes a cost on every other token. Longer contexts are not just more
expensive in proportion; they are more expensive per token. This is not a
hardware limitation that will eventually be engineered away. It is structural
to how self-attention works.

The practical consequence for graph querying is direct. A knowledge graph
neighborhood -- the entities and relationships within two or three hops of
a seed node -- can easily contain hundreds of nodes and thousands of edges.
Serializing that neighborhood naively and stuffing it into the context
window is expensive, and the expense compounds: a larger context costs more
to process and, it turns out, reasons less reliably over its contents.

### Lost in the Middle\index{lost in the middle}

In 2023, a team at Stanford published an empirical study with a title that
became a shorthand for a problem the field had been observing anecdotally:
"Lost in the Middle: How Language Models Use Long Contexts."
[@liu2023lost] The finding was stark. LLM performance on tasks that required
retrieving specific information from a long context degraded sharply when
that information was positioned in the middle of the context window. Models
were good at using information near the beginning and near the end. The
middle was a dead zone.

This was not a minor effect. On some tasks, performance at the middle of a
long context was barely better than chance, while performance at the
boundaries remained strong. The effect was consistent across model families
and context lengths.

The implication for graph querying is that a large, unfiltered graph dump in
the context does not just waste tokens -- it actively degrades reasoning. An
LLM handed a serialized subgraph of three hundred nodes will not reliably
find the relevant dozen. The relevant nodes, wherever they happen to fall in
the serialization, are just as likely to land in the dead zone as not. Giving
the model more context is not the answer. Giving it the right context is.

### The Memory Hierarchy Analogy\index{memory hierarchy}\index{working set}

Computer architects confronted a version of this problem sixty years ago.

In the 1960s, RAM was expensive and scarce. The gap between the speed of the
processor and the speed of available memory was already large and growing.
The naive approach -- treat all memory equally, fetch whatever you need when
you need it -- didn't work at scale. Programs needed more memory than could
be kept fast, and fetching from slow storage on every access made the
processor sit idle.

The solution was the cache hierarchy: a small amount of very fast memory
close to the processor, a larger amount of slower memory behind it, and
backing storage behind that. The key insight was that programs don't access
memory randomly -- they have locality. The data a program needs right now
is probably near the data it needed a moment ago. Keep the working set in
fast memory, page everything else out, and performance improves
dramatically.

Peter Denning formalized this in 1968 with working set theory.
[@denning1968working]\index{Denning, Peter} The working set of a process at
any moment is the set of memory pages it has accessed recently -- the minimum
it needs in fast memory to run efficiently. The question cache architects
asked was not "how much memory can we provide?" but "what does this process
actually need right now?"

The analogy to LLM context is exact. The context window is fast memory --
expensive per token, finite, and the place where reasoning actually happens.
Backing storage is the graph: vast, slow to query, and mostly irrelevant to
any given question. The design question is not "how much of the graph can we
fit in context?" but "what does the model actually need right now to answer
this question?"

BFS-QL's answer, developed in detail in Chapter 3, is a working-set-aware
data structure: topology always present so the model can navigate, full
metadata only where the cost is justified. The context window stays
manageable. The reasoning stays accurate. The graph stays accessible.

### Why the Interface Is the Problem\index{interface design}

Returning to the teams that ran into trouble with production Graph RAG
deployments: the failure mode wasn't that their graphs were bad, or that
their models were too weak, or that knowledge graphs are fundamentally
unsuitable for LLM reasoning. The failure mode was the interface. They were
asking language models to use tools designed for human authors, under
constraints those tools were never designed to respect.

SPARQL\index{SPARQL} is a powerful and well-designed query language. It was
built to let human experts express precise, complex queries against RDF
graphs. It rewards deep familiarity with the schema, careful attention to
prefix namespaces, and an understanding of how the underlying store evaluates
queries. These are things human experts acquire over time. They are not
things a language model can reliably produce on demand, cold, against an
unfamiliar graph, in the middle of a conversation.

Cypher\index{Cypher} has similar properties for property graphs. Expressive,
powerful, designed for human authors.

The failure modes -- hallucinated predicates, wrong prefixes, syntactically
valid but semantically empty queries -- are not bugs that better prompting
fixes. They are predictable consequences of asking a model to generate a
precise formal language it has seen only in training, against a schema it
doesn't know, without feedback. The interface is not designed for this use
case.

The rest of Part I examines the natural alternatives and why they fall short.
Chapter 2 takes SPARQL and RAG in turn. Chapter 3 proposes a different
starting point -- one that fits how language models actually reason, respects
the context window as a constrained resource, and makes the graph accessible
without asking the model to be something it isn't.

## Chapter 2: Why Not SPARQL?

`\chaptermark{Why Not SPARQL?}`{=latex}

In a 2001 article in *Scientific American*, Tim Berners-Lee\index{Berners-Lee, Tim}
described a vision he called the Semantic Web.\index{Semantic Web} The web
he had built was for humans -- pages of text, navigable by people who could
read and interpret them. The Semantic Web would be different: structured,
machine-readable, traversable by software agents that could understand what
they were reading. An agent looking for a drug interaction wouldn't fetch a
page and hope the answer was in the prose. It would issue a query, receive
a structured response, follow links to related data, and assemble an answer
from explicit, typed facts. The knowledge would be in the graph. The agent
would get to it.

The vision failed, for reasons the companion volume examines at length. But
the part worth noting here is what the agents were supposed to do: write
queries. SPARQL -- the query language that emerged from the Semantic Web
effort -- was designed with exactly this use case in mind. Expressive,
precise, composable. Everything an intelligent agent would need.

Twenty years later, intelligent agents arrived. They were language models,
not the rule-based reasoners Berners-Lee had imagined, and they turned out
to be very bad at writing SPARQL. The vision was right about the destination.
It was wrong about what the agent would look like and what interface it would
need.

### How LLMs Generate Text\index{language model!text generation}

To understand why SPARQL generation fails systematically, it helps to
understand what an LLM is actually doing when it writes a query.

A language model generates text token by token, each token sampled from a
probability distribution conditioned on everything that came before. The
model has no symbolic reasoner, no query planner, no schema validator. It
has statistical patterns absorbed from its training corpus -- including
patterns from SPARQL queries, Cypher queries, and documentation about both.
When asked to write a query, it produces text that *looks like* a query,
following the patterns it has seen. Most of the time, the surface form is
correct. The query parses.

What the model cannot do is verify. It cannot check that a predicate name
it has generated actually exists in the target schema. It cannot confirm
that a URI prefix is valid for this particular endpoint. It cannot know
whether the query it has written will return results, return the wrong
results, or time out. It generates plausible text and stops. Verification
is not part of the architecture.

This produces a characteristic failure pattern. The queries look right.
They often parse. They frequently don't work.

### The Failure Modes\index{SPARQL!failure modes}

**Hallucinated predicates.**\index{hallucinated predicates} The model
generates a predicate name that sounds semantically appropriate but does
not exist in the schema. Against a biomedical graph, it might write
`dbo:treatedBy` when the actual predicate is `mesh:treats`, or invent
`schema:hasSymptom` for a graph that uses `snomed:hasPresentation`. The
query is syntactically valid. It returns nothing. The model, receiving an
empty result, may conclude that no such relationship exists in the graph --
a false negative with real consequences.

**Wrong URI prefixes.**\index{URI prefix errors} SPARQL queries over RDF
graphs require correct namespace prefixes. `dbo:` and `dbr:` are different
namespaces in DBpedia; conflating them produces broken queries. Wikidata
uses `wd:` for entities and `wdt:` for properties; the distinction is
non-obvious and frequently confused. A model that has seen many SPARQL
examples in training will have absorbed prefix patterns, but those patterns
don't transfer cleanly to every endpoint, and the model has no mechanism
to verify which prefixes are valid for the graph it is currently querying.

**Syntactically valid, semantically empty.**\index{SPARQL!semantic errors}
Some of the most insidious failures produce queries that parse, execute, and
return results -- just not the right ones. A query that asks for all entities
of type `owl:Thing` will return everything in many triple stores. A query
with a subtly wrong join condition will return a Cartesian product or an
empty set depending on the data. The model has no way to distinguish a
correct result from a plausible-looking wrong one.

**Query shape mismatch.** LLMs tend to generate queries that match the
patterns most common in their training data. Those patterns are not
necessarily the patterns a given endpoint handles efficiently. A query that
works against a local Fuseki instance may time out against a public Wikidata
endpoint with rate limits and query complexity restrictions. The model
doesn't know the difference.

None of these failure modes are fixable by making the model smarter or the
prompt more detailed. They are structural. The model is generating text in
a precise formal language against a schema it cannot inspect, with no
feedback loop between generation and verification. Better prompting reduces
the error rate at the margins. It does not change the underlying mechanism.

### The Same Argument Applies to Cypher\index{Cypher!failure modes}

Cypher, Neo4j's query language for property graphs, is a different language
with the same problem. It is expressive and well-designed, built for human
authors who know their schema and can iterate against a live database. An
LLM generating Cypher cold, against an unfamiliar graph, runs into the same
failure modes: invented relationship types, wrong property names, match
patterns that produce unexpected results. The surface syntax is different.
The mechanism of failure is identical.

This is not a criticism of either language. SPARQL and Cypher are excellent
at what they were designed to do. The problem is that "designed for human
authors with schema familiarity and an interactive development environment"
and "suitable for LLM generation in real time against an unknown graph"
describe different requirements. No amount of language design work makes
both true simultaneously.

### Why RAG Doesn't Close the Gap\index{retrieval-augmented generation!limitations}\index{Graph RAG!structural mismatch}

The natural response to query generation failures is to bypass query
generation entirely. Instead of asking the model to write SPARQL, retrieve
relevant content from the graph and give it to the model as text. This is
the RAG\index{RAG|see{retrieval-augmented generation}} approach applied to
graphs, and it has genuine appeal: it avoids the formal language generation
problem, it fits neatly into existing RAG infrastructure, and it sidesteps
the schema familiarity requirement.

The insight behind RAG is sound. [@lewis2020rag] Giving the model something
to reason from rather than asking it to reason from memory reduces
hallucination and improves accuracy on knowledge-intensive tasks. For
document retrieval, where the question is "find the passage most semantically
similar to this query," vector similarity search is a good fit. The model
generates a query embedding, the retriever finds similar document embeddings,
and the relevant passages land in the context.

Graphs break this in a specific and important way. Relevance in a graph is
structural, not semantic.\index{structural relevance} The most important
node for answering a question might be two hops away from any node that
looks semantically similar to the query. Consider a question about drug
interactions for a specific patient profile. The relevant nodes are the
drug, its metabolic targets, the enzymes those targets share with other
drugs the patient is taking, and the clinical outcomes associated with those
shared pathways. None of those intermediate nodes -- the enzymes, the
pathways -- are semantically similar to "drug interactions for this patient."
They are structurally connected to the answer. Vector similarity retrieval
will not find them. It will find nodes that mention drug interactions in
their text representation, which is a different set.

The distinction is fundamental. Vector similarity retrieval asks: what is
*near* this query in embedding space? Graph traversal asks: what is
*connected* to what I already know? For the kinds of questions that make
knowledge graphs valuable -- multi-hop relational reasoning, pathway
analysis, provenance tracing -- the second question is the right one. A
retrieval system built for the first question answers the second question
poorly, not because the implementation is bad but because the operation is
wrong.

This is where Graph RAG systems built on vector retrieval tend to fail in
practice. They find semantically similar nodes efficiently. They miss
structurally important nodes reliably. The result is a context that looks
relevant but is missing the connections that would make the reasoning
meaningful.

The fix is not better embeddings or a larger retrieval set. The fix is a
different operation: traversal rather than retrieval, structure rather than
similarity. That is what Chapter 3 proposes.

## Chapter 3: The Right Abstraction

`\chaptermark{The Right Abstraction}`{=latex}

In 1980, David Patterson\index{Patterson, David} at UC Berkeley and John
Hennessy\index{Hennessy, John} at Stanford were separately arriving at the
same uncomfortable conclusion about the direction computer architecture had
taken. The prevailing wisdom of the era was that more was better: more
instructions, more addressing modes, more hardware support for complex
operations. The VAX-11/780,\index{VAX-11/780} released by Digital Equipment
Corporation in 1977, was the apotheosis of this philosophy -- a machine with
hundreds of instructions, some of them extraordinarily powerful, capable of
expressing complex operations in a single opcode. Compiler writers loved it.
It was, by the standards of the time, a masterpiece.

Patterson and Hennessy thought it was a mistake.

Their argument was not that complex instructions were useless. It was that
they were expensive in ways that weren't obvious and beneficial in ways that
were overstated. A complex instruction that took ten cycles to execute was
not better than ten simple instructions that each took one cycle -- the
simple version was equally fast and the compiler could see each step, reason
about it, and optimize across them. The hardware complexity required to
implement the full instruction set also made it harder to pipeline, harder
to verify, and harder to push to higher clock speeds. Simplicity wasn't a
limitation. It was an advantage.

The resulting architecture -- RISC,\index{RISC} Reduced Instruction Set
Computing\index{reduced instruction set computing} -- was controversial.
It contradicted decades of conventional wisdom and threatened the business
models of companies that had invested heavily in CISC\index{CISC}
implementations. Patterson's Berkeley RISC and Hennessy's MIPS processors
were academic projects. Industry was skeptical.

The market settled the argument. RISC architectures -- MIPS, SPARC, ARM --
came to dominate embedded computing, then mobile computing, then, with the
Apple M-series chips, high-performance desktop computing. The complex
instruction sets that had seemed so powerful turned out to be expensive
overhead that compilers didn't need and processors couldn't efficiently
execute. Fewer, simpler operations, composable by the compiler, outperformed
the rich surface area that had seemed like a gift to programmers.

The lesson generalizes. A large interface surface area is not a feature. It
is a burden -- on the implementor who must make everything work, on the user
who must learn what to use when, and on any automated system that must
generate calls into it reliably. The question is not "how much can we
express?" but "how little do we need to express everything that matters?"

That is the design question BFS-QL answers.

### Traversal, Not Querying\index{BFS!as natural LLM primitive}\index{traversal}

Chapter 2 established that query generation fails because it asks a language
model to produce precise formal language against an unknown schema without
verification. The failure is structural. But there is a deeper point worth
making: even if query generation worked reliably, it would be the wrong
operation.

Consider how an LLM actually reasons about a domain it is exploring. It
starts with something it knows -- a named entity, a concept, a fact from
context. It wants to know what that thing connects to. It expands outward,
following relationships, building a picture of the neighborhood. It asks
follow-up questions based on what it finds. This is not querying -- it is
traversal. The operation is not "express a precise constraint and retrieve
the matching set" but "start here, look around, go deeper where it's
interesting."

Breadth-first search\index{breadth-first search} is the natural formalization
of this. Start from one or more seed entities. Expand to their immediate
neighbors. Expand again to the next ring. Collect the subgraph. Decide how
far to go based on what you find. BFS over a knowledge graph is exactly the
operation that matches how an LLM explores a domain: incremental, local,
driven by what is already known.

This reframing has an important consequence. A query language like SPARQL is
designed to express the full answer in a single declaration -- here is the
constraint, find everything that matches. BFS is designed to be issued
iteratively -- here is where I am, show me what is nearby. The iterative
model fits the LLM's conversational, multi-turn reasoning style. The
declarative model requires the LLM to know, upfront, what it is looking for.
For graph exploration -- which is often precisely the case where the LLM
*doesn't* know what it's looking for yet -- the iterative model is the right
one.

### Topology and Presentation\index{topology}\index{stub nodes}

BFS over a knowledge graph produces a subgraph. The question is what that
subgraph should contain.

The naive answer is: everything. Return all nodes and all edges within the
traversal depth, with all their metadata. This is correct in the sense that
no information is lost. It is impractical for the reasons Chapter 1
established: a dense graph at two hops can contain hundreds of nodes and
thousands of edges, and dumping all of that into the context window is
expensive and degrades reasoning.

The tempting alternative is filtering: return only the nodes and edges that
match the query's constraints, discard the rest. If the user asks about
drugs and diseases, return only Drug and Disease nodes; drop everything else.
This keeps the context small. It also produces a misleading picture of the
graph.

Consider a Disease node connected to ten Drug nodes, two Gene nodes, and
fifteen Publication nodes. If the query filters for Drugs only and discards
everything else, the model sees a Disease connected to ten drugs and nothing
else. It does not know that the Disease is also connected to genes and
publications. It cannot ask follow-up questions about those connections
because it doesn't know they exist. The filtered subgraph is not a smaller
version of the truth -- it is a different, inaccurate picture of the graph's
structure.

The right answer separates two orthogonal concerns: *topology* -- what
nodes and edges exist -- and *presentation* -- how much data each one
carries. BFS-QL's response to this is the stub.\index{stub nodes!rationale}
A stub is a node or edge that is present in the result but carries only
identity information: its ID and type, nothing more. Stubs are not filtered
out. They are present. The model knows they exist, knows what kind of thing
they are, and can choose to follow up on them -- by calling
`describe_entity` for a node stub, or issuing a new `bfs_query` seeded at
that node. The stub is a navigational handle, not a dead end.

This means the BFS-QL response to "show me drugs and diseases" is not
"here are the drugs and diseases, nothing else." It is "here are the drugs
and diseases with full metadata, and here are the other things they connect
to as lightweight stubs so you know the topology." The context cost is
controlled. The picture of the graph is accurate.

### The Working Set Applied to Graph Data\index{working set!applied to graphs}

Denning's working set theory, described in Chapter 1, asked what the
minimum is that a process needs in memory to run efficiently. The answer was
not "nothing" -- you need the pages that are currently active. It was not
"everything" -- you can't afford to keep it all in fast memory. It was the
working set: the pages recently accessed, likely to be accessed again,
sufficient for the computation at hand.

The BFS-QL query model asks the same question about context. The
`node_types` and `predicates` parameters are the mechanism for declaring
the working set: these are the types of nodes I need in full, these are the
predicates I need with provenance, everything else I need only as topology.
The model pays the context cost where it matters and defers cost where it
doesn't.

This is a principled design choice, not a workaround. The working set
concept is a solution to a fundamental resource allocation problem. Applying
it to context management produces a query model that is context-efficient
by construction -- not by truncating results or hoping the model will ignore
irrelevant content, but by giving the model precise control over where the
cost is paid.

In practice, the recommended first move on an unfamiliar graph is to request
topology only: call `bfs_query` with `topology_only=True`, which returns
every node and edge in the traversal as bare identity records -- ID and type,
nothing more. A 2-hop neighborhood of 84 nodes and 99 edges fits in roughly
14,000 characters this way, compared to 110,000 characters for the same
traversal with full metadata. The model can survey the complete shape of the
neighborhood, identify which nodes are worth expanding, and then call
`describe_entity` selectively on the ones that matter. The result is the
working set in the strict sense: topology in fast memory, metadata paged in
on demand.

### The Minimal Surface\index{minimal surface area}

Returning to Patterson and Hennessy: the RISC insight was that the right
number of instructions is the minimum needed to express everything that
matters. Not fewer -- the architecture must be complete. Not more -- every
additional instruction is overhead.

BFS-QL has six tools.\index{BFS-QL!six tools} The choice of six is not
arbitrary. It is the minimum complete set for graph exploration:

- `describe_schema` orients the model to an unfamiliar graph.
- `search_entities` resolves names to canonical IDs.
- `bfs_query` traverses the graph from known seeds.
- `describe_entity` retrieves full detail for a single stub.
- `describe_entities` retrieves full detail for a batch of stubs.
- `intersect_subgraphs` returns nodes within k hops of every seed simultaneously.

These six operations cover the full space of what an LLM needs to do with
a knowledge graph. Orient, resolve, traverse, expand, batch-expand, intersect.
Each operation earned its place by covering something none of the others do.
The protocol has grown by one each time a real gap appeared -- not by
speculation. Further additions are possible, but the bar is the same: a
genuine capability that cannot be composed from existing tools without
material cost to the model.

A larger surface area would not be more powerful. It would be harder to use
reliably -- more choices about which tool to call when, more schema to
internalize, more opportunity for the model to pick the wrong tool for the
situation. The RISC lesson applies directly: fewer, simpler tools that
compose well outperform a rich surface area that requires expertise to
navigate.

### Canonical IDs and the Epistemic Commons\index{canonical ID}\index{ontological authority}\index{epistemic commons}

BFS-QL uses canonical IDs as the fundamental unit of navigation. A seed is
a canonical ID. A stub carries a canonical ID. `search_entities` resolves
a name to a canonical ID. The entire interface is built around them.

A canonical ID is not merely a unique key. When a graph assigns a MeSH term
to a disease entity, it is connecting that entity to the accumulated judgment
of the biomedical community — its definition, its place in the taxonomy, its
known synonyms — built and maintained over decades. Each identifier is a
pointer into that structure: a *located* fact rather than a merely named one.
A graph node labeled "diabetes" is a string. A graph node identified as
MeSH:D003924 is placed in the edifice of human knowledge as the biomedical
community understands it.

This is why BFS-QL is built around canonical IDs: that epistemic
infrastructure is what makes the interface worth building, and what makes
graphs composable across sources (developed in Part IV). The full argument
— authorities, the epistemic commons, identity resolution, and what you
inherit when you anchor — is in the companion volume *The Identity Server:
Canonical Identity for Knowledge Graphs*.

### A Worked Example: Desmopressin in the Medlit Graph\index{worked example}\index{desmopressin}

Abstract principles are clearest when grounded in a concrete case. The
following is a real session against a knowledge graph built from 36 PubMed
Central papers on Cushing disease and related endocrinology -- the medlit
demo dataset used throughout Part III.

The session uses BFS-QL's six tools exactly as described. No SPARQL. No
schema memorization. No pre-specified query structure. The model orients
itself, finds a seed, surveys the topology, and assembles a picture of how
desmopressin fits into the Cushing disease literature.

**Step 1: Orient.**

```
describe_schema()
→ graph_description:
    "medlit: 36 PubMed papers on Cushing disease"
→ entity_types: [
    anatomicalstructure, author, biologicalprocess,
    biomarker, disease, drug, enzyme, gene, hormone,
    institution, paper, pathway, procedure, protein,
    symptom, ...]
→ predicates: [
    AFFILIATED_WITH, ASSOCIATED_WITH, AUTHORED, CAUSES,
    CITES, DESCRIBED, INHIBITS, REGULATES, TREATS, ...
]
```

The model now knows the vocabulary. No schema memorization required --
the schema was fetched from the graph that defines it.

**Step 2: Resolve.**

```
search_entities("desmopressin")
→ RxNorm:3251  (drug)       ← the canonical drug entry
→ PMC11128938  (paper)
    ← a paper whose name contains "desmopressin"
→ PMC10436086  (paper)
```

Three matches. The model inspects the entity types and selects RxNorm:3251
as the drug node. The paper matches are a useful signal -- PMC11128938 is
the primary paper about desmopressin in this graph.

**Step 3: Survey the topology.**
```
bfs_query(
  seeds=["RxNorm:3251"], max_hops=2, topology_only=True
)
→ 84 nodes, 99 edges
→ Each node: {id, entity_type}
→ Each edge: {subject, predicate, object}
→ Response size: ~14,000 characters
```

The full neighborhood at 14K characters fits comfortably in context. The
model can now read the complete topology -- all 84 nodes and 99 edges --
and identify the structure without having paid for metadata it hasn't
looked at yet.

From this topology survey, three main traversal axes are visible:

- Via `DBPedia:Cushing's_disease`: connected to 15 associated diseases
  (dyslipidemia, hypertension, osteoporosis), competing drugs (osilodrostat,
  metyrapone, cabergoline, pasireotide), and causal factors (pituitary
  adenoma, glucocorticoids).
- Via `RxNorm:5492` (cortisol): connected to HPA axis regulation, adrenal
  anatomy, two proteins (UniProt:A3QQ76, UniProt:D3K902), neuroplasticity,
  and downstream symptoms.
- Via `RxNorm:376` (ACTH): connected to dopamine agonist inhibition and
  hypercortisolism causality.

**Step 4: Drill down selectively.**

```
describe_entity("DBPedia:Cushing's_disease")
→ name: "Cushing's disease"
→ canonical_url:
    "https://dbpedia.org/page/Cushing's_disease"
→ supporting_documents: [
    PMC11128938, PMC11779774, PMC4374115, ...
]
→ properties: {synonyms: ["CD"], ...}
```

The model retrieves full metadata only for the node it wants to understand
in depth. The 83 other nodes remain as topology stubs -- present, navigable,
not consuming context budget.

**What the model learns.**

Desmopressin is primarily a *diagnostic* agent in this graph, not merely a
therapeutic one. It appears in stimulation tests for differential diagnosis
of Cushing disease -- distinguishing pituitary from ectopic ACTH sources --
which is why it connects to ACTH, cortisol, and the procedure cluster
(bilateral inferior petrosal sinus sampling, transsphenoidal surgery) rather
than to the treatment drugs directly.

This is the kind of inference that requires structural knowledge, not semantic
similarity. The connection between desmopressin and BIPSS is not in the text
of any one paper in a way that vector retrieval would surface. It is in the
graph. BFS-QL made it accessible.

### The Landmark Ahead\index{multi-graph composition}

BFS-QL solves the single-graph problem. But there is a more interesting
consequence that Part IV takes up at length.

The interface contract that makes one graph accessible -- six tools, a flat
query format, canonical IDs as seeds -- turns out to make many graphs
composable. When two graphs both use MeSH terms for diseases and HGNC
symbols for genes, an LLM holding connections to both can traverse the
boundary between them using only the canonical IDs it already has. No
special protocol support. No federation layer. No query rewriting. The
shared canonical ID is the bridge.

This is not a property of BFS-QL. It is a property of canonical identity --
a decision the biomedical, legal, and chemistry communities made decades ago
for entirely different reasons. What BFS-QL does is expose it: by building
the interface around canonical IDs as the fundamental unit of navigation,
it makes the composability that was always latent in those shared authorities
directly accessible to LLM reasoning.

The landmark is visible from here. Part IV is where we reach it.

# Part II: The Protocol

## Chapter 4: Six Tools

`\chaptermark{Six Tools}`{=latex}

In 1974, computer scientist Christopher Alexander published *A Pattern
Language*,\index{Alexander, Christopher} a catalogue of 253 design patterns
for buildings and towns. The book's argument was not that architects should
memorize 253 patterns. It was that good design recurs -- that the same
solutions to the same problems appear across different scales and contexts,
and that naming them makes them easier to recognize, teach, and apply.
The patterns ranged from urban planning ("City Country Fingers") to room
layout ("The Flow Through Rooms") to the placement of a window seat. Each
was a named, composable solution to a recurring problem.

What Alexander discovered, and what software engineers rediscovered twenty
years later when they adapted his framework for code, is that the value of
a pattern library is not in its size. It is in the coverage-to-complexity
ratio. A small set of well-chosen patterns that together cover the full
space of common problems is more useful than a large set that covers the
same space redundantly or inconsistently. The goal is completeness with
economy.

BFS-QL has six tools. The choice is not arbitrary and not conservative --
it is the result of asking, for every candidate tool, whether it covers
something the others do not, and whether the space it covers is one an LLM
actually needs.\index{BFS-QL!six tools}

### Why Six\index{minimal surface area!six tools}

The full space of what an LLM needs to do with a knowledge graph can be
decomposed into six operations, each distinct, together exhaustive:

**Orientation.** The LLM arrives at a graph it has never seen. It does not
know what kinds of entities the graph contains, what relationships are
represented, or how they are named. Before it can navigate, it needs a map.
This is `describe_schema`.

**Resolution.** The LLM has a name -- a drug, a disease, an author. It
needs the canonical ID that the graph uses for that entity. Names are
ambiguous; canonical IDs are not. The operation of mapping a name to an ID
is fundamental and cannot be collapsed into traversal without introducing
the hallucination problem Chapter 2 described. This is `search_entities`.

**Traversal.** The LLM has a seed -- one or more canonical IDs. It wants
to know what they connect to. This is the core operation, the one that
makes graph knowledge accessible. Everything else is setup or follow-up.
This is `bfs_query`.

**Expansion.** The traversal returns stubs -- lightweight placeholders for
nodes that were present in the topology but did not warrant full metadata.
The LLM sees that something is there and wants to know what it is. For a
single stub, this is `describe_entity`.

**Batch expansion.** A single `bfs_query` call typically surfaces several
stubs worth inspecting. Calling `describe_entity` on each in sequence
means one round-trip per entity: the LLM issues a call, waits, reads the
result, decides to expand the next stub, and repeats. Each round-trip
carries the full overhead of a tool invocation in an LLM session -- not
a database round-trip, but a model reasoning step. In practice, Claude Code
flagged this explicitly as friction: sequential single-entity expansion is
slow and accumulates latency when several stubs warrant attention.
`describe_entities` accepts a list of IDs and returns full records for all
of them in a single call. It is not a convenience alias for a loop; it is
the operation that makes batch expansion a first-class primitive rather
than an emergent pattern the model has to construct.

**Intersection.** The LLM has a set of seeds and wants to know what is
common to all of them -- not the union of their neighborhoods, but the
nodes reachable from every seed simultaneously. `bfs_query` returns the
union; the LLM cannot reliably do the set intersection itself over hundreds
of nodes. This is `intersect_subgraphs`.

Orient, resolve, traverse, expand, batch-expand, intersect. The protocol
has grown by one each time a real gap appeared -- `intersect_subgraphs` when
multi-seed reasoning proved unreliable without it, `describe_entities` when
sequential single-entity expansion proved too costly. Candidate additions
like "find shortest path" or "list all entities of type X" reduce to
compositions of existing tools without material cost, or add query-oriented
answers rather than navigational handles. The bar is real demonstrated need,
not speculation.

### The Session Workflow\index{session workflow}

The six tools define a natural sequence that a well-behaved LLM follows
against any BFS-QL graph:

```text
1. describe_schema()
   → learn entity types, predicates, graph description

2. search_entities(name, node_types=[...])
   → resolve a name to one or more canonical IDs
   → pass node_types to avoid noise in results
   → inspect entity_type to disambiguate if needed

3. bfs_query(seeds, max_hops, ...)
   → traverse from the resolved ID
   → start with topology_only=True for large graphs, OR
   → use exclude_node_types=["paper","author"], min_mentions=2
     for a concept-only result on literature graphs
   → use node_types and predicates to focus metadata detail

4. describe_entities([id, id, ...])
   → expand any stubs that warrant closer inspection
   → batch multiple IDs in a single call
```

Steps 1 and 2 may be partially redundant if the BFS-QL server injects
schema into tool descriptions at startup -- in that case the LLM may skip
the explicit `describe_schema` call. Steps 3 and 4 are iterative: the
output of one `bfs_query` call identifies stubs that motivate `describe_entity`
calls, which may motivate further `bfs_query` calls seeded at newly
discovered nodes. The workflow is a loop, not a pipeline.

This matters for how the tools were designed. Each tool must be callable
in any order, with the outputs of earlier calls serving as inputs to later
ones. `bfs_query` takes canonical IDs -- which `search_entities` produces.
`describe_entity` takes canonical IDs -- which appear in `bfs_query` results.
The interface is compositional by construction.

### What Is Not a Tool\index{BFS-QL!scope}

The choice of six tools is also a choice of what not to include. Some
candidates worth examining:

*A "shortest path" tool.* Useful for certain graph analyses. Not needed
for LLM reasoning, which doesn't navigate to specific destinations -- it
explores neighborhoods. An LLM that needs to know whether two entities are
connected can issue a multi-hop `bfs_query` and inspect the result. The
two-step answer is not materially worse than a dedicated tool, and adding
the tool adds one more surface for the LLM to reason about.

*A "list all entities of type X" tool.* The medlit demo has 119 disease
entities. A tool that returns all of them is not useful to an LLM trying
to reason; it is a context flood. The right operation is `bfs_query` from
a relevant seed with `node_types=["disease"]`, which returns the disease
entities that are connected to something the LLM already cares about.
Relevance is structural, not taxonomic.

*A "count" tool.* Useful for human analysts building dashboards. Not useful
for LLM reasoning. An LLM that receives "there are 119 disease entities"
has not learned anything it can act on. The count tells it nothing about
which diseases matter, how they connect, or what the graph structure implies
about the domain.

The pattern in all three cases is the same: the candidate tool answers a
query-oriented question rather than a traversal-oriented one. It gives
the LLM a fact rather than a navigational handle. BFS-QL is designed for
navigation. The six tools reflect that.

## Chapter 5: `describe_schema` -- Self-Orienting Graphs

`\chaptermark{describe\_schema}`{=latex}

In the early days of the web, connecting to a new API meant reading its
documentation. The documentation was a separate artifact -- a PDF, a wiki
page, a sequence of example `curl` commands -- maintained by humans, often
out of sync with the actual API, and unavailable to the software that needed
it. A client that wanted to know what endpoints were available had to be
told by a human who had read the docs.

This was not a fundamental limitation. Roy Fielding's REST
dissertation,\index{Fielding, Roy}\index{REST} published in 2000, included
hypermedia as a first-class constraint: a well-designed REST API should
carry, in its responses, the information a client needs to navigate it.
Links, not documentation. The API tells you what it can do; you don't need
to be told separately. This principle -- that interfaces should be
self-describing -- has become standard in modern API design. OpenAPI
specifications, GraphQL introspection, FastAPI's `/docs` endpoint: all are
expressions of the same idea.

`describe_schema`\index{describe\_schema} is BFS-QL's implementation of
this principle for knowledge graphs. An LLM connecting to a graph it has
never seen -- a private Fuseki instance, a domain-specific SPARQL endpoint,
a kgraph-derived Postgres store for a hospital's clinical data -- needs to
know what entity types and predicates exist before it can construct a
meaningful query. In the SPARQL world, this required reading documentation.
In BFS-QL, it requires one tool call.

### What It Returns\index{describe\_schema!response format}

A `describe_schema` response contains three things:

- **`graph_description`**: A human-readable string describing the graph
  and its domain -- what the data represents, where it came from, what
  kinds of questions it is meant to answer. This is provided by the graph
  operator when the BFS-QL server is configured. A well-written description
  tells the LLM whether this is the right graph for its current question.

- **`entity_types`**: The complete list of valid entity type names in the
  graph. These are exactly the values the LLM can pass as `node_types` in
  a `bfs_query` call. Not approximate names, not documentation -- the
  actual strings the query engine understands.

- **`predicates`**: The complete list of valid predicate names. These are
  exactly the values the LLM can pass as `predicates` in a `bfs_query`
  call.

The medlit graph, for example, returns 19 entity types and 16 predicates.
After one call, the LLM knows that `drug`, `disease`, and `procedure` are
valid node types -- and that `protein` and `enzyme` are also present, which
tells it something about the level of mechanistic detail in the graph. It
knows that `TREATS`, `CAUSES`, and `INHIBITS` are valid predicates -- and
that `CITES` and `AUTHORED` are also present, which tells it that the graph
includes bibliographic structure alongside clinical knowledge.

This is orientation in the strict sense. The LLM knows what it is looking
at before it starts navigating.

### Two Delivery Modes\index{describe\_schema!injection mode}

The `describe_schema` tool can be called explicitly or made unnecessary
through a second mechanism: schema injection.

At startup, the BFS-QL server calls `entity_types()` and `predicates()`
on the backend and holds the results in memory. If the schema is small
enough -- the implementation uses a threshold of 20 entity types and 30
predicates -- the server injects the valid values directly into the
`bfs_query` tool description. The LLM reads the tool description before
it calls the tool, so it arrives at `bfs_query` already knowing what
`node_types` and `predicates` values are valid. No explicit `describe_schema`
call required.

This is a zero-cost optimization for small schemas. The LLM doesn't spend
a tool call on orientation; the orientation is already embedded in the
interface.

The tradeoff is tool description size. A graph with 19 entity types and
16 predicates adds roughly 200 characters to the `bfs_query` description --
negligible. A graph with 200 entity types and 500 predicates would make the
tool description unwieldy and consume context before the LLM has done
anything. Above the threshold, injection is suppressed and explicit calling
is the path.

Both modes are supported transparently. The server chooses based on schema
size. The LLM's behavior is the same either way: it starts a session knowing
the schema, whether that knowledge came from injection or from a tool call.

### The `graph_description` as a First-Class Signal

The graph description is worth more attention than it usually receives.
In the medlit example, it reads: "36 PubMed papers on Cushing disease and
related endocrinology." That sentence tells an LLM several things that
affect how it should reason:

- The corpus is small (36 papers). Claims that seem universal may be
  specific to this literature.
- The domain is focused (Cushing disease). Entities and relationships
  outside that domain are unlikely to be well-represented.
- The data source is biomedical literature. Relationships have provenance
  and carry confidence scores.

A graph operator deploying BFS-QL should treat the description as they
would treat a system prompt: an opportunity to shape how the LLM approaches
the data. "This graph contains inferred relationships; verify important
claims against source documents." "The entity type `provisional` indicates
entities whose canonical IDs could not be resolved." "Predicates are
directional; `TREATS` runs from drug to disease, not the reverse."

The server instructions mechanism serves a similar function. BFS-QL's
server sends a block of instructions to the LLM at session initialization,
before any tool calls. These instructions can include graph-specific
guidance that doesn't fit in the tool descriptions -- in the medlit
deployment, for example, the instructions note that entity IDs beginning
with `prov:` are provisional artifacts from the ingestion pipeline, carry
no external canonical meaning, and should be treated as anonymous
placeholders. Without that note, an LLM might waste reasoning cycles
wondering what a provisional ID like
`prov:2e02b663d97c45499d4ce644abf81b8a` refers to.

Self-description is not just schema. It is everything the graph operator
knows about the data that the LLM would benefit from knowing before it
starts.

## Chapter 6: The Query Model

`\chaptermark{The Query Model}`{=latex}

The core of BFS-QL is a single query structure with five parameters.
Understanding why each parameter is present -- and why the others are not --
is the key to using the protocol well and to implementing it correctly.

### The Parameters\index{bfs\_query!parameters}

**`seeds`** is a list of canonical entity IDs. This is the starting point
of the traversal. Multiple seeds are supported because many useful questions
are inherently relational: not "what connects to this entity?" but "what do
these two entities have in common?" A multi-seed query issues a single BFS
from all seeds simultaneously and returns their combined neighborhood,
deduplicated. The LLM doesn't need to issue separate queries and merge the
results manually.

**`max_hops`** is an integer controlling traversal depth. A value of 1
returns only immediate neighbors; 2 returns neighbors of neighbors; and so
on up to a maximum of 5. The practical guidance is to start at 1 and expand
only if the first result doesn't contain what you need. A 2-hop traversal
from a well-connected node in the medlit graph returns 84 nodes and 99
edges. A 3-hop traversal from the same node would return most of the graph.
Depth is a context budget decision, not a correctness decision -- the graph
is the same either way.

**`node_types`** is an optional list of entity type names. Nodes whose type
matches receive full metadata in the response. Nodes whose type does not
match are returned as stubs -- present in the result with their ID and type,
but no metadata. Omitting `node_types` gives full metadata for all nodes,
which is appropriate when the graph is small or when the LLM needs
comprehensive information. Providing `node_types` focuses the context budget
on what matters.

**`predicates`** is an optional list of predicate names. Edges whose
predicate matches receive full metadata in the response, including confidence
scores, source documents, and provenance. Edges whose predicate does not
match are returned as bare subject-predicate-object triples. The behavior
is symmetric with `node_types`: topology is always present, detail is
selectively paid for.

**`topology_only`** is a boolean that, when true, suppresses all metadata
from the response. Every node is returned as a bare ID and type; every edge
as a bare subject-predicate-object triple. No node metadata, no edge
metadata, no provenance. The response is pure structural skeleton.

**`exclude_node_types`** is an optional list of entity type names to remove
entirely from the result. Unlike `node_types` (which demotes non-matching
nodes to stubs but keeps them), `exclude_node_types` removes the specified
types and all edges that touch them. The topology is no longer guaranteed
complete when this parameter is used -- that is the point. Use it to
suppress high-volume types that dominate large traversals without adding
conceptual value. The canonical use case is `exclude_node_types=["paper",
"author"]` on a concept-oriented query: papers and authors are the
connective tissue of a literature-derived graph and account for the majority
of nodes in a deep traversal, but an LLM reasoning about disease mechanisms
rarely needs them.

**`min_mentions`** is an optional integer (default 1, no filtering) that
removes nodes whose `total_mentions` field in metadata is below the
threshold, along with all edges touching them. This suppresses
low-confidence provisional entities that appear in only one or two source
documents and are structurally present but semantically unreliable. Nodes
without a `total_mentions` field are always included regardless of
threshold, so the filter is safe on backends that do not populate it. Note
that `min_mentions` filters the *result*, not the *traversal* -- a
low-mention node can still serve as a bridge to high-mention nodes at deeper
hops, but it will not appear in the returned result.

**`limit`** and **`offset`** are optional integers for paginating large
results. `limit` caps the number of nodes returned; `offset` skips the
first N nodes. Together they allow an LLM to page through a large
neighborhood without requesting everything at once. `node_count` and
`edge_count` always reflect the full traversal regardless of pagination, so
the LLM can see the total size and decide whether to request more pages.
Edges are filtered to those whose both endpoints appear in the returned
node window, so each page is a self-consistent subgraph. When neither
parameter is specified the full result is returned unchanged.

### The Flat Format\index{bfs\_query!flat format}

These five parameters are passed as a flat JSON object. There is no nesting,
no sub-query structure, no boolean expression language. The query either
specifies seeds, a depth, and optional filters, or it doesn't. This
flatness is a deliberate choice.

Query languages like SPARQL and GraphQL support arbitrarily nested
structures because they need to -- they are designed to express complex
constraints precisely. BFS-QL is not designed for precise constraint
expression. It is designed for reliable generation by a language model.
Every level of nesting in a query format is an opportunity for the model
to make a structural error -- a misplaced bracket, a wrong level of
indentation, a filter applied at the wrong scope. A flat format has no
levels. The model either provides the parameter or it doesn't.

This is not a limitation on expressiveness. The five parameters cover the
full space of what BFS-QL needs to express. The flatness is expressiveness
appropriate to the operation.

### Context Budget Management\index{context window!budget management}

The central design constraint of the query model is the context window.
Every token in the response consumes context budget; too many tokens degrade
reasoning. The query parameters are the mechanism for managing that budget.

The recommended query progression reflects this:\index{query progression}

**First: topology survey.** Call `bfs_query` with `topology_only=True`
and `max_hops=2`.
 This returns the complete structural skeleton of the
neighborhood -- every node and edge -- at minimum token cost. For the
medlit desmopressin example, this is 14,000 characters for 84 nodes and
99 edges. The LLM can read the full topology and identify what matters
before committing context budget to metadata.

**Second: selective expansion.** Call `describe_entities` with the IDs of
the nodes the topology survey identified as significant. This retrieves full
metadata for multiple nodes in a single call. The LLM pays for exactly the
information it has decided it needs, and nothing else. (The single-node
`describe_entity` remains available for one-off lookups; use
`describe_entities` when expanding several stubs at once.)

**Third: targeted re-query.** If a follow-up traversal is needed -- perhaps
the topology survey revealed an unexpected cluster that warrants its own
exploration -- issue a new `bfs_query` with `node_types` and `predicates`
filters focused on what matters. The third query is more expensive than the
first but more targeted: it retrieves full metadata only for the entity
types and predicates the LLM has decided are relevant.

This progression from cheap-and-broad to expensive-and-targeted is the
working set principle in practice. The first query establishes the
topological working set. The second and third queries fill in detail
selectively.

**Alternative for concept-dense graphs.** On large literature-derived
graphs, a topology survey at max_hops=2 may itself exceed the context
budget -- hundreds of paper and author nodes dominate the result. In this
case, skip the topology survey and issue a direct concept-only query:

```python
bfs_query(
    seeds=[seed_id],
    max_hops=1,
    exclude_node_types=["paper", "author"],
    min_mentions=2,
)
```

This returns only concept entities (diseases, genes, drugs, pathways, etc.)
with 2 or more corpus mentions -- high-signal nodes with full metadata --
in a single in-band response. The breast cancer 1-hop query on the
graphwright corpus returns 73 nodes and 86 edges this way, compared to
1,347 nodes in the unfiltered 2-hop result. Use `max_hops=1` as the default
and expand to 2 only if the 1-hop result is too sparse.

### Multi-Seed Queries\index{multi-seed query}

The multi-seed case deserves more attention than it typically receives,
because it is the natural form for a large class of clinically and
scientifically interesting questions.

`bfs_query` with multiple seeds returns the *union* of their neighborhoods,
deduplicated. This is useful for many questions: "What connects this disease
to this gene?" returns the combined neighborhood of both seeds, and the
structural answer -- the nodes that appear in both halves of the union --
is present in the result for an LLM to inspect. For small result sets, this
works well.

For larger graphs, union-and-inspect becomes unreliable. When each seed's
1-hop neighborhood contains hundreds of nodes, asking the LLM to identify
which nodes appear in both is structured bookkeeping that language models
do poorly -- they miss nodes, conflate similar IDs, and produce inconsistent
results. This is the problem `intersect_subgraphs` solves: it returns only
the nodes within k hops of *every* seed, without the LLM performing any
manual set operations.

The medlit example illustrates the `bfs_query` case. A 1-hop multi-seed
query from desmopressin (RxNorm:3251) and Cushing syndrome (MeSH:D003480)
returns 35 nodes and 37 edges. Of those, exactly two nodes are in the
direct neighborhood of both seeds: PMC11128938, the paper that co-describes
both entities, and DBPedia:Cushing's_disease, the specific disease subtype
that desmopressin treats. For a 36-paper graph at 1-hop depth, the LLM can
inspect the union reliably. For a larger graph or deeper traversal,
`intersect_subgraphs` is the right tool.

### What the Response Contains\index{bfs\_query!response format}

A BFS-QL response contains:

- **`seeds`**: The seed IDs used. Included for reference -- in a
  multi-turn session, the LLM may need to recall which seeds were used
  for a given result.
- **`max_hops`**: The depth used.
- **`node_count`** and **`edge_count`**: Total counts. These are useful
  for calibrating follow-up queries -- a result with 200 nodes warrants
  a more targeted re-query than a result with 15.
- **`nodes`**: A list of node records. Each is either a full `Node`
  (with metadata) or a stub `EntityStub` (ID and type only), depending
  on whether its type matched `node_types`.
- **`edges`**: A list of edge records. Each is either a full
  `EdgeWithMetadata` (with confidence, source documents, and provenance)
  or a bare `Edge` (subject, predicate, object only), depending on
  whether its predicate matched `predicates`.
- **`schema_summary`**: The entity types and predicates actually present
  in this result subgraph, regardless of the filters applied. See the
  next section.

One design choice worth noting: stub nodes are always included. If a
Disease node is present in the topology but `node_types=["drug"]`, the
Disease node appears as a stub -- ID and type, no metadata. It is not
omitted. The topology is always complete. This is the separation of
topology from presentation that Chapter 3 argued for: filtering controls
detail level, not presence.

### Schema Discovery in Results\index{schema\_summary}\index{bfs\_query!schema discovery}

Every BFS-QL query response includes a `schema_summary` field containing the
entity types and predicates actually present in that result subgraph.
This applies to both `bfs_query` and `intersect_subgraphs`.
This is a first-class feature, not implementation detail.

```json
"schema_summary": {
  "entity_types_found": ["disease", "drug", "gene", "paper"],
  "predicates_found": ["associated_with", "targets", "treats"]
}
```

The value of `schema_summary` is especially clear in two situations.

**Large or open-world graphs.** `describe_schema` may return
`comprehensive=False` when the graph is too large to enumerate entity
types and predicates exhaustively -- a Wikidata endpoint, for instance,
has thousands of predicates that cannot all be listed upfront. In this
case, the LLM cannot know what filters are valid before issuing a query.
`schema_summary` solves the problem by reporting the vocabulary
*actually present in the neighborhood*. After a `topology_only` survey,
the LLM can read `schema_summary` and use those values as `node_types`
and `predicates` filters in a targeted follow-up query. No documentation
needed, no guessing at predicate names.

**Paginated results.** When `limit` and `offset` are used to page through
a large traversal, `schema_summary` always reflects the *full* traversal,
not just the current page. The LLM sees the complete vocabulary of the
neighborhood even if it is only reading a window of nodes. This matters
because the decision about which types and predicates to filter on should
be made with knowledge of the whole subgraph, not just the first page.

`schema_summary` closes the loop that `describe_schema` opens. Together
they ensure an LLM always has valid filter values available, whether from
the static schema at startup or from the live vocabulary of a result.

### Name Disambiguation in `search_entities`\index{search\_entities!disambiguation}

`search_entities` accepts a `node_types` parameter that restricts results
to entities of the specified types. This exists to address a common
disambiguation problem.

Common scientific terms match multiple entity types. "Breast cancer"
matches the disease concept (`MeSH:D001943`) and also dozens of papers
whose titles contain the phrase. When an LLM calls `search_entities` to
resolve a disease name, it typically wants the disease concept, not the
papers. Without `node_types`, the results may be dominated by papers; the
disease entity may not appear in the top results at all.

```python
search_entities("breast cancer", node_types=["disease"])
# Returns only disease entities matching "breast cancer"
# Papers are excluded before ranking
```

The `node_types` parameter on `search_entities` is independent of the
same parameter on `bfs_query`. The former restricts which entity types
are returned by the search; the latter controls which entity types
receive full metadata in a traversal. Both are optional. Both exist to
help the LLM manage an otherwise ambiguous result set.

## Chapter 7: MCP as the Delivery Mechanism

`\chaptermark{MCP as the Delivery Mechanism}`{=latex}

In 2024, Anthropic introduced the Model Context Protocol -- MCP -- as a
standard for connecting language models to external tools and data
sources.\index{Model Context Protocol}\index{MCP} The timing was not
accidental. By 2024, the pattern of equipping LLMs with tools -- functions
the model could call, results it could reason over -- had become standard
practice, but the implementations were fragmented. Every tool integration
was bespoke: a custom function signature, a custom serialization format,
a custom connection mechanism. Integrating a new tool into a new model
meant writing new code for every combination.

MCP's value proposition was standardization. A tool implemented to the
MCP specification could be connected to any MCP-compatible client without
modification. The tool vendor didn't need to know which model would call
it. The model vendor didn't need to know which tools would be connected.
The protocol was the contract between them.

This is the same insight that made HTTP successful as a substrate for the
web, and that made USB successful as a hardware interface standard: an
agreed protocol, implemented by many parties independently, creates a
market of interoperable components. The value grows with the number of
implementations.

BFS-QL is implemented as an MCP server. This choice determines how graphs
are connected to models, how the connection is configured, and what the
operational model looks like.

### The Connection Model\index{MCP!connection model}

Connecting a BFS-QL graph to an MCP-compatible LLM client takes three
steps:

**Provision.** Start the BFS-QL server against a backend:

```bash
uv run bfs-ql serve --backend postgres --transport sse \
  --description "My knowledge graph"
```

**Register.** Tell the client where the server is:

```bash
claude mcp add --transport sse --scope user my-graph \
  http://127.0.0.1:8000/sse
```

**Connect.** Start a new session. The client connects to the server,
receives the tool definitions and server instructions, and the six BFS-QL
tools are available immediately.

That is the complete setup. No schema configuration, no query templates,
no prompt engineering. The graph self-describes through `describe_schema`;
the server instructions carry graph-specific guidance; the tools define
their own parameters and return types. The LLM needs no external
documentation to use the interface.

This is the self-description principle from Chapter 5 extended to the
connection layer. Not just the schema -- the entire interface is
self-contained.

### SSE and Stdio\index{MCP!transport}\index{SSE}\index{stdio}

MCP supports multiple transport mechanisms. BFS-QL supports two:

**SSE (Server-Sent Events)** runs the BFS-QL server as a persistent HTTP
service. The client connects over HTTP; the server pushes responses as
events. SSE is the right choice for most deployments: it supports multiple
concurrent clients, runs as a background service, and is accessible from
any MCP client on the network. The URL format (`http://host:port/sse`) is
what gets registered with the client.

**Stdio** runs the BFS-QL server as a subprocess. The client spawns the
server process and communicates over standard input and output. Stdio is
the right choice for environments where network access is restricted or
where the graph server should not persist between sessions. It is the
default transport and requires no port configuration.

For local development against the medlit demo dataset, SSE is more
convenient -- the server starts once and remains available across sessions.
For production deployments, SSE also simplifies monitoring and restart
management.

### The Protocol as Active Contract\index{MCP!active contract}

It is worth being precise about what MCP provides and what it does not.

MCP is a transport and discovery protocol. It specifies how tools are
described (JSON Schema), how they are called (JSON-RPC), and how results
are returned. It does not specify what the tools do, what data they return,
or how the LLM should use them. Those are determined by the tool
implementation -- in this case, by BFS-QL.

The distinction matters because it clarifies where the intelligence lives.
MCP connects the model to the server. BFS-QL determines what the server
can do and how it behaves. The model decides how to use it.

This is the right division of labor. MCP handles the plumbing. BFS-QL
handles the graph interface semantics: stubs versus full nodes, topology
completeness, the working set model, canonical IDs as seeds. The model
handles the reasoning: what to query, what the results mean, what to do
with them.

None of these three components knows more than it needs to about the
others. The model doesn't know whether the backend is Postgres or
SPARQL or Neo4j -- it only sees six tools. BFS-QL doesn't know what
question the model is trying to answer -- it only executes queries.
The backend doesn't know anything about either -- it only answers eight
primitive operations. Each layer is replaceable independently of the others.

This composability is not an accident of the implementation. It is the
consequence of having a well-defined protocol at each boundary. MCP defines
the boundary between model and server. The `GraphDbInterface` ABC defines
the boundary between server and backend. The BFS-QL query format defines
the boundary between the model's intent and the traversal engine. Clean
boundaries make components replaceable. Replaceable components make the
system adaptable to backends and clients that do not yet exist.

The graph a hospital runs today against its clinical knowledge base is,
from the model's perspective, indistinguishable from the graph a
pharmaceutical company runs against its compound library, or the graph
a university runs against its research literature. Same six tools. Same
query format. Same session workflow. The MCP protocol is how that
uniformity is delivered.

# Part III: Building a Backend

## Chapter 8: The GraphDbInterface ABC

`\chaptermark{The GraphDbInterface ABC}`{=latex}

There is a tension in interface design between expressiveness and simplicity.
An expressive interface gives the caller more power -- more ways to phrase
a request, more control over execution, more options to tune. A simple
interface gives the implementor less to build and the caller fewer things to
get wrong. The usual engineering response is to find a balance, to offer
enough expressiveness without crossing into complexity.

BFS-QL resolves this tension by separating it into two layers. The
`GraphDbInterface` abstract base class is the implementor-facing interface.
It is deliberately primitive -- eight methods, all basic graph navigation,
no traversal intelligence. The BFS-QL server layer is the caller-facing
interface, where all the expressiveness lives: multi-seed BFS, stub/full
filtering, topology mode, caching, the full six-tool surface. These are
not in tension because they are in different places. The ABC is simple so
that backends are easy to write. The server is expressive because it has to
be. Neither layer compromises the other.

### Eight Methods\index{GraphDbInterface!eight methods}

The complete interface:

```python
class GraphDbInterface(ABC):

    @abstractmethod
    async def search_entities(
        self, query: str, node_types: list[str] | None = None
    ) -> list[EntityStub]:
        """Resolve a name or alias to candidate stubs."""

    @abstractmethod
    async def edges_from(self, entity_id: str) -> list[Edge]:
        """Return all outgoing edges from the given entity."""

    @abstractmethod
    async def edges_to(self, entity_id: str) -> list[Edge]:
        """Return all incoming edges to the given entity."""

    @abstractmethod
    async def get_node(self, entity_id: str) -> Node:
        """Return the node record for the given entity ID."""

    @abstractmethod
    async def metadata_for_node(
        self, entity_id: str
    ) -> dict[str, Any]:
        """Return all available metadata for the entity."""

    @abstractmethod
    async def metadata_for_edge(
        self, edge: Edge
    ) -> dict[str, Any]:
        """Return full metadata, including provenance."""

    @abstractmethod
    async def entity_types(self) -> list[str]:
        """Return valid entity type names in this graph."""

    @abstractmethod
    async def predicates(self) -> list[str]:
        """Return valid predicate names in this graph."""
```

Three pairs and two singletons. `edges_from` / `edges_to` are the traversal
primitives -- directed graph navigation in both directions. `get_node` /
`metadata_for_node` separate identity from detail: the first returns just
the entity ID and type, the second returns everything else. `metadata_for_edge`
pairs with the traversal primitives to provide full provenance. Then the two
singletons: `search_entities` maps natural-language names to canonical IDs,
and `entity_types` / `predicates` expose the graph's own vocabulary.

The separation of `get_node` from `metadata_for_node` is deliberate. During
BFS expansion, the engine calls both concurrently for nodes that need full
records, but calls only `get_node` for nodes that will become stubs. A backend
that fetches metadata lazily -- or from a separate service -- can implement
both cheaply without conflating the two concerns.

### What the Interface Does Not Contain\index{GraphDbInterface!what is excluded}

There is no `bfs_query` method. There is no `count_neighbors` method. There
is no `find_shortest_path` method. There is no filter parameter, no hop limit,
no traversal mode.

All of that is in the server layer. The `bfs_query` function in `engine.py`
implements multi-seed BFS entirely in terms of `edges_from`, `edges_to`,
`get_node`, and `metadata_for_node`. The stub/full decision is made at the
server layer. The topology-only mode is a serialization choice at the
server layer. The caching layer wraps the backend transparently.

The consequence is that a backend implementor answers only one question: how
do I perform these eight operations against this particular graph store? Not:
how do I implement BFS? Not: how do I cache edge lists efficiently? Not: how
do I serialize results? Those questions are already answered, once, in the
server layer, and the answers apply to every backend automatically.

### The Caching Layer\index{CachedGraphDb}\index{caching!primitive-level}

`CachedGraphDb` wraps any backend in a dict-keyed cache at the primitive
level. Every call to `edges_from(id)` checks a dict before hitting the backend.
Every `metadata_for_node(id)` is cached after the first fetch. `entity_types`
and `predicates` are cached indefinitely -- they are stable for the lifetime
of a session.

```python
class CachedGraphDb(GraphDbInterface):
    def __init__(
        self, backend: GraphDbInterface, maxsize: int = 1024
    ) -> None:
        self._backend = backend
        self._edges_from_cache: dict[str, list[Edge]] = {}
        self._node_meta_cache: dict[str, dict[str, Any]] = {}
        # ... per-method dicts for all eight methods

    async def edges_from(self, entity_id: str) -> list[Edge]:
        if entity_id not in self._edges_from_cache:
            res = await self._backend.edges_from(entity_id)
            self._edges_from_cache[entity_id] = res
        return self._edges_from_cache[entity_id]
```

The critical property is that caching operates at the level where it pays.
BFS traversal at depth 2 may visit the same node from multiple directions.
Without caching, each visit triggers a backend round-trip. With primitive-level
caching, the second visit is a dict lookup. The backend sees each distinct
call at most once per session. A multi-hop traversal over a well-connected
graph can reduce backend round-trips by an order of magnitude.

Because the cache is transparent -- `CachedGraphDb` implements
`GraphDbInterface` -- backends do not implement caching themselves. They
return fresh data on every call. The server layer decides caching policy.
Backends stay simple.

### All Methods Are Async\index{GraphDbInterface!async design}

Every method in `GraphDbInterface` is `async`. This is not a formality.
BFS expansion calls `edges_from` and `edges_to` for every node in the
current frontier concurrently, via `asyncio.gather`. A 2-hop BFS over
a frontier of 40 nodes issues 80 concurrent edge queries. Against a
Postgres backend, these resolve as concurrent connection pool requests.
Against a SPARQL endpoint, they resolve as concurrent HTTP requests.
Against a Neo4j backend, they resolve as concurrent Bolt protocol calls.

A synchronous interface would serialize this work unnecessarily. The async
design is a performance contract: backends that can serve concurrent queries
concurrently will. Backends that cannot (in-memory dicts, file-backed stores)
pay no penalty -- `async def` with no `await` inside is just a regular
function in async clothing.

## Chapter 9: The Postgres Backend\index{PostgresBackend}

`\chaptermark{The Postgres Backend}`{=latex}

The Postgres backend is the primary BFS-QL backend, not because Postgres is
the only viable graph store -- it is not -- but because it is the natural
target for graphs built with the companion volume's extraction pipeline.
Kgraph writes entities, relationships, and embeddings into Postgres. BFS-QL
reads them through `PostgresBackend`. The two are designed as a pair; this
chapter covers the reading side.

### The Schema\index{kgraph!Postgres schema}

`PostgresBackend` expects the kgraph schema:

- **`entity` table**: `entity_id` (canonical ID), `entity_type`, `name`,
  `embedding` (pgvector float array), `properties` (JSON), `status`,
  `confidence`, `synonyms` (JSON), `source`, `canonical_url`.
- **`relationship` table**: `subject_id`, `predicate`, `object_id`,
  `confidence`, `source_documents` (JSON), `properties` (JSON).
- **`bundle_evidence` table**: `relationship_key` (string FK of the form
  `subject_id:predicate:object_id`), `text_span`, `confidence`,
  `document_id`, `section`.

Entities with `status = 'merged'` are excluded from all queries. The
kgraph pipeline resolves duplicate entities by merging them into a canonical
representative; merged entities are kept in the table for audit purposes
but are not exposed through BFS-QL.

### Connection Pool and Initialization\index{asyncpg!connection pool}

`PostgresBackend` uses asyncpg for async I/O and manages a connection pool:

```python
@classmethod
async def create(
    cls, dsn: str | None = None, ...
) -> "PostgresBackend":
    dsn = dsn or os.environ["DATABASE_URL"]

    async def _init_conn(conn):
        await conn.execute(
            "CREATE EXTENSION IF NOT EXISTS vector"
        )
        await conn.set_type_codec(
            "jsonb",
            encoder=json.dumps,
            decoder=json.loads,
            schema="pg_catalog",
        )

    pool = await asyncpg.create_pool(
        dsn, min_size=2, max_size=10, init=_init_conn
    )
    return cls(pool, embedding_fn)
```

The `_init_conn` callback runs on every new connection in the pool. It
installs the pgvector extension if not present and registers a type codec
that automatically decodes JSONB columns to Python dicts. The `vector`
type for embeddings is handled separately by casting to text in queries.

`PostgresBackend.create` is an async classmethod, not `__init__`. This is
a Python idiom for async initialization: `__init__` cannot be `async`, so
the factory pattern is the clean solution. The `create_server()` function
accepts `PostgresBackend.create` as a factory callable -- the server's
lifespan handler calls it inside the running event loop, ensuring the pool
is created in the same loop that will use it.

### Entity Search\index{search\_entities!Postgres}\index{pgvector}

`search_entities` has two implementations selected at pool creation time:

**Vector search** (when an `embedding_fn` is provided):

```python
async def _search_by_vector(
    self, query: str, limit: int = 10
) -> list[EntityStub]:
    embedding = await self._embedding_fn(query)
    embedding_str = (
        "[" + ",".join(str(x) for x in embedding) + "]"
    )
    rows = await conn.fetch(
        """
        SELECT entity_id, entity_type
        FROM entity
        WHERE embedding IS NOT NULL
          AND (status IS NULL OR status != 'merged')
        ORDER BY embedding::vector <=> $1::vector
        LIMIT $2
        """,
        embedding_str, limit,
    )
```

The `<=>` operator is pgvector's cosine distance operator. The query embeds
the search string and finds the nearest entity embeddings. Embedding model
consistency — using the same model at ingest time and query time — is
critical; mismatched models produce meaningless distances. This is guaranteed
automatically when the identity server owns all embeddings: it uses the same
model for both, and the query layer never needs to know which one.

**Name search** (fallback when no `embedding_fn` is provided):

```python
async def _search_by_name(
    self, query: str, limit: int = 10
) -> list[EntityStub]:
    pattern = f"%{query}%"
    rows = await conn.fetch(
        "SELECT entity_id, entity_type FROM entity "
        "WHERE name ILIKE $1 "
        "AND (status IS NULL OR status != 'merged') "
        "ORDER BY name LIMIT $2",
        pattern, limit,
    )
```

ILIKE is case-insensitive substring matching. It is less precise than
vector search -- a query for "Cushing" matches "Cushing disease," "Cushing
syndrome," and any entity whose name contains the substring. For the
medlit demo graph, where entity names are short and specific, this is
acceptable. For large general-purpose graphs, vector search is preferred.

### Edge Traversal\index{edges\_from}\index{edges\_to}

The traversal methods are straightforward:

```python
async def edges_from(self, entity_id: str) -> list[Edge]:
    rows = await conn.fetch(
        "SELECT subject_id, predicate, object_id "
        "FROM relationship "
        "WHERE subject_id = $1",
        entity_id,
    )
    return [
        Edge(
            subject=r["subject_id"],
            predicate=r["predicate"],
            object=r["object_id"]
        ) for r in rows
    ]
```

`edges_to` is identical with `WHERE object_id = $1`. Both are called
concurrently for every node in the BFS frontier. The connection pool
handles concurrent acquisition; asyncpg's pool is safe for concurrent use.

### Metadata and Evidence\index{metadata\_for\_edge!provenance}

`metadata_for_edge` is the most complex method in the backend. An edge
record in the `relationship` table carries `confidence`, `source_documents`,
and `properties`. Evidence provenance is in `bundle_evidence`, keyed by
the string `subject_id:predicate:object_id`:

```python
async def metadata_for_edge(
    self, edge: Edge
) -> dict[str, Any]:
    rel_key = f"{edge.subject}:{edge.predicate}:{edge.object}"
    evidence_rows = await _fetch_evidence(
        conn, rel_row["id"], rel_key
    )
    ...
```

The `_fetch_evidence` helper tries two schemas: the test schema (an `evidence`
table with a UUID foreign key) and the kgserver schema (`bundle_evidence`
with a string relationship key). This dual-schema support exists because the
integration tests build a minimal schema from scratch while the production
demo data uses the full kgserver schema. Both schemas are handled
transparently.

The resulting `metadata` dict for a full edge includes confidence, source
document IDs, any relationship properties, and a `provenance` list with
text spans, confidence scores, and document references. This provenance
is stripped by `_slim_result` in the server layer before returning BFS
results -- it is available only through `describe_entity` on a specific
node, which fetches the edge metadata directly.

## Chapter 10: The SPARQL Backend\index{SPARQL backend}

`\chaptermark{The SPARQL Backend}`{=latex}

The Postgres backend covers kgraph-derived graphs -- graphs that were built
by the extraction pipeline and live in a database the developer controls.
But there are thousands of knowledge graphs that predate BFS-QL, that were
built by other teams for other purposes, and that expose themselves through
SPARQL 1.1 endpoints. DBpedia, Wikidata, UniProt, ChEMBL, the Gene Ontology,
the NCI Thesaurus -- these are public graphs with public endpoints, accumulated
over decades, containing knowledge that no extraction pipeline will soon
replicate. A SPARQL backend makes all of them accessible through the same
six-tool interface.

### The SPARQL Endpoint Model\index{SPARQL!endpoint model}

A SPARQL 1.1 endpoint accepts HTTP POST requests with a `query` parameter
containing a SPARQL query string and returns results as JSON, XML, or CSV.
The endpoint URL is the only configuration. The backend sends queries over
HTTP and parses the JSON binding response format.

The `edges_from` and `edges_to` methods translate directly to SPARQL
property path queries:

```sparql
-- edges_from(entity_id)
SELECT ?predicate ?object WHERE {
    <{entity_id}> ?predicate ?object .
    FILTER(!isBlank(?object))
}
LIMIT 500

-- edges_to(entity_id)
SELECT ?subject ?predicate WHERE {
    ?subject ?predicate <{entity_id}> .
    FILTER(!isBlank(?subject))
}
LIMIT 500
```

The `FILTER(!isBlank(?object))` clause excludes blank nodes -- anonymous
intermediate nodes that appear in RDF data but have no canonical ID and
cannot be meaningfully referenced in BFS-QL. Blank nodes are a modeling
convenience in RDF; they are a navigational dead end for graph traversal.

### URI Normalization\index{SPARQL!URI normalization}

SPARQL endpoints represent entities as URIs:

```
<http://dbpedia.org/resource/Cushing%27s_disease>
<http://www.wikidata.org/entity/Q183417>
```

BFS-QL canonical IDs are strings. The SPARQL backend must map between
them.

The mapping strategy is endpoint-specific. For DBpedia, the URI prefix
`http://dbpedia.org/resource/` maps to the prefix `DBpedia:`. For Wikidata,
`http://www.wikidata.org/entity/` maps to `Wikidata:`. The backend's
initialization takes a prefix map:

```python
backend = SparqlBackend(
    endpoint="https://dbpedia.org/sparql",
    prefixes={
        "DBpedia": "http://dbpedia.org/resource/",
        "DBpedia-owl": "http://dbpedia.org/ontology/",
    }
)
```

Outgoing URIs are expanded to full form before insertion into SPARQL
queries. Incoming URIs are compressed using the prefix map. URIs that
match no known prefix are included as-is -- they are valid canonical IDs,
just opaque to the user.

### Schema Discovery\index{SPARQL!schema discovery}

`entity_types` and `predicates` are the BFS-QL methods that return the
graph's vocabulary. For SPARQL endpoints, these translate to `SELECT DISTINCT`
queries:

```sparql
-- entity_types()
SELECT DISTINCT ?type WHERE {
    ?s a ?type .
}
ORDER BY ?type
LIMIT 200

-- predicates()
SELECT DISTINCT ?pred WHERE {
    ?s ?pred ?o .
    FILTER(?pred != rdf:type)
}
ORDER BY ?pred
LIMIT 500
```

These queries can be slow on large endpoints -- Wikidata has hundreds of
millions of triples and `SELECT DISTINCT` over all predicates is not
instantaneous. The `CachedGraphDb` wrapper handles this: both methods are
cached indefinitely after the first call. The server's lifespan handler
calls them once at startup and caches the results in `_state`.

For endpoints where `SELECT DISTINCT` is prohibitively slow, an alternative
is to probe from a known seed: start from a well-connected entity and collect
the entity types and predicates that appear in its neighborhood. This
produces a partial schema -- sufficient for the BFS-QL server to inject
into tool descriptions -- without scanning the entire graph.

### `search_entities` Against SPARQL\index{search\_entities!SPARQL}

SPARQL endpoints vary in their full-text search support. Virtuoso (which
backs DBpedia) supports `bif:contains` for full-text matching. GraphDB
supports Lucene-backed text search. Many endpoints support no full-text
search at all.

The most portable approach is `rdfs:label` matching with `FILTER(CONTAINS(...))`:

```sparql
SELECT ?entity ?type WHERE {
    ?entity rdfs:label ?label ;
            a ?type .
    FILTER(CONTAINS(LCASE(?label), LCASE("{query}")))
}
LIMIT 20
```

This is not fast on large graphs, but it works everywhere and avoids
endpoint-specific extensions. For production use against a specific endpoint,
the backend should be configured with that endpoint's preferred search
mechanism.

### Handling Endpoint Variance\index{SPARQL!endpoint variance}

SPARQL 1.1 is a standard, but implementations differ. Virtuoso requires
`DEFINE sql:describe-mode "CBD"` for some queries. GraphDB has different
timeout behavior. Stardog enforces stricter blank node handling. Amazon
Neptune does not support all property path expressions.

The SPARQL backend handles this through a small set of configuration knobs:
query timeout (in seconds), result set size limit (LIMIT clause), and a
flag for whether `SELECT DISTINCT` over the full graph is safe to issue.
These are set at initialization and applied to all generated queries.

The abstraction boundary is clean: an LLM querying a BFS-QL server backed
by Virtuoso, GraphDB, or Neptune sees identical behavior. The endpoint
variance is confined entirely to the backend implementation.

## Chapter 11: The Neo4j Backend\index{Neo4j backend}

`\chaptermark{The Neo4j Backend}`{=latex}

Neo4j is a property graph database, not an RDF store. The distinction matters
for the implementation, though not for the BFS-QL interface. Where RDF graphs
represent everything as triples of URIs and literals, property graphs attach
key-value pairs directly to nodes and relationships. A node in Neo4j has a
label (or multiple labels) and a set of properties. A relationship has a type
and a set of properties. There are no blank nodes; everything is either a
node or a named relationship.

For BFS-QL, the mapping from the property graph model to the
`GraphDbInterface` is direct:

- Node labels → `entity_type`
- Relationship types → predicates
- Node identity (Neo4j's internal ID or a canonical ID property) → entity ID
- Node properties → `metadata_for_node`
- Relationship properties → `metadata_for_edge`

The implementation requires one configuration decision: which node property
holds the canonical ID. In a kgraph-derived Neo4j graph, this would be
`entity_id`. In a general Neo4j graph, it might be `id`, `uri`, `name`,
or something domain-specific. The backend is initialized with the canonical
ID property name.

### Cypher Traversal\index{Neo4j!Cypher traversal}

`edges_from` and `edges_to` are natural Cypher traversals:

```cypher
-- edges_from(entity_id)
MATCH (n {entity_id: $id})-[r]->(m)
RETURN n.entity_id AS subject,
       type(r) AS predicate,
       m.entity_id AS object

-- edges_to(entity_id)
MATCH (n)-[r]->(m {entity_id: $id})
RETURN n.entity_id AS subject,
       type(r) AS predicate,
       m.entity_id AS object
```

`type(r)` returns the relationship type as a string, which becomes the
predicate. Neo4j relationship types are uppercase by convention (`TREATS`,
`INHIBITS`, `ASSOCIATED_WITH`); BFS-QL predicates are lowercase by
convention. The backend normalizes to lowercase at query time.

### Full-Text Search\index{Neo4j!full-text index}\index{search\_entities!Neo4j}

`search_entities` in Neo4j requires a full-text index. Unlike Postgres
(which can fall back to ILIKE) or a SPARQL endpoint (which can use
`CONTAINS` on labels), Neo4j has no built-in substring search on node
properties. A full-text index must be created at graph construction time:

```cypher
CREATE FULLTEXT INDEX entity_names
  FOR (n:Entity) ON EACH [n.name, n.synonyms]
```

With the index in place, `search_entities` becomes:

```cypher
CALL db.index.fulltext.queryNodes("entity_names", $query)
YIELD node, score
RETURN node.entity_id AS id, labels(node)[0] AS entity_type
ORDER BY score DESC
LIMIT 10
```

The index requirement is a constraint on graph construction, not on
BFS-QL. A Neo4j graph served through BFS-QL must have the index; graphs
without it cannot support `search_entities`. The backend checks for index
existence at initialization and raises a clear error if it is missing,
rather than failing silently at query time.

### `entity_types` and `predicates`\index{Neo4j!schema methods}

```cypher
-- entity_types()
CALL db.labels() YIELD label RETURN label ORDER BY label

-- predicates()
CALL db.relationshipTypes() YIELD relationshipType
RETURN relationshipType ORDER BY relationshipType
```

Neo4j's `db.labels()` and `db.relationshipTypes()` procedures return the
complete label and relationship type vocabularies without scanning the
graph. They are fast, stable, and the natural implementation of
`entity_types` and `predicates`. No `SELECT DISTINCT` required.

## Chapter 12: Writing Your Own Backend\index{custom backend}

`\chaptermark{Writing Your Own Backend}`{=latex}

The eight-method contract is a complete specification. If you can answer
each of the eight questions for a given graph store, you can write a
BFS-QL backend for it, and everything above that layer -- traversal,
filtering, caching, the six-tool MCP interface -- comes for free.

### What "Correct" Means for Each Method

**`search_entities(query)`**: Return a ranked list of `EntityStub` records
whose names or aliases match the query string. "Ranked" means most-likely
matches first. "Match" is implementation-defined: substring, vector
similarity, full-text score, or exact match are all valid. Return at most
10-20 candidates. Do not filter by entity type here -- that is the caller's
job. Return an empty list, not an error, if nothing matches.

**`edges_from(entity_id)` / `edges_to(entity_id)`**: Return all outgoing
or incoming edges for the entity. "All" means all -- do not apply relevance
filters. BFS traversal needs complete topology; filtering happens at the
server layer. Return `Edge` records with canonical IDs for subject and
object; do not return metadata here. Raise `KeyError` if the entity does
not exist; return `[]` if it exists but has no edges.

**`get_node(entity_id)`**: Return a `Node` record with the entity's ID
and type. This is the identity call, not the metadata call. It is fast.
Raise `KeyError` if the entity does not exist or is inaccessible.

**`metadata_for_node(entity_id)`**: Return a dict of all available
metadata for the entity. Keys and types are backend-defined. Include
everything: names, synonyms, descriptions, external links, confidence
scores. The server passes this dict to the LLM as-is; the LLM decides
what is relevant. Do not omit fields to save space -- the topology mode
handles that at the server layer.

**`metadata_for_edge(edge)`**: Return a dict of all available edge metadata.
Include provenance: text spans, source documents, extraction confidence,
creation timestamps. The server strips verbose provenance fields from BFS
results (returning them only through `describe_entity`) but the backend
should return everything and let the server decide what to expose.

**`entity_types()` / `predicates()`**: Return complete, stable lists. The
server caches these indefinitely; they must not change during a session.
Return them in a consistent order (alphabetical is conventional). Return
an empty list if the graph has no schema (though this makes `describe_schema`
useless and should be avoided).

### A Worked Example: JSON-LD REST API Backend\index{JSON-LD backend}

To make the contract concrete, consider a JSON-LD REST API as a backend.
The API exposes entities at `/entities/{id}` and their relationships at
`/entities/{id}/relations`. A schema endpoint at `/schema` returns the
vocabulary.

```python
class JsonLdBackend(GraphDbInterface):
    def __init__(self, base_url: str) -> None:
        self._base = base_url.rstrip("/")
        self._session: aiohttp.ClientSession | None = None

    async def _get(self, path: str) -> dict:
        url = f"{self._base}{path}"
        async with self._session.get(url) as resp:
            return await resp.json()

    async def get_node(self, entity_id: str) -> Node:
        data = await self._get(f"/entities/{entity_id}")
        return Node(id=data["id"], entity_type=data["@type"])

    async def metadata_for_node(
        self, entity_id: str
    ) -> dict[str, Any]:
        data = await self._get(f"/entities/{entity_id}")
        return {
            k: v for k, v in data.items()
            if k not in ("id", "@type", "@context")
        }

    async def edges_from(self, entity_id: str) -> list[Edge]:
        path = f"/entities/{entity_id}/relations?direction=out"
        data = await self._get(path)
        return [
            Edge(
                subject=r["subject"],
                predicate=r["predicate"],
                object=r["object"]
            ) for r in data["relations"]
        ]

    async def edges_to(self, entity_id: str) -> list[Edge]:
        path = f"/entities/{entity_id}/relations?direction=in"
        data = await self._get(path)
        return [
            Edge(
                subject=r["subject"],
                predicate=r["predicate"],
                object=r["object"]
            ) for r in data["relations"]
        ]

    async def search_entities(
        self, query: str, node_types: list[str] | None = None
    ) -> list[EntityStub]:
        params = f"?q={query}&limit=10"
        if node_types:
            params += "&types=" + ",".join(node_types)
        data = await self._get(f"/entities{params}")
        return [EntityStub(id=e["id"], entity_type=e["@type"])
                for e in data["results"]]

    async def metadata_for_edge(
        self, edge: Edge
    ) -> dict[str, Any]:
        path = (
            f"/relations?subject={edge.subject}"
            f"&predicate={edge.predicate}"
            f"&object={edge.object}"
        )
        data = await self._get(path)
        return data.get("metadata", {})

    async def entity_types(self) -> list[str]:
        data = await self._get("/schema")
        return sorted(data["entity_types"])

    async def predicates(self) -> list[str]:
        data = await self._get("/schema")
        return sorted(data["predicates"])
```

This is approximately 60 lines. It is incomplete -- there is no session
management, no error handling for missing entities, no JSON-LD context
resolution. But it illustrates the contract. Once these eight methods work
correctly, the backend can be passed to `create_server()` and immediately
served through the full BFS-QL interface: six tools, stub/full filtering,
multi-seed BFS, topology mode, LRU caching. None of that is in the backend.
All of it comes for free.

### The Bar Is Low; the Payoff Is Immediate\index{custom backend!payoff}

The eight-method interface is deliberately small. Its purpose is not to
constrain what backends can do -- they can expose arbitrary metadata, use
any storage technology, call any external service. Its purpose is to define
the minimum surface that the BFS-QL server needs to function.

A backend that correctly implements all eight methods gets, automatically:

- BFS traversal to any depth with concurrency across the frontier
- Stub/full node and edge filtering based on the caller's `node_types` and
  `predicates` parameters
- Topology mode: pure structural skeleton with no metadata
- Multi-seed union: BFS from multiple seeds simultaneously
- LRU caching at the primitive level: no repeated round-trips for the
  same entity or edge within a session
- The full six-tool MCP interface (all six BFS-QL tools)
- Schema injection: valid `node_types` and `predicates` injected into the
  `bfs_query` tool description when the schema is small enough

The cost is eight method implementations. The payoff is a fully functional
LLM graph interface against any data store you can navigate.

# Part IV: The Bigger Picture

Every knowledge graph that uses canonical IDs correctly is automatically
composable with every other one that does the same. This is an emergent
property of anchoring to shared authorities — nobody designed MeSH, HGNC,
RxNorm, and UniProt as an LLM interoperability layer, but that is what they
have quietly become.

The companion volume *Knowledge Graphs from Unstructured Text* argues for
canonical identity as a quality and provenance concern. The companion volume
*The Identity Server* develops the full architecture of how canonical
identity is achieved and maintained. This part is where that investment pays
off: the shared identifiers are the bridges between graphs, and BFS-QL is
the interface that traverses them.

The LLM is the reasoner. BFS-QL is the interface. Shared canonical IDs are
the bridges. All three pieces are available right now.

## Chapter 13: Composing Graphs\index{graph composition}

`\chaptermark{Composing Graphs}`{=latex}

Start a Claude Code session. Add two MCP servers: one for a kgraph-derived
Postgres graph of recent endocrinology literature, one for DBpedia. The model sees twelve tools: the six BFS-QL tools prefixed with
`bfs-ql.` and the same six prefixed with `dbpedia.`.
 The servers are identically structured. The model does
not know or care that one is backed by Postgres and the other by Virtuoso.
It knows only that each gives it six tools for navigating a graph.

This is not a specially engineered federation capability. No protocol
extension is required. No shared schema is negotiated in advance. The
two servers are independent; they know nothing about each other. What
makes them composable is not the protocol -- it is the identifiers.

### Identity Bridging\index{identity bridging}\index{canonical IDs!as bridges}

Desmopressin in the kgraph Postgres graph has the canonical ID `RxNorm:3251`.
Desmopressin in DBpedia has the URI
`<http://dbpedia.org/resource/Desmopressin>`,
which the SPARQL backend normalizes to `DBpedia:Desmopressin`.
 These are
different identifiers -- the graphs use different ID schemes. But both
entities carry an `RxNorm` property. An LLM that knows to look for it
can recognize that `RxNorm:3251` in one graph and `RxNorm: 3251` in the
DBpedia record refer to the same compound.

When graphs share a canonical ID scheme -- both use RxNorm for drugs, both
use MeSH for diseases -- bridging is automatic. The LLM queries the first
graph, finds `RxNorm:3251`, uses that ID as a seed in the second graph's
`bfs_query`, and traverses the boundary. No mapping table. No federation
protocol. The shared ID is the bridge.

When graphs use different ID schemes, bridging requires a step: take the
entity's label from the first graph ("desmopressin"), call `search_entities`
in the second graph with that label, inspect the results, and pick the
right match. This is the same disambiguation step the LLM performs at
the start of any session. The difference is that it is now cross-graph.

Composability is proportional to shared canonical identity. Two graphs
that both use RxNorm for drugs and MeSH for diseases can be traversed
as a single logical graph for any query that stays within those domains.
Two graphs with entirely bespoke ID schemes can be bridged only by label
matching, which is slower and more ambiguous. The degree of composability
is not a property of the BFS-QL protocol. It is a property of the graphs.

### What the LLM Actually Sees

In a session with two BFS-QL servers connected, the model sees something
like this in its tool list:

```
bfs-ql.describe_schema()
  -- medlit Postgres graph
bfs-ql.search_entities(query, ...)
bfs-ql.bfs_query(seeds, ...)
bfs-ql.describe_entity(id)
bfs-ql.describe_entities([id, ...])
bfs-ql.intersect_subgraphs(seeds, k, ...)

dbpedia.describe_schema()
  -- DBpedia SPARQL endpoint
dbpedia.search_entities(query, ...)
dbpedia.bfs_query(seeds, ...)
dbpedia.describe_entity(id)
dbpedia.describe_entities([id, ...])
dbpedia.intersect_subgraphs(seeds, k, ...)
```

The server name prefix is the only differentiator. The tool signatures
are identical. The session workflow is identical. A query that begins in
the kgraph graph -- orient, resolve desmopressin to `RxNorm:3251`, traverse
2 hops -- can continue in DBpedia by using `RxNorm:3251` (or the label
"desmopressin") as the seed for `dbpedia.search_entities`. The model
bridges graphs the same way a human researcher bridges databases: by
carrying a known identifier across sources.

The research literature graph knows what papers say about desmopressin --
which studies, which findings, which patient populations, which confidence
scores. The encyclopedic backbone knows what desmopressin *is* -- its
pharmacological class, its mechanism of action, its related compounds,
its place in the drug taxonomy. Together they give the LLM both the
frontier and the foundation. Neither graph has both. The composition does.

### The Canonical ID Argument, Revisited\index{canonical IDs!composition argument}

The companion volume argues for canonical IDs as a quality concern: an
entity that is anchored to a MeSH term or RxNorm code is unambiguous,
verifiable, and connected to a community of expert judgment. Here, the
same argument appears as a composition argument: that anchoring is what
makes the entity bridgeable across graphs.

The two arguments are not separate. They are the same observation from
different vantage points. A canonical ID is not just a unique key for
deduplication. It is a pointer into a shared epistemic commons -- the
accumulated judgment of a community about how to name and classify things
in a domain. When two graphs both point to that commons, they become
connected through it, without any bilateral coordination.

The biomedical, legal, chemistry, and geography communities built their
identifier infrastructures -- MeSH, MeSH, RxNorm, HGNC, ChEBI, PubChem,
Wikidata, GeoNames -- over decades for their own internal purposes:
literature indexing, regulatory compliance, compound tracking, geographic
reference. They were not building an interoperability layer for LLM
reasoning. But that is what they built, as a side effect of building a
shared commons. The emergent property was always latent in the
infrastructure. BFS-QL makes it accessible.

## Chapter 14: The Server Is Not the Point\index{BFS-QL!as active contract}

`\chaptermark{The Server Is Not the Point}`{=latex}

It is easy, when building infrastructure, to mistake the infrastructure
for the product. The MCP server starts, the tools register, the LLM
connects -- and the system works. It is tempting to call this the
achievement. It is not. The achievement is what happens next: an LLM
reasoning over a knowledge graph and reaching conclusions it could not
reach from any single document.

The server is not the point. The graph is the point. The server exists
to make the graph accessible. If the graph is not worth serving -- if its
entities are poorly extracted, its relationships are hallucinated, its
canonical IDs are inconsistent -- then a flawless MCP server delivers
nothing. The interface contract is only as valuable as what it connects to.

### Graph Quality as the Upstream Constraint\index{graph quality}

The BFS-QL interface exposes whatever the graph contains. It does not
validate, filter, or improve graph content. A relationship that was
extracted with low confidence appears in `bfs_query` results just as a
high-confidence relationship does -- the confidence score is metadata,
not a filter. An entity that was improperly deduplicated appears as two
nodes where one is the canonical representative and the other is a
stub pointing at it. A canonical ID that was assigned incorrectly
connects the entity to the wrong place in the epistemic commons.

These are upstream concerns. They belong to the extraction and curation
pipeline -- to the tools and processes covered in *Knowledge Graphs from
Unstructured Text*, and specifically to its Chapter 9, which covers
diagnostic queries for assessing graph health: entity type distribution,
predicate coverage, deduplication quality, ID resolution rates. The
question "is this graph worth serving?" should be answered before the
MCP server is provisioned, not after.

This is not a criticism of BFS-QL's design. It is the correct division
of labor. An interface that tries to compensate for graph quality issues
-- by silently filtering low-confidence edges, by resolving deduplication
conflicts on the fly, by guessing canonical IDs -- would be doing the
wrong work at the wrong layer. The interface should be transparent.
The graph owner is responsible for what it contains.

### What "Active Contract" Means\index{MCP!active contract}

The phrase *active contract* distinguishes BFS-QL from a passive data pipe.
A passive pipe -- a REST endpoint that returns graph data on demand -- is
indifferent to how its output is used. It has no opinion about session
workflow, query order, or what the caller should do with stubs. It just
serves data.

BFS-QL has opinions. The tool descriptions guide the LLM toward a specific
workflow: orient first, resolve names before traversing, start with
topology before requesting full metadata, use `describe_entity` for
expansion rather than re-querying. The server instructions warn about
`prov:` provisional IDs. The `describe_schema` tool is designed to be
called at session start, not on demand. The `topology_only` flag exists
because the server anticipates that full metadata is often unnecessary
for the first traversal.

These are not protocol features. They are epistemic scaffolding -- design
choices that encode knowledge about how LLMs reason over graphs and what
patterns of use lead to good outcomes. An LLM that follows the intended
workflow reaches better conclusions faster, with less context waste, than
one that queries arbitrarily. The contract is active because the server
is not neutral about outcomes.

### Minimal, Predictable, Describable\index{minimal surface area!as design principle}

The three properties that make an LLM tool interface work -- minimal,
predictable, describable -- are not independent. A larger surface area
is harder to describe accurately. An unpredictable interface (one whose
behavior depends on state, ordering, or undocumented invariants) is
harder to reason about. A surface that is both large and unpredictable
is practically unusable by a language model, which is why SPARQL fails
as an LLM interface despite being a powerful and well-designed query
language.

BFS-QL has six tools. Each does one thing. Each has the same behavior
every time it is called with the same arguments. Each is described in
a tool docstring that fits in a few sentences. The model can hold the
entire interface in its working context simultaneously. It does not need
to reason about which tool to use; the session workflow makes the order
explicit. It does not need to consult documentation mid-session; the
tool descriptions are self-contained.

These properties are not accidents of the current implementation. They
are design constraints that shaped every decision in Parts II and III.
The six-tool surface emerged from asking which operations are truly
distinct. The stub/full model emerged from asking how to keep response
size predictable. The `topology_only` mode emerged from asking what the
minimum useful response is. Minimal, predictable, and describable are
not virtues added at the end -- they are the criteria by which each
design choice was evaluated.

## Chapter 15: Open Source and the SaaS Layer\index{open source}\index{SaaS}

`\chaptermark{Open Source and the SaaS Layer}`{=latex}

The BFS-QL library is open source. This is not a purely ideological
choice, though there are ideological reasons for it. It is a strategic
choice informed by the specific position BFS-QL occupies: a developer
tool that bridges existing infrastructure (knowledge graphs, SPARQL
endpoints, Postgres databases) to a new capability (LLM reasoning over
structured data). Developer tools in this position benefit from open
source in ways that consumer products do not.

### What the Library Gives You\index{BFS-QL!library}

The open-source library provides:

- The `GraphDbInterface` ABC and all backend implementations (Postgres,
  SPARQL, Neo4j)
- The BFS traversal engine, stub/full filtering, topology mode
- The `CachedGraphDb` caching wrapper
- The `create_server()` function and the six-tool MCP server
- The `bfs-ql serve` CLI command for local deployment
- The test suite and integration test infrastructure

This is a complete, functional implementation. A developer with an
existing knowledge graph can clone the library, implement a backend
for their store (or use an existing one), and have a working MCP server
in hours. The library requires no license, no account, no API key.

The intended users of the raw library are developers, researchers, and
organizations with existing infrastructure: a company that runs its own
SPARQL endpoint, a research group with a Postgres graph of domain
literature, a developer building a domain-specific LLM application who
wants to add graph reasoning without depending on an external service.
These users have the technical capability to self-host and the privacy
or control requirements that make a hosted service unattractive.

### What the Hosted Service Adds\index{SaaS!hosted service}

The open-source library solves the single-graph, single-tenant,
developer-operated case. The hosted service solves everything else:

**Provisioning.** Connecting a new SPARQL endpoint or Postgres database
to a hosted BFS-QL server is a configuration operation, not a deployment
operation. The user provides a connection string; the service handles
the rest.

**Multi-tenancy.** Multiple users, multiple graphs, isolated sessions.
The library has no concept of tenants; the service does.

**Schema discovery.** For unknown or public endpoints (DBpedia, Wikidata,
ChEMBL), the service can probe the endpoint, build a partial schema, and
configure the BFS-QL server automatically. The library requires the user
to know their schema in advance.

**Managed caching.** The library's `CachedGraphDb` is session-scoped and
in-memory. The hosted service can maintain persistent, cross-session caches
for frequently queried graphs, reducing latency and backend load.

**Private endpoint support.** An organization with a knowledge graph behind
a firewall can configure the hosted service as a proxy, exposing the BFS-QL
interface to external LLM clients without exposing the raw endpoint.

**Uptime and query accounting.** The library has no monitoring, no rate
limiting, no audit log. The service does.

### The Elastic Playbook\index{open source!Elastic playbook}

Elastic (Elasticsearch) open-sourced its search engine and built a
multi-hundred-million-dollar business selling the managed service:
Elastic Cloud. MongoDB did the same. HashiCorp did the same with
Terraform and Vault. The pattern is well-established: open source the
library, sell the managed service.

The reasons it works in these cases are the same reasons it works for
BFS-QL:

First, the library is genuinely useful on its own. Open-source projects
that are deliberately crippled to push users toward the paid service
develop reputational problems. The library should be complete. Users who
self-host should not feel they are getting an inferior product.

Second, self-hosting has real costs. Setting up and maintaining a
production service -- monitoring, scaling, reliability, security patching
-- is expensive even when the software is free. The managed service
eliminates those costs. Users who value their time over control will
pay for it.

Third, the open-source library is the top of the funnel. Developers
who discover BFS-QL through the library, build something with it, and
then need to scale or simplify operations are the natural customers for
the hosted service. The library is marketing; the service is revenue.

### Why Open Source Is Right for the Library

Beyond strategy, open source is correct for BFS-QL's library for reasons
specific to its position.

**Community backends.** The eight-method interface is a specification.
A community of users implementing backends for their preferred graph
stores -- TigerGraph, Amazon Neptune, TerminusDB, RDFLib, ArangoDB --
extends BFS-QL's reach without requiring the core team to maintain
implementations for every possible backend. Open source is the mechanism
for this.

**Credibility with technical audiences.** The primary users of the
library are developers and researchers who will inspect the source code
before deploying it. Open source means they can. A black-box library
that asks them to trust its behavior without inspection is a harder sell
to a technical audience that has other options.

**The kgraph referral path.** The companion volume (*Knowledge Graphs
from Unstructured Text*) is itself directed at technical practitioners
who are building knowledge graphs. Its readers are exactly the users who
will want to serve those graphs through BFS-QL. An open-source library
that readers can install and run immediately, following the book's
instructions, is a better companion to the book than a hosted service
that requires account creation before the reader can try the first
example.

## Chapter 16: What Comes Next\index{future work}

`\chaptermark{What Comes Next}`{=latex}

BFS-QL as it exists today solves a specific problem: making a single
knowledge graph accessible to an LLM through a minimal, well-defined
interface. The solution is complete in the sense that it works -- the
medlit demo graph, the DBpedia SPARQL endpoint, any kgraph-derived
Postgres database can be served, connected, and queried. But complete
does not mean finished. Several directions are visible from here.

### Multi-Graph Federation\index{federation!multi-graph}

The composition model in Chapter 13 is manual: the LLM navigates across
graphs by carrying identifiers and calling `search_entities` in the
destination graph. This works, but it requires the LLM to be aware of
which graph to query at each step, to manage the bridging operation
explicitly, and to handle the case where a canonical ID in one graph does
not resolve in another.

A federation layer would make this automatic. Given a set of registered
BFS-QL graphs and a query, the federation layer would identify which
graphs are relevant, issue parallel BFS queries, and merge the results --
resolving identity conflicts using shared canonical IDs and presenting the
union as a single logical graph. The LLM would see one set of six tools,
not N sets.

The technical foundation for this exists. Shared canonical IDs provide the
merge key. The `GraphDbInterface` ABC provides the interface that every
backend already implements. The `CachedGraphDb` wrapper provides the
session-scoped caching that would extend naturally to a cross-graph scope.
What does not yet exist is the federation engine itself: the identity
resolution pass, the union semantics for conflicting metadata, the query
routing logic.

### Schema-Aware Query Optimization\index{query optimization!schema-aware}

BFS-QL currently fetches all edges from all nodes in the frontier at each
hop, then applies stub/full filtering to the results. For a well-connected
graph with many predicates, most of those edges may be irrelevant to the
query -- they will become stubs regardless. The traversal still issues the
backend calls, still acquires pool connections, still processes the rows.

Schema-aware optimization would use the `predicates` filter to prune
traversal before it happens. If the caller specifies
`predicates=["treats", "inhibits"]`, the backend's `edges_from` query
can include a `WHERE predicate IN (...)` clause, eliminating irrelevant
edges at the database level rather than after retrieval. The
`GraphDbInterface` would need to support optional predicate hints, or
a specialized `edges_from_filtered` method could be added for backends
that can use it efficiently.

This optimization matters most for large, densely connected graphs where
the majority of edges are structural noise for any given query. For the
medlit demo graph (99 edges total), it is irrelevant. For a Wikidata
subgraph or a large pharmaceutical compound graph, it could reduce
traversal time by an order of magnitude.

### Richer Traversal Primitives\index{traversal primitives!future}

BFS is the right primitive for LLM-driven graph exploration today, for the
reasons Chapter 3 argues: it starts from what the model knows, expands
outward, and produces a bounded, interpretable result. But BFS is not the
only useful traversal primitive, and as LLM context windows grow and
models become better at structured reasoning, richer operations become
viable.

Shortest-path queries -- "what is the shortest connection between compound
A and disease B?" -- are structurally different from BFS but expressible
as a composition of BFS calls. A dedicated `shortest_path` tool would be
more efficient and more explicit. Aggregate queries -- "which entity type
appears most frequently in the 2-hop neighborhood of this seed?" -- are
currently inexpressible in BFS-QL; they require the LLM to aggregate
BFS results manually, which is error-prone for large result sets.

These are not arguments to add these tools now. The six-tool surface is
correct for current LLM capabilities and context constraints. The argument
is that the eight-method ABC is designed to remain stable as the surface
above it evolves: new tools can be added to the MCP server without
changing any backend implementation. The ABC is the stable layer;
the tools are the variable layer. `intersect_subgraphs` is an example of
how this works in practice: it was added to the server layer without any
changes to the three existing backends.

### The Interface Contract as the Stable Layer\index{interface stability}

This is worth stating directly. Backends and LLMs will both evolve.
Postgres will add new features. SPARQL endpoints will grow. Neo4j's
query language will change. LLMs will get better at structured reasoning,
larger context windows, more reliable tool use. Any of these changes
might motivate changes to how BFS-QL works.

The eight-method ABC is designed to absorb these changes without
propagating them. A new backend for a new graph store implements the
same eight methods it would have implemented today. A new LLM with
larger context windows gets larger BFS results from the same `bfs_query`
tool; the interface does not change. A new traversal primitive can be added
as a seventh tool on the MCP server; existing backends continue to work
unchanged because the new tool is implemented in the server layer in
terms of the existing eight methods.

The design principle -- all intelligence in the server layer, all
backend-specific logic behind the ABC -- is what makes this possible.
The boundary between server and backend is not just an organizational
choice. It is the line along which the system can evolve without
breaking the parts that work.

### What Would Have to Change

It is worth asking what would have to happen for BFS-QL to become
inadequate as an interface. Several scenarios are plausible:

**LLM-native graph reasoning.** If future LLMs could natively reason
over graph structures -- not just flat text, but labeled property graphs
with adjacency semantics -- then the BFS-QL interface might be bypassed
in favor of direct graph access. This seems distant; the transformer
architecture has no graph inductive bias, and graph-native reasoning
would require architectural changes beyond what current scaling achieves.

**Context windows that eliminate the working-set constraint.** If context
windows grew to the point where dumping an entire knowledge graph was
computationally reasonable, the argument for selective BFS traversal
would weaken. At ten million tokens, you could load DBpedia. But the
quadratic attention cost means this is not merely a hardware scaling
problem -- it is structural. The working-set constraint does not go away
with larger windows; it becomes more expensive, not less.

**A better traversal primitive.** If a different graph access pattern --
not BFS, not random walk, not shortest path, but something not yet named
-- turned out to be more natural for LLM-driven reasoning, BFS-QL would
need to change. This is possible. BFS is motivated by the analogy to
how LLMs construct reasoning chains, but analogies are not proofs.

None of these scenarios is imminent. What this analysis reveals is that
BFS-QL's longevity depends most on the durability of the working-set
constraint. If context windows remain scarce relative to graph size --
which the transformer architecture strongly suggests they will -- then
selective, bounded traversal from known seeds will remain the right model.
The interface built around that model will remain correct.

# Appendix A: BFS-QL Protocol Reference

`\markboth{Appendix A: BFS-QL Protocol Reference}{Appendix A: BFS-QL Protocol Reference}`{=latex}

BFS-QL\index{BFS-QL!protocol reference} is a graph query protocol for
language model (LLM) consumption. It exposes a knowledge graph through
six MCP\index{MCP} tools with a flat query format. The LLM traverses
the graph by calling tools with natural-language seeds and structured
filters, receiving subgraphs shaped for context-window efficiency.

### The six tools\index{BFS-QL!six tools}

| Tool | Purpose |
|------|---------|
| `describe_schema()` | Orient: learn what the graph contains |
| `search_entities(query, ...)` | Resolve: map a name to canonical IDs |
| `bfs_query(seeds, max_hops, ...)` | Traverse: expand a neighborhood |
| `describe_entity(id)` | Expand: full metadata for one stub |
| `describe_entities(ids)` | Expand (batch): full metadata for multiple stubs |
| `intersect_subgraphs(seeds, k, ...)` | Intersect: nodes reachable from every seed |

### `describe_schema()`\index{describe\_schema}

**Arguments:** none

**Returns:**

```json
{
  "graph_description": "...",
  "comprehensive": true,
  "entity_types": ["Disease", "Drug", "Gene"],
  "predicates": ["TREATS", "INHIBITS", "ENCODES"],
  "next_steps": "...",
  "tool_usage_notes": "..."
}
```

**Fields:**

| Field | Description |
|-------|-------------|
| `graph_description` | Human-readable summary of the graph domain and data source. |
| `comprehensive` | `true` if lists are complete and exhaustive; `false` for large or open-world graphs where they are samples only. |
| `entity_types` | Valid type names for `bfs_query` `node_types`. May be empty. |
| `predicates` | Valid predicate names for `bfs_query` `predicates`. May be empty. |
| `next_steps` | Backend-authored workflow instructions. Follow these in preference to any generic default. |
| `tool_usage_notes` | Reference guide for all BFS-QL tools: parameter meanings, filtering rules, and critical usage patterns. |

When `comprehensive` is `false`, use `schema_summary` from an initial
`bfs_query` result to discover valid type and predicate values for the
local neighborhood.

### `search_entities(query, node_types=None)`\index{search\_entities}

Resolves a natural-language name or alias to canonical entity IDs.
Always call before `bfs_query` when you do not already have a
canonical ID.

**Arguments:**

| Field | Required | Description |
|-------|----------|-------------|
| `query` | Yes | Name, alias, or partial name to look up. |
| `node_types` | No | Restrict results to these entity types. Use to exclude high-volume types (e.g., papers) when resolving concept names. |

**Returns:** array of `EntityStub`\index{EntityStub}

```json
[
  {
    "id": "MeSH:D003480",
    "entity_type": "Disease",
    "name": "Cushing Syndrome",
    "score": 0.94
  },
  {
    "id": "MeSH:D047748",
    "entity_type": "Disease",
    "name": "Cushing Disease",
    "score": 0.91
  }
]
```

`name` is the entity's display name. `score` is the vector
similarity score (0--1, higher is better) when the backend uses
embedding-based search; `null` when full-text search is used instead.
Inspect results before choosing a seed -- common names are often
ambiguous. Use `entity_type` to distinguish concept entities from
papers or authors that share the same name.

### `bfs_query(seeds, max_hops, ...)`\index{bfs\_query}

Performs a breadth-first search from one or more seed entities.
Returns the union of their neighborhoods as a `BfsResult`. Filters
control the *detail level* of items in the result, not which items
are included -- non-matching nodes and edges always appear as
lightweight stubs.

**Arguments:**

| Field | Required | Default | Description |
|-------|----------|---------|-------------|
| `seeds` | Yes | -- | One or more canonical entity IDs. All seeds expand simultaneously; the result is the union of their neighborhoods. |
| `max_hops` | Yes | -- | Maximum graph distance from any seed. Values 1--3 are typical. |
| `node_types` | No | all | Matching nodes receive full metadata; others become stubs. |
| `predicates` | No | all | Matching edges receive full metadata; others become bare triples. |
| `topology_only` | No | `false` | When `true`, every node is a bare `{id, entity_type}` and every edge a bare triple. Overrides `node_types` and `predicates`. |
| `exclude_node_types` | No | none | Remove these types and all edges touching them entirely. Topology is no longer guaranteed complete. Use for high-volume types that add no conceptual value. |
| `min_mentions` | No | `1` | Remove nodes with `total_mentions` below this threshold (and touching edges). Nodes without a `total_mentions` field are always included. Filters the result, not the traversal. |
| `limit` | No | none | Cap the number of nodes returned. Counts always reflect the full traversal. |
| `offset` | No | `0` | Skip the first N nodes. Use with `limit` to page through large results. |

### `describe_entity(id)`\index{describe\_entity}

Retrieves full metadata for a single entity by canonical ID. Use
when `bfs_query` returns a stub and you want the full record for
that node.

**Arguments:**

| Field | Required | Description |
|-------|----------|-------------|
| `id` | Yes | Canonical entity ID. |

**Returns:** full node metadata as a flat dict -- the `id`,
`entity_type`, and all metadata fields merged at the top level.
Same keys as the `metadata` dict inside a full `Node`, but
without nesting.

### `describe_entities(ids)`\index{describe\_entities}

Retrieves full metadata for multiple entities in a single call. Use
instead of sequential `describe_entity` calls when expanding several
stubs at once.

**Arguments:**

| Field | Required | Description |
|-------|----------|-------------|
| `ids` | Yes | List of canonical entity IDs. |

**Returns:** list of full node metadata dicts, same shape as full
nodes in `bfs_query` results. IDs that do not exist in the graph
are silently omitted from the output.

### `intersect_subgraphs(seeds, k, ...)`\index{intersect\_subgraphs}

Returns only nodes within `k` undirected hops of *every* seed
simultaneously -- the intersection of their neighborhoods rather
than the union. Use when a multi-seed `bfs_query` returns too many
nodes for the LLM to intersect manually.

**Arguments:**

| Field | Required | Default | Description |
|-------|----------|---------|-------------|
| `seeds` | Yes | -- | Two or more canonical entity IDs. |
| `k` | Yes | -- | Hop radius (1--5). Every result node must be reachable from all seeds within this distance, treating edges as undirected. |
| `node_types` | No | all | Matching nodes receive full metadata; others become stubs. |
| `exclude_node_types` | No | none | Remove these types and all edges touching them. |
| `predicates` | No | all | Matching edges receive full metadata; others become bare triples. |
| `min_mentions` | No | `1` | Remove nodes with `total_mentions` below this threshold. |
| `topology_only` | No | `false` | When `true`, return IDs and types only. |

Returns an `IntersectionResult`:\index{IntersectionResult}

```json
{
  "seeds":      ["MeSH:D003480", "MeSH:D049970"],
  "k":          2,
  "node_count": 12,
  "edge_count": 15,
  "nodes":      [...],
  "edges":      [...],
  "schema_summary": {
    "entity_types_found": ["Drug", "Gene"],
    "predicates_found":   ["TREATS", "INHIBITS"]
  }
}
```

Note: `intersect_subgraphs` does not support `limit`/`offset`
pagination.

### Response format\index{BfsResult}

`bfs_query` returns a `BfsResult`:

```json
{
  "seeds":      ["MeSH:D003480"],
  "max_hops":   2,
  "node_count": 84,
  "edge_count": 99,
  "nodes":      [...],
  "edges":      [...],
  "schema_summary": {
    "entity_types_found": ["Disease", "Drug", "Gene"],
    "predicates_found":   ["TREATS", "INHIBITS"]
  }
}
```

`node_count` and `edge_count` reflect the full traversal regardless
of `limit`/`offset`. `schema_summary` reflects the full traversal
regardless of filters -- it always contains the actual types and
predicates present in the subgraph.

**Full node** (entity type matches `node_types`, or no filter):

```json
{
  "id":          "PUB:PMC2386281",
  "entity_type": "Publication",
  "metadata": {
    "name":   "The Diagnosis of Cushing's Syndrome",
    "source": "pubmed",
    "canonical_url": "https://pubmed.ncbi.nlm.nih.gov/18493314/",
    "confidence": 0.99,
    "total_mentions": 12
  }
}
```

Metadata keys vary by entity type and backend. Common keys across
backends: `name`, `source`, `canonical_url`, `confidence`,
`usage_count`, `total_mentions`, `synonyms`.

**Stub node** (entity type does not match `node_types`):

```json
{"id": "PERSON:67890", "entity_type": "Person"}
```

**Full edge** (predicate matches `predicates`, or no filter):

```json
{
  "subject":   "DRUG:rxnorm:41493",
  "predicate": "TREATS",
  "object":    "MeSH:D003480",
  "metadata": {
    "confidence":       0.91,
    "source_documents": ["PMC2386281", "PMC3367558"]
  }
}
```

Edge metadata always includes `confidence` and `source_documents`
(a list of document IDs supporting the relationship) when available.
Full provenance text is stored in the backend but stripped from
MCP responses to manage context size; use `describe_entity(id)`
on the source document node to retrieve it.

**Stub edge** (predicate does not match `predicates`):

```json
{
  "subject":   "DRUG:rxnorm:41493",
  "predicate": "INTERACTS_WITH",
  "object":    "DRUG:rxnorm:88014"
}
```

### Session workflow\index{session workflow}

The recommended sequence for any BFS-QL session:

```text
1. describe_schema()
   → learn entity types, predicates, graph description
   → follow next_steps instructions

2. search_entities(name, node_types=[...])
   → resolve name to one or more canonical IDs
   → use node_types to suppress high-volume types

3. bfs_query(seeds, max_hops=1, topology_only=True)
   → survey structure cheaply
   → read schema_summary for valid filter values

4. describe_entities([id, id, ...])
   → batch-expand stubs identified as significant
   → one call regardless of how many IDs

5. bfs_query(seeds, max_hops=1,
             node_types=[...], predicates=[...])
   → targeted re-query using filters from schema_summary
```

Steps 1 and 2 may be skipped when the server injects schema into
tool descriptions at startup. Steps 3--5 are iterative: each
traversal may reveal stubs that motivate further expansion or
re-query.

For large literature-derived graphs where a topology survey exceeds
the context budget, replace step 3 with a direct concept query:

```python
bfs_query(
    seeds=[seed_id],
    max_hops=1,
    exclude_node_types=["paper", "author"],
    min_mentions=2,
)
```

Use `intersect_subgraphs` in place of `bfs_query` when the question
is "what do all of these entities share?" and the result would be
too large for the LLM to intersect manually.

### Design properties\index{BFS-QL!design properties}

**Topology is always complete.**\index{topology!completeness} `node_types`
and `predicates` filters control detail level, not presence.
A stub node is not a missing node. `exclude_node_types` is the only
filter that removes items -- use it deliberately.

**Stubs are navigational handles.**\index{stub nodes} A stub in a
`bfs_query` result carries a canonical ID. Call `describe_entity(id)`
or `describe_entities(ids)` for full metadata. Seed a new `bfs_query`
at a stub to expand its neighborhood.

**`schema_summary` closes the vocabulary loop.**\index{schema\_summary}
For open-world backends where `describe_schema` returns
`comprehensive: false`, `schema_summary` provides the valid
`node_types` and `predicates` values for the actual neighborhood.
Read it after a topology survey before issuing filtered follow-up
queries.

**Multi-seed queries express relational questions.**
`bfs_query` with multiple seeds returns the *union* of neighborhoods.
`intersect_subgraphs` with multiple seeds returns the *intersection*.
Use `bfs_query` for "what connects to any of these?" and
`intersect_subgraphs` for "what do all of these share?"

### Implementation notes\index{BFS-QL!implementation notes}

**Caching.** Cache at the `GraphDbInterface` primitive level --
`edges_from`, `edges_to`, `get_node`, `metadata_for_node` -- keyed
on `(backend_id, method, args)`. All traversal intelligence in the
server layer benefits automatically. Cache `entity_types()` and
`predicates()` results for the lifetime of a session.

**Schema injection.**\index{describe\_schema!injection mode} At
startup, if the schema has fewer than ~20 entity types and ~30
predicates, inject valid values into the `bfs_query` tool description.
FastMCP supports dynamic tool descriptions. Above the threshold,
suppress injection and rely on `describe_schema()`.

**Async concurrency.**\index{GraphDbInterface!async design} All
`GraphDbInterface` methods are async. During BFS expansion, call
`edges_from`/`edges_to` and `get_node`/`metadata_for_node`
concurrently via `asyncio` to minimize latency on I/O-bound backends.

**Context-window budget.** Production deployments against
well-connected graphs should accept an optional `max_tokens` hint
and truncate or stub additional items when the estimated response
size approaches the budget. Approximate response sizes for a 2-hop
traversal over a moderately connected graph: ~110K characters with
full metadata, ~57K with provenance stripped, ~14K with
`topology_only=true`.

