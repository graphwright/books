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

## Chapter 1: What Is Canonical Identity and Why Does It Matter?

`\chaptermark{Canonical Identity}`{=latex}

### The Same Thing, Many Names

Pick any well-studied drug and search for it across a corpus of biomedical
papers. You will find it referred to by its generic name, its brand names, its
chemical name, its abbreviation, and occasionally a misspelling that has
propagated through citations. Desmopressin appears as "desmopressin",
"DDAVP", "dDAVP", "1-deamino-8-D-arginine vasopressin", "desmopressin
acetate", and in older papers simply as "the synthetic vasopressin analogue."
In a graph built from extracted mentions without identity resolution\index{entity resolution}, these are
six unconnected nodes. Every relationship involving desmopressin is split across
them. Queries return partial results. Confidence aggregation is meaningless.
The graph is sophisticated extraction masquerading as structured knowledge.

This is not a corner case. It is the default. Every entity in every technical
domain accumulates surface form\index{surface form} variation over time. Genes have official symbols
and common names and names that were superseded when two research groups
discovered the same gene independently. Diseases have clinical names,
eponyms, and ICD\index{ICD} codes. Chemicals have IUPAC names, trade names, and CAS
registry numbers. The variation is not noise to be cleaned up -- it is a
faithful record of how human knowledge actually develops, in parallel, across
communities that do not always talk to each other.

Canonical identity resolution is the process of deciding that all these surface
forms refer to the same thing and assigning them a single stable identifier.
The identity server is the service that does this.

Nothing about that idea is specific to a **knowledge graph** as a storage
shape. The same problem appears in a relational warehouse, a document database,
a lakehouse table, or a folder of CSV exports: if the same real-world entity can
appear under more than one string, you either resolve those strings to one
stable identifier or accept broken joins, wrong aggregates, and inconsistent
merges across systems. This book speaks the language of graphs because the
companion volumes build and query a graph, and because multi-hop structure makes
the failure modes vivid -- but canonical identity is a requirement of faithful
**data representation**, not of any particular physical schema.

### Identity Is Load-Bearing

A knowledge graph without canonical identity\index{canonical identity} is not a degraded version of a
knowledge graph with canonical identity. It is a different kind of artifact
entirely -- one that cannot support multi-hop reasoning\index{multi-hop reasoning} across sources, cannot
aggregate evidence across papers, cannot compose with other graphs, and cannot
be trusted in high-stakes applications. Identity is not a quality improvement.
It is load-bearing structure.

Consider what becomes possible when every entity has a canonical ID\index{canonical ID}:

Multi-hop reasoning works correctly. A query asking "what drugs have been used
to treat conditions caused by the gene this mutation affects" requires traversing
three relationship types. If the gene appears under two different names in two
different papers, the traversal breaks at the second hop. Canonical identity
closes the gap.

Evidence aggregation is meaningful. The claim "desmopressin inhibits cortisol
secretion" appearing in twelve papers is stronger than the same claim appearing
in one. But this aggregation is only possible if all twelve instances resolve
to the same entity. Without canonical identity, you have twelve separate claims
about six different nodes.

Composition across graphs is automatic. When a graph built from PubMed\index{PubMed} papers
and a graph built from clinical trial data both anchor their drug entities to
RxNorm, a query can traverse from a research finding to a clinical trial
outcome without any special bridging logic. The shared authority is the bridge.

### The Epistemic Commons

The authorities the identity server consults -- MeSH\index{MeSH}, RxNorm\index{RxNorm}, HGNC\index{HGNC}, UniProt\index{UniProt},
ChEMBL\index{ChEMBL} -- are not bureaucratic naming systems. They are the accumulated judgment
of expert communities about how to organize their domain of knowledge. When you
anchor an entity to a MeSH\index{MeSH} term, you are not just assigning a unique key. You
are connecting that entity to its place in a taxonomy built by the National
Library of Medicine over decades: its definition, its hierarchical position
among related concepts, its known synonyms, its cross-references to related
terms in adjacent domains.

This is what it means to place a fact. An unanchored claim that "desmopressin
inhibits cortisol" is a string in a database. An anchored claim that
RxNorm:3251 inhibits MeSH:D003345 is a fact located in the edifice of human
biomedical knowledge, connected to everything the biomedical community knows
about desmopressin and cortisol, traceable to the source that made the claim,
and composable with every other graph that uses the same authorities.

