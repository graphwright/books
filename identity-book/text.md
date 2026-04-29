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

## Chapter 7: Entity Lifecycle

`\chaptermark{Entity Lifecycle}`{=latex}

### Three Statuses

Every entity in the identity server has one of three statuses:

**Provisional**: The entity was created from an extracted mention that did not
resolve to a known authority. It has a provisional ID (a UUID generated by the
identity server) and participates fully in the graph -- relationships can
reference it, evidence accumulates against it -- but it is flagged as unanchored.

**Canonical**: The entity is anchored to an external authority. It has a
canonical ID derived from the authority (e.g., RxNorm:3251). It is the
authoritative node for all surface forms that resolve to it.

**Merged**: The entity was determined to be a duplicate of another entity and
absorbed into the survivor. Merged entities retain their history -- their
provisional ID, their evidence records, their mention strings -- but they are no
longer active graph nodes. All relationships that referenced them are
transparently redirected to the survivor.

### Promotion

A provisional entity accumulates evidence as more papers are processed. When the
evidence crosses a promotion threshold -- configurable per entity type and per
domain -- the identity server triggers a promotion attempt. The domain service's
`/resolve-authority` endpoint is called with the entity's most common surface
form. If a match is found, the entity is promoted to canonical and assigned the
authority ID. If no match is found, the entity remains provisional.

Promotion\index{promotion} is not a one-time event. A provisional entity that fails to promote
early in the corpus run may promote later when additional surface forms have
accumulated and the fuzzy or embedding match finds a better candidate. The
identity server tracks failed promotion attempts and retries them at configurable
intervals.

The promotion threshold is a quality dial. A low threshold promotes entities
quickly but risks premature promotion to incorrect authorities. A high threshold
keeps entities provisional longer but ensures that promotion decisions are
well-evidenced. The medlit reference implementation uses a threshold of three
independent papers for biological process entities and five for drug entities,
reflecting the relative ease of resolving each type.

### Merging

Merging occurs when two entities are determined to be the same thing. This can
happen in several ways: two provisional entities that accumulate the same
authority ID through promotion, two entities whose surface forms exceed the
fuzzy similarity threshold, or two entities whose embedding vectors are within
the cosine distance threshold.

The merge\index{merge (entities)} operation calls the domain service's `/select-survivor` endpoint to
determine which entity becomes the survivor. All relationships that referenced
the non-survivor are updated to reference the survivor. The non-survivor's
status is set to merged, and its history -- including the fact that it was merged
and when -- is preserved in the merge log.

Merge\index{merge (entities)} is idempotent. If two entities have already been merged and the identity
server encounters evidence that they should be merged again (because a new paper
uses a surface form that triggers the same merge condition), the operation
returns the existing merge result without creating a new merge record.

### When the ontology changes

The domain spec\index{domain spec} is not a one-time artifact. The epistemic commons itself evolves --
MeSH terms are deprecated, renamed, or restructured; research communities develop
new consensus on how to categorize things; new predicates become necessary as
the domain matures. When the ontology changes, the graph must have a principled
response. That response should follow the same rule that governs everything else
in a typed graph: make the state visible, not silent.

**Deprecated predicates.** When a predicate is retired from the domain spec,
edges that used it do not disappear. They are flagged -- either at schema reload
time or on the next linter pass -- as carrying a deprecated predicate. The flag
is a structured attribute on the edge, not a deletion. Provenance is never
retroactively erased. The linter emits `DEPRECATED_PREDICATE` violations for
these edges, routing them to a review queue. Actual removal is a deliberate,
auditable operation, not an automatic consequence of the schema change.

**Tightened domain or range constraints.** Suppose the `treats` predicate
originally allowed `BIOLOGICAL_PROCESS` as an object, and a schema revision
restricts it to `DISEASE` only. Existing edges with `BIOLOGICAL_PROCESS` objects
are now constraint violations -- but they were valid when written. The schema
version\index{schema version} recorded at ingest time (see below) is what allows
the linter to distinguish "was valid under the schema in force at the time of
extraction" from "is valid under the current schema." That distinction matters
for prioritizing remediation: edges that were malformed at extraction time are
errors; edges that became malformed due to a schema revision are migration items.

