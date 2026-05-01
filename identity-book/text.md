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

*This foreword appears in all three volumes of the Graphwright series.*

Machine reasoning is being deployed in high-stakes domains: medicine, law,
engineering, buildings and bridges. When mistakes are made in these domains,
lives and livelihoods are threatened. Large language models (LLMs) are here,
they are staying, and there is no turning back the clock.

In those domains, the cost of a hallucination is a misdiagnosis or a collapsed
bridge. You cannot accept "good enough" results. You need to be able to explain
the system's reasoning in terms that a domain expert can verify and dispute. A
user must be able to ask "why that answer?" and get back something trustworthy.

Typed graphs with provenance make that possible.

The key shift is from strings to things. We need to make statements about real
things in the world -- not just look for string similarity. We need identity
(recognizing that two mentions refer to the same real-world entity), causality
(tracking cause and effect across multiple steps), and consequential reasoning
(following what must be true given what we know).

### RAG vs. Graph-RAG

RAG -- retrieval-augmented generation\index{retrieval-augmented generation} --
works by embedding text passages as vectors and retrieving them by cosine
similarity. This is useful for quick lookups that you intend to verify manually
afterward: closer to a Google search than to a reasoning engine.

What RAG cannot give you is identity. It cannot tell you that this thing *is*
that thing -- that "tumor" and "neoplasm" refer to the same biological entity,
or that the drug mentioned in one paper is the same compound studied in another.
It cannot give you cause and effect: that this compound *caused* that reaction,
or that this gene variant *predicts* that outcome.

Graph-RAG\index{Graph RAG} is not just better RAG. It is a different epistemic
commitment. The LLM serves as the extraction and natural-language interface
layer; the graph is the reasoning substrate. Those two roles require different
tools, and conflating them is where most systems go wrong.

### RDF Gets Many Things Right

The Resource Description Framework (RDF)\index{RDF} -- the W3C standard for
linked data -- got the foundational atoms right. It is worth saying clearly
what to keep from it before explaining what to add.

The triple as the atomic unit of knowledge is a brilliant idea, and we keep it.
A triple is a subject-predicate-object statement: the smallest unit of
structured knowledge. URIs as identifiers are equally brilliant: a stable,
globally unique reference to a thing, independent of how that thing is described
in any particular document. SPARQL as a query language is powerful and worth
emulating in spirit. OWL2 reasoning points in the right direction.

What RDF left uncontrolled is the chemistry. There are no entity types, so a
node carries little context about what kind of thing it represents beyond its
OWL2 properties. Predicates are unrestricted: anyone can assert anything about
anything. The result is that there is no mechanism for detecting category
errors. Garbage in, garbage out -- and there is no gate on the garbage.

### Typed Graphs

A *typed graph*\index{typed graph} adds the missing controls:

- A fixed set of entity types -- like an enumeration -- so every node is
  classified, and that classification means something.
- A fixed set of predicates -- so the vocabulary of relationships is bounded
  and agreed upon.
- Domain and range constraints for each predicate -- a predicate's domain
  is the set of entity types allowed as its subject; its range is the set
  allowed as its object.

This makes category errors detectable before they enter the graph. Consider
the assertion "aspirin treats BRCA1." The predicate `treats` has domain
`[Drug]` and range `[Disease]`. Aspirin is a Drug -- that is fine. But BRCA1
is a Gene, not a Disease. The assertion is rejected as a type violation, not
stored as a low-confidence claim.

Most entities in the typed graph carry canonical IDs drawn from authoritative
ontologies. Those IDs are what make seamless multi-hop reasoning possible:
the same entity referenced in two different papers resolves to the same node,
and a traversal can follow edges across sources without ambiguity.

### Canonical IDs and Authoritative Ontologies

Many domains have official ontologies that are known, respected, and carefully
curated over years, decades, or centuries. Medicine alone has several: for
diseases, genes, drugs, organisms, anatomical structures, and more. These
authoritative ontologies assign stable identifiers to real-world things and
connect those identifiers to the knowledge that humanity has assembled.

When a knowledge graph anchors its entities to these ontologies, it inherits
that accumulated knowledge and gains the ability to reason across sources.
Two papers that both mention "metformin" using its canonical drug ID can be
joined at the graph level without any string matching. A traversal that starts
from a disease can follow edges through genes, drugs, and clinical trials
without asking whether the names are spelled the same way.

The practical problems this raises -- resolving synonyms, deduplicating
mentions, extracting entity references from unstructured text, and maintaining
provenance as the graph grows -- are the subject of these three books.

### What We Win with Typed Graphs

When reasoning is grounded in a typed graph, causal chains become tractable.
Each step in a reasoning chain is auditable: you can inspect the edge, the
predicate, the source paper, and the confidence score. Errors can be localized
to specific claims. Nothing is buried in a similarity score.

Provenance tracking enables honest uncertainty quantification. Three hops at
0.9 confidence each give you 0.73 -- you can show that arithmetic. A cosine
similarity chain gives you nothing comparable: there is no principled way to
compose similarity scores into a compound confidence.

Reasoning becomes as straightforward as breadth-first search on a graph where
node identity is unambiguous. Uncertainty is represented as a confidence score
on each claim. Sources are represented by explicit links from claims to the
papers or records that support them.

```{=latex}
\vspace{0.5em}
\begin{center}
\begin{tikzpicture}[
  node distance=0.5cm,
  box/.style={
    draw, rounded corners=3pt,
    text width=3.2cm, align=center,
    font=\small\sffamily,
    inner sep=5pt
  },
  subbox/.style={
    draw=gray!50, rounded corners=2pt,
    text width=2.8cm, align=left,
    font=\footnotesize\sffamily,
    inner sep=5pt, fill=gray!10
  },
  arr/.style={-{Stealth[length=5pt]}, thick}
]
\node[box] (A) {Unstructured Text};
\node[box, below=of A] (B) {Extraction (LLM)};
\node[box, below=of B] (C) {Mentions (strings)};
\node[box, below=of C] (D) {Identity Resolution};
\node[subbox, below=0pt of D, anchor=north]
  (Dsub) {canonical IDs\\deduplication};
\node[box, below=of Dsub] (E) {Typed Graph};
\node[subbox, below=0pt of E, anchor=north]
  (Esub) {entity types\\predicates\\domain / range\\provenance};
\node[box, below=of Esub] (F) {Queries / Traversals};
\node[box, below=of F] (G) {Machine Reasoning};
\node[subbox, below=0pt of G, anchor=north]
  (Gsub) {multi-step\\composable\\inspectable};
\draw[arr] (A) -- (B);
\draw[arr] (B) -- (C);
\draw[arr] (C) -- (D);
\draw[arr] (Dsub.south) -- (E.north);
\draw[arr] (Esub.south) -- (F.north);
\draw[arr] (F) -- (G);
\end{tikzpicture}
\end{center}
\vspace{0.5em}
```

That is the minimum standard for reasoning in high-stakes domains. Not a
guarantee of truth -- but a guarantee of inspectability, reproducibility,
and the possibility of correction.

---

## Preface

The two companion volumes -- *Knowledge Graphs from Unstructured Text* and
*BFS-QL: A Graph Query Protocol for Language Models* -- both depend on canonical
identity but neither has room to fully explain it. The first book builds a
knowledge graph from unstructured text. The second book serves that graph to a
language model. Both books gesture at the identity server\index{identity server} and say "this is
important" and then move on.

This book is what they are pointing at. The same ideas apply whenever
structured data must be deduplicated or joined across sources -- not only when
that data happens to be stored as a graph.

Canonical identity is the difference between a collection of extracted facts and
a knowledge graph that can be trusted. It is the difference between a node
labeled "desmopressin" and a node anchored to RxNorm\index{RxNorm}:3251, connected to the
accumulated judgment of the biomedical community about what that compound is,
what it does, and how it relates to everything else they have named. It is the
difference between a fact and a located fact -- one that can be reasoned about,
connected across sources, and trusted because the community that defined it is
known.

The extraction bottleneck that held back knowledge representation for fifty
years is now broken. Large language models can read a scientific paper and
produce structured claims at a cost that was unimaginable a decade ago. The
remaining question is whether those claims can be trusted -- traced to their
sources, deduplicated across papers, and anchored to shared authorities that
give them stable meaning. That is the question this book answers.

The identity server is a microservice. It has a clean interface. It can be
deployed as a Docker\index{Docker} image and pointed at any knowledge graph project. But it
is also an argument about epistemology: that trustworthiness in a knowledge
system is not a property you add after the fact, it is a constraint you either
satisfy from the beginning or violate permanently.

This book is for engineers building knowledge graphs who want that constraint
to be architectural, not aspirational.

# Part I: The Problem of Identity

## Chapter 1: What a Typed Graph Is

`\chaptermark{What a Typed Graph Is}`{=latex}

### Beyond the Triple

The triple is a good idea. Subject, predicate, object: the smallest unit of
structured knowledge that can stand alone, be stored, be retrieved, and be
combined with other triples to form chains of inference. The Resource
Description Framework\index{RDF} built a global linked-data infrastructure on
this idea, and that infrastructure is real and useful. We keep the triple.

What RDF did not provide was any constraint on what could appear in subject,
predicate, or object position. Any URI can be a subject. Any URI can be a
predicate. Any URI or literal can be an object. The result is a system with
no type layer: a node carries no intrinsic information about what kind of
thing it represents, and a predicate carries no specification of what kinds
of things are allowed on either side of it. The graph accepts whatever it
is handed.

A typed graph\index{typed graph} adds two constraints that RDF leaves open. First, a finite
enumeration of entity types: every node in the graph is classified as
exactly one kind of thing, and that classification is drawn from a closed
list. Second, a finite vocabulary of predicates, each annotated with a
domain and a range: the domain is the set of entity types permitted as the
subject of that predicate, and the range is the set permitted as the object.
Together these define a schema -- not as documentation about what the graph
is supposed to contain, but as a machine-checkable contract that governs
every write.

This sounds like a small addition. It is not. The combination of typed nodes
and constrained predicates changes what the graph can guarantee, what errors
it can detect, and what reasoning it can support. The rest of this chapter
works through each consequence.

### The Ontology as Contract

Documentation describes what a system is supposed to do. A contract specifies
what a system will enforce. The distinction matters because documentation is
read by humans who may or may not follow it, while contracts are checked
mechanically and violations are rejected, not filed as tickets.

The schema of a typed graph is a contract in this second sense. When a
predicate is defined with domain `[Drug]` and range `[Disease]`, that
definition is not advice. It is a gate. Any proposed triple that presents a
non-Drug as the subject or a non-Disease as the object is rejected at write
time. The graph never contains the invalid triple. There is no later cleanup
step that might or might not run. There is no audit that catches violations
after they have propagated through downstream queries. The constraint is
enforced at the point of insertion, unconditionally.

This matters most under scale and automation. A knowledge graph built by
hand, from a small corpus, by a careful engineer, may stay coherent without
mechanical enforcement -- the engineer notices when something looks wrong.
A knowledge graph built by an extraction pipeline processing thousands of
papers cannot rely on human review at insertion time. The pipeline will
produce malformed triples. The only question is whether those triples are
rejected immediately or stored and discovered later, after they have joined
the graph and influenced derived facts. A contract-enforcing schema answers
that question at the architectural level, not the operational one.

The domain spec\index{domain spec} -- the Python module that defines the entity type
enumeration and the predicate list -- is where the contract lives. It is the
single source of truth for what the graph can express. Everything the
identity server, the extraction pipeline, and the query layer know about
valid graph structure comes from the domain spec. Changing the contract means
changing the domain spec; there is no other place to look.

### Finite vs. Open-World

RDF and OWL operate under the open-world assumption\index{open-world assumption}: if a statement
is not asserted in the graph, that does not mean it is false. It might be
true but not yet recorded. The graph is always potentially incomplete, and
absence of an assertion carries no information.

A typed graph operates under the closed-world assumption\index{closed-world assumption}: the predicate
vocabulary is finite and fixed. A predicate that does not appear in the
schema does not exist. An assertion that uses a predicate outside the schema
is not an unknown fact -- it is a type error.

The practical consequence is that absence becomes informative. If the
predicate `inhibits` appears in the schema and no edge labeled `inhibits`
connects two particular entities, that means something: either the
relationship does not hold, or the corpus does not assert it. These two
possibilities are distinct -- and the distinction is explicit, not silent.
A graph built from a particular corpus knows its own coverage. A query can
ask not just "what does this drug inhibit?" but "has this relationship been
studied, and if so, in what papers?"

The open-world assumption is appropriate when the graph is meant to model
all possible knowledge. A typed graph makes a different bet: that the
domain is bounded and agreed upon, that the predicate vocabulary can be
enumerated, and that the power gained from closed-world reasoning is worth
the discipline required to define the schema before writing data into it.
For high-stakes domains -- medicine, law, engineering -- that bet is worth
making. Unbounded expressiveness is not a feature when the cost of a
malformed assertion is a misdiagnosis.

### Category Error Detection

A category error is a statement that is not merely false but wrong at the
level of kind: asserting a relationship between two things of the wrong
types. "Aspirin treats BRCA1" is not a contested empirical claim. It is the
application of a therapeutic predicate to a gene, a type mismatch that
signals an extraction failure rather than a factual disagreement.

Without a type layer, a graph stores this triple without comment. It may
be assigned a low confidence score. It may be flagged by a downstream
reviewer. It may propagate unnoticed into query results that mix it with
valid claims. The error is in the graph.

With domain and range constraints, the triple is rejected before it enters
the graph. The predicate `treats`\index{category error} has domain `[Drug]` and range
`[Disease]`. Aspirin is classified as a Drug -- that side is fine. BRCA1
is classified as a Gene. The range constraint fails. The triple is invalid
and the graph never sees it.

This separation -- structural validity as a property distinct from factual
correctness -- is one of the typed graph's central contributions. A
well-typed triple can still be wrong. The graph may contain the assertion
that desmopressin inhibits cortisol secretion, correctly typed and correctly
sourced, and that assertion may turn out to be false on further evidence.
The schema does not adjudicate the world. What it does is ensure that the
triples reaching the factual adjudication stage are structurally coherent:
that subjects and objects are the right kinds of things, that predicates
are drawn from an agreed vocabulary, and that the question being asked is
at least the right kind of question. Category errors never reach the
adjudication stage. They are stopped earlier, by the contract.

### Subtype Hierarchies