The epistemic commons\index{epistemic commons} -- the shared identifier infrastructure built by the
biomedical, chemical, legal, and geographic communities -- was built for human
use. The identity server makes it available to machines. That is not a small
thing.

### What the Identity Server Does

The identity server is responsible for five operations:

**Resolve**: Given a mention string and an entity type, return a canonical ID.
This is the primary operation. It consults the lookup chain\index{lookup chain} -- exact match,
fuzzy match, embedding\index{embedding (vectors)} similarity -- and falls back to creating a provisional
entity if no match is found.

**Promote**: Given a provisional entity\index{provisional entity} that has accumulated sufficient
evidence, upgrade it to canonical status. The promotion threshold\index{promotion} threshold is
domain-configurable.

**Find synonyms**: Given a canonical ID, return all known surface forms\index{surface forms}. Used
for query-time synonym expansion and graph inspection.

**Merge**: Given two entities determined to be the same, produce one canonical
record. Survivor selection is domain-configurable. Provenance\index{provenance} from both
entities is preserved.

**On entity added**: A hook called after any entity is added or updated. Used
for downstream notifications, cache invalidation, and logging.

These five operations are the complete interface. Everything else -- the lookup
chain, the caching strategy, the Postgres\index{Postgres} schema, the domain service\index{domain service} HTTP calls
-- is implementation detail in service of these five operations.

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

## Chapter 4: What a Typed Graph Is

`\chaptermark{What a Typed Graph Is}`{=latex}

### Beyond the Triple

The foundational unit of the Semantic Web\index{Semantic Web} is the RDF triple\index{RDF triple}: (subject, predicate, object). In its purest form, an untyped graph is a collection of these triples where any node can be a subject or object, and any string can be a predicate. While this flexibility was a design goal for the "Web of Data," it is a liability for an engineering artifact. In an untyped graph, you can assert that a drug "inhibits" a city, or that a gene "is_prescribed_for" a protein. The system has no grounds to object; it merely records the triple.

A typed graph\index{typed graph} abandons this infinite flexibility in favor of structural guarantees. It declares a finite set of **entity types**\index{entity types} (e.g., `DRUG`, `GENE`, `DISEASE`) and a finite vocabulary of **predicates**\index{predicates}. Crucially, every predicate in a typed graph carries a domain\index{domain} and a range\index{range}: the set of entity types that may appear as its subject and object, respectively. A predicate like `inhibits` might have a domain of `(DRUG, GENE)` and a range of `(GENE, BIOLOGICAL_PROCESS)`. Any attempt to create an edge that violates these constraints is not a "bad fact"—it is a structural failure, as meaningless as a syntax error in a compiled language.

### The Ontology as Contract

In a typed graph, the ontology\index{ontology} is not documentation; it is a machine-checkable contract\index{contract} that governs every edge. This distinction is foundational. Documentation is aspirational—it describes how the data *should* look. A contract is enforceable—it defines what the data *is permitted* to look like.

When a graph is governed by a contract, the software that interacts with it can make strong assumptions. A query optimizer knows exactly which entity types it will encounter after traversing a specific predicate. A visualization tool knows which icons to use for nodes based on their declared type. Most importantly, an ingestion pipeline can reject malformed extractions before they ever reach the database. By moving constraints from the application layer into the graph's own structure, we ensure that the graph's integrity is an architectural property rather than a convention that must be remembered by every developer.

### PredicateSpec and EntityType

To make these constraints concrete, we represent the ontology as a **Domain Spec**\index{domain spec}. In the reference implementation, this is defined using Pydantic\index{Pydantic} models and Python enums.

```python
from enum import Enum
from pydantic import BaseModel, Field
from typing import Optional, FrozenSet

class EntityType(str, Enum):
    DRUG = "drug"
    GENE = "gene"
    DISEASE = "disease"
    PROCESS = "biological_process"

class PredicateSpec(BaseModel):
    name: str
    domain: FrozenSet[EntityType]
    range: FrozenSet[EntityType]
    description: str
    is_functional: bool = False
    negation_of: Optional[str] = None

    class Config:
        frozen = True
```

The `EntityType`\index{EntityType} enum defines the closed world of things that can exist. The `PredicateSpec`\index{PredicateSpec} carries the rules for their interaction. The `domain` and `range` are sets, allowing a predicate to bridge multiple type pairs (e.g., a `DRUG` can inhibit a `GENE`, but a `GENE` can also inhibit another `GENE`). The `is_functional` flag indicates that a subject can have at most one such outgoing edge—a structural way to represent unique properties.

