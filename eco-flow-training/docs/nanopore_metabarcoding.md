# Running the nanopore metabarcoding pipeline

🧭 [◀️ Part 2 · Pipelines](./pipelines.md) &nbsp;|&nbsp; [🏠 Course menu](../README.md)

---

⏱ **Estimated time:** ~60–90 minutes (including pipeline run time) &nbsp;•&nbsp; 🟡 Practical

In this practical you'll run **nanoporemetabarcoding**, a pipeline built by Eco-Flow ([`Eco-Flow/nanoporemetabarcoding`](https://github.com/Eco-Flow/nanoporemetabarcoding)) — from raw Nanopore reads all the way to a taxonomically-annotated ASV table.

> ℹ️ **Not an official nf-core pipeline.** nanoporemetabarcoding was scaffolded with the [nf-core](https://nf-co.re) template and follows its conventions (module structure, config profiles, `-profile docker`, etc.), which is why some of the tooling will feel familiar to Part 3 of this workshop. But it isn't part of the official nf-core pipeline collection, isn't listed on nf-co.re, and has no tagged release yet, as it is still in active development.

<!--
Disclaim
-->
### What you'll do

- Understand what our nanopore metabarcoding pipeline is and how it owrks
- Inspect raw Nanopore reads
- Work out what inputs the pipeline needs
- **Design** a samplesheet and metadata sheet for a real experimental scenario
- **Run** the pipeline on its built-in test data with Docker containers
- Explore the results — quality reports, BLAST hits, taxonomy, and a community matrix
- Learn to **`-resume`** a run and change pipeline options (let's see...)

<!--
> ✅ **Before you start**, make sure you've completed [Setup](./setup.md) and that your terminal is inside the **`eco-flow-training`** folder. Check with:
> ```bash
> pwd     # should end in eco-flow-training
> ```
-->

### The experiment

We'll use a case study to motivate the design steps: **DNA barcoding of adult wasps to identify their prey.**

Adult wasps were collected at two sites: oak woodland and grassland. Each wasp was individually DNA-barcoded (COI) using a **wasp exclusion ** (`WaspExF_*` forward / `LuthienR_*` reverse) to profile its host's diet signature. Each site's wasp PCR products were pooled onto one Nanopore barcode — i.e. **one plate = one ONT barcode = one FASTQ file**, but each *well* inside that plate is its own wasp, told apart later by a second, PCR-level tag.

> 💡 **What's an exclusion primer?** A wasp carries trace host DNA from its prey in the gut/cuticle residue, but its own DNA is far more abundant in the sample, so a plain universal COI primer pair would mostly just re-sequence the wasp itself. `WaspExF_*` primers — the same tagged primers used for demultiplexing — are designed to be less complementary to the wasp's own COI sequence than to other (host) DNA, so amplification of the wasp's own template is suppressed relative to that trace host signal. It's rarely perfect: some wasp DNA usually still gets through, which is one reason checking control wells for unexpected hits (see Step 6) matters.

| Site | Description | Plate / ONT barcode |
| --- | --- | --- |
| Site A ("Woodland") | Adult wasps collected in oak/hazel woodland | plate01 / barcode01 |
| Site B ("Meadow") | Adult wasps collected in grassland/meadow | plate02 / barcode02 |

Within each plate, three forward tags (`F1`–`F3`) and two reverse tags (`R1`–`R2`) are combined pairwise to label individual wells — giving each wasp (and each control) a unique forward+reverse tag combination.

We'll **design** the samplesheet/metadata for this scenario ourselves in Steps 3–4, then **run** the pipeline for real in Step 5 using the small dummy dataset.

---

## Step 0 — Understand nanopore metabarcoding

Metabarcoding sequences a short, taxonomically-informative marker gene (here, COI) from many samples/individuals at once, then compares each sequence against a reference database to assign it to a species (or best-available taxonomic rank).

With Nanopore sequencing, an entire multi-well PCR plate is typically pooled into **one** sequencing run/barcode — so a second layer of "tags" (short index sequences stuck onto the primers during PCR) is needed to work out which read came from which well.

<details>
<summary>📚 Good background resources</summary>
<!--
- [Nanopore sequencing — how it works (Oxford Nanopore)](https://nanoporetech.com/how-it-works)
- [DNA metabarcoding — a beginner's guide (Nature Ecology & Evolution primer)](https://www.nature.com/articles/s41559-019-0951-3) -->
- [Cutadapt documentation](https://cutadapt.readthedocs.io/) — the demultiplexing tool this pipeline uses
</details>

---

## Step 1 — Inspect the raw data

The pipeline ships with a small built-in test dataset, but we will use a custom one made for this training, following the case study above. Clone the pipeline repository first:

```bash
git clone https://github.com/Eco-Flow/nanoporemetabarcoding.git
cd nanoporemetabarcoding
```

The raw reads live in `wasp_test_data/`. Nanopore FASTQs are gzipped, so peek at them with `zcat` (as in Part 1):

> ▶️ **Try it — peek at a raw FASTQ**
>
> ```bash
> zcat test_data/test.fastq.gz | head -8
> ```
>
> <details>
> <summary>✅ Expected output</summary>
>
> Groups of four lines per read, same FASTQ format as Illumina — but unlike the paired, fixed-length RNA-Seq reads from Part 3, Nanopore reads are **single, variable-length long reads** with no pair:
>
> ```
> @<read id> ...
> ATGCGT...(a few hundred bp, length varies read to read)
> +
> !%'&&$#"...(quality string, same length as the sequence)
> ```
> </details>

> ▶️ **Try it — count the reads**
>
> ```bash
> zcat test_data/test.fastq.gz | wc -l
> ```
>
> FASTQ uses **4 lines per read**, so divide the line count by 4 to get the number of reads. This file is deliberately tiny (a handful of reads per well) so the whole pipeline runs in minutes.

Also inspect the other files you'll need:

```bash
cat wasp_test_data/primers_f.fasta      # forward primer-tag sequences
cat wasp_test_data/primers_r.fasta      # reverse primer-tag sequences
cat wasp_test_data/metadata.csv         # which tag combination = which sample
```

---

## Step 2 — Explore the pipeline's requirements

Read the pipeline's own usage docs: [`docs/usage.md`](https://github.com/Eco-Flow/nanoporemetabarcoding/blob/master/docs/usage.md) and the parameter block at the top of [`nextflow.config`](https://github.com/Eco-Flow/nanoporemetabarcoding/blob/master/nextflow.config).

<details>
<summary>Cheat sheet — what the pipeline needs</summary>

To run nanoporemetabarcoding you need:

* a **samplesheet** (`--input`) — one row per Nanopore barcode/plate, pointing to a single merged FASTQ
* a **metadata** sheet (`--metadata`) — one row per well, mapping a forward+reverse tag combination to a sample name
* a **forward primer-tag FASTA** (`--tags_f`) and a **reverse primer-tag FASTA** (`--tags_r`)
* a **reference database** for taxonomy — either `--blast_db` (pre-built) or `--custom_db` (a FASTA the pipeline will build a BLAST DB from)
</details>

> 💡 **What the pipeline does for you** (in containers): trims/filters reads (NanoFilt), QCs raw and filtered reads (NanoPlot), demultiplexes by primer-tag (Cutadapt, twice — forward then reverse), clusters reads per well into consensus "species" sequences (amplicon_sorter), polishes each consensus (Medaka), BLASTs each consensus against your reference database, assigns taxonomy from the best hit (taxonomizr), and builds per-run abundance/presence-absence community matrices.

---

## Step 3 — Design a samplesheet

The **samplesheet** links each Nanopore barcode (one plate) to its FASTQ. It has just two columns:

| Column | Meaning |
| --- | --- |
| `id` | An identifier you choose for the plate/barcode (can be anyrhing, but cannot contain spaces or '_') |
| `fastq` | Path to that plate's single, merged FASTQ file |

> ▶️ **Try it — design `samplesheet.csv` for the wasp experiment**
<!-- >
> Using the table in [The experiment](#the-experiment) (2 sites → 2 plates → 2 barcodes), write out what the samplesheet should look like.
-->
<details>
<summary>Cheat sheet — samplesheet.csv for the wasp scenario</summary>

```csv
id,fastq
plate01,barcode01/plate1_combined.fastq.gz
plate02,barcode02/plate2_combined.fastq.gz
```

One row per ONT barcode/plate. `fastq` must point to a single, existing `.fastq.gz` file — if your sequencer produced several chunk files per barcode, merge them (e.g. `cat`) before writing the samplesheet.
</details>

---

## Step 4 — Design a metadata sheet and primer-tag FASTAs

The **metadata** sheet is what actually resolves each demultiplexed well down to a sample name. It has three columns:

| Column | Meaning |
| --- | --- |
| `id` | Must match a plate `id` from the samplesheet |
| `primer_comb` | `<forward tag header>_<reverse tag header>` — must exactly match headers in your `tags_f`/`tags_r` FASTAs |
| `sample` | The name you want in the final ASV table — must be **unique within each plate** |

> ⚠️ **Key rule:** `primer_comb` is a straight string match against your FASTA headers. If the tag names don't match exactly (typos, case, extra characters), that well's reads won't be assigned to a sample.

> ▶️ **Try it — design the metadata for plate01**
>
> Plate01 has 3 forward tags (`F1_WaspExF_Tab1`, `F2_WaspExF_Tab2`, `F3_WaspExF_Tab3`) and 2 reverse tags (`R1_LuthienR_Tab29`, `R2_LuthienR_Tab54`), giving 6 wells: one extraction blank, one positive control, one PCR blank, and 3 adult wasps netted in the Woodland site. Write out the FASTAs and the metadata rows.

<details>
<summary>Cheat sheet — primers_f.fasta / primers_r.fasta</summary>

```fasta
>F1_WaspExF_Tab1
AACAAGCCCCTTTATCWTSWRRWWTTGS
>F2_WaspExF_Tab2
GGAATGAGTCCTTTATCWTSWRRWWTTGS
>F3_WaspExF_Tab3
AATTGCCGGTCCTTTATCWTSWRRWWTTGS
```

```fasta
>R1_LuthienR_Tab29
GAGTAACCACTTCWGGRTGWCCAAARAAYCA
>R2_LuthienR_Tab54
CGATGAGTTACTTCWGGRTGWCCAAARAAYCA
```
</details>

<details>
<summary>Cheat sheet — metadata.csv for plate01</summary>

```csv
id,primer_comb,sample
plate01,F1_WaspExF_Tab1_R1_LuthienR_Tab29,EXT_NEG_F1_R1
plate01,F2_WaspExF_Tab2_R1_LuthienR_Tab29,WD_wasp01
plate01,F3_WaspExF_Tab3_R1_LuthienR_Tab29,WD_wasp02
plate01,F1_WaspExF_Tab1_R2_LuthienR_Tab54,WD_wasp03
plate01,F2_WaspExF_Tab2_R2_LuthienR_Tab54,POS_CON_F2_R2
plate01,F3_WaspExF_Tab3_R2_LuthienR_Tab54,BLANK_F3_R2
```

`plate02` reuses the same 6 tag combinations (the same primer plate design was run at both sites) — only the `id` and the wasp `sample` names change; controls can share the same short name pattern (`EXT_NEG_F1_R1`, `POS_CON_F2_R2`, `BLANK_F3_R2`) since `id` already keeps plate01 and plate02 apart.
</details>

> 💡 **Always include controls.** `EXT_NEG` (extraction blank — no tissue), `POS_CON` (mock DNA of a known reference species), and `BLANK` (PCR no-template control) are how you catch contamination and confirm the assay worked — track them through the metadata sheet exactly like a real sample.

---

## Step 5 — Run the pipeline

Now put the theory aside and actually run the pipeline — on its small **built-in** test dataset (`test_data/`), so it finishes in minutes regardless of whether your wasp FASTQs exist yet.

Read the parameters block in [`nextflow.config`](https://github.com/Eco-Flow/nanoporemetabarcoding/blob/master/nextflow.config) for the full option list.

<details>
<summary>Cheat sheet — the full command</summary>

```bash
nextflow run main.nf \
-profile docker \
--input test_data/../assets/samplesheet.csv \
--metadata test_data/metadata.csv \
--tags_f test_data/primers_f.fasta \
--tags_r test_data/primers_r.fasta \
--custom_db test_data/test_database.fasta \
--outdir results
```

</details>

> 👉 **Single vs double dashes matter!** A single dash (`-profile`, `-resume`) is a **Nextflow** core option. A double dash (`--input`, `--metadata`, `--outdir`) is a **pipeline** parameter defined by nanoporemetabarcoding.

> ✅ **What success looks like:** Nextflow prints a banner, then a live list of processes as they run (`NANOFILT`, `NANOPLOT`, `CUTADAPT` ×2, `AMPLICON_SORTER`, `MEDAKA`, `BLAST_BLASTN`, `ASSIGN_TAXA`, ...). On the tiny test data this should complete in a few minutes, plus a bit longer the first time while Docker pulls the containers.

### Troubleshooting Step 5

<details>
<summary>❌ <code>Missing required parameter: --input</code> / <code>--outdir</code></summary>

Check every `--input`, `--metadata`, `--tags_f`, `--tags_r` and `--outdir` is present and spelled correctly.
</details>

<details>
<summary>❌ A well/sample is missing from the final ASV table</summary>

Almost always a `primer_comb` mismatch — the tag combination in `metadata.csv` doesn't exactly match `<tags_f header>_<tags_r header>`. Double-check spelling and case.
</details>

<details>
<summary>❌ <code>.command.sh: ... command not found</code> (exit status 127)</summary>

You forgot **`-profile docker`**. Without it, Nextflow expects every tool (Cutadapt, Medaka, BLAST, ...) to already be installed locally.
</details>

---

## Step 6 — Explore the results

Once you see `Pipeline completed successfully`, look inside `results/`:

```bash
ls results
```

<details>
<summary>✅ Roughly what you'll see</summary>

```
nanoplot/  blast/  assign_taxa/  community_matrix/  mafft/  plots/  multiqc/  pipeline_info/  reads_per_step/
```
</details>

**Where to look, in order:**

1. **`multiqc/multiqc_report.html`** — one HTML report summarising QC across all samples (built from NanoStat).
2. **`nanoplot/demultiplexed/<plate>/`** — per-plate read-length/quality plots, generated *after* demultiplexing, so you can sanity-check each well individually.
3. **`reads_per_step/reads_per_step.csv`** — a read-count funnel: how many reads survived filtering, then each demultiplexing step. This is the fastest way to spot a well that dropped to zero reads (usually a `primer_comb` typo).
4. **`blast/<plate>.txt`** — raw BLAST hits for every consensus sequence.
5. **`assign_taxa/<plate>/ASV_table_final.csv`** — the key output: one row per ASV (consensus sequence) per well, with its assigned taxonomy from the best BLAST hit.
6. **`community_matrix/<plate>/<plate>_abundance.csv`** and **`..._presence_absence.csv`** — the ASV table pivoted into a classic samples × taxa community matrix, ready for ecological analysis (diversity indices, ordination, etc.).
7. **`plots/proportion/*.png`** — stacked bar plots of taxonomic composition per barcode, at each rank listed in `--tax_list`.

> 🧬 **If you completed Step 4:** open `assign_taxa/.../ASV_table_final.csv` and check whether `EXT_NEG` and `BLANK` picked up any real hits — if they did, that's contamination worth flagging, exactly as it would be in a real run.

---

## Step 7 — Resuming a run and changing options

### Changing an option

Taxonomy assignment has adjustable identity thresholds per rank — e.g. `--spident` (species), `--gpident` (genus). Work out how you'd tighten the species-level threshold to 98% identity, but **don't run it yet**:

<details>
<summary>Answer — the modified command</summary>

```bash
nextflow run main.nf \
-profile test,docker \
--outdir my_results \
--spident 98
```
</details>

### The `-resume` flag

Add **`-resume`** and Nextflow reuses cached results for any step whose inputs haven't changed — so re-running the command above only re-executes taxonomy assignment (and anything downstream of it), not the demultiplexing or clustering steps.

> ✅ **What you'll see with `-resume`:** unchanged processes marked `cached`, e.g. `[a1/b2c3] ...:CUTADAPT_FORWARD (plate01) [100%] 1 of 1, cached: 1 ✔`.

---

## Finish

🎉 **You've finished this practical.** You've gone from raw Nanopore reads to a taxonomically-annotated, per-sample ASV table and community matrix — and designed a samplesheet/metadata scheme for a real multi-plate, primer-tagged experiment.

**Next steps:**

- Adapt what you designed in Steps 3–4 to your **own** primer-tag scheme and run it on your own data.
- Explore the full parameter list in [`nextflow.config`](https://github.com/Eco-Flow/nanoporemetabarcoding/blob/master/nextflow.config) — worth tuning per-rank identity thresholds (`--spident`/`--gpident`/`--fpident`/`--opident`) and `--tax_list` for your own taxonomic group.
- Running on a cluster? See the bonus **[Running a pipeline on an HPC](./hpc.md)**.

---

🧭 [◀️ Part 2 · Pipelines](./pipelines.md) &nbsp;|&nbsp; [🏠 Course menu](../README.md)