Entity types do not have to be flat. A predicate whose domain includes
`Organism` should be applicable to `Bacterium` and `Mammal` as well,
without requiring each subtype to be listed explicitly in every predicate
definition. The type system supports this through a subtype hierarchy: a
directed acyclic graph of entity types where a subtype inherits the
predicate permissions of its supertypes.

The hierarchy lives in the schema, not in the graph. Individual nodes are
classified as leaf types -- `Dog`, `Bacterium`, `SmallMolecule` -- and
the hierarchy determines which predicates those nodes can participate in.
A predicate with domain `Organism` accepts a `Dog` node because `Dog` is
a subtype of `Organism`. The graph data does not need to encode this
inheritance; the schema carries it.

This has a practical consequence for schema design: predicates should be
declared at the most general type level that is correct. A predicate that
applies to all living things should have domain `Organism`, not a union
of every leaf organism type. As new leaf types are added to the schema,
they automatically inherit the predicate without any change to the
predicate definition. The schema grows at the leaves; the predicate
vocabulary stays stable.

### `PredicateSpec` and `EntityType`

The contract has to live somewhere concrete. In the Graphwright system,
it lives in a Python module called `domain_spec.py`\index{domain\_spec.py}, which defines two
kinds of objects.

Entity types are represented as a Python `enum.Enum`. Each member of the
enum is one permitted node classification. The enum is the complete list:
if a type is not a member, it does not exist in this graph. The enum can
define a subtype hierarchy by annotating members with their parent types,
giving the schema its DAG structure without any external configuration
file.

Predicates are represented as frozen Pydantic\index{Pydantic} models -- instances of a
class called `PredicateSpec`\index{PredicateSpec}. A `PredicateSpec` carries the predicate's
name, its domain (a set of entity type enum members), its range (likewise),
and optional flags that capture additional semantic constraints:
`is_functional` signals that a subject can have at most one object for this
predicate; `negation_of` links a predicate to its logical inverse.

Using frozen Pydantic models is not arbitrary. Frozen models cannot be
mutated after construction, which means a `PredicateSpec` loaded from the
domain spec at startup is the same object at every point in the server's
lifetime. There is no window during which the schema is partially loaded
or inconsistently represented. The domain spec is loaded once, validated
once, and then treated as a read-only fact about the world. Any downstream
component that holds a reference to a `PredicateSpec` holds the same
object every other component holds. Consistency is structural, not
procedural.

The domain spec module is also where provisional types are declared and
flagged. A type that the schema designer is not yet certain about -- one
that might be refactored, split, or absorbed into another type as the
domain model matures -- is marked provisional in the spec. Provisional
types carry full type constraints and participate in the schema normally;
the flag is a signal to domain designers, not a mechanical restriction.
Chapter 2 introduces two provisional types specific to the Holmes corpus,
and Chapter 3 discusses the role of provisional status in schema lifecycle.

## Chapter 2: The Scale of the Problem

`\chaptermark{Scale of the Problem}`{=latex}

### Multiplicity at Corpus Scale

A corpus of one thousand biomedical papers contains, conservatively, tens of
thousands of entity mentions. A well-studied disease like Cushing's disease\index{Cushing's disease}
will appear under its eponym, its clinical description ("hypercortisolism"),
its ICD-10 code, and several abbreviated forms. A gene like POMC will appear
under its official symbol, its full name ("pro-opiomelanocortin"), and older
names used in papers from the 1980s and 1990s. A drug used in diagnosis like
desmopressin will appear under its generic name, its brand name, its chemical
name, and abbreviations.

Across a thousand papers, a single well-studied entity might generate fifty
distinct surface forms. Across ten thousand papers, it might generate a hundred.
The multiplicity scales with corpus size, with the breadth of time covered, and
with the diversity of research communities that contributed papers.

Manual deduplication does not scale. An expert might be able to reconcile the
entity mentions in a hundred papers with reasonable effort. At a thousand papers
it becomes a full-time job. At ten thousand papers it is impossible. The
identity server exists because the problem cannot be solved by hand at the
scale where knowledge graphs become useful.

### Sources of Variation

Surface form variation has several sources, each requiring a different
resolution strategy:

**Abbreviations and acronyms**: ACTH for adrenocorticotropic hormone, DDAVP
for desmopressin. Abbreviations are often defined at first use in a paper and
then used without expansion. A system that only sees the abbreviation has no
way to resolve it without consulting the paper's own definition section or an
external authority.

**Synonyms and alternate nomenclatures**: Different research communities
sometimes develop independent naming systems for the same concepts before
converging on a standard. In genetics, two groups that independently discover
the same gene often give it different names; official symbols are assigned later
by nomenclature committees.

**Misspellings and OCR artifacts**: Papers from older literature, or papers
processed through optical character recognition, contain systematic
misspellings. These are a small fraction of mentions but they are present in
every large corpus.