### Where the Ontology Comes From

The engineer does not invent this schema from first principles. Instead, the ontology is derived from the **epistemic commons**\index{epistemic commons}. The biomedical community has already done the hard work of defining what these types and relationships are.

MeSH's\index{MeSH} category hierarchy provides the implicit entity types. RxNorm's\index{RxNorm} drug-disease relationships provide the predicates. HGNC's\index{HGNC} gene-protein associations define the domain and range constraints. The typed graph schema simply makes these implicit structures explicit and computable. By deriving the ontology from the same authorities used for identity resolution, we ensure that the graph's structure is aligned with the community's own knowledge. If the National Library of Medicine says that a drug treats a disease, the `treats` predicate in our schema will have a domain of `DRUG` and a range of `DISEASE`.

### Finite vs. Open-World

The typed graph is a **closed-world artifact**\index{closed-world assumption}. This is the key difference from the RDF/OWL\index{RDF/OWL} open-world assumption\index{open-world assumption}. In an open-world system, the absence of a statement means its truth is unknown. In a closed-world typed graph, predicates outside the schema do not exist. If `upregulates` is not in the domain spec, it cannot be asserted.

This limitation is the source of the graph's expressive power. By bounding the vocabulary, we make the graph's contents predictable and searchable. We move from a "bag of triples" to a structured knowledge base that can be linted, validated, and queried with mathematical precision. The typed graph does not try to represent everything; it tries to represent its specific domain perfectly.

## Chapter 5: The Domain Service and the Schema

`\chaptermark{Domain Service}`{=latex}

### What the Domain Provides

The domain service is where domain knowledge lives. It is a small HTTP service --
four endpoints, each doing one thing -- that the identity server calls when it
needs to make a domain-specific decision.

The biomedical domain service for the medlit reference implementation calls the
PubChem\index{PubChem} API for chemical entities, the MeSH\index{MeSH} API for disease and biological
process entities, the HGNC REST API for gene entities, and the RxNorm API for
drug entities. It implements synonym detection thresholds tuned for biomedical
nomenclature. It selects survivors by preferring authority-anchored records over
provisional ones. It computes confidence from a study type\index{study type} weight table aligned
with evidence-based medicine\index{evidence-based medicine} principles.

A domain service for legal entities would call different authorities -- perhaps
a court document database for case citations, a legislative database for
statute references -- with different synonym criteria and different confidence
weights (or none at all). The domain service for a materials science corpus
would consult different authorities again.

The base server does not know or care about any of this. It knows the four
endpoint contracts. The domain service fulfills them.

### Evidence Quality Weighting

In evidence-based medicine\index{evidence-based medicine}, not all evidence is equal. A randomized controlled
trial is the strongest form of evidence for a clinical claim. A meta-analysis
that synthesizes multiple RCTs is stronger still, but depends on the quality
of the constituent trials. An observational study is weaker; a single case
report is the weakest form of published evidence.

The domain service encodes this hierarchy in a weight table:

```python
STUDY_WEIGHTS = {
    "meta_analysis": 0.95,
    "rct": 1.0,
    "cohort": 0.8,
    "case_control": 0.7,
    "observational": 0.6,
    "review": 0.5,
    "case_report": 0.4,
}
```

When the identity server asks the domain service to compute confidence for a
list of provenance records, the domain service looks up the study type of each
record, retrieves its weight, and aggregates. The aggregation formula is
configurable -- a simple maximum, a weighted mean, or a formula that rewards
replication across independent studies.

The weight table is a model, not ground truth. A well-replicated observational
finding across five independent cohorts may be more reliable than a single
small RCT. The weights are a defensible starting point; the domain service
makes them transparent and filterable rather than hiding them inside a black
box.

### The Schema as a Runtime Artifact

In traditional database design, the schema is a static artifact—a set of SQL DDL
statements or a compiled Protobuf definition that remains fixed until the next
deployment. In the typed graph architecture, we treat the schema\index{schema}
as a dynamic runtime artifact\index{runtime artifact} served by the domain
service.

When the base identity server\index{identity server} initializes, it is
semantically empty. It understands the mechanics of resolution and the state
machine of entities, but it has no knowledge of the specific entity types or
predicates that define a domain. Its first action is to query the domain
service's `GET /schema` endpoint. The response is a serialized
ontology\index{ontology}: a complete declaration of the finite set of
`EntityType` enums and `PredicateSpec` objects that govern the graph.