**Predicate renaming or splitting.** A predicate that is renamed or split into
two more specific predicates is handled as deprecate-old plus introduce-new.
Edges carrying the old predicate are flagged as deprecated. A migration script --
not the identity server -- moves them to the new predicate with a provenance note
recording the transformation. The migration script is an explicit, reviewable
artifact; the transformation is logged in the merge history alongside entity
merges and promotions.

**Versioned schemas.** The domain service's `GET /schema` response should carry
a version field\index{schema version} -- a semantic version or a content hash. The identity
server records which schema version was active when each edge was ingested. This
makes the migration state auditable: you can query "show me all edges ingested
under schema version 2.1 that fail validation under schema version 2.3" and get
a concrete work list.

The philosophical point follows directly from Chapter 12: the graph's response
to ontology evolution is the same as its response to any other form of conflict
or structural tension -- surface it, record it, and resolve it deliberately.
An ontology change that silently invalidates existing edges is a hidden
violation of the provenance guarantee. An ontology change that makes violations
visible and auditable is just another form of graph linting.

# Part III: Integration

## Chapter 8: Identity During Extraction

`\chaptermark{Identity During Extraction}`{=latex}

### The Ingestion Pipeline's View

The ingestion pipeline treats the identity server as a black box. It calls
`resolve(mention, entity_type)` and receives a canonical or provisional ID. It
stores that ID in the relationship record. It does not know or care whether the
ID was resolved from an authority, created as provisional, or returned from
cache.

This separation is the design goal. The ingestion pipeline is responsible for
extracting structured claims from text. The identity server is responsible for
deciding what those claims are about. Keeping these responsibilities separate
means the pipeline can be tested against a stub identity server, and the
identity server can be upgraded without changing the pipeline.

### The Ingest Stage

After the LLM extraction pass produces raw mentions and relationships, the ingest
stage calls the identity server to resolve each mention to a canonical ID. The
ingest stage processes one paper at a time. For each mention in the paper's
extraction output, it calls `resolve` and records the returned ID. For each
relationship, it substitutes the canonical IDs for both the subject and object
mentions before storing the relationship.

The ingest stage is the point where the graph's entities gain their stable
identities. Before ingest, entities are mention strings. After ingest, they are
canonical or provisional IDs. The graph is built from IDs, not strings.

### Handling Provisional Entities

Provisional entities participate in the graph exactly like canonical entities.
A relationship between two provisional entities is a valid graph edge. Queries
that traverse provisional entities return results. Evidence accumulates against
provisional entities and is preserved through promotion and merging.

This is an important design choice. An alternative design would defer graph
construction until all entities are resolved -- but this creates a chicken-and-egg
problem: resolution quality improves with more evidence, but evidence can only
accumulate if entities are in the graph. By allowing provisional entities to
participate immediately, the identity server enables a pipeline that processes
papers in any order and resolves entities progressively as evidence accumulates.

## Chapter 9: Identity During Querying

`\chaptermark{Identity During Querying}`{=latex}

### `search_entities`\index{search\_entities@\texttt{search\_entities}} and the Identity Server

BFS-QL's `search_entities` tool accepts a natural-language string and returns
a list of matching entity IDs. Under the hood, this is an identity server
operation: embed the query string, search for nearby entity vectors in the
identity server's database, return the canonical IDs of the matching entities.

The caller -- the LLM using the BFS-QL interface -- does not know that it is
calling the identity server. It provides a string and receives IDs. The identity
server provides the matching. This is the correct abstraction: the query layer
is responsible for traversal, the identity server is responsible for resolution.

### Embeddings Are an Identity Server Concern

The Postgres/pgvector backend described in *BFS-QL* Chapter 10 notes that
"embedding model consistency between ingest and query time must be explicit
metadata, not convention." The identity server resolves this requirement by
owning all embeddings.

