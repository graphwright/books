---
title: "Principles of Reliable Machine Reasoning"
author: "Will Ware"
date: "2026"
publisher: "Graphwright Publications"
rights: "CC BY 4.0"
lang: en
---

## Foreword: A Manifesto for Machine Knowledge

`\markboth{Foreword}{Foreword}`{=latex}

Reasoning in high-stakes domains -- medicine, law, social infrastructure --
cannot run on the frailties LLMs are prone to: hallucination, misattribution,
confident error. Here, reasoning requires things, not strings.

Similarity is not identity. Retrieval is not reasoning.

The LLM is the extraction and language layer. The graph is the reasoning
substrate. Conflating those two roles is where most systems go wrong.

RDF got the atoms right. It left the chemistry uncontrolled. Three base vectors
supply that chemistry:

* A typed graph fixes the chemistry: a finite, closed vocabulary of entity types
  and predicates, each predicate with declared subject and object types. What
  falls outside the vocabulary is inexpressible, not merely discouraged.
  Category errors stop being possible to write down.

* Canonical IDs connect the graph to the edifice of human knowledge. Two
  sources that agree on an ID agree on a referent. Multi-hop causal reasoning
  becomes possible when identity is unambiguous.

* Provenance makes uncertainty composable: confidence can be tracked, combined,
  and audited, not just asserted. Inspectability makes correction possible.

This is the minimum standard. Not a guarantee of truth -- a guarantee that
truth is pursuable.

## Preface

My brother told an LLM:

> I live near a carwash and the weather is warm and sunny. I want to get
> my car washed. Should I walk or drive there?

and of course he was told that on a nice day like this, he could use the
exercise, so he should walk to the carwash. The model didn't know he would
need his car in order to get it washed. The wrong answer was delivered with
the same tone and confidence as a right one. That is the problem this book is
about.

Large language models\index{large language model} are fluent, capable, and
unreliable in ways that are hard to predict in advance. They fail not randomly
but systematically: at the boundary of what their training covered, at questions
that require grounded reasoning about specific domains, at any task where being
wrong matters. The fix is not to distrust them entirely. It is to give them
something reliable to reason from -- a structured, inspectable, domain-specific
representation of what is actually known. That is a knowledge graph.

This book argues that machine reasoning becomes trustworthy in proportion to
how precisely its knowledge is typed, sourced, and anchored to shared identity.
Strong typing, provenance, and ontology alignment are not three separate features
to weigh against each other — they are three conditions that must hold together
before a graph can be trusted.

Type systems in programming languages were originally invented as tools for
mathematical proof. They migrated into compilers not because mathematicians
demanded it but because programmers kept making the same classes of mistakes --
mistakes that a formal vocabulary of types makes structurally inexpressible.
The same logic applies to graphs. A graph with a closed vocabulary of entity
types and predicates, each predicate with a declared type signature, can
reject a category error at write time rather than propagating it silently
through every downstream query.

The book leads with the concrete. Chapter 2 walks through a complete working
system -- the Sherlock Holmes corpus, end to end, from raw text to in-memory
graph -- because the lived experience of building and querying a real typed
knowledge graph is the best argument for the discipline. The formal definition
lives in the Appendix, where it serves as a precise reference rather than a
barrier to entry.

Holmes is chosen deliberately: the stories contain disguises, false identities,
unreliable narration, and time-shifted revelations. These stress-test a typed
graph in ways a clean, well-curated corpus does not. Medical literature is the
second domain -- structurally different, higher stakes, and anchored to
established external ontologies.

Readers who work in other languages can engage fully with the conceptual
chapters and understand exactly what they would need to build. The code
examples use Python and the `ner_20260608` package, but the ideas are
language-independent.

## Introduction: Why Machines Need to Show Their Work

`\chaptermark{Why Machines Need to Show Their Work}`{=latex}

**What a Graph Actually Is**

Before any of the failure modes, base vectors, or formal definitions, it helps
to be precise about the basic object this book keeps returning to: a graph.

A graph is nothing more than a set of things and a set of connections between
them. Draw three dots on a page — Holmes, Watson, Baker Street — and connect
Holmes to Watson with a line, and Holmes to Baker Street with another. That is a
complete, if trivial, graph. The dots are usually called *nodes* or *vertices*;
the connecting lines are *edges*.

The first refinement is direction. "Holmes knows Watson" is naturally two-way —
if Holmes knows Watson, Watson knows Holmes too. But "Holmes lives at Baker
Street" only runs one way; Baker Street does not live at Holmes. Once edges have
direction, you can distinguish these cases, and a graph becomes a more faithful
model of how relationships actually behave.

The second refinement is labels. An unlabeled edge just says "these two things
are connected," which is barely more useful than a list of pairs. Label the edge
from Holmes to Watson `Knows`, and the edge from Holmes to Baker Street
`LivesAt`, and the graph starts to say something. Add labels to the nodes too —
`Person`, `Location` — and you can ask questions like "show me every `Person`
connected to a `Location` by `LivesAt`," which is the seed of everything this
book calls querying.

The third refinement is metadata. A real-world claim usually carries more than
just "this is connected to that." It carries *when* it was true, *how confident*
you are, *where it came from*. Attach these as extra fields on the edge — not as
separate nodes, just as data riding along with the connection — and the graph
starts to carry the kind of context a reasoning system actually needs.

That, in barest form, is what people mean by **Graph RAG**: instead of
retrieving raw passages of text and hoping a language model can piece together
the relationships buried inside them (plain RAG), you retrieve directly from a
graph where the relationships are already explicit, labeled, and traversable.
The retrieval step hands the model *structure*, not just *prose*.

You could implement the graph above in a few lines of Python, with no special
libraries at all:

```python
# nodes are just labeled strings
nodes = { "Holmes": "Person",
          "Watson": "Person",
          "Baker_St": "Location" }

# edges: a dict mapping each node to a list of (label, target) pairs
edges = {
    "Holmes": [ ("Knows", "Watson"),
                ("LivesAt", "Baker_St") ],
    "Watson": [ ("Knows", "Holmes") ]
}

# Q1: who does Holmes know?
print([tgt for lbl, tgt in edges["Holmes"] if lbl == "Knows"])
# → ['Watson']

# Q2: is there any path from Watson to Baker_St?
print(any(tgt == "Baker_St" for lbl, tgt in edges.get("Watson", [])))
# → False (not directly -- you'd need to go through Holmes)
```

That is the whole idea: nodes, directed labeled edges, and a couple of
dictionary lookups to ask questions of the structure. Everything else in this
book — types, predicates, provenance, canonical IDs, BFS, transitive closure —
is this same idea, made precise enough that a machine can use it without getting
confused.

### The structural failure mode

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
a domain expert can verify and dispute.

The book's core claim is this: in high-stakes domains, LLM\index{large language model}
hallucination is not a quirk to be tolerated but a structural failure mode with
real costs. Typed knowledge graphs with first-class provenance and ontology
alignment are a principled mitigation -- not a replacement for LLMs, but a
discipline that constrains and audits what they produce.

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

### The reasoning layer is not the extraction layer

A typed graph does not require a large language model to operate -- only to
build. The extraction layer is where LLMs earn their role: reading unstructured
text and producing structured claims. Once those claims are in the graph, the
reasoning substrate is simple, fast, and auditable: breadth-first traversal
over well-organized typed data.

This separation matters for more than architectural cleanliness. It means the
graph is future-proof in a way that an LLM-integrated system is not. The
extraction technology will change. The model that extracts claims today will
be replaced by a better one tomorrow. But the graph -- if it is typed, if it
has canonical IDs, if it has provenance -- remains the stable substrate. You
can re-extract from the same corpus with a better model, compare the new
triples against the old, and update selectively without discarding accumulated
reasoning.

### Machine reasoning needs what experts already have

Here is the argument for knowledge graphs, stated plainly: genuine reasoning
about a complex domain requires a representation that makes the structure of
that domain explicit, inspectable, and correctable. Not as an engineering
convenience. As an epistemological necessity.

There is a version of this argument that undersells itself. The weak version
says: machines need explicit knowledge representations because they cannot do
what humans do implicitly. The strong version -- the one worth making -- says:
humans need explicit knowledge representations too, for exactly the same
reasons, and the best human expertise already has them, just not written down
in a form that machines can use.

Think about what it means to be genuinely expert in a complex domain. A working
cardiologist does not hold relevant knowledge as a pile of facts. She holds it
as a structured web of relationships -- this drug potentiates that pathway, this
symptom cluster suggests this differential, this interaction is dangerous in
patients with this history. The knowledge is relational. It has direction. It
has confidence levels implicitly -- she trusts the large randomized trials more
than the case reports, the established mechanisms more than the preliminary
findings. She has, in effect, a knowledge graph in her head, built over years of
training and practice. What she does not have is an artifact that a machine can
query.

The knowledge graph is not a substitute for that expertise. It is an attempt to
make its structure explicit -- to take the relational model the expert has built
and put it in a form that can be shared, extended, corrected, and reasoned over
by systems that did not spend fifteen years in medical training.

The objection that large language models are getting better fast -- that the
case for explicit knowledge representation is really just a case for not-yet-
good-enough LLMs, and will dissolve as the models improve -- misses the point.
A more capable language model reasons better over its training distribution. It
does not, by virtue of being larger or better trained, acquire the specific,
curated, provenance-tracked model of *this* domain as *this* community of
experts currently understands it. That model is constructed through human
judgment, domain expertise, and deliberate curation. No amount of training data
substitutes for it, because training data reflects the past and the general,
while a curated knowledge graph reflects the present and the specific. A living
graph does not have to be behind the frontier of expert knowledge. An LLM
always is.

### Three base vectors

The book is organized around three properties that together make a knowledge
graph trustworthy. They are introduced here and elaborated throughout.

**Strong typing.**\index{strong typing} Every entity and every claim has a declared type.
Domain and range constraints are enforced by the type system, not runtime
string parsing. The insight that types prevent entire classes of errors was
discovered in the ML\index{ML (programming language)} and OCaml\index{OCaml} tradition and
formalized in Xavier Leroy's CompCert\index{CompCert} project -- a formally verified C
compiler whose correctness guarantee rests entirely on the discipline of types.
The argument here is not "use OCaml." It is that these people found something
real, and it applies to knowledge representations.

**Provenance tracking.**\index{provenance tracking} Every claim carries its origin. A
proposition without provenance is an unverifiable assertion. When provenance is
a first-class schema requirement -- not an afterthought -- any fact can be
traced to its source in a field lookup, not a search. This discipline makes
dispute resolution and epistemic auditing tractable.

**Alignment with authoritative ontologies.**\index{ontology alignment} Canonical IDs sourced
from community-curated authorities -- MeSH\index{MeSH}, UMLS\index{UMLS},
Wikidata\index{Wikidata}, Baker Street Wiki\index{Baker Street Wiki} -- rather than minted
ad hoc. Ad-hoc IDs are a traceability failure: they cannot be correlated across
documents, systems, or time.

There is a larger point here that is easy to understate. The canonical
identifier authorities -- MeSH for diseases, RxNorm for drugs, UniProt for
proteins, HGNC for genes -- were designed as identity resolution tools: a way
for different databases, research groups, and institutions to refer to the same
entity without ambiguity. They were not designed for LLM reasoning. But that is
what they have quietly become, because when two graphs both anchor their disease
entities to MeSH terms, a machine reasoner holding connections to both graphs
can traverse the boundary between them using only the shared canonical IDs.
No special protocol support. No federation layer. The shared canonical ID is the
bridge. It was always the bridge. It did not matter until machine reasoners
needed to cross it. Every knowledge graph that uses canonical IDs correctly is
automatically composable with every other one that does the same. Graphs that
mint their own IDs are islands.

### Tour of the book

Chapter 1 develops all three base vectors in depth and presents a
domain-neutral walkthrough of the five-stage ingestion pipeline. Chapter 2 is
the primary worked example: the Sherlock Holmes corpus, with a complete schema,
a running pipeline, and a queryable in-memory graph. Chapter 3 applies the same
architecture to medical literature, showing how a domain with strong external
ontologies looks different from one with only a fan wiki for authority. Chapters
4 and 5 cover the domain service and identity server -- the two components that
make entity resolution robust at scale. Chapter 6 is the payoff: the graph as a
reasoning surface, with worked query examples. Chapter 7 sketches the production
architecture for continuous ingestion. The Appendix provides the formal
definition for those who want to ground the concepts precisely.