This late-binding of the ontology is what enables the separation of concerns
between the engine and the domain. Because the base server discovers its
constraints at runtime, it can perform predicate validation\index{predicate
validation}, type checking\index{type checking}, and conflict
detection\index{conflict detection} without being recompiled for every new
project. If the medlit domain service adds a new predicate—for instance,
`contraindicated_in(drug, disease)`—the identity server immediately inherits
the knowledge of that predicate's domain and range constraints.

By elevating the schema to a runtime artifact, we move it from being passive
documentation to an active, executable specification. This same artifact seeds
the graph linter\index{graph linter} (Chapter 13) and the BFS-QL compiler
(Chapter 10), ensuring that every component in the stack is synchronized
against a single, authoritative definition of what a well-formed claim looks
like. The schema is not just a description of the data; it is the
machine-readable contract that makes the data trustworthy.

### Implementing the Domain Service

The medlit domain service is implemented in Python using FastAPI\index{FastAPI} and Pydantic\index{Pydantic}.
FastAPI provides automatic OpenAPI\index{OpenAPI} documentation and request validation. Pydantic
models define the request and response schemas for each endpoint.

The `/resolve-authority` endpoint accepts a mention string and entity type.
It dispatches to the appropriate authority API based on entity type, normalizes
the response to a canonical ID and authority name, and returns the result. On
a cache miss, it calls the external API and caches the response for the duration
of the run.

The `/select-survivor` endpoint accepts two entity records and returns the
preferred one. The medlit implementation prefers the record with an authority
ID; if both have authority IDs from the same authority, it prefers the one with
more supporting evidence; if evidence counts are equal, it prefers the more
recently updated record.

The `/compute-confidence` endpoint accepts a list of provenance records and
returns a float. The medlit implementation looks up the study type of each
record, applies the weight table, and returns a weighted mean capped at 0.99.

The `/synonym-criteria` endpoint returns a static configuration object defining
the similarity thresholds for fuzzy and embedding-based synonym detection.

## Chapter 6: The Base Identity Server

`\chaptermark{Base Identity Server}`{=latex}

### Domain-Agnostic Core

The base identity server contains everything that is true of identity resolution
regardless of domain:

The provisional/canonical/merged state machine. Every entity starts as
provisional or enters directly as canonical (for provenance\index{provenance}-derived entities
like papers and authors). Provisional entities accumulate evidence and are
promoted when a threshold is met. Merged entities are absorbed into a survivor
and cease to exist as independent nodes.

The lookup chain. Exact match against known surface forms. Fuzzy match via
edit distance. Embedding similarity via pgvector. These three stages are
universal; only the thresholds and the authority consulted at each stage are
domain-specific.

Idempotency\index{idempotency}. All operations must be safe to retry. Ingestion pipelines fail.
Runs restart from checkpoints. The identity server must produce the same result
whether a resolve call is the first or the fifteenth for a given mention.

Postgres locking. Multiple ingestion workers run concurrently. Advisory locks
prevent race conditions on entity creation and merging without serializing the
entire pipeline.

pgvector similarity search. Embedding vectors are stored in Postgres using the
pgvector extension. The cosine distance query `ORDER BY embedding <=> $1 LIMIT k`
is the implementation of the embedding similarity stage of the lookup chain.

None of this is domain-specific. A graph of legal entities uses the same state
machine, the same lookup chain structure, the same idempotency\index{idempotency} requirements,
the same locking strategy as a graph of biomedical entities. The base server
handles all of it.

### The Plugin Contract

The base server calls out to a domain service for four things it cannot know:

**Authority lookup**: Given a mention string and entity type, consult the
appropriate external authority and return a canonical ID if one exists. The
base server does not know which authorities exist, which APIs to call, or how
to interpret their responses. The domain service knows all of this.

**Synonym criteria**: Given two entity records, are they close enough to be
considered synonyms? The threshold for synonym detection varies by domain and
entity type. A gene symbol and a gene full name that share no characters may be
synonyms; two drug names that differ by one character may not be.

**Survivor selection**: Given two entities being merged, which record becomes
the survivor? The domain may prefer the record with an authority ID over a
provisional one, the record with more supporting evidence, or the more recently
updated record. The domain service implements this preference.

**Confidence weighting**: Given a list of provenance records, compute an
aggregate confidence score\index{confidence score}. The base server provides the list; the domain
service provides the weights and the aggregation logic. In biomedicine, an RCT
outweighs a case report; in other domains, the weights are different or absent.