Because the identity server manages both ingest-time embedding (during entity
creation and the embedding-similarity stage of the lookup chain) and query-time
embedding (during `search_entities`), it guarantees consistency without any
coordination between the ingestion pipeline and the query layer. The query layer
calls `search_entities` with a string; the identity server embeds it with the
same model it used during ingest; the cosine distances are meaningful.

The embedding model, vector dimensions, and distance metric are internal
implementation details of the identity server. The ingestion pipeline does not
know which embedding model is in use. The query layer does not know. Only the
identity server knows, and it is consistent because it is a single service.

### Cross-Graph Composition

When a BFS-QL client has connections to two graphs -- one built from research
papers, one built from clinical trial records -- and both graphs anchor their
entities to the same authorities, the client can traverse from one graph to the
other using canonical IDs as bridges.

This traversal requires no special protocol support in BFS-QL. The client calls
`bfs_query` on the first graph starting from a canonical ID. The response
includes the canonical IDs of neighboring entities. The client calls
`search_entities` on the second graph with those IDs. If the second graph
contains entities with matching canonical IDs, the traversal crosses graphs.

The identity server is why this works. Both graphs used the same authorities.
Both graphs anchored their entities to those authorities. The shared IDs are
the bridges. The identity server made them available; BFS-QL traverses them.

# Part IV: Trustworthiness

## Chapter 10: Provenance as Architecture

`\chaptermark{Provenance as Architecture}`{=latex}

### Provenance Is Not Optional

In high-stakes domains -- medicine, law, materials safety -- every claim in the
knowledge graph must be traceable to its source. This is not a feature. It is
a constraint. A graph that cannot answer "where did this claim come from?" is
not suitable for use in these domains regardless of how sophisticated its
extraction pipeline is.

Provenance must be architectural, not retrofitted. Adding provenance to an
existing graph requires touching every relationship record. The data model
for provenance affects the schema, the extraction output format, the ingest
stage, the confidence aggregation logic, and the query interface. Getting it
right at the start costs little. Getting it wrong costs a full re-extraction.

### What Provenance Records

A complete provenance record contains:

- **paper_id**: Which paper made this claim
- **section_type**: Where in the paper (abstract, introduction, methods, results,
  discussion, conclusion)
- **paragraph_idx**: Exact paragraph within the section
- **extraction_method**: How the claim was extracted (LLM model and version,
  prompt version)
- **confidence**: Confidence in this specific piece of evidence
- **study_type**: The study design (RCT, meta-analysis, cohort, case report, etc.)

The section type is meaningful for evidence quality: a claim stated in the
results section carries more weight than the same claim in the discussion, where
it may be speculative. The paragraph index enables a reader to find the exact
sentence in the paper that supports the claim -- essential for human verification.

### Multi-Source Claims

A claim that appears in multiple papers is stronger than a claim that appears
in one. The identity server aggregates evidence across sources as part of its
normal operation: when the same relationship is extracted from multiple papers
and both subject and object entities resolve to the same canonical IDs, the
identity server records a multi-source claim with a composite confidence\index{composite confidence}.

The composite confidence is computed by the domain service. In the medlit
reference implementation, it is a weighted mean of the individual confidence
scores, where weights are determined by study type. A claim supported by two
RCTs and one cohort study has a composite confidence higher than the same claim
supported by two case reports.

Replication is a signal of robustness, not a guarantee of correctness. The
identity server records replication faithfully; the interpretation of that
replication is a human judgment informed by the provenance records.

## Chapter 11: Making Bad Ideas Inexpressible

`\chaptermark{Making Bad Ideas Inexpressible}`{=latex}

### Hilbert's Dream

At the turn of the 20th century, David Hilbert\index{Hilbert, David} proposed a grand program for mathematics: to find a formal system in which every true statement could be proved and, crucially, no false or meaningless statement could even be constructed. He wanted a system where bad mathematics was **inexpressible**\index{inexpressible}, not merely discouraged. Kurt Gödel\index{Gödel, Kurt} famously proved that this was impossible for mathematics as a whole.