## Chapter 1: The Base Vectors in Depth

`\chaptermark{The Base Vectors in Depth}`{=latex}

This chapter builds the conceptual vocabulary and architectural overview using
a domain-neutral example. No code from the worked domains yet -- those arrive in
Chapters 2 and 3. The goal here is to make the three base vectors concrete
enough that the design decisions in those chapters feel motivated rather than
arbitrary.

### Strong typing as a knowledge discipline

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

Types in a knowledge graph are Python classes, not strings. Domain and range
enforcement is the type system's job. The schema layer -- entity types, predicate
types, traits -- is fixed at design time. The instance layer is populated at
ingestion. What a predicate type *is*: a directed, typed, truth-bearing
proposition class. What a predicate instance *is*: one concrete claim, with a
subject, object, truth status, and provenance.

This matters most at scale. A knowledge graph built by hand, from a small
corpus, by a careful engineer, may stay coherent without mechanical enforcement.
A graph built by an extraction pipeline processing thousands of documents cannot
rely on human review at insertion time. The pipeline will produce malformed
triples. The only question is whether those triples are rejected immediately or
stored and discovered later, after they have joined the graph and influenced
derived facts.

#### Meaning is relational: a brief intellectual history

The intellectual lineage of the typed knowledge graph runs through two mid-
twentieth-century ideas that turned out to be more right than their authors
could fully demonstrate at the time.

Marvin Minsky's\index{Minsky, Marvin} 1974 paper "A Framework for Representing
Knowledge"\index{A Framework for Representing Knowledge (Minsky)} argued that
knowledge is not a list of facts -- it is a web of structured relationships.
When you walk into a restaurant you do not reason from first principles; you
retrieve a pre-existing frame with slots for host, menu, food, check, tip, and
fill in the details from observation. The relationships *are* the knowledge. A
node in isolation is just a label; a node embedded in a typed graph of
relationships to other nodes is a concept, with context, with implications, with
a place in a web of meaning.

Douglas Hofstadter's\index{Hofstadter, Douglas} argument in
*Gödel, Escher, Bach*\index{Godel Escher Bach@\textit{Gödel, Escher, Bach} (Hofstadter)}
sharpened this: meaning is not a property of individual symbols but of symbol
systems -- of the relationships and transformations between symbols. "BRCA1" as
a string of characters means nothing. It means something because of its typed
relationships to other nodes: it *encodes* a protein, it *increases risk* of
breast cancer, it *interacts with* other genes. The meaning is in the web, not
in the label.

The typed knowledge graph as built today is the realization of what both were
pointing at: a rigorous, computable, queryable structure where entities have
typed relationships and the graph itself carries meaning. The difference is that
Minsky and Hofstadter were working at the level of cognitive theory. We are
building infrastructure.

The bottleneck was always getting knowledge in. Expert systems\index{expert systems}
in the 1970s and 1980s encoded domain knowledge as explicit rules -- MYCIN\index{MYCIN}
could outperform medical residents on bacterial infection diagnosis. Cyc\index{Cyc}
attempted to hand-encode common sense at scale, accumulating millions of
assertions over decades. Every approach hit the same wall. The extraction step
that was supposed to be temporary never ended. The marginal cost of a new
extraction task dropped from months of annotation work to a prompt. That shift
changes everything. The rest of the analysis still applies.