These four hooks are the complete plugin contract\index{plugin contract}. The domain service implements
them. The base server calls them. Neither needs to know anything about the
other's internal implementation.

### The Docker Image

The base identity server ships as a Docker image. The image contains:

- The Python service implementing the five identity server operations
- Postgres client libraries and pgvector support
- An HTTP client for calling the domain service
- An LRU cache\index{LRU cache} layer wrapping the domain service client
- A stub domain service that returns nulls and defaults

The stub domain service makes the image functional without any domain
configuration. It resolves nothing to authorities (all entities start as
provisional), accepts all candidates as non-synonyms, always selects the first
entity as the survivor, and returns a confidence of 0.5 for all provenance
lists. This is correct behavior for a system with no domain knowledge -- it is
not an error state.

To deploy the identity server for a real domain, replace the stub with a real
domain service pointed at the appropriate authorities. The identity server image
does not change. The domain service is a separate container.

### Caching

#### Why caching is not optional

The lookup chain calls the domain service for every entity mention that does
not resolve at the exact match stage. In a corpus of ten thousand papers, this
means tens of thousands of HTTP calls to the domain service, each of which may
call an external authority API. Without caching, a large corpus run is slow,
expensive in API costs, and potentially rate-limited out of completion.

The caching strategy has two levels: an LRU cache in the identity server that
caches domain service HTTP responses, and a long-TTL cache in the domain service
that caches external authority API responses. Together they ensure that the
expensive operations -- external API calls -- happen once per unique entity, not
once per mention.

#### LRU cache in the identity server

The identity server wraps its HTTP client to the domain service with an LRU
cache keyed on `(mention, entity_type)`. A call to `/resolve-authority` for
"desmopressin" with type "drug" will hit the external authority API on the
first mention in the corpus and return the cached result for every subsequent
mention.

The hit rate for this cache is high in practice. Entity mentions are not
uniformly distributed across a corpus -- a paper about Cushing's disease\index{Cushing's disease} will
mention ACTH, cortisol, and desmopressin many times, and these same entities
will appear in many other papers about the same disease. The most-mentioned
entities are exactly the ones that benefit most from caching.

Cache size is configurable. For a corpus run that processes all papers
sequentially in a single worker, an LRU size of 10,000 entries is sufficient
to capture the hot set of entities in most domains. For parallel workers, each
worker maintains its own cache; there is no shared cache between workers, which
avoids coordination overhead at the cost of some redundant API calls at the
start of each worker's run.

#### Long-TTL cache in the domain service

The domain service caches external authority API responses with a long TTL --
hours or days, or for the duration of a batch run. Authority records are stable:
a MeSH\index{MeSH} term's canonical ID and synonyms do not change between the start and end
of a corpus ingestion run. There is no value in fetching the same authority
record twice.

The domain service uses Redis\index{Redis} for this cache. Redis provides TTL-based
expiration and handles cache persistence across domain service restarts. If the
domain service is restarted mid-run, the cache survives the restart and the run
can continue without re-fetching all previously resolved authority records.

This is the most important cache in the system. External authority API calls are
the bottleneck for resolution performance. The domain service cache eliminates
them after the first call.

#### Co-location

The identity server, domain service, Postgres, and Redis run in the same
docker-compose\index{docker-compose} network. HTTP calls between them traverse a virtual network
interface; latency is sub-millisecond. The caching strategy is designed for
this topology -- it assumes that cache misses are cheap (a local network call to
Redis or Postgres) and that the expensive operations (external authority APIs)
are eliminated by caching.

If the identity server and domain service are deployed in separate network
regions, the latency assumptions change. The caching strategy remains correct
but the per-call cost of cache misses increases. Co-location is a deployment
requirement for the performance characteristics described here, not just a
convenience.

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

### An Invitation

The extraction bottleneck that held back knowledge representation for fifty
years is now broken. The epistemic commons -- the shared identifier
infrastructure built by the biomedical, chemical, legal, and geographic
communities -- has existed for decades. The identity server is the bridge
between them: the service that takes extracted mentions, anchors them to shared
authorities, aggregates their evidence, and makes the resulting graph
trustworthy.

This is not a small thing. It means that the vision of machine reasoning over
explicit, traceable, cross-domain knowledge -- a vision that animated researchers
from McCarthy to Lenat to Berners-Lee -- is now achievable with tools that exist
today, at a cost that is no longer prohibitive, for domains that matter.

The infrastructure is built. The epistemic commons is there. The invitation is
to use them.

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