However, for a domain-constrained knowledge graph, we can actually achieve a version of Hilbert's dream. We are not trying to represent all of human thought; we are trying to represent a finite set of biomedical or legal claims. By using a typed schema, we can build a boundary that structurally refuses to hold certain classes of "bad ideas."

### What Becomes Inexpressible

The typed schema operates at four distinct layers to make unwarranted or malformed assertions inexpressible:

**The Type Layer**\index{type layer}: Edges where the subject or object violates the predicate's domain or range are structurally rejected. You cannot state that "Aspirin (DRUG) inhibits New York (LOCATION)" if the `inhibits` predicate only accepts `GENE` or `PROCESS` as its object. Predicates outside the finite vocabulary are simply not available for use.

**The Identity Layer**\index{identity layer}: Assertions involving unresolvable or "provisional" entities that fail to meet minimum evidence thresholds are sequestered. A claim about a thing that cannot be named and anchored to an authority is an incomplete idea; the system can choose to refuse these until identity is established.

**The Provenance Layer**\index{provenance layer}: The schema can require that every edge carries a pointer to its warrant. An assertion without a source, or a claim whose extraction method is undeclared, is not a fact in the system's eyes—it is a malformed record. The "undifferentiated provenance bag" common in untyped systems is structurally replaced by mandatory, typed provenance records.

**The Consistency Layer**\index{consistency layer}: Contradictory assertions—such as a functional predicate having two different values, or both a predicate and its `negation_of` pair coexisting—are not permitted to "just sit there." They must either be resolved or wrapped in a **conflict record**\index{conflict record} that acknowledges the dispute. The "bad idea" of unacknowledged contradiction becomes inexpressible.

### The Functional Programming Analogy

This approach mirrors the "make illegal states unrepresentable"\index{illegal states unrepresentable} mantra of functional programming in languages like Haskell\index{Haskell} or Rust\index{Rust}. In those languages, you don't write runtime checks for null values if your type system can guarantee a value is always present. You move the invariant into the type system.

A typed knowledge graph applies this principle to assertions. We move the "rules of evidence" into the graph's structure. If the schema compiles and the linter passes, we know that certain classes of errors—type mismatches, missing sources, unanchored identities—simply cannot exist in the data.

### What This Requires of the Ontology

This level of enforcement is only as good as the ontology it enforces. To make bad ideas inexpressible, the ontology must be rich:
- **Functional predicates**\index{functional predicates} must be declared (e.g., `has_official_symbol`).
- **Negation pairs**\index{negation pairs} must be identified (e.g., `activates` vs. `inhibits`).
- **Provenance completeness rules** must be defined (e.g., "every extraction must have a confidence score").

The Domain Spec becomes the constitution of the graph. If it is weak, the graph is noisy. If it is rigorous, the graph becomes a high-fidelity instrument for reasoning.

### The Limits: Gödel's Revenge

We must be honest about the boundary: the typed graph enforces **structural well-formedness**, not **semantic correctness**. A well-typed, well-sourced edge can still be factually wrong. An LLM might extract "Aspirin treats Cancer" and correctly link it to RxNorm and MeSH. The linter will pass it because the types match and the provenance is present.

This is not a defect; it is a feature. It separates the **structural integrity** of the knowledge base from the **truth value** of the claims it contains. We can guarantee the former; for the latter, we provide the provenance so a human (or a more sophisticated agent) can decide.

## Chapter 12: The Graph Linter

`\chaptermark{The Graph Linter}`{=latex}

### Linting as Explicit Epistemics

In the Unix philosophy\index{Unix philosophy}, tools are small, focused, and composable. The ingestion pipeline can enforce schema constraints at insertion time, but there is a complementary tool worth building: a standalone linter that audits the graph independently of the insertion path. Call it `kglint`\index{graph linter}.