The notion of a type system originates not in programming but in mathematical
logic, as a response to a crisis. In 1901, Bertrand Russell\index{Russell, Bertrand}
discovered that naive set theory contains a contradiction now known as Russell's
paradox\index{Russell's paradox}. The set of all sets that do not contain
themselves: does it contain itself? Either answer leads to a contradiction.

Russell's own remedy was the theory of types\index{type theory}. The key move
was to stratify mathematical objects into levels and to forbid any statement
that mixed levels. The paradox dissolved because the offending construction
tried to cross a level boundary the type system prohibited. Bad mathematics
became not just false but syntactically unformable.

Types migrated into programming languages through a series of increasingly
practical forms. ML introduced *inferred* types: the programmer need not
annotate every variable, because the compiler can deduce the types from how
values are used. Haskell\index{Haskell} and OCaml\index{OCaml} extended this to algebraic data types and
parametric polymorphism. The slogan that emerged from this tradition was "make
illegal states unrepresentable"\index{illegal states unrepresentable}: design your
types so that a program that compiles cannot reach an invalid state.

Rust\index{Rust} pushed this further with ownership types that track not just
what kind of data a value holds, but who owns it and for how long. Use-after-
free, double-free, and data races are type errors in Rust.

The through-line across this history is a bet: that certain classes of error
can be made structurally inexpressible -- not caught at runtime, not documented
in a README, but impossible to form in the first place. A typed graph places the
same bet on knowledge claims.

#### What the $E \subseteq V$ insight means

Classical graph formalisms treat vertices and edges as disjoint sorts. A typed
knowledge graph makes a single relaxation: every predicate instance is a full
member of the vertex set. This means a claim -- say, "Watson knows Holmes" --
can itself be the subject or object of another claim: "Watson came to know that
Holmes was alive at the moment of the Briony Lodge alarm."

This is not reification in the RDF sense. There is no wrapper node. The
`KnewAt` predicate simply declares its `object_` field as `BaseStatement`, and
any predicate instance can fill that role directly. Higher-order predication
comes for free, without structural overhead. The formal definition in the
Appendix makes this precise.

### Provenance as a first-class citizen

Every predicate instance carries a provenance sub-schema: a set of fields
declared in the field schema that record how the assertion was produced. The
minimum required fields for any predicate type are `source` (the origin of the
claim) and `extraction_method` (how it was derived).

This is architectural, not aspirational. Provenance that lives in a side
table, optional and sparsely populated, is not provenance in any meaningful
sense. Provenance that is required by the schema and enforced at construction
time is a constraint the system upholds unconditionally.

`truth_status` and provenance are distinct and both necessary. Truth status is
the graph's current epistemic commitment to a proposition. Provenance is the
audit trail behind that commitment. A claim with high-confidence provenance
from a reliable source may still be `disputed` (if contradicted) or `retracted`
(if overturned by new evidence).

The truth status lifecycle moves one way: `hypothetical` → `asserted_true` →
`disputed` / `retracted`. The extraction pipeline always produces
`hypothetical` claims. Promotion is a separate pass. This is a deliberate
invariant: the pipeline reports what it found, not what is true.

There are two ID regimes for predicate instances. Pipeline-extracted instances
get a unique ID per extraction event, preserving the full audit trail -- two
extractions of the same claim from two different passages are two distinct
members of $V$. Content-addressed instances use `statement_id()`, which
produces the same ID for the same `(subject, predicate, object)` triple --
re-extraction is confirmation, not a duplicate. The two patterns should not be
mixed in a single loading pass.

### Ontology alignment

Why are canonical IDs sourced from authorities worth the cost? Because ad-hoc
IDs are a traceability failure. An ID you mint yourself cannot be correlated
across documents, systems, or time. An ID sourced from a community-curated
authority -- a Wikidata QID, a MeSH identifier, a Baker Street Wiki URL -- is
shared by every system that uses the same authority. Two extractions from
different sources that agree on the ID agree on the referent without
negotiation.

Ontology authority is a domain-level choice. Different domains have different
authorities. For medicine: MeSH, UMLS, UniProt. For the Sherlock Holmes
corpus: Baker Street Wiki. What counts as authoritative is assessed by three
criteria: coverage (does it enumerate the entities this graph needs?),
stability (are its identifiers durable?), and community backing (is there an
organization accountable for its quality over time?).

Provisional IDs (`provisional:N`) are a principled fallback when no authority
match exists. They are not a failure signal -- they are the correct output for
entities the authority does not cover. Provisional entities are full graph
citizens: type constraints apply, edges reference them, evidence accumulates.
Promotion to a canonical ID is a later operation that does not require re-
running any pipeline stage.

The `id` field is never parsed to recover type. Type is the exclusive
responsibility of the Python class hierarchy and Pydantic's type system.
Display is entirely separate. `__str__` returns `display_name` for entities
that carry one, and `ClassName(subject → object)` for predicate instances.
It is a one-way presentation artifact, never parsed back.

### A hypothetical ingestion -- end to end

Before examining the Holmes and medical domains in detail, it is useful to
see the five pipeline stages in abstract, applied to a simple biography passage.

**Sentencize.** Raw text is split into numbered sentences emitted as JSONL.
Each record carries a sequential ID and a paragraph index. The numbering is
continuous across the document. Why JSONL: it is streamable, inspectable
without a database, and trivially resumable -- the highest existing ID tells
the stage where to restart after a crash.

**Coreference resolution.** Chunk-level entity/mention clusters are produced.
Each chunk is a window of sentences. The model returns, for each recognized
entity in the chunk, the list of spans that refer to it. A carry-in context
from the previous chunk handles references that cross chunk boundaries.

**Entity merge.** The per-chunk entity labels are resolved into a global entity
table with canonical IDs. This is the stage that calls the authority: Baker
Street Wiki, MeSH, or whatever the domain service configures. Entities that
receive an authority match get a `wiki:` or ontology-prefixed ID. Entities that
miss get `provisional:N`. Alias lists are accumulated and will be used by the
next stage.

**Event/moment extraction.** Discrete events and temporal anchors are extracted
as first-class entities. An event is something that *happened*; a moment is a
temporal anchor, optionally tied to a specific character's epistemic perspective.
These are not noun phrases -- they require narrative reasoning to identify, and
so this pass uses a frontier model rather than a local one.

**A note on LLMs vs. classical NLP here.** Named entity recognition and
relation extraction had become genuinely practical by the mid-2010s.
BioBERT\index{BioBERT} family models set benchmarks that were hard to dismiss.
But the brittleness showed up at the edges, and the edges were everywhere.
Domain adaptation\index{domain adaptation} required months of annotation per new
domain. The annotation treadmill\index{annotation} kept moving as schemas evolved.
Hedged language\index{hedging} ("the effect was attenuated") and implicit
relationships ("patients showed 40% reduction in tumor burden") routinely
defeated classical architectures that relied on statistical proxies for
semantic relationships. The honest summary: classical systems worked well on
easy cases and failed in ways that were hard to characterize on the hard cases.
LLMs change this not by being magic but by changing the economics: the marginal
cost of a new extraction task is a prompt. The cycle from "I want to extract
this relationship" to "I have a working extractor" is hours, not months.

**Triplet extraction.** Predicate instances are extracted by slot-filling
against the known schema. Given the complete entity/event/moment index and a
chunk of sentences, the model fills: subject (from the entity table), predicate
type (from the schema vocabulary), object (from the entity table), and
provenance fields. Every output record has `truth_status: hypothetical`. Domain
and range constraints are validated in Python, not in the prompt. Unknown
aliases and type mismatches are warned and dropped.

The design choices that look incidental here -- JSONL, continuous IDs, local
vs. frontier model allocation, `hypothetical` as a pipeline invariant -- all
become concrete and motivated in Chapter 2.

### Pipeline, domain service, and identity server

The three components of the architecture are cleanly separated by what they
know.

**The pipeline** is a sequence of stateless transforms over JSONL. Each stage
reads from one or more input files and writes to an output file. No stage has
in-memory state that persists across runs. Resume support is a first-class
requirement for multi-hour runs: each stage scans its existing output on
startup and skips already-processed records.

**The domain service** is the wall between domain knowledge and the rest. It
implements exactly three decisions: how to resolve a mention to an authority
ID (for Holmes: query Baker Street Wiki; for medicine: query MeSH/UMLS); how
to select a survivor when two entities merge (prefer canonical over provisional;
prefer longer canonical name); and what similarity threshold to use for
automatic synonym merging (literary circumlocutions need a lower threshold than
biomedical synonyms). Everything that surprised us about a domain belongs
inside this wall. The pipeline stages, the identity server core, and the graph
loader are domain-agnostic.

**The identity server** is the domain-agnostic core for entity resolution at
scale. It provides atomic `find-or-create` for canonical entities, a Redis
read-through cache for high-throughput per-mention resolution, and embedding-
based similarity search for automatic merge when entities exceed a threshold.
It calls the domain service for its three decisions; it knows nothing about
Baker Street Wiki or MeSH directly.

Chapter 4 covers the domain service in depth. Chapter 5 covers the identity
server. Neither is required for single-document, single-pass ingestion -- the
`scandal_instances.py` pattern in Chapter 2 works without either. Both become
essential for concurrent multi-document ingestion.

### Graph traversal -- a first look

The graph is an in-memory index over instances: `by_id` (ID → instance),
`out_edges` (entity ID → list of outgoing predicate instances), `in_edges`
(entity ID → list of incoming predicate instances). All lookup operations are
O(1) or O(degree).

BFS is the fundamental query primitive. It returns hop layers: `layers[0]` is
the seed set, `layers[1]` is everything reachable in one hop, and so on. BFS
traverses both outward and inward edges, so symmetric predicates (`Knows`) and
event participation (`Involves`) are reachable regardless of storage direction.
Statement nodes appear in hop layers, making higher-order predicates traversable
in later hops. The default truth-value filter is `asserted_true` only.

The asserted graph -- the projection of the edge set where `truth_status =
asserted_true` -- is the default traversal surface. Disputed and hypothetical
claims remain in the graph and can be queried directly, but they are excluded
from BFS and transitive closure by default. Overriding the filter is a
deliberate choice.

Chapter 6 develops traversal in depth, with worked examples from the Holmes
corpus.

## Chapter 2: The Holmes Corpus

`\chaptermark{The Holmes Corpus}`{=latex}

*A Scandal in Bohemia* is eight thousand words. It is self-contained, well-
known, and structurally demanding. The plot turns on identity concealment,
epistemic asymmetry, and one person's ability to out-think another -- which
means a schema that can faithfully represent the story must handle belief,
deception, temporal knowledge, and contested facts. That is exactly the kind
of stress test a typed knowledge graph needs.

This chapter walks through the complete Holmes pipeline: schema design, the
five ingestion stages, and the in-memory graph that results. Every design
choice is motivated by something the domain forced. The surprises are as
instructive as the clean parts.

### 2.1 Why Holmes?

Three properties make *A Scandal in Bohemia* an unusual choice for a knowledge
graph worked example, and all three are features rather than accidents.

**Epistemic richness.** The story is not just about what happened; it is about
who knew what and when. Watson narrates. Holmes deduces. The King conceals his
identity. Irene Adler\index{Adler, Irene} deceives Holmes about where she keeps
the photograph. Godfrey Norton appears and disappears in a way that Watson
witnesses but does not fully understand. A graph that only records facts --
*Irene lives at Briony Lodge, Holmes visited it on 21 March* -- misses most of
what is interesting. The schema needs to represent belief states, epistemic
moments ("Watson came to know that the King was in disguise at this moment"),
and the temporal dimension of knowledge.

**Literary circumlocution.** Doyle almost never calls his characters by the same
name twice in a row. The King is variously "my royal client", "His Majesty",
"Count Von Kramm", "a large man with a broad florid face and a strong assertive
chin", and his full name, Wilhelm Gottsreich Sigismond von Ormstein. A pipeline
that has to resolve all of these to a single entity under pressure from an
8,000-word corpus, with only a fan wiki as the authority, is a genuine stress
test for entity resolution.

**A thin external ontology.** Baker Street Wiki is a well-maintained fan wiki
with good coverage of the major characters and reasonable coverage of the
canonical locations. But it is not a curated ontology in the way MeSH or UMLS
are. Many incidental characters -- the groom Holmes bribes, the cab driver, the
witnesses at the wedding -- have no wiki page at all. The pipeline must handle
these gracefully, falling back to provisional IDs without failing.

These three properties together produce a domain where you cannot rely on the
ontology to do the hard work, where local models are not strong enough for the
reasoning-intensive passes, and where the schema needs to model epistemic
states -- not just physical facts. That combination forces every interesting
design decision that makes the architecture general.

### 2.2 The Holmes Schema

The schema is in `src/ner_20260608/holmes_schema.py`. It is the executable
specification: every type and constraint is enforced by Pydantic\index{Pydantic} at
construction time and by the Python type system statically. Designing the schema
was an inductive process -- it was built by annotating the story, not pre-
designed from first principles.

#### Entity types

Eight entity types cover the Holmes domain:

| Type | Purpose |
|------|---------|
| `Person` | A real individual: Holmes, Watson, Irene Adler, the King |
| `Persona` | A role a person plays: Count Von Kramm, the Clergyman |
| `Location` | A place: 221B Baker Street, Briony Lodge, London |
| `Object` | A physical thing: the cabinet photograph |
| `Document` | A written artifact: the King's note, Irene's letter |
| `Event` | A discrete occurrence: the fake fire alarm, the wedding |
| `Moment` | A temporal anchor for events and epistemic changes |
| `Plan` | A course of action (provisional) |

`Persona` is the first schema decision that the domain forced. Doyle uses
disguise as a plot device so heavily that it demanded its own type. A `Persona`
is not a `Person` -- it is a role played by a person. Holmes disguised as a
Nonconformist Clergyman and the King disguised as Count Von Kramm are both
`Persona` instances. The `DisguisedAs` and `HasTrueIdentity` predicates link
personas to their underlying persons. Without this distinction, the graph would
either merge the King and Count Von Kramm into the same node (wrong) or treat
them as separate people with no connection (also wrong).

`Moment` has an important epistemic variant. A `Moment` without a `narrator`
field is an objective time anchor: "Evening of 20 March 1888." A `Moment` with
a `narrator` is epistemic: it records the moment *from a specific character's
perspective*, i.e. the moment a person came to know something.

```python
moment_watson_sees_king_unmasked = Moment(
    id="sib:moment:watson_sees_king_unmasked",
    story_id=STORY,
    label="Watson witnesses the King remove his mask",
    narrator=watson,  # epistemic: Watson's moment of discovery
)

moment_kings_visit = Moment(
    id="sib:moment:kings_visit_evening",
    story_id=STORY,
    label="Evening of 20 March 1888 -- King visits Baker Street",
    # no narrator: objective timeline anchor
)
```

#### Predicate types and their traits

```python
class Knows(
    BaseStatement, ProvenanceMixin, EpistemicMixin, Symmetric
):
    subject: Person
    object_: Person

class LocatedIn(BaseStatement, ProvenanceMixin, Transitive):
    subject: Location
    object_: Location

class DisguisedAs(
    BaseStatement, ProvenanceMixin, EpistemicMixin,
    Inverse['HasTrueIdentity']
):
    subject: Person
    object_: Persona

class HasTrueIdentity(
    BaseStatement, ProvenanceMixin, EpistemicMixin,
    Functional, Inverse[DisguisedAs]
):
    subject: Persona
    object_: Person

class KnewAt(BaseStatement, ProvenanceMixin, EpistemicMixin):
    subject: Person
    object_: BaseStatement  # higher-order: any predicate instance
    moment: Moment

class Contradicts(BaseStatement, ProvenanceMixin, Symmetric):
    subject: BaseStatement  # both subject and object_ are statements
    object_: BaseStatement
```

The traits -- `Symmetric`, `Transitive`, `Functional`, `Inverse` -- are Python
mixin classes inherited alongside `BaseStatement`. They are introspectable at
runtime: `issubclass(LocatedIn, Transitive)` is `True`. The `Inverse` trait is
generic: `Inverse[DisguisedAs]` on `HasTrueIdentity` records the partner
predicate as a type-level annotation, making the inverse relationship recoverable
without any external lookup table.

`Functional` on `HasTrueIdentity` is a schema claim: each persona has exactly
one true identity. No persona is two people. The schema asserts this;
enforcement requires a separate validation pass (not yet implemented).

`KnewAt`\index{KnewAt} is the schema's most important design decision. Its
`object_` field is annotated as `BaseStatement` -- any predicate instance at
all. This enables sentences like "Watson came to know that the King was
disguised as Count Von Kramm at the moment the mask was removed." The target of
`KnewAt` is not a new Statement node; it is the existing `DisguisedAs` instance
-- a full member of $V$ that `KnewAt` simply points at:

```python
e_watson_knew_king_disguised = KnewAt(
    id=_sid(watson, KnewAt, e_king_as_count),
    subject=watson,
    object_=e_king_as_count,   # IS e_king_as_count, no wrapper
    moment=moment_watson_sees_king_unmasked,
    **_p(57, watson),
)
```

This is $E \subseteq V$ in practice: `e_king_as_count` is a `DisguisedAs`
instance and simultaneously a member of $V$ that any predicate whose range
includes `BaseStatement` can reference directly.

#### Provenance and epistemic mixins

Every predicate type in the Holmes schema inherits `ProvenanceMixin`:

```python
class ProvenanceMixin(BaseModel):
    story_id: str
    paragraph_index: int
    asserting_narrator: Person | None = None
    extraction_method: str
    extraction_confidence: float = Field(ge=0.0, le=1.0)
```

`paragraph_index` ties every claim to its location in the source text.
`asserting_narrator` is typically Watson, occasionally `None` for events
narrated in the omniscient voice. `extraction_confidence` is `1.0` for manually
annotated instances and a model-emitted float for pipeline-extracted ones.

`EpistemicMixin` adds `narrator_confidence`, for predicates where Watson's
expressed certainty is worth recording separately from extraction confidence:

```python
e_watson_knows_of_irene = Knows(
    id=_sid(watson, Knows, irene_adler),
    subject=watson, object_=irene_adler,
    **{**_p(63, watson), "extraction_confidence": 0.7},
)
```

#### Identity: canonical IDs and `__str__`

Every entity has an `id` -- a string assigned at construction that is never
derived from any other field and never parsed back. For persons and locations
with Baker Street Wiki pages, the id is the full wiki URL:

```python
holmes = Person(
    id="https://bakerstreet.fandom.com/wiki/Sherlock_Holmes",
    display_name="Sherlock Holmes",
)
```

For corpus-local entities with no external authority, it is a `sib:`
namespaced slug:

```python
evt_fake_fire_alarm = Event(
    id="sib:event:fake_fire_alarm",
    story_id=STORY,
    description=(
        "Holmes, disguised as a clergyman, stages "
        "a fake fire alarm at Briony Lodge."
    ),
)
```

Display is entirely separate. `__str__` returns `display_name` for entities
that have one, and `ClassName(subject → object)` for predicate instances:

```python
>>> str(holmes)
'Sherlock Holmes'
>>> repr(holmes)
"Person('wiki:Sherlock_Holmes')"
>>> str(e_king_as_count)
'DisguisedAs(Wilhelm ... von Ormstein → Count Von Kramm)'
```

No code anywhere in the system parses an `id` string to determine a type. That
is the type system's job.

#### Predicate IDs: content-addressed with `statement_id()`

For the manually annotated corpus, predicate IDs are content-addressed:

```python
def statement_id(
    subject_id: str,
    predicate_name: str,
    object_id: str,
) -> str:
    return f"stmt:{subject_id}:{predicate_name}:{object_id}"
```

Re-constructing the same fact from a different passage yields the same ID --
re-extraction is confirmation, not a duplicate. For the pipeline-extracted
JSONL, each triplet gets a unique ID per extraction event, preserving the full
audit trail.

### 2.3 The Ingestion Pipeline

The pipeline has five stages:

```
bohemia.txt
    ↓ sentencize.py
bohemia_sentences.jsonl
    ↓ coref.py
bohemia_coref.jsonl
    ↓ merge.py
bohemia_entities.jsonl  (global entity table, canonical IDs)
bohemia_mentions.jsonl  (flat mention index)
    ↓ events.py
bohemia_events.jsonl    (discrete events, participant links)
bohemia_moments.jsonl   (temporal anchors)
    ↓ triplets.py
bohemia_triplets.jsonl  (all truth_status = hypothetical)
```

Each stage is a stateless transform over JSONL. Intermediate files can be
inspected, re-run independently, or fed into other tools. All five stages
support resume: they read the existing output on startup and skip already-
processed records.

#### sentencize.py -- raw text to numbered sentences

The first decision is the splitter. Standard options (spaCy's sentencizer,
NLTK's punkt) trip on Doyle's abbreviations: "Dr.", "Mr.", "Mrs." all produce
false sentence boundaries. The LLM splitter sidesteps this entirely.

The approach: split the raw text on double newlines to get paragraphs (robust,
no LLM required), then send each paragraph to a local model (`qwen2.5:14b`\index{qwen2.5}
via Ollama) with a carry-in offset for continuous numbering. `temperature=0.0`
ensures deterministic output.

```json
{"id": 1,  "para": 1,
 "text": "To Sherlock Holmes she is always the woman."}
{"id": 2,  "para": 1,
 "text": "I have seldom heard him mention her under any other name."}
{"id": 42, "para": 11,
 "text": "His Majesty had hardly spoken before Holmes had sprung
  from his chair and advanced towards him."}
```

The `para` field is cheap and valuable: it provides a coarser locality signal
alongside `id` for downstream stages.

*A Scandal in Bohemia* produces 689 sentences across 218 paragraphs.

#### coref.py -- entity mention clusters

The coreference pass identifies which nouns and pronouns refer to the same
entity. The pass runs locally on `qwen2.5:14b`. Each call covers a window of
20 sentences with 3 sentences of carry-in context from the previous chunk. The
model returns:

```json
{
  "chunk_id": "1-20",
  "entities": [
    {
      "label": "Irene Adler",
      "type": "person",
      "mentions": [
        {"sentence_id": 1, "span": "the woman",
         "confidence": 0.95},
        {"sentence_id": 7, "span": "she",
         "confidence": 0.85}
      ]
    }
  ]
}
```

A context leak guard filters any mention whose `sentence_id` falls outside the
current chunk -- models occasionally pull IDs from the context block despite
instruction.

The coref pass runs entirely locally. This is the volume pass: 46 chunks for a
single story, each requiring one LLM call. At scale, local throughput matters
more than reasoning quality here -- the merge pass will correct clustering
errors.

#### merge.py -- global entity table

The coref pass produces per-chunk entity labels. The merge pass resolves them
into a global entity table with canonical IDs. It has three sub-passes.

**Pass 1 -- label clustering via Claude API.** All unique entity labels across
all chunks are sent to Claude in a single call. Claude has strong world-knowledge
of Holmes canon and can correctly merge "His Majesty", "the King", "Count Von
Kramm", "my client", and "Wilhelm Gottsreich Sigismond von Ormstein" into one
entity. A 14B local model cannot reliably do this.

The output is a set of clusters, each with a canonical label and an alias list:

```json
{
  "canonical": "Wilhelm Gottsreich Sigismond von Ormstein",
  "aliases": [
    "King of Bohemia", "Count Von Kramm", "the King",
    "my client", "His Majesty"
  ],
  "type": "person"
}
```

**Pass 2 -- Baker Street Wiki lookup with Claude judgment.** For each canonical
entity, the merge pass queries the Baker Street Wiki opensearch endpoint. This
returns candidate URLs by string similarity -- sufficient for "Irene Adler" but
unreliable for "the woman" (which might match an unrelated article). Instead of
accepting the opensearch result blindly, the pass sends the top candidates to
Claude for a binary judgment: is this the correct article for this entity, given
the story context? Entities that receive `null` get a `provisional:N` ID.

```json
{"canonical": "Irene Adler",
 "wiki_url": "https://bakerstreet.fandom.com/wiki/Irene_Adler",
 "entity_id": "wiki:Irene_Adler",
 "aliases": ["the woman", "the lady", "Irene Norton"]}

{"canonical": "the groom",
 "wiki_url": null,
 "entity_id": "provisional:14",
 "aliases": ["the ostler", "the groom"]}
```

**Post-merge deduplication.** Multiple clusters sometimes link to the same wiki
page -- the most common case is a character whose first name and full name
appear as separate coref clusters (Watson appeared as both "Dr Watson" and
"John"). The dedup pass groups by `entity_id` and merges: union the alias lists,
pick the longer canonical name, emit one record.

**Pass 3 -- mention rewriting.** Walk back through `bohemia_coref.jsonl` and
rewrite every mention's entity label to the canonical form, adding `entity_id`
and `wiki_url`. The output `bohemia_mentions.jsonl` is the primary query surface
for downstream stages.

#### events.py -- events and moments

Events and moments are corpus-local constructs that the coref pipeline does not
produce. They must be extracted separately.

This pass uses Claude. Identifying discrete events ("Holmes stages the fake fire
alarm at Briony Lodge") rather than states ("Irene Adler lives at Briony
Lodge"), and extracting temporal anchors tied to narrative moments, requires
narrative reasoning that `qwen2.5:14b` does not reliably provide.

Each Claude call covers a window of sentences with the known entity index
injected into the prompt. The model returns events and moments with participant
links using the entity IDs from `bohemia_entities.jsonl`:

```json
{"id": "sib:event:fake_fire_alarm",
 "description":
   "Holmes, disguised as a clergyman, stages a fake fire
    alarm at Briony Lodge.",
 "sentence_ids": [196, 197, 198],
 "para": 65,
 "participants": [
   "https://bakerstreet.fandom.com/wiki/Sherlock_Holmes",
   "https://bakerstreet.fandom.com/wiki/Irene_Adler"
 ],
 "extraction_confidence": 0.97}

{"id": "sib:moment:fake_fire_evening",
 "label": "Evening of 21 March 1888 -- fake fire alarm",
 "event_id": "sib:event:fake_fire_alarm",
 "narrator_id": null,
 "sentence_ids": [196],
 "extraction_confidence": 0.92}
```

A `SlugRegistry` enforces global uniqueness of `sib:event:` and `sib:moment:`
slugs within a run. A progress sidecar file records completed chunk IDs for
resume.

*A Scandal in Bohemia* produces 178 events and 36 moments.

#### triplets.py -- predicate instances

The triplet pass is the slot-filling stage. Given the full entity/event/moment
index and a chunk of sentences, the model identifies predicate instances:
subject, predicate type, object, and provenance fields.

This pass runs locally. By the time the triplet pass runs, the entity index is
complete and the predicate vocabulary is fixed. The model is not doing open NER
or creative reasoning -- it is filling slots from a constrained set of known IDs
and known predicate names. `qwen2.5:14b` handles this reliably.

**The alias scheme.** Injecting full Baker Street Wiki URLs into the prompt
produces poor results -- the model finds them unwieldy. Instead, the prompt uses
short aliases:

```
person:sherlock_holmes  →  Sherlock Holmes
person:dr_watson        →  Dr. John H. Watson
location:briony_lodge   →  Briony Lodge, Serpentine Avenue
```

The alias table is built from the entity JSONL and includes all known aliases
from the clustering pass. A validator expands aliases back to canonical IDs and
enforces domain/range constraints. Model output referencing an unknown alias is
warned and dropped; model output with a valid alias but a type mismatch is also
dropped.

**Event window filtering.** Only events and moments whose `sentence_ids` fall
within ±15 sentences of the current chunk are injected into the prompt.
Injecting all 178 events produces slow generation and worse output.

**Output convention.** Every predicate instance in the pipeline output has
`truth_status: "hypothetical"`. This is a schema-level invariant: the pipeline
reports what it extracted, not what is true. Promotion is a separate pass.

```json
{"id": "trip:042",
 "predicate": "AssociatedWith",
 "subject_id": "wiki:Irene_Adler",
 "object_id": "wiki:Briony_Lodge",
 "truth_status": "hypothetical",
 "story_id": "scandal_in_bohemia",
 "paragraph_index": 118,
 "asserting_narrator_id": "wiki:John_Watson",
 "extraction_method": "llm-triplet-extraction",
 "extraction_confidence": 0.93,
 "sentence_ids": [118, 119]}
```

### 2.4 Loading: The Fixpoint Problem

The five pipeline stages produce JSONL. The loader (`loader.py` in the
`ner_20260608` package) hydrates these records into live Pydantic instances.
Most hydration is straightforward: read the record, look up subject and object
IDs in the `InstanceSet`, construct the predicate instance.

Higher-order predicates break this pattern. `KnewAt` takes a `BaseStatement` in
its `object_` field -- meaning it can only be constructed after the target
predicate instance has been built. In file order, a `KnewAt` record pointing at
a `Knows` record may appear before the `Knows` record. Worse, a `Contradicts`
may point at a `KnewAt` that points at a `Knows`, requiring three passes to
resolve.

The loader handles this with a fixpoint loop\index{fixpoint loop}. On the first
pass, all first-order predicates are hydrated immediately. Higher-order
predicates are deferred. The deferred list is retried in a loop until it stops
shrinking:

```python
while deferred:
    remaining = []
    for rec in deferred:
        subject_id = rec.get("subject_id")
        object_id  = rec.get("object_id")
        if (
            (subject_id and iset.get(subject_id) is None)
            or (object_id and iset.get(object_id) is None)
        ):
            remaining.append(rec)
            continue
        _hydrate_one_triplet(rec, pred_cls, iset)
    if len(remaining) == len(deferred):  # no progress
        for rec in remaining:
            iset.warnings.append(
                f"higher-order triplet {rec['id']!r}: "
                f"referent(s) unresolvable -- skipping"
            )
        break
    deferred = remaining
```

The termination condition is key: the loop exits when the *deferred set* stops
shrinking, not when the global instance set stops growing. The distinction matters
when some higher-order triplets have genuinely unresolvable referents. Keying on
global growth would re-attempt those records on every pass until other chains
exhausted -- an O(n²) waste. Keying on deferred-set shrinkage terminates in one
extra iteration after the last resolvable record is processed.

### 2.5 The In-Memory Graph

`graph.py` provides the in-memory index. Construction is O(n) over the instance
set; all subsequent operations are O(degree) or better.

```python
from ner_20260608 import load_bohemia_graph

g = load_bohemia_graph()  # ~100ms; loads bundled JSONL from wheel

holmes = g.get("wiki:Sherlock_Holmes")
print(holmes)      # Sherlock Holmes
print(repr(holmes))  # Person('wiki:Sherlock_Holmes')
```

Both the `wiki:` slug form and the full Baker Street Wiki URL are valid lookup
keys -- `_canonicalize_id` normalizes full URLs to slug form internally.

#### Traversal: edges_from and edges_to

```python
from ner_20260608.holmes_schema import Possesses, Involves

# What does Irene Adler possess, per asserted facts?
edges = g.edges_from(
    "wiki:Irene_Adler",
    pred_type=Possesses,
    truth="asserted_true",
)
for e in edges:
    print(f"  {e.object_.display_name}")

# What events involve Irene Adler?
events = g.edges_to(
    "wiki:Irene_Adler", pred_type=Involves
)
for e in events:
    print(f"  {e.subject}")
```

`edges_from` and `edges_to` accept a `truth` parameter that can be a string
value (`"asserted_true"`), a `TruthStatus` enum member, or a set of either. No
filter means return all edges regardless of truth status.

#### BFS

```python
layers = g.bfs(["wiki:Sherlock_Holmes"], max_hops=2)
# layers[0] = {'wiki:Sherlock_Holmes'}
# layers[1] = IDs reachable in one hop
# layers[2] = everything reachable in two hops
```

BFS traverses both outward and inward edges, so symmetric predicates (`Knows`)
and event participation (`Involves`) are reachable regardless of the direction
they were stored. Statement nodes are added to layers -- a `KnewAt` reachable
in hop 1 makes the statement it points at reachable in hop 2. The default
`truth_values=('asserted_true',)` filter excludes hypothetical and disputed
claims from traversal.

#### Transitive closure

```python
from ner_20260608.holmes_schema import LocatedIn

reachable = g.transitive_closure(
    "wiki:221B_Baker_Street", LocatedIn
)
# → {'wiki:London'}
```

`LocatedIn` is declared `Transitive` in the schema. The transitive closure
follows it recursively through the asserted graph.

> **Note on `scandal_instances.py`:** This file is in the source repository
> under `src/` and is not shipped in the wheel. On a clean install,
> `import scandal_instances` will fail. Use `Graph.from_module` with the repo
> on the path, or run from the repo root with `pdm run python`.

#### Temporal queries: sentence_cutoff

`load_bohemia_graph(sentence_cutoff=N)` loads only triplets whose `sentence_ids`
are all strictly less than N. This builds a temporally-bounded subgraph:
everything the graph knew before sentence N.

```python
CUTOFF = 485  # Holmes says "You have the photograph?"

pre = load_bohemia_graph(sentence_cutoff=CUTOFF, warn=False)

# Is the Possesses edge in the pre-cutoff graph?
photo_edges = pre.edges_from(
    "wiki:Irene_Adler",
    pred_type=Possesses,
    truth="asserted_true",
)
# → []  (the Possesses edge is at sentence 511)
```

This is useful for reasoning about what the characters could have known at any
point in the narrative. Combined with `KnewAt` edges and their attached `Moment`
instances, it enables questions like: "What did Watson know, and when did he
come to know it, as of sentence 200?"

### 2.6 Design Decisions and Their Consequences

**Local vs. frontier allocation.** The coref and triplet passes run on a local
`qwen2.5:14b` model. The clustering and event extraction passes use Claude via
the API. This division reflects the nature of each task. Coref and triplet
extraction are slot-filling against constrained schemas; the local model is
adequate and the volume is high. Clustering requires narrative world-knowledge
that the local model does not have; event extraction requires reasoning about
states vs. actions that the local model consistently gets wrong. The frontier
model is used only where reasoning quality is the bottleneck.

**The domain service wall.** Every surprise in the Holmes pipeline lived inside
the domain service boundary: spurious wiki links, the "John"/"Dr Watson"
deduplication bug, the alias scheme for prompt injection. None of these forced
changes to the loader, graph, or schema. That is the test of a clean boundary,
and it passed.

**Provisional IDs as principled output.** `provisional:N` IDs are not failures
-- they are the correct output for entities that have no Baker Street Wiki page.
The pipeline produces a queryable graph even with partial ontology coverage.
Provisional entities can be manually upgraded to canonical IDs in a later pass
without re-running any pipeline stage.

**`truth_status: hypothetical` as a pipeline invariant.** The pipeline never
promotes claims to `asserted_true`. That is a deliberate choice: the pipeline
reports what it extracted, not what is true. Promotion requires a judgment the
pipeline is not equipped to make automatically. The manually annotated
`scandal_instances.py` has `truth_status: asserted_true` throughout because
every claim in it was verified by a human against the source text.

**The unified Statement model.** The decision to make $E \subseteq V$ --
every predicate instance a full member of the vertex set -- eliminated what
would otherwise have been a separate reification mechanism. `KnewAt` and
`Contradicts` simply declare their domain or range as `BaseStatement` and get
higher-order predication for free. There is no Statement node type, no three-
edge structural overhead, no multi-hop traversal tax for the common case. The
fixpoint problem in the loader is the only complexity this introduces, and it
is tractable.

## Chapter 3: Medical Literature

`\chaptermark{Medical Literature}`{=latex}

> **This chapter is a placeholder. The medical schema and pipeline are not yet
> implemented. The design is sketched here as a contrast to the Holmes corpus.**

### 3.1 Why medical literature?

Medicine is the right second domain for several reasons that Holmes alone cannot
demonstrate. Where the Holmes corpus is a closed literary universe with a
fan-maintained wiki as its authority, medical literature has established
authoritative ontologies built by large professional communities over decades.
Where Holmes's epistemic complexity comes from narrative structure and deliberate
misdirection, medicine's complexity comes from genuine scientific uncertainty,
hierarchical disease classification, and evidence grading that must be first-
class in the schema.

**Established, community-curated ontologies.** MeSH\index{MeSH} covers diseases,
drugs, and biological processes and has served biomedical literature indexing
since 1963. UMLS\index{UMLS} provides cross-ontology harmonization. UniProt\index{UniProt}
covers proteins. OMIM covers genetic conditions. These do most of the entity
resolution work that Baker Street Wiki cannot.

**Structured abstracts.** Background, Methods, Results, Conclusions sections
provide coarse provenance for free. A claim in Results has different epistemic
weight than one in Discussion.

**High entity reuse across papers.** "IL-6", "interleukin-6", and "interleukin
6" in 300 papers all resolve to the same MeSH ID without any LLM involvement.
By paper 200, most common entities are cached; the marginal LLM cost per paper
approaches zero.

**Different epistemic needs.** Belief states and deception (the Holmes
machinery) are largely irrelevant. Provenance and confidence carry more weight.
`disputed` maps to conflicting study results rather than character deception.

### 3.2 The medical schema

> **[Placeholder -- schema not yet implemented]**

Sketch of entity types: `Drug`, `Disease`, `Gene`, `Protein`,
`ClinicalTrial`, `PatientCohort`, `Measurement`. Predicate types: `Treats`,
`AssociatedWith`, `InhibitsPathway`, `IndicatesRiskOf`, `Administered`,
`Measured`. Higher-order predicates: `SupportedBy` (one claim supported by a
finding) and `Contradicts` (reused from the Holmes schema).

Domain/range for medical is tighter and more checkable than Holmes:
`Treats(Drug, Disease)` is wrong if the subject is a `Gene`. The type system
catches this at construction time.

### 3.3 The ingestion pipeline for medical literature

> **[Placeholder -- design is sketched, not implemented]**

**Sentencize** -- same approach, minimal change. Medical prose is more regular
than literary prose.

**Coref** -- same local approach. Medical coref is simpler (less circumlocution)
but entity mention density is higher.

**Merge / entity resolution** -- the key difference from Holmes: MeSH/UMLS
lookup replaces Baker Street Wiki, and most common entities resolve without LLM
judgment. The Claude judgment pass only fires on ontology misses -- a small
fraction of calls for a mature medical corpus.

**Events** -- largely absent as a concept in medical literature. Replace with
*findings*: a Measurement or Result tied to a study and a cohort.

**Triplets** -- same local slot-filling approach. The finite predicate
vocabulary does more work here because medical relationship types are more
standardized.

### 3.4 Per-mention resolution vs. batch clustering

The Holmes pipeline batches all labels per story and sends one clustering call
to Claude. For medical literature at scale (hundreds of papers), the better
approach is per-mention resolution: each label hits the IdentityServer
immediately, MeSH/UMLS lookup returns a canonical ID on contact, and the LLM
is only invoked for cache misses that also miss the ontology.

### 3.5 The Cushing's syndrome case study

> **[Placeholder -- reference to earlier work on a specific paper]**

## Chapter 4: Domain Services -- What the Wall Contains

`\chaptermark{Domain Services}`{=latex}

Both domain services implement the same interface -- `DomainPolicy` / 
`DomainClient` -- but look completely different inside. The contrast reveals
what belongs inside the domain service wall and why.

### 4.1 The DomainPolicy contract

Three methods:

- `resolve_authority(mention, entity_type, context)` → canonical ID or null
- `select_survivor(cluster)` → preferred canonical name when merging clusters
- `synonym_criteria(entity_type)` → similarity threshold for auto-merge

Everything outside this wall -- the identity server core, all pipeline stages
that call it, the graph and loader -- is domain-agnostic.

### 4.2 The Holmes domain service

- `resolve_authority`: Baker Street Wiki opensearch → Claude judgment
  (accept/reject candidate)
- `select_survivor`: prefer longer canonical name ("Dr Watson" beats "John")
- `synonym_criteria`: lower threshold than medical (around 0.75) -- literary
  circumlocutions are semantically looser than biomedical synonyms
- `resolve_batch`: optional extension for holistic clustering ("my client" is
  ambiguous in isolation, obvious in context of the full label set for a story)

### 4.3 The medical domain service

> **[Placeholder -- design sketched, not yet implemented]**

- `resolve_authority`: MeSH/UMLS API lookup (deterministic, no LLM)
- `select_survivor`: prefer the ontology's preferred label; fall back to most
  specific name
- `synonym_criteria`: higher threshold -- "IL-6" and "interleukin-6" should
  merge; "IL-6" and "IL-8" should not
- `resolve_batch`: largely unnecessary -- ontology linkage handles what
  clustering would otherwise do

### 4.4 What the contrast reveals

**The wall works.** Every surprise in the Holmes pipeline lived inside the
domain service; the identity server core and all pipeline stages were untouched.

**The `resolve_batch` extension is Holmes-specific.** It is a Holmes-specific
optimization driven by the property that batch clustering is better than per-
mention resolution for literary text. It is an extension to the contract, not a
change to it.

**The synonym threshold is domain-specific knowledge.** Medical literature needs
a tighter threshold; literary text needs a looser one.

**Scaling characteristics differ.** The Holmes domain service makes many LLM
calls relative to entity count; the medical service makes almost none for a warm
cache.

### 4.5 When the ontology changes

The domain spec carries a version field. The identity server records which
schema version was active when each edge was ingested.

**Deprecated predicates** are flagged, not deleted. Edges using a deprecated
predicate are marked and routed to a review queue. Actual removal is a
deliberate, logged operation.

**Tightened constraints** produce migration items, not errors. An edge valid
under schema version 2.1 but violating version 2.3 is a migration item --
"this edge became malformed because the schema tightened" -- distinct from an
extraction error.

**Predicate renaming** follows the deprecate-old, introduce-new pattern, with a
migration script that records the transformation in the provenance record. The
transformation is auditable after the fact.

## Chapter 5: The Identity Server

`\chaptermark{The Identity Server}`{=latex}

### 5.1 What the identity server does

The extraction pipeline reads unstructured text and produces structured output:
subject, predicate, object, with subject and object expressed as mention
strings. "Holmes" appears as a subject string. "Baker Street" appears as an
object string. These strings are not entities. They are references to entities
-- references that may be ambiguous, inconsistent across passages, and
duplicated across dozens of story chapters.

The identity server\index{identity server} is the bridge: it provides atomic
`find-or-create` for canonical entities, a Redis read-through cache for high-
throughput per-mention resolution, and embedding-based similarity search for
automatic merge when entities exceed a threshold.

### 5.2 Why a service, not a library

The obvious alternative to a service is a library. A library would work
correctly for a single-process pipeline running sequentially. It fails under
the conditions where knowledge graph construction actually operates.

Real ingestion pipelines run many workers in parallel. Worker A is processing
chapter three of *The Hound of the Baskervilles*; worker B is processing
chapter seven; both extract a mention of "Stapleton." Without a shared service,
both may mint a new provisional entity for "Stapleton." The graph now has two
provisional nodes for the same character.

A service with a database and advisory locking\index{advisory locking} solves
this. When two workers race to create "Stapleton," exactly one wins; the other
receives the same ID. Cross-process uniqueness is enforced by the service.

### 5.3 When you need it

You need the identity server when:

- **Concurrent ingestion** -- multiple workers processing documents in parallel;
  entity resolution must be atomic across workers
- **Multiple sources** -- entities appearing in both extracted JSONL and hand-
  authored instances must resolve to the same canonical ID
- **Long-running corpus** -- provisional IDs assigned in batch 1 may be
  upgraded or merged by batch 100; the identity server tracks the full lifecycle

You do not need it when:

- Single-document manual curation (the `scandal_instances.py` pattern)
- Small, single-pass ingestion with no concurrency
- Prototype or exploratory work where provisional IDs are acceptable final output

### 5.4 The lookup chain

The lookup chain\index{lookup chain} applies resolution strategies in order,
stopping when a match is found, ordered by cost.

**Exact match.** The mention string is looked up verbatim in the synonym table.
A single indexed database lookup. Handles all mentions that have been seen
before in exactly this form -- the majority of cases in a large corpus.

**Fuzzy match.** The mention string is compared against all known surface forms
using a string-similarity metric. Handles abbreviations, misspellings, and minor
variations. "Sherlock Homes" resolves to Sherlock Holmes. A configurable
threshold prevents false positives.

**Embedding similarity.** The mention is embedded and compared against stored
surface form embeddings via approximate nearest neighbor search. Catches
semantic equivalence that string methods miss. Most expensive; reserved for
cases the cheaper methods cannot handle.

**Authority lookup.** The domain service's `resolve_authority` method is called
with the mention string and entity type. If successful, the canonical ID is
added to the local synonym table for exact-match resolution on all future
encounters.

If all four stages fail, a provisional entity is minted. The chain is ordered
by cost, not sophistication. Embedding similarity is last because it is
expensive, not because it is less accurate.

### 5.5 Entity lifecycle

Every entity has one of three statuses, and transitions are one-way.

**Provisional.**\index{provisional entity} Created from a mention that did not
match any known authority. Participates fully in the graph -- relationships
reference it, evidence accumulates -- but flagged as unanchored.

**Canonical.**\index{canonical entity} Anchored to an external authority.
Promotion from provisional to canonical happens when the lookup chain finds an
authority match, either at creation time or later as more surface forms
accumulate.

**Merged.**\index{merged entity} Absorbed into another entity. Merged entities
retain their full history but are no longer active graph nodes. All
relationships referencing a merged entity transparently resolve to the survivor.
Merged status is terminal.

### 5.6 Advisory locking in Postgres

Before creating a new entity, the base server acquires a Postgres\index{Postgres}
advisory lock keyed on the hash of `(mention, entity_type)`. The first worker
acquires the lock, checks for an existing entity, finds none, creates one, and
releases the lock. The second worker acquires the lock, checks for an existing
entity, finds the one the first worker just created, and returns its ID without
creating a duplicate.

Advisory locks are the right tool here rather than standard transactions because
the resolution operation spans multiple queries -- a lookup, possibly an
authority call, an insert, a cache update. Holding a transaction open across all
of that would serialize concurrency more than necessary.

### 5.7 The identity server HTTP interface

`POST /resolve` is the primary operation. The caller supplies a mention string
and an entity type; the server returns a canonical ID. The operation may mint a
provisional entity -- that is a write, and it belongs on a POST. The endpoint
is idempotent: repeated calls with the same arguments return the same ID.

`POST /promote` elevates a provisional entity to canonical status. The caller
supplies the provisional entity ID and the canonical ID to assign. The caller
supplies the canonical ID rather than the server computing it because authority
lookup is domain knowledge that lives in the domain service.

`POST /merge` declares two entities to be the same. The server calls the domain
service's `select_survivor` method to determine which record survives, redirects
all relationships from the non-survivor to the survivor, and marks the non-
survivor as merged. Merge requires an explicit call rather than happening
automatically because merges are irreversible.

`GET /entity/{id}` returns the full record for an entity: current status, all
known surface forms, the full provenance audit trail, and -- if canonical -- the
authority name and ID.

## Chapter 6: Querying -- The Payoff

`\chaptermark{Querying -- The Payoff}`{=latex}

The graph is only useful if you can ask it questions. This chapter walks through
the `ner_20260608` graph API in depth, with worked examples from the Holmes
corpus. The five-minute introduction comes first; the deeper worked example and
specialized query patterns follow.

### 6.1 Five-minute introduction

```python
from ner_20260608 import load_bohemia_graph

g = load_bohemia_graph()  # loads bundled JSONL, ~100ms

# Direct lookup -- wiki: prefix or full URL both work
holmes = g.get("wiki:Sherlock_Holmes")
print(holmes)       # Sherlock Holmes
print(repr(holmes)) # Person('wiki:Sherlock_Holmes')

# describe() delegates to str()
print(g.describe("wiki:Irene_Adler"))  # Irene Adler

# Who does Watson know (asserted true)?
edges = g.edges_from(
    "wiki:John_Watson", truth="asserted_true"
)
g.print_edges(edges)
# → Knows(Dr. Watson → Sherlock Holmes)  [asserted_true]
```

### 6.2 Evidence assembly just before the revelation

This example builds a temporally-bounded subgraph -- everything up to but not
including the moment Holmes reveals the photograph's location -- and shows what
evidence is available to support the conclusion.

> **What this example does and does not do.** The code below assembles the
> evidence base: it shows which facts in the pre-cutoff graph bear on the
> question of who has the photograph. It does *not* mechanically derive
> `Possesses(Irene, photograph)` as a new statement -- that would require a
> rule (in the `Rule(phi => psi)` sense from the Appendix) and an inference engine
> to fire it. Step 5 verifies the conclusion using the full graph, which is a
> spoiler check, not a proof.

**The scene:** Holmes and Watson have just walked away from Briony Lodge after
the staged fire alarm. Watson asks: *"You have the photograph?"* Holmes replies:
*"I know where it is."* That exchange is sentence 485--486. We stop the graph
one sentence before it.

#### Step 1 -- build the pre-revelation subgraph

```python
from ner_20260608 import load_bohemia_graph
from ner_20260608.holmes_schema import Possesses, Involves

CUTOFF = 485  # sentence 485: "You have the photograph?"

pre = load_bohemia_graph(sentence_cutoff=CUTOFF, warn=False)
# sentence_cutoff is exclusive: triplets included only when
# max(sentence_ids) < CUTOFF.
```

#### Step 2 -- what does the subgraph say Irene Adler possesses?

```python
irene_possesses = pre.edges_from(
    "wiki:Irene_Adler",
    pred_type=Possesses,
    truth="asserted_true",
)
print([e.object_.display_name for e in irene_possesses])
# → ["Irene Adler's purse", "Irene Adler's watch"]
```

The photograph is absent. The subgraph contains no `Possesses` statement linking
Irene to the photograph -- that statement only appears at sentence 511, after
Holmes observes her reach for it during the smoke-rocket alarm.

#### Step 3 -- trace the photograph evidence chain

Even without the possession statement, the subgraph holds three events
connecting Irene to the photograph:

```python
photo_events = [
    e.subject
    for e in pre.edges_to(
        "wiki:Irene_Adler",
        pred_type=Involves,
        truth="asserted_true",
    )
    if "photograph" in e.subject.description.lower()
]
for ev in photo_events:
    print(repr(ev))
    print(" ", ev.description)
```

These three events establish: (1) the photograph exists and Irene has it; (2)
Irene intends to use it as leverage; (3) Holmes has already reasoned that she
keeps it hidden at home, not on her person.

#### Step 4 -- the plan execution events

```python
plan_event_ids = {
    "sib:event:holmes_explains_plan_to_watson",
    "sib:event:holmes_watson_pace_briony_lodge",
    "sib:event:holmes_feigns_injury",
    "sib:event:irene_tends_to_injured_holmes",
    "sib:event:holmes_signals_need_for_air",
    "sib:event:watson_tosses_smoke_rocket",
    "sib:event:holmes_declares_false_alarm",
    "sib:event:watson_rejoins_holmes",
}

executed = [
    e.subject
    for e in pre.edges_to(
        "wiki:Sherlock_Holmes",
        pred_type=Involves,
        truth="asserted_true",
    )
    if e.subject.id in plan_event_ids
]
print(f"{len(executed)} plan events confirmed in subgraph")
# → 7 plan events confirmed in subgraph
```

Seven of the eight plan-execution events are reachable via Holmes's Involves
edges. A rule-based inference engine with the right `Rule(phi => psi)` declaration
could derive `Possesses(Irene, photograph)` from this evidence -- but none
exists yet.

#### Step 5 -- confirm with the full graph (spoiler check)

```python
full = load_bohemia_graph(warn=False)

full_possesses = full.edges_from(
    "wiki:Irene_Adler",
    pred_type=Possesses,
    truth="asserted_true",
)
print([e.object_.display_name for e in full_possesses])
# → ["Irene Adler's purse", "Irene Adler's watch",
#    "Irene Adler's photograph", "male costume"]
```

### 6.3 Interesting queries

#### All people Holmes is connected to (2 hops)

```python
from ner_20260608 import load_bohemia_graph
from ner_20260608.holmes_schema import Person

g = load_bohemia_graph()
layers = g.bfs(["wiki:Sherlock_Holmes"], max_hops=2)
for i, layer in enumerate(layers):
    print(f"hop {i}: {len(layer)} nodes")

all_ids = set().union(*layers)
people = [
    g.get(eid) for eid in all_ids
    if isinstance(g.get(eid), Person)
]
print([p.display_name for p in people if p])
```

#### Events involving Irene Adler

```python
from ner_20260608.holmes_schema import Involves, Event

irene_events = g.edges_to(
    "wiki:Irene_Adler", pred_type=Involves
)
for e in irene_events:
    ev = g.get(e.subject.id)
    if isinstance(ev, Event):
        print(ev.description)
```

#### Transitive location -- 221B Baker Street is in London

The LLM-extracted JSONL graph has sparse `LocatedIn` coverage. The manual
instance graph in `scandal_instances.py` has the full geographic chain.

> **Note:** `scandal_instances.py` lives in the source repo under `src/` and is
> not shipped in the wheel. Clone the repo and add `src/` to `sys.path`, or run
> from the repo root with `pdm run python`.

```python
import scandal_instances as si
from ner_20260608.graph import Graph
from ner_20260608.holmes_schema import LocatedIn

g_manual = Graph.from_module(si)
reachable = g_manual.transitive_closure(
    "wiki:221B_Baker_Street", LocatedIn
)
print(reachable)  # {'wiki:London'}
```

#### Epistemic query -- what did Watson know, and when?

```python
from ner_20260608.holmes_schema import KnewAt, TruthStatus

knew_edges = [
    inst for inst in g.by_id.values()
    if isinstance(inst, KnewAt)
    and inst.subject.id == "wiki:John_Watson"
    and inst.truth_status == TruthStatus.ASSERTED_TRUE
]

for k in knew_edges:
    stmt = g.describe(k.object_.id)
    when = k.moment.label if k.moment else "unknown moment"
    print(f"Watson knew [{stmt}] at [{when}]")
```

#### Subgraph export -- serialize neighbors to JSON

```python
import json
from ner_20260608.holmes_schema import BaseStatement

def subgraph_json(g, seed_ids, max_hops=2):
    layers = g.bfs(seed_ids, max_hops=max_hops)
    all_ids = set().union(*layers)
    nodes, edges = [], []
    for eid in all_ids:
        inst = g.get(eid)
        if inst is None:
            continue
        if isinstance(inst, BaseStatement):
            edges.append({
                "id": inst.id,
                "type": type(inst).__name__,
                "subject": inst.subject.id,
                "object": inst.object_.id,
                "truth_status": inst.truth_status.value,
            })
        else:
            nodes.append({
                "id": inst.id,
                "type": type(inst).__name__,
                "label": str(inst),
            })
    return json.dumps(
        {"nodes": nodes, "edges": edges}, indent=2
    )

print(subgraph_json(g, ["wiki:Irene_Adler"]))
```

### 6.4 Writing pytest tests

#### Smoke tests against the bundled graph

```python
# tests/test_smoke.py
import pytest
from ner_20260608 import load_bohemia_graph
from ner_20260608.holmes_schema import Person, Knows, TruthStatus


@pytest.fixture(scope="session")
def g():
    return load_bohemia_graph(warn=False)


def test_graph_non_empty(g):
    assert len(g.by_id) > 50


def test_holmes_exists(g):
    assert g.get("wiki:Sherlock_Holmes") is not None


def test_watson_knows_holmes(g):
    edges = g.edges_from(
        "wiki:John_Watson",
        pred_type=Knows,
        truth="asserted_true",
    )
    targets = {e.object_.id for e in edges}
    assert "wiki:Sherlock_Holmes" in targets


def test_bfs_reaches_irene(g):
    layers = g.bfs(["wiki:Sherlock_Holmes"], max_hops=3)
    all_ids = set().union(*layers)
    assert "wiki:Irene_Adler" in all_ids
```

#### Unit tests with synthetic fixture graphs

```python
# tests/conftest.py
import pytest
from ner_20260608.graph import Graph
from ner_20260608.holmes_schema import (
    Person, Knows, TruthStatus,
)

_PROV = dict(
    story_id="test",
    paragraph_index=0,
    extraction_method="manual",
    extraction_confidence=1.0,
)


@pytest.fixture(scope="module")
def trio():
    """Holmes knows Watson (true) and Irene (false)."""
    holmes = Person(
        id="wiki:Sherlock_Holmes",
        display_name="Sherlock Holmes",
    )
    watson = Person(
        id="wiki:John_Watson",
        display_name="John Watson",
    )
    irene = Person(
        id="wiki:Irene_Adler",
        display_name="Irene Adler",
    )
    k_hw = Knows(
        id="stmt:hw", subject=holmes, object_=watson,
        truth_status=TruthStatus.ASSERTED_TRUE, **_PROV,
    )
    k_hi = Knows(
        id="stmt:hi", subject=holmes, object_=irene,
        truth_status=TruthStatus.ASSERTED_FALSE, **_PROV,
    )
    return Graph([holmes, watson, irene, k_hw, k_hi])


def test_truth_filter_keeps_only_true(trio):
    edges = trio.edges_from(
        "wiki:Sherlock_Holmes", truth="asserted_true"
    )
    assert len(edges) == 1
    assert edges[0].object_.id == "wiki:John_Watson"
```

### 6.5 MCP wrapper

Expose the graph as an MCP server\index{MCP} so Claude (or any MCP client) can
query it via tool calls.

```python
# bohemia_mcp.py
from mcp.server.fastmcp import FastMCP
from ner_20260608 import load_bohemia_graph
from ner_20260608.holmes_schema import BaseStatement

mcp = FastMCP("bohemia-graph")
_g = None


def _graph():
    global _g
    if _g is None:
        _g = load_bohemia_graph(warn=False)
    return _g


@mcp.tool()
def describe_entity(entity_id: str) -> str:
    """Return a one-line description of any entity."""
    return _graph().describe(entity_id)


@mcp.tool()
def edges_from(
    entity_id: str, truth: str = "asserted_true"
) -> list[dict]:
    """Return all outward edges from entity_id."""
    edges = _graph().edges_from(entity_id, truth=truth)
    return [
        {
            "id": e.id,
            "predicate": type(e).__name__,
            "object": e.object_.id,
            "truth_status": e.truth_status.value,
        }
        for e in edges
    ]


@mcp.tool()
def bfs(
    seed_ids: list[str], max_hops: int = 2
) -> list[list[str]]:
    """BFS from seed_ids. Returns one list per hop."""
    layers = _graph().bfs(seed_ids, max_hops=max_hops)
    return [sorted(layer) for layer in layers]


if __name__ == "__main__":
    mcp.run()
```

Register it in your Claude Code MCP config:

```json
{
  "mcpServers": {
    "bohemia": {
      "command": "python",
      "args": ["bohemia_mcp.py"]
    }
  }
}
```

### 6.6 Adding a predicate to the schema

Add the class to `holmes_schema.py`:

```python
class Employs(BaseStatement, ProvenanceMixin):
    """Person employs another Person."""
    subject: Person
    object_: Person
```

Two mechanisms must both see the new class:

1. **`model_rebuild()` loop** (bottom of `holmes_schema.py`) -- Pydantic
   requires this to resolve forward references. Omitting it causes
   `ValidationError` at construction time, not import time.

2. **`_PREDICATE_CLASSES` scan** (`loader.py`) -- built automatically at
   import time by scanning `holmes_schema` for `BaseStatement` subclasses.
   No manual step needed.

The only manual step is adding `Employs` to the `model_rebuild()` list.

## Chapter 7: Production Scale

`\chaptermark{Production Scale}`{=latex}

> **This chapter is a placeholder. The production architecture is sketched
> here; it has not been implemented or tested.**

### 7.1 The SQS / ECS worker pattern

Documents arrive on an SQS queue; ECS workers consume and process them through
the five pipeline stages. The identity server is an independently scalable
service that all workers call synchronously. The pipeline stages are stateless
transforms over JSONL; any worker can pick up any document.

### 7.2 Local inference at scale

High-throughput batch inference for NER and triplet extraction runs locally on
a GPU machine (the G533 with an RX 9060 XT, in the current setup). Local for
cost, not for latency. ROCm vs. CUDA considerations apply for Ollama-based
local inference. Model size tradeoffs: `qwen2.5:14b` fits in 16GB VRAM for
coref and triplet extraction. The G533 is suited for overnight batch runs;
frontier cloud models handle the low-volume, high-reasoning passes.

### 7.3 Auto-scaling groups

> **[Placeholder]**

### 7.4 Monitoring and audit

> **[Placeholder]**

Provenance as the audit surface: every claim is traceable to its source
document and extraction pass. Disputed claim dashboards: when two papers produce
conflicting claims about the same entity pair and predicate, the graph surfaces
the conflict rather than silently overwriting.

# Closing

## Chapter 8: Bias, Limits, and Responsibility

`\chaptermark{Bias, Limits, and Responsibility}`{=latex}

### What the graph cannot know

A knowledge graph built from a corpus knows only what that corpus contains.
The Holmes stories were written by Arthur Conan Doyle between 1887 and 1927,
from a particular cultural vantage point, with particular narrative choices
about whose perspective is centered and whose is absent. Watson's view of
events is well-represented. Mrs. Hudson's\index{Hudson, Mrs.} is not.

This is not a problem specific to fiction. A biomedical knowledge graph built
from PubMed\index{PubMed} inherits the coverage biases of biomedical publishing:
English-language journals are overrepresented; negative results are
underrepresented; diseases that attract research funding are better covered
than diseases that do not. The identity server cannot correct for absences
it cannot see.

Coverage gaps create false negatives. A query returning no result for a
relationship does not mean the relationship does not hold -- it means the
corpus does not assert it. The distinction between "the relationship does not
hold" and "the corpus has not asserted it" requires active communication to
users of the graph.

### Bias encoded at scale

Source biases propagate into the graph and are amplified by confidence
weighting. Transparency is the available remedy, not elimination. The provenance
architecture makes the evidence distribution visible: a query can retrieve not
just a confidence score but the full list of source passages and their
individual confidence values.

### Capability is not bounded by intent

A typed graph built for one purpose supports inferences its builders did not
anticipate. A Holmes graph built to study narrative structure can be queried to
identify characters who are systematically deceived. A medical graph built to
support drug discovery can be queried to identify precursor compounds for
controlled substances. A legal graph built to assist lawyers can be queried to
identify patterns in judicial decisions that correlate with demographic factors.

None of these are edge cases or failures. They follow directly from the system
working as designed. The builder's responsibility does not end at deployment.

### Who owns the graph

Open versus proprietary carries consequences for what the graph becomes and who
benefits from it. GenBank\index{GenBank}, the public repository of genetic
sequences, was built as a commons and shaped how molecular biology developed for
decades. Clinical trial data, by contrast, has often been held proprietary by
sponsors; the consequences for public health have been documented and contested.

A comprehensive typed graph over a scientific domain is a significant
infrastructure investment, and whoever controls it controls what gets synthesized,
what gets surfaced, and how the schema evolves. The governance question -- who
owns the graph, who can query it, who can extend the schema, who can audit the
ingestion -- is worth answering deliberately before it is answered by default.

The technology is neutral on governance. The builder is not.

## Chapter 9: What This Makes Possible

`\chaptermark{What This Makes Possible}`{=latex}

### The connective tissue

Without canonical identity, the graph is a collection of strings. Without the
typed schema, a collection of untyped triples. Without provenance, a collection
of unsigned assertions. The three base vectors are connective tissue: they make
the graph queryable, trustworthy, and composable.

### Cross-domain reasoning

Shared canonical IDs let two graphs built independently compose automatically.
A Holmes graph and a Victorian history graph, both anchoring their `Location`
entities to Wikidata\index{Wikidata} URIs, can be traversed as a single graph: a query
starting from Baker Street in the Holmes graph can follow an edge to a Wikidata
node and continue into the history graph without any coordination between the
teams that built each. The shared identifiers are the bridge.

### Grounding LLM inference

The difference between asking an LLM to reason from its training data and asking
it to reason from a typed, provenance-tracked graph is qualitative, not
quantitative. Training data is a frozen snapshot of text compressed into weights.
It cannot be updated without retraining. Its sources cannot be cited.

A graph provides all of these things. The system retrieves the relevant subgraph
and injects it into the model's context. The model reasons over that context.
The answer is grounded in retrieved claims with known sources, not in training-
data recall. When the graph is wrong, you fix the graph. You do not retrain the
model.

This also changes who can audit the reasoning. An explicit graph can be
inspected: every entity can be examined, every relationship queried, every
provenance record traced back to its source. A physician using an AI system to
inform a treatment decision needs to be able to ask "why?" and get an answer
that makes sense. A lawyer relying on AI-assisted analysis needs to trace the
claim to its source. An explicit representation makes this possible. A neural
network's implicit representation does not. Auditability\index{auditability} is
not a nice-to-have in high-stakes domains. It is a precondition for justified
trust.

The expert systems of the 1980s had the right intuition: reason over explicit
representations whose inferences are auditable. What they got wrong was
economics. Building those representations required armies of knowledge engineers
working with domain experts. The statistical revolution of the 1990s and 2000s
threw out explicit representation in favor of learned, implicit ones, and gained
enormous practical capability at the cost of auditability. The current moment is
the first time in the history of the field that building explicit, structured,
domain-specific representations at scale has been practical -- because the
extraction step, always the bottleneck, can now be done by a language model with
a well-designed prompt.

The extraction bottleneck that stopped everything else is now broken. The case
for explicit knowledge representation has not changed. The cost has.

### Hypothesis generation

A well-constructed typed graph supports a class of query impossible over
unstructured text: "what relationships exist between X and Y that no single
source asserts but that follow from combining multiple sources?"

In a scientific corpus, this generates drug-disease candidate pairs, gene-pathway
associations, and cross-trial comparisons that no single paper asserts. These
are candidate hypotheses, not established facts. The graph does not decide which
are worth pursuing. It surfaces candidates that a human can filter, prioritize,
and test.

There is a sharper version of this problem worth naming. Detecting Holmes's plan
from a sequence of events is tractable precisely because Doyle has Holmes state
his goal out loud before he acts on it — the pipeline only has to recognize a
stated intention and gather the events that follow it, not infer a hidden
purpose from silence. Most interesting scientific hypotheses are the opposite
case. No single paper states "the unifying mechanism behind these twelve
independently observed effects is X" — that synthesis is exactly what's missing,
and exactly what a human researcher's insight supplies. A graph that has
correctly typed, sourced, and time-stamped a thousand papers' worth of claims
has done the tractable part. It has not done the part that corresponds to
Holmes's own deductive leap. Closing that gap — building a reasoning layer that
proposes the unstated unifying claim, rather than one that merely traverses and
aggregates stated ones — is the harder problem underneath automated scientific
discovery, in the lineage of King's robot scientists and their successors. This
book's three base vectors are the precondition for that work, not a substitute
for it: a system cannot responsibly propose what it cannot first trace, type,
and audit.

### To Jupiter, and beyond the infinite

The epistemic commons -- MeSH, HGNC, RxNorm, UniProt, Wikidata, and the dozens
of domain-specific authorities that curated communities have built over decades
-- was built for human use. The typed graph makes it available to machines in a
form that carries its own warrant: canonical IDs anchoring to the authorities, a
schema constraining what can be expressed, provenance tracing every claim to its
source.

That is not a small thing. The extraction bottleneck that prevented this for
fifty years is now broken.

# Appendix: Formal Definition

`\chaptermark{Formal Definition Reference}`{=latex}

This appendix defines the formal model precisely, establishes vocabulary, states
hard rules, and lists explicit non-goals. When in doubt, check against this
appendix before writing code, prose, or schema definitions.

The notation itself is not the point -- the benefits come from what the process
of formalizing forces, and those benefits survive translation into plain prose.

**It settles ambiguity permanently.** Natural language descriptions of data
structures always leave wiggle room. "Edges have types" could mean a dozen
things. A formal definition closes off all of them at once.

**It separates schema from instance.** The $T$ vs. $V$ split is the single most
important conceptual distinction in the book. A formal definition makes it
impossible to conflate the two.

**It gives you a checklist.** The 4-tuple is a completeness check. If you can't
place something in one of those slots, either it doesn't belong in the model or
the model is missing a slot.

**It anchors the vocabulary.** Once you've defined $\text{Tr}(p)$ formally,
"trait" has a precise meaning for the rest of the book.

**It makes identity unambiguous.** Two instances that represent the same real-
world entity must be distinguishable from two instances that represent the same
claim at different epistemic states. Canonical IDs close off that confusion.

**It grounds every claim in its source.** A proposition without provenance is
not reliable knowledge -- it is an unverifiable assertion.

### Formal Definition

A typed graph $G$ is a 4-tuple $(T,\ \Phi,\ V,\ \tau)$ where:

#### Schema layer -- fixed at graph-design time

- $T$ -- finite set of **types**, partitioned into:
  * $T_\text{ent}$ -- **entity types** (e.g. Person, Drug, Location)
  * $T_\text{pred}$ -- **predicate types** (e.g. Treats, KnewAt, LocatedIn)
- $\Phi: T \to \text{FieldSchema}$ -- the **field schema**, mapping each type
  to a Pydantic model declaration of named, typed fields. For predicate types,
  $\Phi$ includes three distinguished fields:
  * `subject` -- typed reference to an instance in $V$; the type annotation
    constitutes $\text{dom}(p)$
  * `object_` -- typed reference to an instance in $V$; the type annotation
    constitutes $\text{ran}(p)$
  * `truth_status` -- the graph's current commitment to the proposition
- For each $p \in T_\text{pred}$:
  * $\text{dom}(p) \subseteq T$ -- permitted subject types
  * $\text{ran}(p) \subseteq T$ -- permitted object types
  * $\text{Tr}(p) \subseteq \text{Trait}$ -- finite set of semantic traits

The partition is strict: $T_\text{ent} \cap T_\text{pred} = \emptyset$ and
$T_\text{ent} \cup T_\text{pred} = T$. Every type is exactly one of the two;
$\Phi$ determines which, by whether it declares the distinguished fields
`subject`, `object_`, and `truth_status`. Note the asymmetry with the instance
layer: every predicate *instance* is a full member of $V$ ($E \subseteq V$),
but no predicate *type* is an entity *type*. The Python realization mirrors both
facts at once: `EntityInstance` and `BaseStatement` are disjoint siblings under
a common root class `Instance`, which carries membership in $V$ (the `id`
field). $\tau$ assigns each instance its most-derived class, which falls
unambiguously on one side of the partition.

#### Instance layer -- populated at ingestion or reasoning time

- $V$ -- set of all **instances** (both entity instances and predicate instances)
- $\tau: V \to T$ -- type assignment for all instances

The **edge set** $E$ is derived, not primitive:

$$E = \{v \in V : \tau(v) \in T_\text{pred}\}$$

$E \subseteq V$: every member of $E$ is also a member of $V$. A predicate
instance is a full member of $V$ -- it has an id, it can be referenced by other
predicate instances as their subject or object. This is the single relaxation
relative to the classical graph formalism, where $V$ and $E$ are disjoint sorts.
It is what enables higher-order predication without a separate reification
mechanism.

#### Canonical identity

Each instance $v \in V$ carries a distinguished field $v.\text{id} \in
\mathcal{I}$, where $\mathcal{I}$ is a universe of stable identifiers. The
identity axiom requires:

$$\forall\, v, v' \in V:\ v \neq v' \Rightarrow v.\text{id} \neq v'.\text{id}$$

The identifier is:

- **Assigned at construction** -- not derived from any mutable field
- **Stable** -- once assigned, it does not change
- **Non-dispatch** -- the id string is never parsed to recover type; type is
  the exclusive responsibility of $\tau$ and the Python class hierarchy
- **Ontology-anchored where possible** -- for entity instances that correspond
  to real-world referents, the id should be sourced from or aligned with a
  community-curated authoritative ontology

Display is separate from identity. Instances implement `__str__` to return a
human-readable label -- `display_name` for entities that carry one, and
`ClassName(subject → object)` for predicate instances. This presentation string
is one-way: it is generated for human consumption and is never parsed back.

#### Validity constraint

Each instance $v \in V$ carries fields conforming to $\Phi(\tau(v))$.

For predicate instances, this subsumes domain/range enforcement: if $\Phi(p)$
declares `subject: Drug` and `object_: Disease`, then an instance of type $p$
whose subject is a Location fails field validation. No separate domain/range
check is needed.

#### Trait vocabulary

$$
\begin{aligned}
\text{Trait} ::=\ &\text{Symmetric} \mid \text{Transitive}\\
    \mid\ &\text{Functional} \mid \text{InverseFunctional}\\
    \mid\ &\text{Inverse}(p') \mid \text{Rule}(\varphi \Rightarrow \psi)
\end{aligned}
$$

Traits are realized as Python mixin classes inherited alongside the base
predicate class.

##### Rule($\varphi \Rightarrow \psi$) -- Datalog rules

`Rule(phi => psi)` is a **Datalog rule** -- a Horn clause restricted to positive,
function-symbol-free literals:

- **body ($\varphi$)** -- a conjunction of positive graph pattern conditions
- **head ($\psi$)** -- a single derived predicate instance to assert when
  the body holds

$$
p_1(x_{a_1}, x_{b_1}) \wedge \cdots \wedge p_k(x_{a_k}, x_{b_k})\
\Rightarrow\ p_0(x_{a_0}, x_{b_0})
$$

The Datalog restrictions -- no function symbols, no negation, no existential
variables in the head -- keep inference decidable. Rule application is iterated
to a **least fixed point** over the asserted graph.

The named traits are special cases of Datalog rules:

| Trait | Equivalent rule |
|---|---|
| `Transitive` | $p(x, y) \wedge p(y, z) \Rightarrow p(x, z)$ |
| `Symmetric` | $p(x, y) \Rightarrow p(y, x)$ |
| `Inverse(p')` | $p(x, y) \Rightarrow p'(y, x)$ |

#### Truth status

Every predicate instance carries a `truth_status` field:

$$
\begin{aligned}
\text{TruthStatus} ::=\ &\text{asserted\_true}
    \mid \text{asserted\_false}\\
    \mid\ &\text{hypothetical} \mid \text{disputed}
    \mid \text{retracted}
\end{aligned}
$$

Under the closed-world assumption, the presence of a predicate instance does NOT
by itself assert the proposition; the `truth_status` field carries the assertion
explicitly. This replaces the classical convention where edge-presence is
assertion.

The **asserted graph** is the projection of $E$ where
`truth_status = asserted_true`. A disputed proposition remains in $V$ (it can
be referenced, queried, and reasoned about) but is excluded from the asserted
graph.

Lifecycle: a predicate instance is typically created as `hypothetical` at first
mention, promoted to `asserted_true` when grounded, and may later become
`disputed` (conflicting sources) or `retracted` (overturned by new evidence).

#### Provenance

Every predicate instance carries a **provenance sub-schema** -- a distinguished
set of fields in $\Phi(p)$ that record how the assertion was produced. The
minimum provenance fields required for any $p \in T_\text{pred}$ are:

- `source` -- the origin of the claim: a text span or document reference
- `extraction_method` -- how the claim was derived

Provenance fields are instance metadata: they describe how this particular
assertion was produced, not what the predicate type means. **Provenance does not
replace truth_status.** A claim with high-confidence provenance from a reliable
source may still be `disputed` or `retracted`. Truth status is the graph's
current epistemic commitment; provenance is the audit trail behind it.

### Vocabulary

Use these terms consistently. Do not treat them as synonyms.

| Term | Definition |
|------|-----------|
| **Instance** | A member of $V$ -- the common root of both sorts. Every entity instance and every statement is an Instance. |
| **Entity type** | A member of $T_\text{ent}$. Realized as a Python class inheriting from `EntityInstance`. Example: `Person`, `Location`. |
| **Predicate type** | A member of $T_\text{pred}$. Realized as a Python class inheriting from `BaseStatement`. Example: `LocatedIn`, `KnewAt`. |
| **Entity instance** | A member of $V$ with $\tau(v) \in T_\text{ent}$. A concrete node. |
| **Statement** | A member of $V$ with $\tau(v) \in T_\text{pred}$. A concrete proposition. Also a member of $E$. |
| **Field schema** | $\Phi(t)$: the Pydantic model declaration of named fields for type $t$. |
| **Domain** | $\text{dom}(p)$ -- the set of types permitted in the subject role for $p$. |
| **Range** | $\text{ran}(p)$ -- the set of types permitted in the object role for $p$. |
| **Trait** | A declarative semantic property of a predicate type. Member of $\text{Tr}(p)$. |
| **Asserted graph** | The subset of $E$ where `truth_status = asserted_true`. |
| **Canonical identifier** | The value of $v.\text{id}$ for instance $v \in V$. Globally unique within $V$, assigned at construction, immutable, never parsed for type dispatch. |
| **Provenance** | The set of fields $\Pi(p) \subseteq \Phi(p)$ that record how a predicate instance was produced. |

#### Terms to avoid or use carefully

- **Edge** -- informal synonym for Statement when discussing traversal. Use "Statement" in definitions.
- **Relationship** -- use to mean a predicate instance, never a predicate type.
- **Node** -- informal synonym for entity instance. Acceptable in casual prose.
- **Property** -- overloaded. Be explicit about whether you mean a field on an instance or a trait on a predicate type.
- **Entity** -- do not use as a synonym for "member of $V$." A Statement is a member of $V$ but is not an entity instance.
- **Reification** -- in this model, there is nothing to reify. The word applies to models where edges and vertices are disjoint sorts; here they are not.

### Hard Rules

**R1. Traits belong to predicate types, never to instances.** A predicate either
has `Transitive` or it does not. In Python, traits are declared by inheriting
the trait mixin class alongside `BaseStatement`.

**R2. Metadata fields belong to instances, never to predicate types.** Provenance,
confidence, timestamps -- these are facts about a particular assertion and live
on the instance.

**R3. Every predicate instance is a directed, typed, truth-bearing proposition.**
It carries `subject`, `object_`, `truth_status`, and whatever additional fields
$\Phi$ requires.

**R4. Domain and range are sets of types, not instances.** You constrain which
*kinds* of things may appear as subject or object, not which specific things.

**R5. Schema is fixed; instances are populated.** Nothing discovered during
ingestion changes $T$, $\Phi$, domain, range, or traits.

**R6. Domain and range constraints are enforced by the Python type system.**
Types are Python classes. Each predicate class declares its `subject` and
`object_` fields with concrete class annotations. Mypy enforces these statically;
Pydantic enforces them at construction time.

**R7. Pydantic models for instances are frozen.** Use
`model_config = ConfigDict(frozen=True)`. Instances are facts; they must not be
mutated after construction.

**R8. Higher-order predication is a schema-level type declaration, not a runtime
promotion.** A predicate enables higher-order claims when its range includes a
predicate type (a `BaseStatement` subclass). This is declared once in $\Phi$ at
schema design time. There is no runtime "promotion" of instances between layers.

Do **not** use higher-order predication to attach provenance or epistemic
metadata to a proposition. That is R2's job. Higher-order predication is for
*predicating over* a proposition, not for *annotating* one.

**R9. Every instance has a canonical, stable identifier; display is separate.**
The `id` field is assigned at construction and does not change. The id string
must never be parsed to recover type -- type is the exclusive responsibility of
$\tau$ and the Python class hierarchy.

Human-readable display is the responsibility of `__str__`, not `id`. `__str__`
returns `display_name` for entities that carry one, and
`ClassName(subject → object)` for predicate instances. It is a one-way
presentation artifact -- generated for human consumption, never parsed back.

**R10. Every predicate type declares a provenance sub-schema.** $\Phi(p)$ must
include at minimum `source` and `extraction_method` for all
$p \in T_\text{pred}$. These fields are required, not optional.

### Python Enforcement Pattern

The class hierarchy mirrors the formalism exactly. A single root class,
`Instance`, carries the `id` field and the frozen model configuration --
it realizes membership in $V$. Entity types are `EntityInstance` subclasses;
predicate types are `BaseStatement` subclasses with trait mixins inherited
alongside. `EntityInstance` and `BaseStatement` are disjoint siblings under
`Instance`: the sibling split realizes the strict partition of $T$, and
`BaseStatement` $\subset$ `Instance` realizes $E \subseteq V$.

Domain and range constraints are expressed as Pydantic field type annotations --
no custom validation logic is needed. Traits are introspectable at runtime
(`issubclass(LocatedIn, Transitive)`), and `get_inverse` resolves declared
inverse pairs.

### Non-Goals

**Not RDF / OWL.** In RDF, predicates are URIs and are themselves nodes; the
graph is a flat set of triples with no first-class edge objects. OWL adds
description logic semantics and open-world assumption. This model is a closed-
world typed graph where every predicate instance is a truth-bearing, field-
carrying member of $V$. RDF requires reification or named graphs for higher-
order predication; this model handles it through type declarations on domain
and range.

**Not Neo4j's informal property graph.** Neo4j allows arbitrary key-value
properties on edges without schema enforcement. This model requires a declared
field schema ($\Phi$) and enforced domain/range constraints.

**Not an entity-relationship diagram.** ER diagrams are a database design tool.
This is a runtime knowledge representation with provenance, epistemic scope, and
trait-based inference semantics.

**Not a general ontology language.** This model does not support open-world
reasoning, class hierarchies, disjointness axioms, or the full OWL trait
vocabulary. Traits are a small, fixed set of declarative properties. If a use
case seems to require full description logic, that is scope creep.

**Not a stringly-typed system.** Types are Python classes, not ID prefixes.
Domain and range enforcement is the job of the Python type system and Pydantic,
not of string parsing. Any code that parses an identifier string to determine or
dispatch on a type is a violation of R6.

### Current Domain: Holmes Corpus

The worked example uses the Sherlock Holmes canon as domain.

- **Ontology authority**: Baker Street Wiki
- **Schema construction method**: inductive -- built by annotating stories
- **Primary stories**: *A Scandal in Bohemia* (complete); *The Speckled Band*
  (planned)
- **Entity types**: `Person`, `Location`, `Object`, `Document`, `Moment`,
  `Event`, `Persona`, `Plan`
- **Higher-order predicates**: `KnewAt`, `Contradicts` -- these take
  `BaseStatement` in their range, enabling epistemic and dispute tracking