**Evolving terminology**: Medical terminology changes. What was called "Cushing's
syndrome\index{Cushing's syndrome}" in older literature may be distinguished from "Cushing's disease\index{Cushing's disease}" in
newer literature, where the former refers to hypercortisolism from any cause and
the latter specifically to a pituitary adenoma. A system that treats these as
the same entity conflates distinct clinical concepts; a system that treats them
as always different misses genuine synonymy in papers that use them
interchangeably.

**Cross-language variants**: In a corpus drawn from international literature,
the same entity may appear under its English name, its name in another language,
or a transliteration.

No single resolution strategy handles all of these. The lookup chain addresses
this by applying strategies in sequence, from cheapest and most precise to most
expensive and most approximate.

### The Lookup Chain

The lookup chain is the identity server's resolution strategy. It applies three
stages in order, stopping when a match is found:

**Exact match**: Compare the normalized mention string against known surface
forms in the identity server's database and against the authority's own synonym
list. Fast, zero false positives, handles the majority of mentions in a
well-studied domain.

**Fuzzy match**: Apply edit-distance or token-based similarity to catch
misspellings and minor variations. Requires a similarity threshold to avoid
false positives; the threshold is domain-configurable.

**Embedding similarity**: Embed the mention string and search for nearby
vectors in the entity database using pgvector\index{pgvector}. Handles semantic equivalence
that lexical methods cannot -- cases where two surface forms share no characters
but refer to the same concept. Most expensive; used only when the first two
stages fail.

If all three stages fail, the identity server creates a provisional entity. The
mention is not discarded -- it participates in the graph immediately, under a
provisional ID -- but it is flagged for later resolution or promotion.

The three-stage design is a cost optimization. Most mentions in a well-studied
domain will resolve at the exact match stage. Fuzzy and embedding stages are
invoked only for the residue. In a large corpus run, this keeps the total cost
manageable without sacrificing resolution quality on the hard cases.

## Chapter 3: The Epistemic Commons

`\chaptermark{Epistemic Commons}`{=latex}

### Authorities as Infrastructure

The identity server does not invent canonical identifiers. It borrows them from
communities that have been building shared identity infrastructure for decades.

MeSH\index{MeSH} -- Medical Subject Headings\index{Medical Subject Headings} -- is maintained by the National Library of
Medicine and covers diseases, drugs, biological processes, and anatomical
structures. It has been the standard vocabulary for biomedical literature
indexing since 1963. Its hierarchical structure encodes relationships among
concepts that would otherwise have to be extracted from text.

HGNC -- HUGO Gene Nomenclature Committee -- maintains official symbols and names
for human genes. When a paper from 1987 uses a gene name that was superseded in
1995, HGNC records both names and the relationship between them. The identity
server can resolve the old name to the current symbol without any domain-specific
logic.

RxNorm, maintained by the National Library of Medicine\index{National Library of Medicine}, provides normalized
names for clinical drugs. UniProt\index{UniProt} maintains the authoritative database for
protein sequences and functional information. ChEMBL\index{ChEMBL} covers bioactive molecules.

### NCBI Taxonomy

The Linnaean\index{Linnaeus, Carl} hierarchy\index{Linnaean hierarchy} -- kingdom, phylum, class, order, family, genus, species --
is the picture most people carry from school biology. When a knowledge graph
needs **organisms** (strains, species, higher taxa) to sit in a stable tree, not
just diseases and drugs, a separate class of authority applies. **NCBI\index{NCBI}
Taxonomy**\index{NCBI Taxonomy}, maintained by the National Center for
Biotechnology Information\index{National Center for Biotechnology Information}, is the taxonomy that backs GenBank\index{GenBank}, RefSeq\index{RefSeq}, BLAST\index{BLAST},
and the organism lines in UniProt\index{UniProt} and related resources. In practice it is the
shared hierarchy most biomedical pipelines assume when they say "this
sequence is from *Homo sapiens*\index{Homo sapiens}" or "this clade." It is not the same thing as
MeSH\index{MeSH}: it encodes clinical and literature concepts (including some organism
terms for indexing); NCBI Taxonomy encodes **taxonomic** parent/child
relationships for naming and classifying life for sequence and database work.
Other curated name lists exist for specialized domains (marine taxa, fungi,
viruses under ICTV\index{ICTV} rules, and so on); a production domain service may consult
more than one. This book treats NCBI Taxonomy as the canonical placeholder for
"the official online organism tree" in a biomedical stack -- with the
understanding that a fuller treatment would spell out API usage, version
stability, and when to fall back to embedding-based resolution for organisms
without a clean database hit.

These authorities share a common property: they were built to solve the same
problem the identity server solves, at the level of a single domain, by a
community of experts who needed shared identity to communicate. The identity
server aggregates them. It is a client of the epistemic commons, not a
replacement for it.

### What You Inherit When You Anchor

Anchoring an entity to an authority identifier does more than assign a unique
key. It connects the entity to the authority's full record for that identifier:
its definition, its synonyms, its taxonomic position, its cross-references to
related identifiers in adjacent authorities.

A disease entity anchored to MeSH\index{MeSH}:D003480 (Cushing Syndrome\index{Cushing syndrome}) inherits the MeSH\index{MeSH}
tree's knowledge that Cushing Syndrome\index{Cushing syndrome} is a subtype of Adrenal Cortex Diseases,
which is a subtype of Endocrine System Diseases, which is a subtype of
Pathological Conditions, Anatomical. It inherits the MeSH\index{MeSH}-recorded synonyms:
"Hypercortisolism", "Adrenal Cortex Hyperfunction". It inherits the
cross-references to ICD-10-CM\index{ICD-10-CM} codes.

None of this has to be extracted from the corpus. It is already encoded in the
authority. Anchoring is the operation that makes it available to the graph.

### Cross-Domain Composition

The consequence of anchoring to shared authorities extends beyond a single
graph. When two graphs -- one built from research papers, one built from clinical
trial records -- both anchor their disease entities to MeSH\index{MeSH} and their drug
entities to RxNorm, a query can traverse from a research finding to a clinical
trial outcome. The shared identifiers are the bridges.

This is not a feature of BFS-QL\index{BFS-QL}, or of any query protocol. It is a consequence
of the decision to anchor to shared authorities. The identity server makes that
decision systematic and enforced rather than optional and inconsistent.

The practical implication for graph builders: every entity that could be anchored
to an authority should be. Provisional entities that remain unanchored are
islands -- they participate in their local graph but cannot bridge to other
graphs. The authority lookup stage of the lookup chain is not an optimization.
It is the operation that connects the graph to the epistemic commons.

# Part II: The Typed Graph

## Chapter 4: What an Authoritative Ontology Is

`\chaptermark{What an Authoritative Ontology Is}`{=latex}

### Strings vs. Things

Two passages in two different Holmes stories both mention "Holmes." In one,
Watson records that Holmes spent three days in disguise as an elderly Italian
priest. In another, a client addresses him directly as "Mr. Holmes." These
are the same person. A human reader does not deliberate about this. The
referent is unambiguous.

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
storing the things themselves. The graph is, in that sense, a collection of
pointers that has lost track of what it is pointing at.

Canonical identity\index{canonical identity} is the mechanism that makes the transition from strings
to things. It assigns each real-world entity a single stable identifier, and
it resolves surface form variation -- synonyms, abbreviations, misspellings,
alternate names -- to that identifier. The result is a graph where every
node represents a thing, not a mention, and where two nodes connected by an
edge are genuinely related, not merely co-occurring in text.

The identifier needs a home. It cannot be invented arbitrarily, or it will
be invented differently by every system that builds a graph over the same
domain. Two graphs that assign different identifiers to the same entity
cannot be composed without a third system that bridges their identifier
spaces -- and that bridging system faces exactly the same problem the
original graphs faced. The solution is to anchor identifiers to an external
authority: a community that has already done the work of naming things
unambiguously in this domain, whose identifiers are stable, whose coverage
is known, and whose judgment about what constitutes a distinct entity is
trustworthy.

That external authority is an authoritative ontology.

### What an Authoritative Ontology Provides

An authoritative ontology\index{authoritative ontology} is more than a naming system. It is a
community's organized understanding of a domain, encoded in a form that
machines can consume. At minimum it provides four things.

**A stable identifier.** Each entity in the ontology has an identifier that
does not change when the entity's preferred name changes, when new
information is discovered about it, or when the ontology is reorganized.
Stability is what makes it safe to use the identifier as a graph node key.
A node keyed on a string name is hostage to whatever renaming decision the
community makes next. A node keyed on a stable ID survives those decisions
intact.

**A canonical name and known synonyms.** The ontology records what the
community currently considers the preferred way to refer to this entity,
along with all the alternate names it has been known by. This is the
synonym table that identity resolution consults. The graph does not need to
maintain its own synonym list for well-studied entities -- it inherits the
ontology's, which is likely to be more complete and more carefully curated
than anything a graph-building pipeline could produce.

**A position in a relational structure.** Most authoritative ontologies
are not flat lists of names. They encode relationships: hierarchical
position (this disease is a subtype of that class of diseases), cross-domain
links (this drug targets that gene), and semantic relationships between
concepts. When a graph entity is anchored to an ontology term, it inherits
that entity's position in a web of knowledge that the community assembled
over years or decades. A traversal that starts from that entity can follow
edges that were never extracted from any text -- they come from the ontology
itself.

**Community trust.** An authoritative ontology is maintained by an
identified community with a stake in its accuracy and a process for
correcting errors. MeSH\index{MeSH} is maintained by the National Library of Medicine.
HGNC\index{HGNC} is maintained by the HUGO Gene Nomenclature Committee. UniProt\index{UniProt} is
maintained by a consortium of Swiss, American, and European research
institutes. The authority is not just the data -- it is the human
organization behind the data, accountable for its quality over time.

A canonical ID drawn from such an authority is not just a unique key. It is
a claim that this entity has been placed in the epistemic commons\index{epistemic commons} of its
domain -- that it has been named by people who know the domain, cross-
referenced against adjacent knowledge, and assigned a position in the
community's shared understanding. That placement is inherited by any graph
that anchors to the same identifier.

### URIs as Stable Referents

The cleanest implementation of this idea is the one the web already
provides. A URI -- a Uniform Resource Identifier -- is a globally unique,
syntactically unambiguous name for a thing. Two systems that use the same
URI for the same entity agree on the referent without any negotiation. No
central registry is required beyond whatever system minted the URI in the
first place.

Wikidata\index{Wikidata} exploits this directly. Every entity in Wikidata has a stable
URI of the form `https://www.wikidata.org/entity/Q{n}`. These URIs are
dereferenceable: following them returns structured data about the entity.
They are stable: the Wikidata community treats ID permanence as a design
commitment. They are broadly scoped: Wikidata covers geographic entities,
historical figures, organizations, creative works, biological taxa, chemical
compounds, and much else. And they are cross-referenced: each Wikidata
entity links to its identifiers in other authoritative systems, making
Wikidata a practical hub for navigating between identifier spaces.

Wikipedia's article URLs serve a similar function for a narrower purpose.
The URL of an article is, for most entities significant enough to have a
Wikipedia article, a stable and globally recognized identifier. Two systems
that use the Wikipedia URL for the same entity agree on the referent even if
they use entirely different internal representations. The URL is not just an
address -- it is an identity claim, backed by the editorial community that
maintains the article and keeps the URL pointing at the right thing.

This is the model the Holmes domain will use, for a domain-specific reason
explored in Chapter 5. For now, the structural point is general: URI-based
identifiers, drawn from sources with a community commitment to stability,
are the practical implementation of "things, not strings" in a graph
context. Two graphs that share a URI share a referent. Composition becomes
a matter of set intersection on identifier spaces, not a disambiguation
problem.

### Domains Without Official Authoritative Ontologies

Medicine, chemistry, biology, and geography have mature authoritative
ontologies built over decades by large professional communities. Most domains
do not. A graph built over legal case law, historical correspondence,
engineering specifications, or literary fiction has no MeSH to consult, no
HGNC, no ChEMBL\index{ChEMBL}. The entities in those domains have not been enumerated by
any standards body. Their synonyms have not been catalogued. Their
relationships have not been formalized.

This is not a reason to abandon canonical identity. It is a reason to be
clear about what "authoritative" means in each domain.

In domains without official ontologies, authority is assembled from whatever
stable, community-maintained resources exist. A well-maintained wiki.
A reference database maintained by a scholarly community. A curated
catalogue published by a professional organization. The assessment criteria
are the same as for a formal ontology: Does it cover the entities this
graph needs? Are its identifiers stable? Is there a community behind it
with an interest in maintaining it? The source of authority may be less
formal, but the function is identical.

The Holmes corpus illustrates this directly. Sherlock Holmes is one of the
most extensively documented fictional universes in existence, with a devoted
scholarly community that has catalogued its entities in considerable detail.
Chapter 5 examines what that community has produced and how it can serve as
a domain authoritative ontology for a graph built over the stories. The
assessment is honest about fitness: coverage, stability, identifier
structure. No source is assumed to be authoritative simply because it
exists.

Where no external source fits -- where entities are too obscure, too
domain-specific, or too newly coined to appear in any catalogue -- the
identity server mints provisional identifiers. Provisional entities are
valid graph nodes. They participate in the schema with full type constraints.
They accumulate evidence. They can be promoted to canonical status when
evidence reaches a threshold, or merged with a later-discovered canonical
entity without requiring re-ingestion of the edges that reference them.
The graph does not stall because an entity cannot be immediately anchored.
It records uncertainty honestly and continues.

The boundary between "has an authoritative ontology" and "does not" is not
a binary. It is a spectrum. A graph built over biomedical literature sits
near one end: rich, overlapping authoritative ontologies, decades of
curation, high identifier stability. A graph built over a collection of
Victorian detective stories sits further along, with a smaller community
and a less formal apparatus, but a genuine scholarly tradition that can
serve the same function. A graph built over proprietary internal documents
may have no external authority at all, and must construct its own -- a
harder problem, addressed in the discussion of domain service design in
Part IV. The architecture is the same in all cases. What varies is how much
of the authority must be constructed locally rather than inherited from the
community.

## Chapter 5: The Baker Street Wiki as Domain AO

`\chaptermark{The Baker Street Wiki}`{=latex}

### Assessment of Fitness

An authoritative ontology earns that designation. The assessment is not
ceremonial -- it is the work of establishing that a source is fit to serve
as the identity backbone of a graph, and that entities anchored to it will
remain anchored as the graph grows, ages, and is composed with other graphs.
Three criteria matter: coverage, stability, and identifier structure.

**Coverage** is the question of whether the source has an entry for every
entity the graph needs to represent. A source with excellent coverage of
major characters and none of minor ones forces a hybrid strategy from the
start: canonical anchors for some entities, provisional identifiers for
others, with the boundary drawn by the source's editorial decisions rather
than the graph's needs. Partial coverage is workable -- the identity server
is designed for it -- but it is a cost, and it should be assessed honestly
before committing to a source.

**Stability** is the question of whether identifiers will remain valid over
time. A source that reorganizes its URL structure, merges articles, or
deletes entries without redirects will silently break any graph anchored to
it. The canonical ID stored in the graph becomes a dead reference. Stability
is partly a technical property of how the source manages its URLs, and
partly a social property of the community behind it -- whether they treat
identifier permanence as a commitment or merely as a current convenience.

**Identifier structure** is the question of whether the source's URLs or
keys are clean enough to use directly as canonical IDs. A URL that encodes
a stable, human-readable entity name is easy to work with: it is inspectable,
searchable, and self-documenting. A URL that encodes a session parameter,
a content-delivery path, or a database row number opaque to the outside
world is harder. The identifier structure does not determine whether a source
can be used, but it affects how much adapter logic the domain service needs
to write.

The Baker Street Wiki\index{Baker Street Wiki} -- hosted at \texttt{bakerstreet.fandom.com} -- is the
most comprehensive publicly available reference for the Sherlock Holmes
canonical stories. It is a fan-maintained wiki in the Fandom network,
with articles covering characters, locations, objects, events, and stories
across the entire Conan Doyle\index{Doyle, Arthur Conan} corpus. Assessing it against the three
criteria:

Coverage is strong for the canonical stories. Every named character of
any significance in the sixty stories of the original canon has an article.
Major locations -- Baker Street itself, Baskerville Hall, the Reichenbach
Falls -- are documented in detail. Significant objects -- the blue carbuncle,
the speckled band, Watson's service revolver -- have entries. The coverage
thins for truly minor figures: a landlady mentioned once by name, an
unnamed constable who appears in a single scene. These will become
provisional entities in the graph regardless of which AO is chosen.

Stability is adequate. Fandom wikis do not guarantee identifier permanence
in the way that Wikidata does, and the history of fan wikis includes
migrations, reorganizations, and domain changes. The Baker Street Wiki
has been stable at its current domain for long enough to constitute a
reasonable bet, and its article titles -- which drive its URL structure --
are unlikely to change for entities as well-documented as Holmes, Watson,
and Irene Adler. The risk is real but manageable: the domain service can
maintain a mapping from Baker Street Wiki URLs to local identifiers, so
that if a URL changes, the update is made once in the domain service and
propagates automatically to any graph anchored through it.

Identifier structure is clean. A Baker Street Wiki URL takes the form
\texttt{https://bakerstreet.fandom.com/wiki/\{Article\_Title\}}, where the
article title is the canonical name of the entity with spaces encoded as
underscores. This is inspectable and self-documenting. The URL for
Sherlock Holmes is \texttt{https://bakerstreet.fandom.com/wiki/Sherlock\_Holmes}.
The URL for Irene Adler is
\texttt{https://bakerstreet.fandom.com/wiki/Irene\_Adler}. No opaque
database keys, no session parameters, no content-delivery indirection.
The identifier is the name, structured for machine consumption.

The Baker Street Wiki is a reasonable domain AO for this corpus. It is not
perfect. It is fit for purpose.

### Using Wiki Page URLs as Canonical IDs

The practical consequence of the assessment is straightforward: each Holmes
entity in the graph is assigned the URL of its Baker Street Wiki article as
its canonical ID. No external identifier service is required. No mapping to
a formal ontology's numbering scheme needs to be maintained. The AO is a
static resource that the domain service can query -- or cache locally, since
the wiki changes rarely -- and the identifier is the URL itself.

This simplicity is worth noting because it runs against a common instinct
in knowledge graph design, which is to mint clean internal identifiers --
short strings or UUIDs -- and maintain a separate mapping to external
sources. That architecture has merits when multiple external sources need
to be reconciled, when the external source's identifiers are unstable, or
when the internal identifier space needs to be controlled for performance
reasons. For a single-domain graph anchored to one stable AO with clean
URL structure, it adds complexity without adding value. The URL is the
identifier. The domain service uses it directly.

The domain service's \texttt{resolve-authority} endpoint -- which the
identity server calls when it cannot resolve a mention by exact or fuzzy
match against its local database -- queries the Baker Street Wiki by
constructing a candidate URL from the mention string and checking whether
the article exists. If the article exists and the entity type is consistent
with what the article describes, the URL is returned as the canonical ID.
If the article does not exist, or if the article describes an entity of
the wrong type, the call returns null and the identity server falls back to
the next stage of the lookup chain.

The domain service also benefits from the wiki's redirect structure. A
query for "Holmes" will redirect to "Sherlock\_Holmes." A query for
"Sherlock" will redirect to the same article. The redirect is the wiki's
own synonym resolution, and the domain service can follow it: any URL that
resolves to the canonical article URL, whether directly or through
redirects, is treated as a surface form of the same entity.

### Synonym Resolution via the Authoritative Ontology

The Baker Street Wiki's synonym coverage is partly explicit -- alias lists
in article infoboxes, redirect articles for common alternate names -- and
partly implicit in the redirect structure. Both forms are useful.

"Holmes," "Sherlock," "Mr. Holmes," "the great detective," "the world's
only consulting detective" -- these all refer to the same person, and
a reader of the stories knows this immediately. An extraction pipeline
does not. It sees strings, and it needs a lookup table that maps these
strings to the canonical ID. The Baker Street Wiki provides a starting
point for that table: the redirect graph captures the most common alternate
names, and the alias field in structured article data captures others.

What the wiki does not capture is the full range of surface forms that
appear in natural text. Contextual references -- "my friend," "the
detective," "he" -- are not resolvable from a synonym table alone, and are
outside the scope of the identity server in any case: pronoun resolution
is an extraction-layer concern, and by the time a mention reaches the
identity server it has already been classified as a named entity. The
identity server resolves named mentions; the extraction pipeline is
responsible for deciding which pronouns and contextual references to
convert into named mentions before passing them downstream.

Within the space of named mentions, the synonym lookup operates as follows.
An exact match against the synonym table is attempted first. If the mention
string appears in the table, the canonical ID is returned immediately. If
it does not, fuzzy matching against the synonym table catches misspellings
and minor variations. If fuzzy matching fails to produce a confident match,
embedding similarity compares the mention against the full set of known
surface forms in vector space. The chain is ordered by cost: exact match
is free, fuzzy matching is cheap, embedding similarity is expensive and
reserved for cases the cheaper methods cannot handle. Chapter 6 examines
this lookup chain in detail.

### Entities the Wiki Does Not Cover

Every corpus contains entities that no authoritative source has documented.
In the Holmes corpus, these are typically minor figures: the unnamed
landlady of a client, a constable referred to only by the narrator's
description, a location invented for a single story that the Baker Street
Wiki has not thought worth a dedicated article. These entities exist in the
text. Relationships involving them are real claims that the graph should
record. Their absence from the wiki is a coverage gap in the AO, not a
reason to discard the information.

The identity server handles this through provisional entities\index{provisional entity}. When the
lookup chain -- exact match, fuzzy match, embedding similarity, AO query --
exhausts without finding a match, the identity server mints a local
identifier for the entity: a UUID prefixed with a namespace marker that
distinguishes it from Baker Street Wiki URLs. The entity is entered into
the identity database as provisional: real, typed, usable, but not yet
anchored to any external authority.

Provisional entities are full graph citizens. They receive the same type
constraints as canonical entities. Edges can reference them. They
accumulate evidence across multiple extractions. If, on a later ingestion
run, the same entity is encountered again and a match is found -- because
the AO has since added an article, or because a different surface form now
matches -- the provisional entity can be promoted to canonical status, and
all edges that referenced the provisional ID are updated to reference the
canonical one. The graph does not need to be re-ingested. The promotion
operation is surgical.

The existence of provisional entities means the graph can be built
incrementally, with honest uncertainty, without stalling on entities that
cannot yet be resolved. The Holmes corpus has a finite entity population,
and most of it is well-covered by the Baker Street Wiki. The provisional
tail is small. But the architecture that handles it cleanly for Holmes
handles it equally well for a domain where the AO covers thirty percent
of the entities rather than ninety. The design does not assume ideal
coverage.

## Chapter 6: Deduplication and Provenance

`\chaptermark{Deduplication and Provenance}`{=latex}

### Deduplication as Graph Hygiene

The most common source of structural corruption in a knowledge graph is not
bad data. It is good data, stored twice, under different names, with no
mechanism to recognize that the two entries refer to the same thing.

A graph that contains two nodes for Irene Adler -- one created from the
mention "Irene Adler" in one story, another from "the woman" resolved to a
named entity in another -- has not made a factual error. Both nodes are
correctly typed as `Person`. Both accumulate correctly extracted
relationships. The graph's failure is structural: it has split one entity
across two nodes, and every query that asks about Irene Adler will return
at most half of what the graph knows about her. The other half is stored
under a node the query did not reach.

Deduplication is not a cleanup step that follows ingestion. It is a
structural requirement that must be satisfied continuously, at ingestion
time, for every entity mention the pipeline produces. A deduplication step
that runs weekly, or after ingestion is complete, or on demand when a user
notices something wrong, will always be fighting a growing backlog of split
entities. The identity server enforces deduplication at write time, before
a duplicate node can be created, because the cost of preventing a split
entity is much lower than the cost of merging two nodes that have
accumulated relationships independently.

The challenge is that deduplication at insertion time requires resolving
mentions against the full current state of the identity database --
checking not just whether this exact string has been seen before, but
whether this mention, under any of its possible surface forms, refers to an
entity already in the graph. This is the lookup chain.

### The Lookup Chain

The lookup chain\index{lookup chain} is a sequence of resolution strategies, ordered by cost,
each handling the cases the prior stage cannot. A mention that resolves at
an early stage costs less than one that falls through to a later stage.
The ordering reflects that asymmetry: the cheapest strategy is attempted
first, and subsequent strategies are invoked only when cheaper ones fail.

**Exact match** is the first stage. The mention string is looked up
verbatim in the synonym table -- the identity server's local database of
canonical IDs and their associated surface forms. If the string appears in
the table, the canonical ID is returned immediately. The cost is a single
indexed database lookup. The stage handles all mentions that have been seen
before in exactly this form, which, in a large corpus being processed
incrementally, is the majority of cases.

**Fuzzy match** is the second stage, reached when exact match fails. The
mention string is compared against all known surface forms using a
string-similarity metric -- the Graphwright implementation uses
\texttt{rapidfuzz}\index{rapidfuzz}, which provides several metrics and is fast enough to
scan a synonym table of tens of thousands of entries in milliseconds.
A match above a configurable threshold is accepted as a synonym and the
corresponding canonical ID is returned. This stage handles abbreviations,
misspellings, and minor variations that differ from a known surface form
by a small edit distance. "Sherlock Homes" resolves to Sherlock Holmes.
"DDAVP" resolves to desmopressin if the synonym table has been seeded from
the authoritative ontology.

**Embedding similarity** is the third stage, reached when fuzzy match
fails or produces no confident result. The mention string is embedded into
a vector representation using the same embedding model the extraction
pipeline uses, and that vector is compared against the stored embeddings
of all known surface forms using \texttt{pgvector}\index{pgvector}'s approximate nearest
neighbor search. This stage catches semantic equivalence that string methods
miss: two surface forms that are not similar as strings but refer to the
same concept will tend to cluster in embedding space. It is slower and
more expensive than the prior stages, and it is reserved for cases they
cannot handle.

The ordering is deliberate, and worth stating explicitly: the chain is
ordered by cost, not by sophistication. Embedding similarity is the most
sophisticated method, but that is not why it is last. It is last because
it is expensive, and because exact and fuzzy matching already handle the
large majority of cases. Running embedding similarity on every mention
would be correct but wasteful. Running it only when cheaper methods have
failed is correct and efficient.

**The authoritative ontology lookup** is the fourth stage, invoked when
the local synonym table has no match at any confidence level. The domain
service's \texttt{resolve-authority} endpoint is called with the mention
string and entity type. The domain service queries the Baker Street Wiki,
or whatever authority is configured for this domain, and returns a
canonical ID if a match is found. If the AO lookup succeeds, the canonical
ID is added to the local synonym table so that the same mention will resolve
via exact match on all future encounters. If the AO lookup also fails, the
mention is provisionally identified.

This four-stage chain -- exact match, fuzzy match, embedding similarity,
AO lookup -- handles the full range of resolution cases with costs
proportional to difficulty. Simple cases are cheap. Hard cases are
expensive. The distribution of cases in a typical corpus means the chain
is fast in aggregate even when individual mentions fall through to the
later stages.

### Provisional Entities

When the full lookup chain exhausts without a match, the identity server
does not block. It mints a provisional entity\index{provisional entity}: a new graph node with
a locally generated canonical ID, typed as specified by the extraction
pipeline, and flagged as provisional in the identity database.

The rationale for provisional entities rather than blocking is
architectural. A pipeline processing a large corpus cannot wait for every
entity to be resolved before proceeding. Some entities will not be
resolvable at the time of their first encounter: the AO may not have an
entry, the mention may be too ambiguous to match confidently, or the entity
may be genuinely novel -- a name coined in this document that appears nowhere
else. Blocking on these cases would stall the pipeline on a problem that
may never be solvable. Minting a provisional entity allows the pipeline to
continue, the relationship to be recorded, and the question of identity to
remain open.

Provisional entities are not second-class citizens of the graph. They carry
full type constraints. Edges incident to them are valid. They accumulate
evidence across multiple extraction runs. A provisional entity that appears
in fifty documents, each of which extracts relationships involving it, has
fifty sources of evidence even before it is promoted to canonical status.

Promotion\index{promotion} occurs when the provisional entity accumulates enough evidence to
warrant anchoring it to a canonical ID. The threshold is domain-configurable:
a conservative domain might require a high evidence count and an AO match
before promoting; a permissive domain might promote on the first confident
AO lookup. When promotion occurs, the entity's local ID is replaced by the
canonical ID, and all edges referencing the old ID are updated. Downstream
systems are notified via the \texttt{on-entity-added} hook. The graph
continues without re-ingestion.

Merge\index{merge} is the related operation for the case where two provisional
entities, or a provisional entity and a canonical one, are determined to
be the same. Chapter 9 covers the merge operation and its interface in
detail. The key property shared by promotion and merge is that the graph
remains navigable throughout: at no point does a canonical ID reference an
entity that no longer exists, and at no point does a merge produce a graph
with dangling edges.

### Provenance: Linking Every Triple to Its Source

A triple without a source is not a claim. It is a rumor: an assertion that
has been separated from the evidence that generated it, and that can
therefore be neither confirmed nor corrected by inspecting that evidence.
A knowledge graph built from extracted text is only as trustworthy as its
ability to trace every edge back to the passage that produced it.

Provenance\index{provenance} in the Holmes graph means that every edge carries a pointer
to its origin: the story title, the chapter, and the specific passage from
which the relationship was extracted. This is not optional metadata that
can be added later if someone wants it. It is a structural requirement,
enforced by the schema in the same way that domain and range constraints
are enforced. An edge without provenance is rejected at insertion time, for
the same reason that a type-invalid edge is rejected: because the graph's
usefulness depends on this property holding for every edge, not just the
ones someone remembered to annotate.

The practical value of provenance operates on several levels. The most
immediate is inspection: when a query returns a relationship that looks
surprising or wrong, the provenance link tells the user exactly which
passage produced it. The user can read the passage, assess whether the
extraction was correct, and if not, flag the edge for correction without
disturbing anything else in the graph. Errors are localizable to specific
claims, not diffused across the graph's structure.

The second level is confidence aggregation. The claim that Holmes suspects
Irene Adler of concealing the photograph appears in one passage. The claim
that Holmes considers her "the woman" -- his sole term of admiration -- is
supported by multiple authorial observations across the story. These are
not equally strong claims. Provenance makes it possible to count supporting
passages and weight confidence accordingly: a claim backed by three
independent passages is assigned higher confidence than one backed by one.
Without provenance, the graph has no mechanism for this arithmetic. Every
claim is equally unsupported.

The third level is correction. When the Holmes schema is revised -- a
predicate renamed, a type constraint tightened, a provisional type promoted
or removed -- provenance makes it possible to audit the impact. A graph
linter can enumerate every edge that used the old predicate, trace each to
its source passage, and determine whether the passage actually supports a
claim expressible under the new predicate. Schema evolution becomes
manageable. Without provenance, schema revision means re-extracting and
re-ingesting the entire corpus, because there is no way to know which edges
are affected.

### What `Moment` Enables for Provenance

The Holmes corpus presents a provenance problem that a simple source
pointer does not fully solve.

Watson knows things at different times. A fact can be true throughout a
story while remaining unknown to Watson -- and therefore unrecorded in his
narration -- until a specific moment of revelation. In "The Adventure of
the Empty House," Holmes reveals that he survived the struggle at
Reichenbach Falls and has spent three years in hiding. This fact was true
during the events of "The Final Problem." But Watson's narrative of those
events records Holmes as dead, because Watson did not know otherwise. The
graph, if it only records what Watson asserts and when he asserts it, will
contain a contradiction: Holmes is dead (per Watson's account in "The Final
Problem") and Holmes is alive (per Holmes's own account in "The Empty
House").

The `Moment`\index{Moment (entity type)} entity type exists to resolve this class of problem. A
`Moment` is not a clock time. It is a named point in the epistemic
timeline of the narrative: the moment at which a particular assertion
became knowable to a particular narrator. A provenance record can include
not just the source passage but the `Moment` associated with it: the point
in the story's epistemic sequence at which this claim entered the
narrator's knowledge.

The assertion "Holmes is alive" can then be stored with two provenance
records: one anchored to the `Moment` of Holmes's return in "The Empty
House," at which point the claim becomes known; and one anchored to
events that Holmes himself reports from his hidden years, which were true
throughout but knowable only retrospectively. The graph does not collapse
these into a single undated claim. It records the epistemics honestly:
when was this known, by whom, and on what evidence.

This is not a general-purpose mechanism for all knowledge graphs. Most
domains do not have the deliberate narrative structure that makes the
Holmes corpus epistemically complex in this way. `Moment` is a provisional
type specific to this corpus, and its provisional status in the schema
reflects exactly that: it carries full type constraints and participates
normally in the graph, but it is flagged as domain scaffolding that may
not transfer to other domains. The value of showing it here is not to
argue that every graph needs a `Moment` type. It is to show what the
schema can express when a domain's epistemics require it -- and that a
typed graph with provenance has the vocabulary to represent this kind of
complexity without collapsing it into noise.

## Chapter 7: The Problem the Identity Service Solves

`\chaptermark{The Problem the Identity Service Solves}`{=latex}

### Extraction Produces Mentions, Not Entities

The extraction pipeline reads unstructured text and produces structured output:
subject, predicate, object, with the subject and object expressed as mention
strings. "Holmes" appears as a subject string. "Baker Street" appears as an
object string. These strings are not entities. They are references to entities --
references that may be ambiguous, inconsistent across passages, and duplicated
across dozens of papers or story chapters.

The graph needs nodes with canonical IDs. A node labeled "Holmes" and a node
labeled "Mr. Holmes" are, to the graph, two different things unless something
resolves them to the same identity. The extraction pipeline cannot do this
resolution: it processes one passage at a time and has no memory of what it
has already seen. The identity service\index{identity service} is the bridge between what the
extraction pipeline produces (mention strings) and what the graph requires
(canonical IDs).

This is not a minor bookkeeping step. It is the operation that determines whether
the graph is a collection of loosely related strings or a network of unambiguously
identified entities that can support multi-hop reasoning. The identity service is
where the strings become things.

### Why a Service, Not a Library

The obvious alternative to a service is a library: a set of functions the
extraction pipeline calls to resolve mentions. A library would work correctly for
a single-process pipeline running sequentially. It fails under the conditions
where knowledge graph construction actually operates.

Real ingestion pipelines run many workers in parallel. Worker A is processing
chapter three of *The Hound of the Baskervilles*\index{Hound of the Baskervilles, The}; worker B is processing
chapter seven of the same story; both extract a mention of "Stapleton." Without
a shared service, both workers may decide to mint a new provisional entity for
"Stapleton" -- because neither knows the other has already done so. The graph now
has two provisional nodes for the same character, and the deduplication problem
that the identity system was supposed to solve has been re-created by the identity
system itself.

A service with a database and advisory locking\index{advisory locking} solves this by making entity
creation a serialized, database-backed operation. When two workers race to create
"Stapleton," exactly one wins and returns the new ID; the other receives the
same ID that the first worker just created. Cross-process uniqueness is enforced
by the service. A library cannot provide this guarantee.

### The Identity Service as a Black Box to the Pipeline

The extraction pipeline's view of the identity service is deliberately narrow.
It sends a (mention string, entity type) pair and receives a canonical ID. That
is all. It does not know whether the ID was resolved against the Baker Street
Wiki,\index{Baker Street Wiki} retrieved from the server's in-memory cache, returned from the embedding
similarity stage of the lookup chain, or freshly minted as a provisional entity.
The pipeline stores the ID in the relationship record and moves on.

This opacity is not a limitation -- it is the design. The resolution logic inside
the identity service can be upgraded, tuned, or replaced without touching the
extraction pipeline. The pipeline can be tested against a stub identity service
that returns predictable IDs. The identity service can be scaled independently
of the pipeline. The clean interface between them is what makes both components
maintainable as the system grows.

# Part III: The Identity Service

## Chapter 8: Architecture and Design Rationale

`\chaptermark{Architecture and Design Rationale}`{=latex}

### Domain-Agnostic Core

The identity service splits into two components: a base server and a domain
service. The base server is domain-agnostic. It orchestrates the lookup chain,
enforces idempotency, manages Postgres advisory locking, runs the pgvector
similarity search, and maintains the entity lifecycle state machine. None of
that logic knows anything about Holmes, or medicine, or materials science.

The domain service is where domain knowledge lives. It knows which authoritative
ontology\index{authoritative ontology} to consult, how to evaluate candidate synonyms, how to pick a
survivor when two entities merge, and how to weight evidence for confidence
scoring. These are the decisions that change from domain to domain; everything
else is mechanics.

Keeping domain knowledge out of the base server is not organizational tidiness.
It is what makes the system reusable. A base server that contains no domain
assumptions can be deployed for a new domain by writing a new domain service,
not by modifying the core. Domain logic that leaks into the core creates
maintenance debt that compounds with every new deployment: you can no longer
reason about the base server without understanding every domain it has ever
served.

### The Plugin Contract

The domain service implements exactly four endpoints that the base server calls
during resolution and merging:

- `POST /resolve-authority` -- given a mention and entity type, query the
  domain's authoritative ontology and return a canonical ID if found.
- `POST /select-survivor` -- given two entity records, return the one that
  should survive a merge.
- `POST /compute-confidence` -- given a list of evidence records, return a
  composite confidence score.
- `GET /synonym-criteria` -- return the thresholds the identity server should
  use when deciding whether two mentions are synonyms.

Four endpoints, not more. These are the four decisions that vary by domain;
everything else is mechanics that the base server handles uniformly. A small
contract surface means the contract is auditable: you can read it in five
minutes and understand exactly what a new domain service must implement. It
also means the domain service is easy to test in isolation -- stub the four
endpoints and you can exercise every code path in the base server.

### Advisory Locking in Postgres

When two parallel extraction workers both encounter a mention of "Watson" for
the first time, they both call `resolve("Watson", "Person")`. Both find no
existing entity. Without coordination, both mint a new provisional entity, and
the graph has two nodes for the same character.

Postgres\index{Postgres} advisory locks solve this. Before creating a new entity, the base
server acquires an advisory lock keyed on the hash of `(mention, entity_type)`.
The first worker acquires the lock, checks for an existing entity, finds none,
creates one, and releases the lock. The second worker acquires the lock, checks
for an existing entity, finds the one the first worker just created, and returns
its ID without creating a duplicate.

Advisory locks are the right tool here rather than standard transactions for a
practical reason: the resolution operation spans multiple queries -- a lookup,
possibly an authority call, an insert, a cache update. Holding a transaction
open across all of that would serialize concurrency more than necessary. Advisory
locks scope the mutual exclusion to the logical operation and release as soon as
the entity ID is determined, letting other operations proceed in parallel.

### Entity Lifecycle: Three Statuses

Every entity in the identity service has one of three statuses, and transitions
between them are one-way.

**Provisional**\index{provisional entity}: Created from a mention that did not match any known authority.
The entity participates fully in the graph -- relationships reference it,
evidence accumulates against it -- but it is flagged as unanchored. It has a
locally minted ID, not an authority ID.

**Canonical**\index{canonical entity}: Anchored to an external authority. The entity has an authority
ID (for example, a Baker Street Wiki URL) and is the authoritative node for all
surface forms that resolve to it. Promotion from provisional to canonical happens
when the lookup chain finds an authority match, either at creation time or later
as more surface forms accumulate.

**Merged**\index{merged entity}: Absorbed into another entity. Merged entities retain their full
history -- their ID, their evidence records, their mention strings -- but they
are no longer active graph nodes. All relationships that referenced a merged
entity transparently resolve to the survivor. Merged status is terminal.

Status transitions are immutable by design. A merged entity cannot be un-merged
without invalidating every edge that referenced the survivor. Making transitions
one-way means the provenance audit trail is permanently trustworthy: every merge
event is logged and its consequences are stable.

### Idempotency

The identity service is designed to be called many times with the same arguments
and produce the same result every time. This is not a courtesy -- it is a
requirement.

Ingestion pipelines fail. A worker crashes halfway through a chapter, the batch
is retried, and the identity service receives the same mentions it already
processed. If the service is not idempotent, the retry produces different entity
IDs, and the graph is corrupted. If the service is idempotent, the retry returns
the same IDs the first run returned, and the graph is consistent.

Idempotency is implemented at the database level, not in application logic.
Entity creation is an upsert on `(mention, entity_type)`: if a row with those
values already exists, return its ID; otherwise insert and return the new ID.
Merge is checked against the merge log before executing: if these two entities
were already merged, return the existing result. Every write operation follows
the same pattern. The service is safe to retry unconditionally.

### Caching

Resolution is called once per mention per document. A large corpus run may call
`resolve` millions of times. Without caching, most of those calls would hit the
database for lookups that return the same result every time.

The identity service maintains two cache layers. The base server keeps an
LRU\index{LRU cache} (least-recently-used) cache keyed on `(mention, entity_type)` for resolved
IDs. A mention that has already been resolved returns its canonical ID from
memory without a database round-trip. The domain service keeps a long-TTL
(time-to-live) cache for authority API responses, so that repeated lookups of
the same entity against the Baker Street Wiki or another external authority do
not generate redundant HTTP requests across ingestion runs.

The `compute-confidence` endpoint is intentionally not cached. Its inputs vary
per call -- different sets of evidence records produce different scores -- and
the computation is cheap enough that caching would add complexity without
meaningful performance benefit. Caching decisions should be driven by the cost
of the operation and the likelihood of repeated identical inputs; not every
endpoint benefits equally.

## Chapter 9: The Identity Service HTTP Interface

`\chaptermark{The Identity Service HTTP Interface}`{=latex}

### `POST /resolve`

`POST /resolve` is the identity service's primary operation. The caller
supplies a mention string and an entity type; the service returns a canonical
ID. That ID is either anchored to an authoritative ontology or provisionally
minted -- the caller receives it either way and stores it in the relationship
record without needing to know which.

The operation runs the full lookup chain: exact match against known surface
forms, fuzzy match against the synonym table, embedding similarity search
against the pgvector\index{pgvector} index, and finally an authority lookup via the domain
service. If all four stages fail, a new provisional entity is created, its ID
returned, and the mention is recorded as a known surface form of that entity.

The endpoint is a POST, not a GET, because the operation has side effects.
A GET that creates database rows would violate HTTP semantics and confuse
any caching layer between the caller and the service. The resolve operation
may mint a provisional entity; that is a write, and it belongs on a POST.

### `POST /promote`

`POST /promote` elevates a provisional entity to canonical status. The caller
supplies the provisional entity ID and the canonical ID to assign; the service
records the transition, updates all surface forms to point to the canonical ID,
and marks the provisional ID as an alias.

The caller supplies the canonical ID rather than the service computing it
because authority lookup is domain knowledge. The domain service knows which
ontology to query and what the resulting ID should be; the identity service
records the transition. Responsibility stays where the knowledge lives.

Promotion is logged. The audit trail records when the promotion happened,
which caller triggered it, and which authority ID was assigned. A provisional
entity that was promoted in error can be investigated: the log shows what
evidence was available at promotion time.

### `POST /merge`

`POST /merge` declares two entities to be the same. The identity service calls
the domain service's `/select-survivor` endpoint to determine which record
survives, redirects all relationships from the non-survivor to the survivor,
and marks the non-survivor as merged.

Merge requires an explicit call rather than happening automatically when two
entities look similar. Merges are irreversible. A fuzzy match that was close
but wrong would corrupt the graph permanently if it triggered an automatic
merge. Requiring an explicit call means something deliberate triggered it:
a human review, a high-confidence rule, or a promotion that produced the
same canonical ID for two previously distinct entities. The explicitness is
a quality gate, not a convenience feature.

The merge operation is idempotent. If the two entities have already been
merged, the call returns the existing result without creating a new log entry.
Pipelines that retry on failure can call merge as many times as needed.

### `GET /entity/{id}`

`GET /entity/{id}` returns the full record for an entity: its current status,
all known surface forms, the full provenance audit trail, the composite
confidence score, and -- if canonical -- the authority name and authority ID.

This endpoint exists for inspection and debugging, not for the hot path of
ingestion. The ingestion pipeline calls `resolve` and stores the returned ID;
it does not need to fetch the full record. `GET /entity/{id}` is for the
engineer who wants to understand why a particular entity resolved the way it
did, or for the review tool that presents disputed entities to a human curator.

### `GET /schema`

`GET /schema` returns the domain spec as JSON: the complete set of entity
types and the full predicate vocabulary with domain, range, and constraint
declarations. The identity service fetches this from the domain service at
startup and re-fetches it when the schema version changes.

The schema endpoint belongs on the domain service, not the identity service.
The schema is domain knowledge; the identity service is domain-agnostic. The
identity service is a consumer of the schema, not its owner. This endpoint is
documented here because it is part of the contract between the two services,
but the implementation sits in the domain service -- covered in Part IV.

# Part IV: The Domain Service

## Chapter 10: `domain_spec.py` as the Single Source of Truth

`\chaptermark{domain\_spec.py as the Single Source of Truth}`{=latex}

### What the Domain Service Owns

The domain service is the boundary between the domain-agnostic identity
service and the actual knowledge of a specific domain. Everything that
varies from one deployment to the next lives here: the entity type
enumeration, the predicate list with domain and range declarations, the
choice of which authoritative ontology to consult, the rules for synonym
thresholds, the logic for survivor selection, and the weight table for
confidence scoring.

The identity service calls the domain service for four decisions and for
nothing else. The clean boundary means that a team deploying the Graphwright
infrastructure for a new domain -- say, legal case law rather than Holmes
stories -- writes a new domain service without touching the identity service.
The entire variation between domains is contained in this one component.

### Python as the Spec Language

The domain spec is a Python module named `domain_spec.py`,\index{domain\_spec.py} not a YAML or
JSON configuration file. The choice is deliberate. A configuration file can
express data: lists, dictionaries, strings, numbers. A Python module can
express logic: it can define the entity type enum, instantiate frozen Pydantic
models for each predicate, declare validation functions, and compute derived
values -- all in the same file, all testable with standard tooling, all
readable by any Python developer without learning a configuration schema.

The module round-trips to JSON for the `GET /schema` endpoint. The identity
service fetches the JSON; the domain service serializes it from the Python
objects. The Python module is the source of truth; the JSON is a derived
representation for wire transport. Changing the schema means editing
`domain_spec.py` -- there is one place to look.

Pydantic\index{Pydantic} frozen models are used for predicate definitions (`PredicateSpec`\index{PredicateSpec})
because frozen models cannot be mutated after construction. The spec is loaded
once at startup and then treated as a read-only fact. Any component that holds
a reference to a `PredicateSpec` holds the same object throughout its lifetime.
Consistency is structural.

### The Holmes Domain Spec Written Out

The Holmes corpus uses six entity types: `Person`, `Location`, `Object`,
`Event`, `Moment`, and `ConfidenceLevel`. The last two are flagged provisional
in the spec -- the domain designers are not yet certain these abstractions will
survive unchanged as the corpus grows, but they are operationally necessary now.

A fragment of `domain_spec.py` for the Holmes domain:

```python
from enum import Enum
from pydantic import BaseModel, Field
from typing import FrozenSet, Optional

class EntityType(str, Enum):
    PERSON = "Person"
    LOCATION = "Location"
    OBJECT = "Object"
    EVENT = "Event"
    MOMENT = "Moment"          # provisional
    CONFIDENCE_LEVEL = "ConfidenceLevel"  # provisional

PROVISIONAL_TYPES = frozenset({
    EntityType.MOMENT,
    EntityType.CONFIDENCE_LEVEL,
})

class PredicateSpec(BaseModel, frozen=True):
    name: str = Field(
        description="Predicate identifier")
    domain: FrozenSet[EntityType] = Field(
        description="Allowed subject types")
    range: FrozenSet[EntityType] = Field(
        description="Allowed object types")
    description: str = Field(
        description="Human-readable definition")
    is_functional: bool = Field(
        default=False,
        description="At most one object per subject")
    negation_of: Optional[str] = Field(
        default=None,
        description="Name of logical inverse")

PREDICATES = [
    PredicateSpec(
        name="associated_with",
        domain=frozenset({EntityType.PERSON}),
        range=frozenset({EntityType.LOCATION}),
        description=(
            "Person is habitually connected to location."
        ),
    ),
    PredicateSpec(
        name="disguised_as",
        domain=frozenset({EntityType.PERSON}),
        range=frozenset({EntityType.PERSON}),
        description=(
            "Person adopted the identity of another "
            "person or type."
        ),
    ),
    PredicateSpec(
        name="occurred_at",
        domain=frozenset({EntityType.EVENT}),
        range=frozenset({EntityType.MOMENT}),
        description=(
            "Event is anchored to a narrative moment."
        ),
    ),
    PredicateSpec(
        name="known_to_watson_at",
        domain=frozenset({EntityType.EVENT}),
        range=frozenset({EntityType.MOMENT}),
        description=(
            "Event became part of Watson's knowledge "
            "at this narrative moment."
        ),
    ),
]
```

The `occurred_at` and `known_to_watson_at` predicates illustrate why `Moment`
exists as an entity type: a single event may have two different temporal
anchors in the Holmes corpus -- when it happened, and when Watson (and through
him, the reader) came to know it. Tracking both is not a quirk of the stories;
it is what makes the graph epistemically precise for a corpus where disguise,
concealment, and delayed revelation are central to the narrative.

The Holmes `domain_spec.py` is small enough to read in an afternoon. That is
intentional: a schema that cannot be read and understood by a domain expert is
not serving its purpose. The spec is the contract; the contract must be legible
to the people who are bound by it.

## Chapter 11: The Domain Service HTTP Interface

`\chaptermark{The Domain Service HTTP Interface}`{=latex}

### `POST /resolve-authority`

`POST /resolve-authority` is the endpoint the identity service calls when
it needs to check whether a mention maps to a known authority ID. The caller
supplies a mention string and an entity type; the domain service queries its
authoritative ontology and returns either a canonical ID or null.

The domain service owns this endpoint because authority lookup is entirely
domain-specific knowledge. Which ontology to query, in what order, with what
fallback logic, how to normalize the mention before querying -- all of this
varies by domain and none of it belongs in the identity service. The identity
service knows that authority lookup should happen; the domain service knows how.

For the Holmes domain, this endpoint queries the Baker Street Wiki\index{Baker Street Wiki} by
constructing a URL from the mention and checking whether the page exists and
is a direct article rather than a redirect. If it is, the page URL becomes the
canonical ID. If not, the endpoint returns null and the identity service proceeds
to create or retain a provisional entity.

### `POST /select-survivor`

When two entities are merged, one must survive and one must be absorbed. The
identity service calls `POST /select-survivor` with both entity records and
receives back the ID of the record that should survive.

The full entity records are passed rather than just the IDs because the
selection logic may depend on fields that are not derivable from the ID alone:
evidence count, confidence score, whether the entity is already canonical,
which authority it is anchored to, and how many surface forms it has accumulated.
The domain service can implement any selection rule it needs, ranging from
"always prefer canonical over provisional" to a weighted combination of evidence
quality metrics.

For the Holmes domain, the survivor selection rule is simple: prefer canonical
over provisional; if both are canonical, prefer the one with more evidence
records; if equal, prefer the one with an older creation timestamp. Most merges
in a well-maintained corpus will resolve at the first tie-break.

### `POST /compute-confidence`

`POST /compute-confidence` receives a list of evidence records for a
relationship and returns a composite confidence score between 0 and 1. The
identity service aggregates evidence from multiple sources; the domain service
decides how much each piece of evidence is worth.

The weight table is domain knowledge. In a biomedical corpus, a randomized
controlled trial is stronger evidence than a case report, and a result section
is stronger than a discussion section. In the Holmes corpus, a direct statement
by Holmes is stronger than a conjecture by Watson, which is stronger than
a claim reported second-hand. The identity service supplies the mechanism for
aggregation; the domain service supplies the weights.

Not caching this endpoint is intentional. Each call receives a different
set of evidence records, so repeated identical calls are rare. The computation
is fast -- a weighted mean over a short list. Adding a cache would introduce
consistency questions (when does the cached result expire?) for no measurable
performance gain.

### `GET /synonym-criteria`

`GET /synonym-criteria` returns the thresholds the identity service should use
when deciding whether two mentions are close enough to be synonyms. The response
specifies a fuzzy similarity threshold (for edit-distance matching), an embedding
cosine similarity threshold (for vector matching), and optionally per-entity-type
overrides for either threshold.

This is a GET because the thresholds are configuration, not the result of a
stateful operation. They change only when the domain spec changes. The identity
service fetches them at startup and re-fetches them when the domain spec version
increments.

Per-entity-type overrides exist because different types need different precision.
Gene symbols in a biomedical corpus are short and must match with high precision
-- a fuzzy threshold of 0.95 prevents "BRCA1" from matching "BRCA2." Person
names in the Holmes corpus can tolerate slightly lower precision -- "Mrs. Hudson"
and "Mrs Hudson" should match despite the missing period. The domain service
encodes these distinctions; the identity service enforces them uniformly.

### `GET /schema`

`GET /schema` serves the full domain spec as JSON: entity types, predicates
with domain and range, constraint flags, and a version field. The identity
service fetches this at startup to load its validation logic, and the graph
linter fetches it at runtime to derive its rule set.

The schema endpoint belongs on the domain service rather than being pushed
to the identity service at startup for a dependency-direction reason. If the
domain service pushed its schema to the identity service, the domain service
would need to know the identity service's address -- and the domain service
would become a client of the identity service as well as a server it calls.
That inverts the dependency. With a pull model, the identity service knows
about the domain service; the domain service knows about nothing but its own
domain. The dependency arrow points in one direction.

## Chapter 12: Validation and the Lifecycle

`\chaptermark{Validation and the Lifecycle}`{=latex}

### How a Proposed Triple Is Accepted or Rejected

Every proposed triple entering the graph passes through a sequence of gates.
Each gate asks a different question. A triple that fails any gate is rejected
before it touches the graph; there is no partial insertion.

The first gate is the **entity type check**: does the subject ID correspond to
a known entity, and does that entity's type match the predicate's domain? The
second gate is the **predicate vocabulary check**: is this predicate defined in
the domain spec at all? A predicate that does not appear in the spec does not
exist. The triple is not stored with a flag; it is rejected.

The third gate is the **domain/range check**: given that the predicate exists,
do the subject and object entity types fall within its declared domain and range?
This is the gate that catches category errors -- the "aspirin treats BRCA1"
pattern, where the types are syntactically present but semantically wrong. The
schema knows the domain and range; it does not need to inspect the content of
the entities to detect the violation.

The fourth gate is the **provenance completeness check**: does the proposed
triple carry a provenance record, and does that record contain the required
fields? A triple without a source is not a claim -- it is an unsigned assertion.
Required fields are declared in the domain spec; the identity service reads
them at startup from `GET /schema`.

These four gates run at insertion time, in this order, on every triple. The
ordering reflects cost: entity type and predicate vocabulary checks are
dictionary lookups; domain/range checks are set membership tests; provenance
completeness requires parsing a structured record. Cheap gates run first.

### Type Constraints Across the Entity Lifecycle

Entity type is assigned when an entity is created and never changes. A `Person`
entity that was created as a provisional entity for "Watson" is still type
`Person` after it is promoted to canonical status and still type `Person` after
it is merged with another entity.

Immutability is not a limitation -- it is what makes type checking a one-time
cost. If entity types could change, every edge incident to the entity would need
re-validation on every type change. With immutable types, the domain/range check
at insertion time is permanent: if the triple was valid when it was inserted, it
remains valid unless the schema itself changes.

Merge operations between entities of different types are rejected. This is
enforced at the identity service level before the `POST /merge` call reaches the
domain service's survivor selection logic. If the identity service receives a
merge request for a `Person` and a `Location`, the operation fails immediately
with a type mismatch error. This prevents a deduplication error from silently
corrupting the type layer of the graph.

### When the Ontology Changes

The domain spec is not fixed forever. Research communities develop new consensus;
new predicates become necessary; existing predicates turn out to have been
defined too broadly. When the ontology changes, the graph must respond without
silently invalidating what already exists.

**Deprecated predicates** are flagged, not deleted. When a predicate is retired
from the domain spec, edges that used it do not disappear. They are marked with
a `deprecated_predicate` flag -- a structured attribute on the edge, not a
deletion. The linter emits `DEPRECATED_PREDICATE` violations for these edges,
routing them to a review queue. Actual removal is a deliberate, logged operation,
not an automatic side effect of updating the spec.

**Tightened constraints** produce migration items, not errors -- with a caveat.
The domain spec carries a version field. The identity service records which
schema version was active when each edge was ingested. An edge that was valid
under schema version 2.1 but violates schema version 2.3 is a migration item,
not an extraction failure. The linter distinguishes between the two: "this edge
was malformed when it was written" (an error) versus "this edge became malformed
because the schema tightened" (a migration item that needs remediation). The
distinction matters for prioritizing work.

**Predicate renaming or splitting** follows the deprecate-old, introduce-new
pattern. The old predicate is deprecated; the new predicate is added; a
migration script -- external to the identity service -- moves existing edges
from the old predicate to the new one, recording the transformation in the
provenance record. The migration script is an explicit, reviewable artifact.
The transformation is auditable after the fact.

The philosophical point is the same one that governs everything else in this
architecture: make the state visible. An ontology change that silently
invalidates existing edges is a hidden violation of the provenance guarantee.
An ontology change that makes violations visible, classifies them correctly,
and routes them to appropriate remediation is just another form of graph
maintenance.

## Chapter 13: The Graph Linter

`\chaptermark{The Graph Linter}`{=latex}

### Two Enforcement Points

The insertion path enforces constraints at write time: every triple that enters
the graph has passed the four gates described in Chapter 12. This protects the
graph against new bad data as it arrives.

The graph linter is a separate tool that audits the graph after the fact,
independently of the insertion path. It asks the same questions -- are predicates
valid, do domain/range constraints hold, is provenance present, are there
unacknowledged contradictions -- but it asks them of the whole graph, not just
the triple currently being inserted.

The two enforcement points are complementary, not redundant. Insertion-time
checks protect against new violations. The linter catches cross-edge consistency
issues that are invisible at single-write time: a contradiction between two edges
inserted in separate pipeline runs, a provenance gap in data that predates a
stricter provenance requirement, an edge that was valid under an older schema
version and now violates the current one. The linter also serves as a CI gate
on ingestion batches: run it before a batch lands and reject the batch if
violations exceed a threshold. This is the compiler-pass model applied to graph
data.

### What the Linter Checks

The linter's rule set is derived entirely from the domain spec at runtime. There
are no hardcoded rules. Every predicate in the spec has a domain, a range, a
provenance requirement, and optionally a `is_functional` flag and a `negation_of`
pairing. The linter reads the spec and generates its checks from those
declarations automatically. Adding a predicate to the spec automatically extends
lint coverage to that predicate; the linter requires no maintenance as the schema
evolves.

**Predicate vocabulary violations**: the graph contains an edge with a predicate
name that does not appear in the current domain spec. Either the predicate was
invented by a faulty extraction, or the spec changed and the edge predates the
change.

**Domain/range violations**: an edge's subject or object entity type does not
satisfy the predicate's declared domain or range. The entity type is immutable,
so if this violation exists, either the edge was ingested under a different schema
version or the extraction pipeline produced a type error that the insertion check
missed.

**Provenance gaps**: an edge is missing a provenance record, or its provenance
record is missing required fields. Required fields are declared per-predicate in
the domain spec; the linter checks each predicate's requirements independently.

**Unacknowledged contradictions**: two edges exist that logically conflict. For
`is_functional` predicates, two different objects for the same subject is a
contradiction. For `negation_of` predicate pairs, both `activates(A, B)` and
`inhibits(A, B)` existing between the same entity pair is a contradiction. The
linter flags these; it does not delete the edges.

### Violation Structure

Each violation is a typed, structured record, not free text:

```json
{
  "violation_type": "DOMAIN_RANGE_MISMATCH",
  "severity": "ERROR",
  "edge_id": "edge_789",
  "subject_type": "Person",
  "predicate": "occurred_at",
  "object_type": "Location",
  "message": "Predicate 'occurred_at' requires object type
    'Moment'; got 'Location'.",
  "remediation": "Check entity resolution for object node."
}
```

Severity levels are `ERROR`, `WARNING`, and `INFO`. Errors represent violations
that make the edge uninterpretable or structurally inconsistent. Warnings
represent degraded data quality that is worth fixing but does not invalidate
reasoning. Info items flag things worth knowing -- a deprecated predicate still
in use, a provisional entity with unusually low evidence -- without requiring
immediate action.

Output is JSONL\index{JSONL}: one JSON object per line, no outer array. JSONL is composable
without parsing overhead: pipe it into a dashboard, filter by severity with
`grep` or `jq`, load it into a review queue, fail a CI step if the error count
exceeds a threshold. The linter does one thing and its output is designed to be
handled by other tools.

### Conflict Records as First-Class Data

When the linter finds a contradiction -- two edges that logically cannot both be
true -- it does not simply report an error and stop. It emits a conflict
record:\index{conflict record} a structured object that names both edges, identifies the conflict
type, and records whether the conflict has been acknowledged and resolved.

The graph is richer for containing the dispute than for suppressing it.
Contradiction is information, not failure. In a scientific corpus, genuine
disagreement between sources is common. An extraction pipeline that ran last
year may have captured a claim that newer literature has overturned. A Holmes
story may contain a claim that a later story retcons. Representing these
disputes explicitly, as first-class records linked to the edges involved, allows
the graph to model the actual state of knowledge in the corpus -- including the
parts that are contested -- without sacrificing structural integrity.

A conflict record that has been reviewed and marked resolved carries the
resolution note as part of its structure. A conflict that has been reviewed
and left open is also a valid state: the evidence is genuinely ambiguous, the
community has not converged, and the graph records that honestly.

# Part V: Trustworthiness

## Chapter 14: Provenance as Architecture

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
it is an audit log that nobody reads. Provenance that is required by the schema,
enforced at insertion time, and checked by the linter is architecture: it is
a constraint that the system upholds unconditionally, not a field that well-
intentioned engineers fill in when they remember to.

### What a Provenance Record Contains

A complete provenance record for an edge in the Holmes graph contains the
story title and publication date, the chapter and paragraph index pointing to
the specific passage, the extraction method (which model, which prompt version),
and the confidence assigned to that specific piece of evidence.

The passage locator is the most important field for human verification. It is
not sufficient to know that an edge came from *A Scandal in Bohemia*; the
reader who wants to verify the claim needs to find the sentence. A paragraph
index makes that possible. An extraction log that records only the document is
not traceable -- it is merely attributable.

The extraction method field serves a different purpose: reproducibility. If a
claim needs to be re-extracted because the original extraction is suspected to
be wrong, the provenance record tells you which model and prompt produced it.
You can re-run with the same configuration, compare the output, and determine
whether the original extraction was an error or a correct reading of an
ambiguous passage.

### Confidence Is Computed, Not Assigned

Confidence scores on edges are not the opinion of the extraction model about
how certain it feels. They are computed values derived from evidence quality
and evidence count, using a weight table that the domain service declares.

A single passage asserting that Holmes maintained lodgings at Baker Street
warrants a moderate confidence score. The same assertion appearing independently
in a dozen stories, extracted from different passages by the same pipeline, warrants
a higher score -- not because the later extractions are individually stronger,
but because independent corroboration is itself evidence. The identity service
aggregates these into a composite confidence\index{composite confidence} via `POST /compute-confidence`.
The domain service supplies the weights; the base server handles the arithmetic.

This matters for multi-hop reasoning. A chain of three inferences, each at 0.9
confidence, produces a chain confidence of 0.73 by simple multiplication. That
arithmetic is possible because each step's confidence is a computed value with
a defined meaning, not a vague qualitative label. A cosine similarity score
from a retrieval system cannot be composed this way: it has no principled
relationship to probability, and similarity scores from different steps cannot
be multiplied to produce a meaningful compound value.

### Typed Provenance

Because predicates are finite and typed, provenance completeness is checkable.
The domain spec declares, per predicate, what a complete provenance record must
contain. The linter checks every edge of every predicate type against that
requirement. Incompleteness is not a silent gap -- it is a detectable violation
with a severity level and a remediation suggestion.

This is what "typed provenance" means: not merely that provenance records are
structured rather than free text, but that the schema defines what "complete"
looks like for each kind of claim, and the linter enforces that definition.
An edge of predicate `disguised_as` might require a passage locator and an
extraction confidence. An edge of predicate `occurred_at` might also require
a `Moment` entity reference. The requirements are per-predicate because the
nature of the claim determines what evidence is needed to warrant it.

### Multi-Source Claims

When the same relationship appears in multiple independent passages, the
identity service aggregates the evidence. If the same edge -- say, "Holmes
associated_with 221B Baker Street" -- is extracted from five different stories,
the identity service does not create five separate edges. It creates or updates
one edge and attaches all five provenance records to it.

The composite confidence for this edge is computed from all five records.
The provenance audit trail shows all five sources. A reader who wants to
verify the claim has five passages to consult. A query that asks for the
evidence behind a claim returns a structured list: five stories, five
paragraphs, five extraction runs. The graph does not flatten this into a
single score and discard the detail. The detail is the trustworthiness.

## Chapter 15: Making Bad Ideas Inexpressible

`\chaptermark{Making Bad Ideas Inexpressible}`{=latex}

### Hilbert's Dream

At the turn of the twentieth century, David Hilbert\index{Hilbert, David} proposed
a program for mathematics: find a formal system in which every true statement
could be proved and, crucially, no false or meaningless statement could even be
constructed. He wanted a system where bad mathematics was not just discouraged --
it was *inexpressible*.\index{inexpressible} Kurt Gödel\index{Gödel, Kurt} showed
in 1931 that this is impossible for mathematics in general: any sufficiently
powerful formal system is either incomplete or inconsistent.

For a domain-constrained typed graph, the situation is different. We are not
trying to represent all of human knowledge. We are trying to represent a
finite, agreed-upon set of claims about a specific domain -- Holmes stories,
biomedical literature, legal case law. In that narrower space, the boundary
Hilbert wanted is achievable. The finite predicate vocabulary is that boundary.
A predicate that is not in the schema does not exist. A type combination that
violates a declared domain or range cannot be expressed. The constraint is not
a runtime check that fires when someone tries to insert bad data -- it is a
structural property of the system that makes certain data unrepresentable in
the first place.

### What Becomes Inexpressible

The typed graph makes four classes of error structurally inexpressible, one at
each layer of the architecture.

**Type-layer violations**: an edge whose subject or object entity type violates
the predicate's declared domain or range cannot be inserted. "Aspirin treats\index{category error}
BRCA1" -- a drug predicated against a gene using a disease predicate -- is not
a low-confidence claim in the graph. It is an unrepresentable claim. The schema
closes the vocabulary; what falls outside it cannot be expressed.

**Identity-layer violations**: an edge that references an entity ID the identity
service cannot resolve has no valid endpoint. The graph cannot contain a
relationship to a thing it has no record of. Provisional entities are valid
endpoints; truly unresolvable IDs are not. The requirement that every node be
known to the identity service is enforced at write time.

**Provenance-layer violations**: the domain spec declares, per predicate, what
a complete provenance record must contain. An edge without a required provenance
field is not a weak claim -- it is a malformed record that fails the insertion
check. An unsigned assertion is not an assertion at all in a system that treats
sourcing as structural rather than optional.

**Consistency-layer violations**: a functional predicate can have at most one
object per subject. A predicate and its `negation_of` pair cannot both hold
between the same entity pair without a conflict record acknowledging the
dispute. Unacknowledged contradiction -- two edges that logically cannot both
be true, sitting silently in the graph -- is inexpressible. The contradiction
must be surfaced as a conflict record or one of the edges must be retracted.

### The Functional Programming Analogy

The slogan in statically typed functional programming is "make illegal states
unrepresentable."\index{illegal states unrepresentable} In ML,\index{ML (programming language)} Haskell,\index{Haskell} and Rust,\index{Rust} the type system
is designed so that programs that would enter invalid states cannot be written.
The invariant is not enforced by a runtime check that fires when the state is
reached -- it is enforced by the compiler, which refuses to produce a program
that can reach the state at all. A null pointer exception is impossible in a
language that has no null. A use-after-free error is impossible in a language
whose ownership rules prevent it.

A typed graph applies the same principle to knowledge claims. We do not write
runtime checks that fire when a bad triple is inserted and then clean up the
damage. We design a schema in which certain classes of bad triple cannot be
formed. The domain spec is the type system. The insertion validation is the
compiler pass. The graph that results from a successful insertion is, by
construction, free of type-layer and provenance-layer violations -- not because
we checked every edge after the fact, but because non-conforming edges were
never representable.

The analogy has limits, as all analogies do. The typed graph cannot enforce
factual correctness any more than a type system can enforce algorithmic
correctness. A well-typed program can still implement the wrong algorithm. A
well-typed edge can still carry a false claim.

### The Limits: Gödel's Revenge

The typed graph enforces structural well-formedness.\index{structural well-formedness} It does not
enforce semantic correctness.\index{semantic correctness} A well-typed, well-sourced edge -- correct
entity types, valid predicate, complete provenance -- can still be factually
wrong. An extraction pipeline that misread a passage, or a passage that was
itself mistaken, can produce a triple that passes every gate and enters the
graph as a valid claim. The schema does not adjudicate the world.

This is not a defect. It is the honest boundary of what formal structure can
guarantee. The typed graph's job is to ensure that the claims it contains are
well-formed, traceable, and internally consistent -- that they are the right
*kind* of claim about the right *kind* of entities with a known *source*. Whether
those claims are true is a question for domain experts, for replication across
sources, for the confidence scores that aggregate evidence quality. The graph
provides the structure that makes verification possible. It does not perform
the verification itself.

Gödel's result was about the limits of formal systems as truth machines. The
typed graph does not aspire to be a truth machine. It aspires to be a
trustworthy container for claims that humans and machines can reason over,
verify, and dispute. That is a more modest goal, and it is achievable.

## Chapter 16: Bias, Limits, and Responsibility

`\chaptermark{Bias, Limits, and Responsibility}`{=latex}

### What the Graph Cannot Know

A knowledge graph built from a corpus knows only what that corpus contains.
The Holmes stories were written by Arthur Conan Doyle between 1887 and 1927,
from a particular cultural vantage point, with particular narrative choices
about whose perspective is centered and whose is absent. The graph built from
those stories inherits those choices. Watson's view of events is well-represented.
Mrs. Hudson's\index{Hudson, Mrs.} is not.

This is not a problem specific to fiction. A biomedical knowledge graph built
from PubMed\index{PubMed} inherits the coverage biases of biomedical publishing: English-
language journals are overrepresented; negative results are underrepresented;
diseases that attract research funding are better covered than diseases that do
not. A graph built from legal case law inherits the selection biases of which
cases are litigated, appealed, and reported. The identity service cannot
correct for absences it cannot see. It processes what it receives.

Coverage gaps create false negatives. A query that returns no result for a
relationship does not mean the relationship does not hold -- it means the corpus
does not assert it. This distinction, which Chapter 1 described as the
closed-world assumption, requires active communication to users of the graph.
A system that presents silence as denial, rather than as a coverage gap, will
mislead the people who rely on it.

### Bias Encoded at Scale

Source biases propagate into the graph and are amplified by confidence weighting.
If the Holmes stories describe Holmes's deductions in more detail than Watson's,
the graph will have higher-confidence edges about Holmes's mental states than
about Watson's. This is a faithful representation of what the corpus asserts.
It is also a distortion of the underlying reality the corpus was trying to
capture.

Confidence weighting can amplify this effect. An entity that appears in many
passages accumulates more evidence records and earns higher composite confidence
scores than an entity mentioned once. The confidence score is a measure of
evidential support within the corpus, not a measure of importance or truth in
the world the corpus describes. A builder who presents confidence scores without
this caveat is misleading the graph's users.

Transparency is the available remedy, not elimination. The provenance
architecture described in Chapter 14 makes the evidence distribution visible:
a query can retrieve not just a confidence score but the full list of source
passages and their individual confidence values. A user who sees that all five
supporting passages for a claim are from a single story, told from a single
character's perspective, can weigh that evidence accordingly. The graph does
not do the weighing. It provides the data that makes weighing possible.

### What Typed Structure Cannot Guarantee

Structural well-formedness is not factual correctness. This has been said before
in this book -- in Chapter 1, in Chapter 15 -- because it is the most important
thing to understand about what a typed graph is and is not.

A well-typed, well-sourced edge can be wrong. Holmes misidentifies a suspect.
Watson misremembers an event. Conan Doyle contradicts himself between stories.
The extraction pipeline misreads a passage. The graph faithfully records all of
these as valid claims with provenance. The schema cannot distinguish between a
claim that reflects reality and a claim that reflects a character's mistake,
an author's error, or an extractor's misreading.

The graph records disputes rather than adjudicating them. Conflict records exist
precisely for this purpose: when two sources contradict each other, the graph
represents the contradiction as a structured object rather than silently
resolving it in favor of one source. The dispute is information. Suppressing
it would be a loss.

### Capability Is Not Bounded by Intent

A typed graph built for one purpose supports inferences its builders did not
anticipate, because structure supports inference and inference does not respect
the boundaries of intended use. A Holmes graph built to study narrative structure
can be queried to identify characters who are systematically deceived. A medical
graph built to support drug discovery can be queried to identify precursor
compounds for controlled substances. A legal graph built to assist lawyers can
be queried to identify patterns in judicial decisions that correlate with
demographic factors.

None of these are edge cases or failures. They follow directly from the system
working as designed: the graph contains structured, typed, traceable claims,
and those claims can be combined in traversals that no single source asserts.
The system is more powerful than any particular use case imagined for it, and
that power does not turn off at the boundaries of the intended use case.

This does not mean the system should not be built. It means the builder should
be honest about what they are building. A system that encodes the architecture
of expertise for a domain will be used in ways its builders did not foresee.
The choices about access control, logging, and what gets ingested are not
purely technical choices -- they are choices about what inferences will be
possible and who will be able to draw them.

### The Builder's Responsibility

Trustworthiness is not a one-time design choice. It is an ongoing commitment
that extends past the point of deployment.

Honesty about coverage limits means documenting what the corpus covers and what
it does not, and surfacing that documentation at query time rather than burying
it in a README. Infrastructure for verification means ensuring that provenance
records are complete, that confidence computations are reproducible, and that
the schema is legible to domain experts who need to understand what the graph
can and cannot express. Consideration of foreseeable misuse means asking, before
deployment, what traversals the graph enables that were not intended, and whether
access controls or audit logging are warranted.

The identity service architecture provides the infrastructure for all of this:
every merge is logged, every promotion is logged, every confidence computation
is reproducible from the provenance records, and the schema is a readable Python
module rather than an opaque binary. The infrastructure for verification is
built in. Using it -- treating it as a commitment rather than a compliance
checkbox -- is the builder's responsibility.

### Who Owns the Graph

Open versus proprietary carries consequences for what the graph becomes and who
benefits from it. GenBank,\index{GenBank} the public repository of genetic sequences, was
built as a commons and shaped how molecular biology developed for decades. Any
researcher, anywhere, could query it. The field advanced accordingly. Clinical
trial data, by contrast, has often been held proprietary by sponsors; the
consequences for public health have been documented and contested.

A comprehensive typed graph over a scientific domain is a significant
infrastructure investment, and whoever controls it controls what gets synthesized,
what gets surfaced, and how the schema evolves. These are not neutral technical
decisions. The governance question -- who owns the graph, who can query it, who
can extend the schema, who can audit the ingestion -- is worth answering
deliberately before it is answered by default.

The typed graph's architecture does not resolve this question. Provenance,
canonical IDs, and schema enforcement are equally available to an open commons
and to a proprietary platform. The technology is neutral on governance. The
builder is not.

## Chapter 17: What This Makes Possible

`\chaptermark{What This Makes Possible}`{=latex}

### The Three-Book Arc

*Knowledge Graphs from Unstructured Text*\index{Knowledge Graphs from Unstructured Text@\textit{Knowledge Graphs from Unstructured Text}} solves the extraction problem: how
to read unstructured text at scale and produce structured, typed claims. *BFS-QL:
A Graph Query Protocol for Language Models*\index{BFS-QL@\textit{BFS-QL}} solves the interface problem:
how to serve those claims to a large language model (LLM)\index{large language model} in a form it can
traverse and reason over. This book solves the problem that sits between them:
how to ensure that what was extracted is trustworthy enough to reason from.

The identity service and the typed schema are the connective tissue. The
extraction pipeline calls the identity service to resolve every mention to a
canonical ID before the claim enters the graph. The query layer relies on those
canonical IDs to traverse the graph without ambiguity. The schema that the
identity service enforces at write time is the same schema that the query layer
uses to understand what a result means. Without canonical identity, the graph
is a collection of strings. Without the typed schema, the graph is a collection
of untyped triples. Without provenance, the graph is a collection of unsigned
assertions. This book is about what it takes to have none of those problems.

### Cross-Domain Reasoning

Shared canonical IDs let two graphs built independently compose automatically.
A Holmes graph and a Victorian history graph, both anchoring their `Location`
entities to Wikidata\index{Wikidata} URIs, can be traversed as a single graph: a query
that starts from Baker Street in the Holmes graph can follow an edge to a
Wikidata node and continue into the history graph without any coordination
between the teams that built each graph. The shared identifiers are the bridge.

The typed schema ensures the composition is structurally coherent. When two
graphs share a predicate vocabulary -- or when the predicate vocabularies have
a declared mapping -- edges from one graph can be interpreted in the context of
the other. Cross-graph reasoning is not just a matter of shared IDs; it requires
shared semantics. The domain spec is where those semantics live.

This composability is not a designed feature of any single system. It is an
emergent property of the decision to anchor to shared authorities and declare
a typed schema. The epistemic commons was built over decades for human use. The
typed graph is what makes it available to machines in a form that carries its
own warrant.

### Grounding LLM Inference

The difference between asking an LLM to reason from its training data and asking
it to reason from a typed, provenance-tracked graph is qualitative, not
quantitative. Training data is a frozen snapshot of text that the model
compressed into weights. It cannot be updated without retraining. Its sources
cannot be cited. Its confidence cannot be computed from evidence. When the model
is wrong, there is no audit trail that explains why.

A graph provides all of these things. A user asks a question. The system
retrieves the relevant subgraph -- entities and edges that bear on the question
-- and injects it into the model's context. The model reasons over that context.
The answer is grounded in retrieved claims with known sources, not in training-
data recall. When the graph is wrong, you fix the graph. You do not retrain the
model. When the model's answer is surprising, you can trace the reasoning path
through the graph edges and provenance records that informed it.

This is the integration that *BFS-QL* describes from the query side. The
trustworthiness that makes it worth doing is what this book has been about.

### Hypothesis Generation

A well-constructed typed graph supports a class of query that is impossible over
unstructured text: "what relationships exist between X and Y that no single
source asserts but that follow from combining multiple sources?"

In the Holmes corpus, this looks like: Holmes knows Irene Adler\index{Adler, Irene} outmaneuvered
him. Irene Adler is associated with a particular case in a particular year.
The case involves a client whose later appearances are documented in other
stories. A traversal that combines these facts can surface a connection between
Holmes's experience with Adler and his subsequent behavior in cases involving
women clients -- a connection no single story states but that follows from the
graph. The graph narrows the space of possibilities for a literary analyst to
evaluate.

In a scientific corpus, the same pattern generates drug-disease candidate
pairs, gene-pathway associations, and cross-trial comparisons that no single
paper asserts. These are candidate hypotheses, not established facts. The graph
does not decide which are worth pursuing. It surfaces candidates that a human
can filter, prioritize, and test.

### An Invitation

The epistemic commons -- MeSH, HGNC, RxNorm, UniProt, Wikidata, and the dozens
of domain-specific authorities that curated communities have built over decades
-- was built for human use. Researchers navigated it through literature searches,
reference lists, and expert consultation. The knowledge was there. The access
was slow.

The typed graph makes that commons available to machines in a form that carries
its own warrant: canonical IDs that anchor to the authorities, a schema that
constrains what can be expressed, provenance that traces every claim to its
source. A machine that traverses this graph is not pattern-matching over text.
It is reasoning over a structured representation of what expert communities have
established, with the ability to follow chains of evidence and surface the
sources behind every step.

That is not a small thing. The extraction bottleneck that prevented this for
fifty years is now broken. The infrastructure described in these three books is
buildable today, with tools that exist, at a cost that is no longer prohibitive.
The question is no longer whether it is possible. The question is what we build
it for, and how carefully we build it.

# Appendix A: Identity Server Specification

## Abstract Interface

```python
from abc import ABC, abstractmethod
from typing import Optional, FrozenSet
from enum import Enum
from pydantic import BaseModel, Field


class EntityStatus(str, Enum):
    PROVISIONAL = "provisional"
    CANONICAL = "canonical"
    MERGED = "merged"


class EntityRecord(BaseModel, frozen=True):
    """An entity in the identity server."""
    entity_id: str = Field(description="Stable identifier for this entity")
    entity_type: str = Field(description="Entity type from the domain spec")
    surface_forms: FrozenSet[str] = Field(
        description="All known mention strings for this entity"
    )
    status: EntityStatus = Field(description="Current lifecycle status")
    authority: Optional[str] = Field(
        description="Name of the anchoring authority, if canonical"
    )
    authority_id: Optional[str] = Field(
        description="Canonical ID from the authority, if canonical"
    )
    confidence: float = Field(description="Aggregate confidence score")
    evidence_count: int = Field(
        description="Number of supporting provenance records"
    )


class ResolveResult(BaseModel, frozen=True):
    """Result of a resolve operation."""
    entity_id: str = Field(description="Canonical or provisional entity ID")
    status: EntityStatus = Field(description="Status of the returned entity")
    was_created: bool = Field(
        description="True if a new provisional entity was created"
    )


class MergeResult(BaseModel, frozen=True):
    """Result of a merge operation."""
    survivor_id: str = Field(description="Entity ID of the surviving record")
    absorbed_id: str = Field(description="Entity ID of the absorbed record")
    was_already_merged: bool = Field(
        description="True if this merge had already been performed"
    )


class IdentityServer(ABC):
    """
    Abstract base class for the identity server.

    All operations must be idempotent: safe to call multiple times
    with the same arguments and guaranteed to produce the same result.
    """

    @abstractmethod
    def resolve(
        self,
        mention: str,
        entity_type: str,
    ) -> ResolveResult:
        """
        Resolve a mention string to a canonical or provisional entity ID.

        Applies the lookup chain: exact match, fuzzy match, embedding
        similarity, authority lookup. Creates a provisional entity if
        no match is found.

        Args:
            mention: The surface form to resolve.
            entity_type: The type of entity (e.g., "drug", "gene", "disease").

        Returns:
            ResolveResult with the entity ID and status.
        """

    @abstractmethod
    def promote(
        self,
        entity_id: str,
    ) -> Optional[EntityRecord]:
        """
        Attempt to promote a provisional entity to canonical status.

        Calls the domain service to look up the entity's most common
        surface form against the appropriate authority. Returns the
        updated EntityRecord if promotion succeeded, None otherwise.

        Args:
            entity_id: The provisional entity ID to promote.

        Returns:
            Updated EntityRecord with canonical status, or None if
            promotion failed.
        """

    @abstractmethod
    def find_synonyms(
        self,
        entity_id: str,
    ) -> frozenset[str]:
        """
        Return all known surface forms for a canonical entity\index{canonical entity}.

        Args:
            entity_id: A canonical entity ID.

        Returns:
            Frozenset of all surface forms associated with this entity.
        """

    @abstractmethod
    def merge(
        self,
        entity_id_a: str,
        entity_id_b: str,
    ) -> MergeResult:
        """
        Merge two entities determined to be the same.

        Calls the domain service to select the survivor. Updates all
        relationships referencing the non-survivor to reference the
        survivor. Records the merge in the merge log.

        Args:
            entity_id_a: First entity ID.
            entity_id_b: Second entity ID.

        Returns:
            MergeResult indicating which entity survived and whether
            the merge had already been performed.
        """

    @abstractmethod
    def on_entity_added(
        self,
        record: EntityRecord,
    ) -> None:
        """
        Hook called after any entity is added or updated.

        Used for downstream notifications, cache invalidation, and
        logging. Implementations should be fast and non-blocking;
        expensive downstream operations should be queued.

        Args:
            record: The EntityRecord that was added or updated.
        """
```

## Domain Plugin HTTP Contract

The domain service implements five endpoints. The identity server calls these
endpoints; the domain service fulfills them.

### `POST /resolve-authority`

Request:
```json
{
  "mention": "desmopressin",
  "entity_type": "drug"
}
```

Response (match found):
```json
{
  "canonical_id": "RxNorm:3251",
  "authority": "RxNorm",
  "confidence": 1.0
}
```

Response (no match):
```json
{
  "canonical_id": null,
  "authority": null,
  "confidence": null
}
```

### `POST /select-survivor`

Request:
```json
{
  "entity_a": { ... EntityRecord ... },
  "entity_b": { ... EntityRecord ... }
}
```

Response:
```json
{
  "survivor_id": "RxNorm:3251"
}
```

### `POST /compute-confidence`

Request:
```json
{
  "provenance_records": [
    {
      "paper_id": "PMC1234567",
      "section_type": "results",
      "paragraph_idx": 3,
      "extraction_method": "claude-sonnet-4-6/v2",
      "confidence": 0.92,
      "study_type": "rct"
    }
  ]
}
```

Response:
```json
{
  "confidence": 0.87
}
```

### `GET /synonym-criteria`

Response:
```json
{
  "fuzzy_threshold": 0.85,
  "embedding_threshold": 0.92,
  "entity_type_overrides": {
    "gene": {
      "fuzzy_threshold": 0.95
    }
  }
}
```

### `GET /schema`

No request body. Returns the complete domain spec: the closed set of entity
types and the full predicate vocabulary with domain, range, and constraint
declarations. The identity server fetches this at startup and re-fetches it
when the schema version changes.

Response:
```json
{
  "version": "2.3.0",
  "entity_types": ["drug", "gene", "disease", "biological_process"],
  "predicates": [
    {
      "name": "treats",
      "domain": ["drug"],
      "range": ["disease"],
      "description": "Drug is used therapeutically to manage the disease.",
      "is_functional": false,
      "negation_of": null
    },
    {
      "name": "inhibits",
      "domain": ["drug", "gene"],
      "range": ["gene", "biological_process"],
      "description": "Subject suppresses the activity of the object.",
      "is_functional": false,
      "negation_of": "activates"
    }
  ]
}
```

## Entity Status Rules

```{=latex}
\begin{footnotesize}
\begin{tabularx}{\textwidth}{@{}l l X X@{}}
\hline
Current Status & Operation & Condition & New Status \\
\hline
provisional & promote & authority match found & canonical \\
provisional & promote & no authority match & provisional (unchanged) \\
provisional & merge & --- & merged \\
canonical & merge & --- & merged (rare; requires manual override) \\
merged & any & --- & error (operate on survivor) \\
\hline
\end{tabularx}
\end{footnotesize}
```

Invariants:

- A merged entity's `entity_id` is never returned by `resolve`
- All relationships referencing a merged entity transparently resolve to the survivor
- Merge is always between two non-merged entities

## Idempotency Contract

```{=latex}
\begin{footnotesize}
\begin{tabularx}{\textwidth}{@{}l X@{}}
\hline
Operation & Idempotency Mechanism \\
\hline
\texttt{resolve} & Upsert on \texttt{(mention, entity\_type)}; return existing ID if already resolved \\
\texttt{promote} & Check canonical status before attempting; return existing record if already canonical \\
\texttt{find\_synonyms} & Read-only; always idempotent \\
\texttt{merge} & Check merge log before executing; return existing MergeResult if already merged \\
\texttt{on\_entity\_added} & Implementation responsibility; hook must be idempotent \\
\hline
\end{tabularx}
\end{footnotesize}
```

# Appendix B: The Domain Spec Schema

`\chaptermark{Domain Spec Schema}`{=latex}

The Domain Spec is the configuration file that governs the typed graph's behavior. It is served by the domain service and consumed by the identity server, the ingestion pipeline, and the graph linter.

### EntityType Enum

Entity types must be a closed set. In the JSON serialization, this is represented as a list of strings.

```json
{
  "entity_types": [
    "drug",
    "gene",
    "disease",
    "biological_process",
    "protein"
  ]
}
```

### PredicateSpec

The core of the schema. Every predicate is defined by its constraints.

| Field | Type | Description |
| :--- | :--- | :--- |
| `name` | `string` | The unique identifier for the predicate (e.g., `inhibits`). |
| `domain` | `list[string]` | The allowed `EntityType`s for the subject. |
| `range` | `list[string]` | The allowed `EntityType`s for the object. |
| `description` | `string` | A human-readable definition for use in prompts. |
| `is_functional` | `boolean` | If true, a subject can have only one object for this predicate. |
| `negation_of` | `string?` | The name of the predicate that is the logical opposite. |

**Annotated Example (medlit domain):**
```json
{
  "name": "treats",
  "domain": ["drug"],
  "range": ["disease"],
  "description": "A therapeutic relationship where the drug is used to manage the disease.",
  "is_functional": false,
  "negation_of": null
}
```

### JSON Serialization

The Domain Spec is served at `GET /schema`. At startup, the identity server fetches this JSON and uses it to configure its validation logic. This allows the schema to be updated in the domain service without restarting the identity server.

### Deriving Lint Rules

`kglint` maps `PredicateSpec` fields to `ViolationType` checks at runtime:

- `domain`/`range` $\rightarrow$ `DOMAIN_RANGE_MISMATCH`
- `is_functional` $\rightarrow$ `FUNCTIONAL_VIOLATION`
- `negation_of` $\rightarrow$ `NEGATION_CONFLICT`
- Missing provenance $\rightarrow$ `PROVENANCE_MISSING`

### Conflict Record Schema

When a violation is detected but the data is preserved (e.g., in a contradiction), a `ConflictRecord` is created.

```python
class ConflictRecord(BaseModel):
    conflict_id: str
    conflict_type: Literal["FUNCTIONAL", "NEGATION_PAIR", "CONFIDENCE_DIVERGENCE"]
    edge_id_a: str
    edge_id_b: str
    severity: float  # 0.0 to 1.0
    resolved: bool = False
    resolution_note: Optional[str] = None
```

These records are stored in a dedicated table and can be queried to find areas of the graph where the literature is in active disagreement.

# Appendix C: Reference Implementation Details

## Postgres Schema

```sql
CREATE TABLE entities (
    entity_id       TEXT PRIMARY KEY,
    entity_type     TEXT NOT NULL,
    status          TEXT NOT NULL CHECK (status IN ('provisional', 'canonical', 'merged')),
    authority       TEXT,
    authority_id    TEXT,
    confidence      FLOAT NOT NULL DEFAULT 0.5,
    evidence_count  INT NOT NULL DEFAULT 0,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE surface_forms (
    entity_id   TEXT NOT NULL REFERENCES entities(entity_id),
    surface     TEXT NOT NULL,
    normalized  TEXT NOT NULL,
    PRIMARY KEY (entity_id, normalized)
);

CREATE TABLE entity_embeddings (
    entity_id       TEXT PRIMARY KEY REFERENCES entities(entity_id),
    embedding       VECTOR(1536),
    embedding_model TEXT NOT NULL
);

CREATE INDEX ON entity_embeddings USING ivfflat (embedding vector_cosine_ops);

CREATE TABLE merge_log (
    merge_id        SERIAL PRIMARY KEY,
    survivor_id     TEXT NOT NULL REFERENCES entities(entity_id),
    absorbed_id     TEXT NOT NULL,
    merged_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    reason          TEXT
);

CREATE TABLE promotion_log (
    promotion_id    SERIAL PRIMARY KEY,
    entity_id       TEXT NOT NULL REFERENCES entities(entity_id),
    from_status     TEXT NOT NULL,
    to_status       TEXT NOT NULL,
    authority       TEXT,
    authority_id    TEXT,
    promoted_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

## Docker Compose Setup

```yaml
services:
  identity-server:
    image: graphwright/identity-server:latest
    environment:
      POSTGRES_URL: postgres://identity:identity@postgres:5432/identity
      DOMAIN_SERVICE_URL: http://domain-service:8001
      LRU_CACHE_SIZE: 10000
    depends_on:
      - postgres
      - domain-service
    ports:
      - "8000:8000"

  domain-service:
    build: ./domain-service
    environment:
      REDIS_URL: redis://redis:6379
      MESH_API_KEY: ${MESH_API_KEY}
      RXNORM_API_KEY: ${RXNORM_API_KEY}
    depends_on:
      - redis
    ports:
      - "8001:8001"

  postgres:
    image: pgvector/pgvector:pg16
    environment:
      POSTGRES_USER: identity
      POSTGRES_PASSWORD: identity
      POSTGRES_DB: identity
    volumes:
      - postgres-data:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    volumes:
      - redis-data:/data

volumes:
  postgres-data:
  redis-data:
```

## Confidence Aggregation

The medlit domain service computes composite confidence from a list of provenance
records using a replication-weighted mean:

```python
from pydantic import BaseModel
from typing import Literal

StudyType = Literal[
    "meta_analysis", "rct", "cohort",
    "case_control", "observational", "review", "case_report"
]

STUDY_WEIGHTS: dict[StudyType, float] = {
    "meta_analysis": 0.95,
    "rct": 1.0,
    "cohort": 0.8,
    "case_control": 0.7,
    "observational": 0.6,
    "review": 0.5,
    "case_report": 0.4,
}

REPLICATION_BONUS_PER_PAPER = 0.02
MAX_REPLICATION_BONUS = 0.15


class ProvenanceRecord(BaseModel):
    paper_id: str
    section_type: str
    paragraph_idx: int
    extraction_method: str
    confidence: float
    study_type: StudyType


def compute_confidence(records: list[ProvenanceRecord]) -> float:
    if not records:
        return 0.0
    base = max(
        r.confidence * STUDY_WEIGHTS[r.study_type]
        for r in records
    )
    replication_bonus = min(
        (len(records) - 1) * REPLICATION_BONUS_PER_PAPER,
        MAX_REPLICATION_BONUS,
    )
    return min(base + replication_bonus, 0.99)
```

The base confidence is the maximum weighted confidence across all supporting
records -- the strongest single piece of evidence sets the floor. The replication
bonus rewards claims that appear in multiple independent papers, capped to
prevent a large number of weak case reports from inflating a claim beyond what
the evidence supports.