The idea is straightforward. A code linter checks source files for structural violations that the compiler might not catch -- style problems, unused variables, suspicious patterns. A graph linter does the same for knowledge claims. It doesn't just check for broken data; it checks for broken epistemics. It asks, of every edge in the graph: is this claim well-formed? Is it sourced? Does it contradict something else without acknowledgment?

This separation -- enforcement at insertion, auditing after the fact -- reflects Unix philosophy. The insertion path needs to be fast. A linter can be thorough. Running them as distinct tools makes both easier to reason about and test.

### What a Graph Linter Checks

The key design insight is that a graph linter should not have hardcoded rules. Its rule set should be derived entirely from the Domain Spec at runtime. Every predicate in the spec has a domain, a range, a provenance requirement, and optionally a functional flag or a negation pair. The linter reads the spec and generates its checks from those declarations.

The checks fall into the same four layers described in Chapter 11:

- **Vocabulary violations**: predicates in the graph not defined in the schema
- **Domain/range violations**: edges where subject or object entity type violates the predicate's declared constraints
- **Provenance gaps**: edges without a valid provenance record, or with provenance that does not declare an extraction method
- **Unacknowledged contradictions**: functional predicates with multiple values for the same subject, or edges whose predicates are declared negation pairs and both exist between the same entity pair

Adding a new predicate to the Domain Spec automatically adds lint coverage for it. The linter requires no maintenance as the schema evolves.

### Violation Structure

A useful linter emits structured output, not free text. Each violation should be a typed record that downstream tools can handle programmatically:

```json
{
  "violation_type": "DOMAIN_RANGE_MISMATCH",
  "severity": "ERROR",
  "edge_id": "edge_789",
  "subject_type": "DRUG",
  "predicate": "inhibits",
  "object_type": "LOCATION",
  "message": "Predicate 'inhibits' cannot have object type 'LOCATION'. Expected 'GENE' or 'PROCESS'.",
  "remediation": "Check entity resolution for object 'New York'."
}
```

JSONL output makes the linter composable: pipe it into a dashboard, a review queue, a CI step, or a script that filters by severity.

### Conflict Records as First-Class Data

One worthwhile design choice for a graph linter: when it detects that two papers disagree -- one says a drug activates a gene and another says it inhibits it -- it should not simply report the contradiction as an error and stop. Instead, it should emit a **Conflict Record**\index{conflict record}: a structured record naming both edges, the conflict type, and the resolution status.

The graph is richer for containing the dispute rather than suppressing it. In a typed graph, **contradiction is information**\index{contradiction}, not failure. Unresolved scientific disagreements are real and worth representing. A linter that turns unacknowledged contradictions into first-class records allows the graph to represent the messiness of scientific discourse without sacrificing structural rigor.

### A Note on What Exists

None of this requires the graph linter to exist before the graph is useful. The typed schema and identity server provide meaningful guarantees at insertion time without any separate linter. But as a corpus grows and multiple ingestion runs accumulate, the value of an independent audit pass increases. A linter built along these lines -- schema-driven, structured output, conflict records as data -- would be a natural next tool to build once the core pipeline is running.

## Chapter 13: Bias, Limits, and Responsibility

`\chaptermark{Bias and Responsibility}`{=latex}

### What the Graph Cannot Know

A knowledge graph built from a corpus knows only what that corpus contains.
PubMed\index{PubMed} indexes a large fraction of biomedical literature, but not all of it.
Papers published only in languages other than English are underrepresented.
Research from institutions in lower-income countries is underrepresented.
Research that was conducted but never published -- because the results were
negative, because the funding ran out, because the research group disbanded --
is absent entirely.

The identity server cannot correct for these absences. It can only process what
it is given. A graph that achieves high internal consistency through careful
identity resolution is not a complete picture of a domain; it is a consistent
picture of what the corpus contains.

This is a limitation, not a failure. Every knowledge system has coverage
boundaries. The important thing is that the boundaries are known and
communicated to users of the graph, not obscured by the system's apparent
sophistication.

### Bias Encoded at Scale

Source biases propagate into the graph and are amplified by confidence
weighting. If the corpus contains more RCTs on a particular drug than on
comparable drugs -- because the manufacturer funded more research -- the
drug's claims will have higher confidence scores than the claims of unfunded
comparators. This is not a bug in the confidence weighting formula. It is
a faithful representation of what the evidence shows. But it may mislead
users who do not understand the relationship between publication patterns and
confidence scores.

The identity server cannot eliminate this bias. It can make it visible:
by recording the study type of every source, by exposing the provenance of
every confidence score, by providing query interfaces that let users examine
the evidence distribution behind any claim. Transparency about bias is not
the same as absence of bias, but it is a necessary condition for informed use.

### The Builder's Responsibility

Building a knowledge graph that is used in high-stakes decisions carries
responsibilities that do not end at deployment. The graph's coverage boundaries
should be documented. The confidence weighting methodology should be transparent
and auditable. The provenance records should be sufficient for a user to verify
any claim independently.

The identity server's architecture supports these responsibilities: every merge
is logged, every promotion is logged, every confidence computation is
reproducible from the provenance records. The infrastructure for verification
is built in. Using it is a commitment that extends beyond the code.

### Credit, Priority, and Provenance\index{credit (scientific)}\index{scientific priority}

When a machine surfaces a connection -- a drug-disease relationship that no
single paper states but that the graph implies from combining multiple sources
-- who gets credit? The authors of the papers that contributed the underlying
facts? The builders of the graph? The user who ran the query? The question
matters for scientific priority, intellectual property, and the sociology of
research. Scientists are rewarded for discovery. If the discovery is made by
a system, the reward structure gets complicated.

Provenance tracking, which this book has treated as a technical concern
throughout, turns out to have significant ethical implications. How you record
where a fact came from determines who can be credited. A relationship with full
provenance -- source document, passage, extraction method -- makes it possible
to trace the contribution back to the original authors. A relationship stored
without provenance makes that impossible. The technical decision about schema
design is also a decision about how credit will flow. The same is true for
conflicts: when two sources assert contradictory relationships, provenance lets
you represent the conflict rather than silently merging. That representation
matters for how disputes get resolved and how the community understands what's
known versus what's contested. The builder of the graph is making choices that
affect the sociology of the domain, whether or not they intend to.

### Who Owns the Graph\index{open science}\index{graph ownership}

Open versus proprietary is not a new tension in science. GenBank\index{GenBank},
the repository of genetic sequences, was built as a public resource; the
decision to make it open and freely accessible shaped how molecular biology
developed. Clinical trial data, by contrast, has often been held proprietary
by sponsors; the fight for access has been long and only partially won. The
question of who owns a comprehensive knowledge graph over a significant
scientific domain will have similar consequences.

If a single entity -- a company, a government, a consortium -- controls the
graph, that entity controls who can query it, what they can do with the
results, and how the graph evolves. The incentives may align with the
scientific commons, or they may not. A company that built a drug-discovery KG
might restrict access to protect competitive advantage. A government might
restrict access for national security reasons. An open consortium might make
the graph freely available but lack the resources to maintain it. The
historical analogies are instructive: GenBank succeeded because the community
agreed that sequence data should be a commons; clinical trial data remains
contested because the incentives are mixed. A knowledge graph over a domain
like medicine or materials science will face the same tensions. What it would
mean for a single entity to control it -- the power to shape what gets
synthesized, what gets surfaced, what gets updated -- is worth thinking about
before it happens.

### Capability Is Not Bounded by Intent\index{capability vs. intent}\index{architecture of expertise}

Consider what it means to build a system that encodes the architecture of
expertise for a domain. You built a graph for drug discovery; a user runs a
traversal that surfaces a drug-pathway combination that could be repurposed for
something harmful. You built a graph for medical literature; a query connects
the dots in a way that reveals something about a person's health that they
didn't intend to share. You built a graph for materials science; the same
structural similarity query that finds promising battery compounds could find
promising explosives. None of these are edge cases or failures. They follow
directly from the system working as designed.

The graph encodes structure; structure supports inference; inference doesn't
respect the boundaries of what you had in mind. A reasoning system with access
to rich, typed, provenance-tracked knowledge will expose connections its
builders didn't anticipate -- because the value of the system is precisely that
it can traverse the graph more exhaustively than any individual human would.
That traversal doesn't stop at the edges of your intended use case. Capability
is not neatly bounded by intent.

That doesn't mean you shouldn't build. It means you should build with your
eyes open. The inferences the system can expose are a feature when they advance
science and a risk when they don't. The difference is often context, use case,
and the choices you make about access, provenance, and what gets logged. Those
choices deserve to be taken seriously.

### Dual Use at Graph Scale\index{dual use}

The drug interaction that saves lives and the synthesis route that enables harm
are both pattern-matching problems over structured knowledge. A graph that
encodes "compound X inhibits enzyme Y" and "reaction A produces compound X"
can answer "what inhibits Y?" for a clinician looking for treatments and for
someone looking for precursors. The same query interface serves both. The graph
doesn't know the difference. Dual use is not a bug; it's inherent to how
knowledge works. Facts don't come with moral valence. The same fact can support
healing or harm depending on who uses it and how.

What does responsible construction and deployment look like? There's no clean
answer, but there are practices that help. Access control\index{access control}:
who can query the graph, and for what? Some graphs should be broadly available;
others may need to be restricted to credentialed researchers or vetted use
cases. Provenance and transparency: when the system surfaces a connection, can
the user trace it to sources? That traceability supports verification and
accountability. Logging and monitoring: if the graph is used for something
harmful, can you detect it? Auditing: who reviews how the system is used? These
are operational questions, not just technical ones. They don't eliminate dual
use. They make it harder to misuse the system without leaving a trace, and they
create channels for accountability when misuse occurs. The right response to
dual use isn't to not build. It's to build with these questions in mind.

### The Epistemic Responsibility of the Builder\index{epistemic responsibility}

What do you owe to the users of the system you build? At minimum, you owe them
honesty about what the system is and isn't. It's a synthesis of the literature,
not a representation of ground truth. It has gaps, biases, and limits. Users
who don't understand that may over-trust it. You also owe them the
infrastructure for verification: provenance, so they can trace claims to
sources; confidence, so they can weight what they find; and documentation, so
they know what the schema captures and what it doesn't.

Beyond that, the builder's choices about provenance, transparency, access, and
schema design are ethical choices, not just technical ones. Deciding what to
extract, how to represent it, who gets to query it, and what gets logged --
these decisions shape how the system will be used and what consequences it will
have. That doesn't mean every builder must solve every ethical problem before
shipping. It means the builder is a stakeholder, with some power to shape
outcomes. The right response isn't paralysis. It's to take the responsibility
seriously, to build with the foreseeable consequences in mind, and to create
the conditions for accountability when things go wrong.

## Chapter 14: What This Makes Possible

`\chaptermark{What This Makes Possible}`{=latex}

### The Three-Book Arc

*Knowledge Graphs from Unstructured Text* solves the extraction problem: how
to get structured claims out of unstructured text at scale. This book solves
the trustworthiness problem: how to ensure those claims are anchored to stable
identities, sourced to their evidence, and aggregated correctly across sources.
*BFS-QL* solves the interface problem: how to get those claims to a language
model in a form it can actually reason over.

The three books are independent in the sense that each addresses a distinct
problem. They are interdependent in the sense that each one's solution depends
on the others being solved. An extraction pipeline without an identity server
produces an unusable graph. An identity server without an extraction pipeline
has nothing to process. A query protocol without a trustworthy graph is an
interface to noise.

The identity server is the connective tissue. It is called by the extraction
pipeline and queried by the query layer. It is the service that makes the graph
trustworthy, and trustworthiness is what makes the system useful.

### Cross-Domain Reasoning

The shared canonical ID infrastructure makes cross-domain reasoning possible
in a way that was not previously practical. A graph built from biomedical
literature can compose with a graph built from clinical trial data, a drug
adverse event database, and a genomics resource -- not because any of these
sources were designed to interoperate, but because they all anchor to the same
authorities.

The biomedical community built MeSH\index{MeSH}, HGNC\index{HGNC}, RxNorm\index{RxNorm}, and UniProt\index{UniProt} over decades
for their own purposes: to organize their literature, to name their discoveries,
to communicate across research groups. The identity server treats these
authorities as the interoperability layer they accidentally became. The
cross-domain reasoning capability is an emergent property of the decision to
anchor to shared authorities, not a designed feature of any single system.

### Democratization and Its Limits

Building and maintaining a serious knowledge graph still requires significant
resources. You need a corpus, which may be behind paywalls\index{paywalls}.
You need compute for extraction, which costs money. You need domain expertise
to design the schema and validate the output. The result is that the first
generation of domain-spanning knowledge graphs will likely be built by those
who can afford to build them -- pharmaceutical companies, large universities,
government agencies, well-funded startups. The question of who gets access then
becomes a question of licensing, openness, and governance.

The promise the technology holds out is real nonetheless. A researcher at a
small institution, or in a developing country, with access to a comprehensive
KG over their domain would have the same structural view of the literature as
a researcher at a well-funded lab. The graph doesn't care who queries it. The
capability to expose connections that citation networks hide, to ground an LLM
in curated knowledge -- that capability could be democratized. The technology
enables it; policy and incentive will decide whether it happens.

### Grounding LLM Inference

The pattern that changes what a language model can do: instead of asking a
model to reason from its training data, give it structured, typed,
provenance-tracked claims from your graph and ask it to reason from those. The
difference in reliability is substantial. A model hallucinating over raw text
and a model reasoning over a curated graph with explicit provenance are doing
qualitatively different things, even if they look similar from the outside.
This is the integration that makes a knowledge graph more than a database.

The mechanics are straightforward. A user asks a question. Your system
retrieves relevant subgraphs -- entities and relationships that match the
question's scope -- and injects them into the model's context. The model
reasons over that context and produces an answer. The answer is grounded in the
retrieved graph, not in the model's training. You can cite the sources. You can
trace the reasoning path. When the graph is wrong, you fix the graph; you don't
retrain the model.

### Hypothesis Generation

Graph traversal as a discovery tool: not "what do we know about X" but "what's
adjacent to X that hasn't been studied," "what entities are structurally similar
to X in the graph," "what relationships exist between X and Y that no single
paper asserts but that follow from combining multiple sources." These are
queries that are impossible over raw text and natural over a well-constructed
graph.

Consider a concrete example. Drug A treats disease D. Gene G is associated with
disease D. Drug B modulates gene G. No single paper may state that drug B is
worth testing for disease D. The inference follows from combining three
relationships that exist in the graph. A researcher who had read all the
relevant papers might make that connection; the graph makes it queryable. The
results are candidate hypotheses -- drug-disease pairs that the graph implies
but that may not have been studied together. The graph doesn't decide which are
worth pursuing. It surfaces candidates that a human can filter and prioritize.

### What Has Changed

The extraction bottleneck that held back knowledge representation for fifty
years is now broken. The epistemic commons -- the shared identifier
infrastructure built by the biomedical, chemical, legal, and geographic
communities -- has existed for decades. The identity server is the bridge
between them: the service that takes extracted mentions, anchors them to shared
authorities, aggregates their evidence, and makes the resulting graph
trustworthy.

The vision of machine reasoning over explicit, traceable, cross-domain
knowledge -- a vision that animated researchers from McCarthy to Lenat to
Berners-Lee -- is now achievable with tools that exist today, at a cost that is
no longer prohibitive, for domains that matter.

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
