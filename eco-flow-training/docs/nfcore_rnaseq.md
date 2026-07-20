# Running an nf-core pipeline (RNA-Seq)

🧭 [◀️ Part 2 · Pipelines](./pipelines.md) &nbsp;|&nbsp; [🏠 Course menu](../README.md) &nbsp;|&nbsp; **Next:** [Part 4 · Differential expression ▶️](./differential.md)

🚀 **Start now:** [![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/Eco-Flow/training) — *first launch takes a couple of minutes to build.*

---

⏱ **Estimated time:** ~60–90 minutes (including pipeline run time) &nbsp;•&nbsp; 🟡 Practical

In this practical you'll run a real, published-standard **nf-core RNA-Seq pipeline** ([nf-core/rnaseq](https://nf-co.re/rnaseq/3.14.0)) on example data — from raw sequencing reads all the way to a gene-count table and a quality report.

**nf-core** is a community that builds gold-standard, reproducible data pipelines that have become the industry standard.

![nf-core logo](https://github.com/Eco-Flow/training/assets/9978862/cdb59557-128d-48f8-8df1-0a6b548f89e9)

**nf-core** have a variety of [pipelines](https://nf-co.re/pipelines) that tackle key bioinformatic challenges. Join them on Slack [here](https://nf-co.re/join/slack).

### What you'll do

- Inspect the raw RNA-Seq data
- Work out what inputs the pipeline needs
- Build a **samplesheet** describing your samples
- Download a reference **genome** and **annotation**
- **Run** the pipeline with Docker containers
- Explore the **results** (quality reports and gene counts)
- Learn to **`-resume`** a run and change pipeline options

> ✅ **Before you start**, make sure you've completed [Setup](./setup.md) and that your terminal is inside the **`eco-flow-training`** folder. Check with:
> ```bash
> pwd     # should end in eco-flow-training
> ```
> Everything below assumes you run commands from there. In Codespaces the full path is `/workspaces/training/eco-flow-training`; on a local machine substitute your own path (use `pwd` to see it).

### The experiment

We'll compare gene expression between **wild-type** yeast cells and cells with a **Rap1 gene knock-down (KD)**. There are 3 replicates of each condition. The data come from this paper: https://pubmed.ncbi.nlm.nih.gov/30576656/

<img width="400" alt="Experiment overview" src="https://github.com/Eco-Flow/training/assets/9978862/d51a00c6-4184-4805-b823-3d6248bb2fde">

| Sample | Condition | Reads |
| --- | --- | --- |
| SRR6357070 | wild-type | paired-end (`_1` + `_2`) |
| SRR6357071 | wild-type | paired-end (`_1` + `_2`) |
| SRR6357072 | wild-type | paired-end (`_1` + `_2`) |
| SRR6357073 | manipulated (KD) | single-end (`_1` only) |
| SRR6357074 | manipulated (KD) | single-end (`_1` only) |
| SRR6357075 | manipulated (KD) | single-end (`_1` only) |

---

## Step 0 — Understand RNA-Seq

Before running an RNA-Seq analysis, it helps to understand what it *is*. In short: RNA-Seq measures how much each gene is being **expressed** by sequencing the RNA in a sample, mapping those reads back to a reference genome, and counting how many land on each gene. This is covered in the lecture; the resources below go deeper.

<details>
<summary>📚 Great RNA-Seq learning resources</summary>

- [Azenta — Quick-start guide to RNA-Seq data analysis](https://www.azenta.com/blog/quick-start-guide-rna-seq-data-analysis#step1)
- [Bioinformatics Core (Cambridge) — RNAseq in R](https://bioinformatics-core-shared-training.github.io/RNAseq-R/)
- [NYU GenCore — RNA-Seq analysis](https://learn.gencore.bio.nyu.edu/rna-seq-analysis/)
</details>

---

## Step 1 — Inspect the raw data

It's always worth looking at your data by eye before running anything. The reads live in the `data` folder.

The FASTQ files are compressed with `gzip` (they end in `.gz`), so they aren't directly human-readable — plain `cat`/`head` would print gibberish (don't panic if you see `<��xT�r-�B7�...`, that's expected!). Instead, use **`zcat`** (from Part 1), which reads gzipped files.

> 🍎 **On a Mac?** In Codespaces (Linux) `zcat` reads `.gz` files directly. macOS's `zcat` is different — it expects a `.Z` file and will error on `.gz`. If you're following along locally on a Mac, use **`gzcat`** (or `gunzip -c`) everywhere this page says `zcat`.

> ▶️ **Challenge — inspect a FASTQ file**
>
> Try to answer these two questions from the data:
>
> 1. How many lines are in the FASTQ file?
> 2. What is the length of the reads?
>
> Use these commands:
>
> ```bash
> zcat data/SRR6357070_1.fastq.gz | wc -l
> zcat data/SRR6357070_1.fastq.gz | head -n 2 | tail -n 1 | tr -d '\n' | wc -c
> ```
>
> <details>
> <summary>✅ Answer</summary>
>
> ```
> 200000
> 101
> ```
>
> The first command shows there are `200000` lines in the file. A FASTQ record uses **4 lines per read**, so that corresponds to `50000` reads. The second command uses `head` and `tail` to grab the second line of the file, which is the first read sequence, and `wc -c` counts the number of characters in it. We add `tr -d '\n'` to strip the trailing newline first — without it, `wc -c` would also count the line break and report `102`. So the reads are `101` bases long. There are many ways to do this, and even copying the file into an editor and looking at it manually is fine.
> </details>

### Structure of a typical FASTQ file

Each read in a FASTQ file is stored as four lines:

1. **Header line** — starts with `@` and contains the read identifier.
2. **Sequence line** — the DNA or RNA bases for that read.
3. **Separator line** — a single `+`, often followed by the same read identifier.
4. **Quality line** — one character of quality score per base, usually in ASCII.

For example:

```text
@SRR6357070.1 1/1
GATCGGAAGAGCACACGTCTGAACTCCAGTCAC...
+
AAAAEEEEEEEEEEEEEEEEEEEEEEEEEEEE...
```

This layout is important because it lets the pipeline keep the sequence and its quality information together for every read.

---

## Step 2 — Explore the pipeline's requirements

Go to the nf-core/rnaseq page and read what the pipeline does and what inputs it expects: 👉 **https://nf-co.re/rnaseq/3.14.0**

<img src="img/image.png" alt="nf-core/rnaseq usage page" width="700"/>

<details>
<summary>Cheat sheet — what the pipeline needs</summary>

To run nf-core/rnaseq you need three things:

* a **genome** (in FASTA format)
* an **annotation** (in GTF or GFF format) — tells the pipeline where the genes are
* an **input samplesheet** (CSV) that links to your raw RNA-Seq FASTQ data
</details>

> 💡 **What the pipeline will do for you** (automatically, in containers): quality-check the reads (FastQC), trim adapters (Trim Galore), align to the genome (STAR), quantify gene expression (Salmon), and summarise everything into one report (MultiQC). That's a lot of tools you *don't* have to install yourself!

---

## Step 3 — Build the samplesheet

The **samplesheet** is a CSV file that tells the pipeline which files belong to which sample. Create a file called `samplesheet.csv` in the `eco-flow-training` folder (e.g. with `nano samplesheet.csv`).

It has four columns:

| Column | Meaning |
| --- | --- |
| `sample` | A name you choose for the sample (must match across replicates you want grouped) |
| `fastq_1` | Full path to the forward reads (R1) |
| `fastq_2` | Full path to the reverse reads (R2) — **leave empty for single-end** samples |
| `strandedness` | Library strandedness — use `auto` to let the pipeline detect it |

> ⚠️ **Paired vs single-end:** samples SRR6357070–072 are paired-end (fill both `fastq_1` and `fastq_2`); SRR6357073–075 are single-end (fill `fastq_1`, leave `fastq_2` blank — note the trailing comma).

> 💡 **For larger projects:** if you had hundreds of samples, creating a samplesheet by hand would be tedious. nf-core/rnaseq includes a helper script, [fastq_dir_to_samplesheet.py](https://github.com/nf-core/rnaseq/blob/master/bin/fastq_dir_to_samplesheet.py), that can scan a folder of FASTQ files and generate a samplesheet automatically. In this example, you would point it at the folder containing the FASTQ files (for example the `data` directory), and it would infer sample names and pair files such as `_1` and `_2` together. You would still want to inspect the generated CSV to make sure the sample names and single-end/paired-end rows look correct before using it.
>
> If you wanted to try it yourself, you could download the script and run it like this:
>
> ```bash
> curl -L https://raw.githubusercontent.com/nf-core/rnaseq/master/bin/fastq_dir_to_samplesheet.py -o fastq_dir_to_samplesheet.py
> python3 fastq_dir_to_samplesheet.py \
>   /workspaces/training/eco-flow-training/data \
>   /workspaces/training/eco-flow-training/samplesheet.csv \
>   -r1 _1.fastq.gz \
>   -r2 _2.fastq.gz
> ```
>
> This scans the `data` directory, infers sample names from the FASTQ filenames, and writes a CSV that you can inspect and adjust before using it. Because this example dataset mixes paired-end and single-end reads, it is worth checking the generated file carefully and renaming samples if you want to match the `CONTROL_REP*` / `MANIPULATED_REP*` names used later in the course.

Try to build the samplesheet yourself using the [example on the nf-core page](https://nf-co.re/rnaseq/3.14.0/docs/usage#samplesheet-input) as a guide to build the 3 wild type and 3 knock down samples, then compare with the cheat sheet.

<details>
<summary>Cheat sheet — full samplesheet.csv</summary>

```csv
sample,fastq_1,fastq_2,strandedness
CONTROL_REP1,/workspaces/training/eco-flow-training/data/SRR6357070_1.fastq.gz,/workspaces/training/eco-flow-training/data/SRR6357070_2.fastq.gz,auto
CONTROL_REP2,/workspaces/training/eco-flow-training/data/SRR6357071_1.fastq.gz,/workspaces/training/eco-flow-training/data/SRR6357071_2.fastq.gz,auto
CONTROL_REP3,/workspaces/training/eco-flow-training/data/SRR6357072_1.fastq.gz,/workspaces/training/eco-flow-training/data/SRR6357072_2.fastq.gz,auto
MANIPULATED_REP1,/workspaces/training/eco-flow-training/data/SRR6357073_1.fastq.gz,,auto
MANIPULATED_REP2,/workspaces/training/eco-flow-training/data/SRR6357074_1.fastq.gz,,auto
MANIPULATED_REP3,/workspaces/training/eco-flow-training/data/SRR6357075_1.fastq.gz,,auto
```

The `CONTROL_*` samples are the wild-type (paired-end) and `MANIPULATED_*` are the Rap1 knock-downs (single-end). **Keep these sample names** — Part 4 (differential expression) reuses them.
</details>

> 💡 **Paths must be absolute.** The paths above are the Codespaces location. On a local machine, replace `/workspaces/training/eco-flow-training` with the output of your own `pwd`.

---

## Step 4 — Download the genome and annotation

The pipeline needs a reference **genome** (FASTA) and **annotation** (GFF). Download both into the `eco-flow-training` folder (the same place as your samplesheet) using `wget` (from Part 1):

```bash
wget -O genome.fasta https://raw.githubusercontent.com/nf-core/test-datasets/7f1614baeb0ddf66e60be78c3d9fa55440465ac8/reference/genome.fasta
wget -O genes.gff.gz https://raw.githubusercontent.com/nf-core/test-datasets/7f1614baeb0ddf66e60be78c3d9fa55440465ac8/reference/genes.gff.gz
```

> ▶️ **Check the downloads**
>
> ```bash
> ls -lh genome.fasta genes.gff.gz
> ```
>
> <details>
> <summary>✅ Expected output</summary>
>
> Both files should be listed with a non-zero size:
>
> ```
> -rw-r--r-- 1 user user  ...  genome.fasta
> -rw-r--r-- 1 user user  ...  genes.gff.gz
> ```
>
> If a file is 0 bytes or missing, the download failed — check your internet connection and re-run the `wget`.
> </details>

> 💡 The `-O` flag names the downloaded file. The genome is the yeast reference sequence; the GFF lists where each gene sits on that sequence.

---

## Step 5 — Run the pipeline

Now run nf-core/rnaseq, pointing it at your genome (`--fasta`), annotation (`--gff`), samplesheet (`--input`) and an output directory name (`--outdir`, choose anything).

Read the official run instructions here: https://nf-co.re/rnaseq/3.14.0/docs/usage

Two extra flags you **must** include in this environment:

- **`-profile docker`** — runs every step inside its Docker container, so you don't have to install any of the underlying tools. (On an HPC you'd use `-profile singularity` or `apptainer` instead — ask your HPC team.)
- **`-c .../codespaces.config`** — a small custom config that adapts the pipeline to the tiny Codespaces machine. Without it the run is likely to fail. See below for exactly what it does.

We also pin the pipeline version with **`-r 3.14.0`** so you get exactly the version this course was written for.

> 💡 **Why pin the version?** Without `-r`, Nextflow runs the *latest* revision of the pipeline. Pipeline parameters change between releases (options get renamed or removed), so an un-pinned command can silently break over time. Pinning to `3.14.0` guarantees this exact command keeps working — pinning is the safe choice, not a risky one.

#### What is the `codespaces.config` and why do we need it?

nf-core pipelines ship with sensible **default** resource requests — but those defaults assume a beefy server. A GitHub Codespace is a small machine (about **2 CPUs and 8 GB RAM**), so several steps would ask for more memory or CPUs than exist and the run would crash. The config file solves this. Open it (`cat codespaces.config`) and you'll see:

```groovy
process {
    resourceLimits {
        memory = '6.GB'   // never request more than 6 GB for any step
        cpus   = 2        // never request more than 2 CPUs
        time   = '1.h'    // cap each step at 1 hour
    }
}

params {
    skip_markduplicates = true   // skip a memory-heavy step we don't need here
}
```

- **`resourceLimits`** is a Nextflow feature that *caps* each step's request. If the pipeline asks a step for 12 GB, Nextflow quietly clamps it down to our 6 GB limit so it still fits on the machine.
- **`skip_markduplicates = true`** turns off the duplicate-marking step. It's memory-hungry and not needed for this teaching example, so skipping it keeps the run fast and stable on the small machine.

> 📝 On your own laptop or an HPC you generally **wouldn't** need this file — you'd let the pipeline use its defaults, or write a config tuned to *your* machine. It exists purely to make the pipeline fit inside Codespaces.

<details>
<summary>Cheat sheet — the full command</summary>

```bash
nextflow run nf-core/rnaseq \
-r 3.14.0 \
-profile docker \
-c /workspaces/training/eco-flow-training/codespaces.config \
--input /workspaces/training/eco-flow-training/samplesheet.csv \
--gff /workspaces/training/eco-flow-training/genes.gff.gz \
--fasta /workspaces/training/eco-flow-training/genome.fasta \
--outdir my_results
```

The `\` at the end of each line just lets one command span several lines for readability.
</details>

> 👉 **Single vs double dashes matter!** A single dash (`-profile`, `-r`, `-c`, `-resume`) is a **Nextflow** core option. A double dash (`--input`, `--fasta`, `--outdir`) is a **pipeline** parameter defined inside nf-core/rnaseq.

> ✅ **What success looks like:** Nextflow prints a banner and then a live list of processes as they run — something like:
>
> ```
>  N E X T F L O W   ~  version 24.x.x
>  Launching `https://github.com/nf-core/rnaseq` [gigantic_newton] ...
>  executor >  local
>  [a1/b2c3d4] NFCORE_RNASEQ:...:FASTQC (CONTROL_REP1)   [100%] 6 of 6 ✔
>  [e5/f6a7b8] NFCORE_RNASEQ:...:STAR_ALIGN (...)         [ 50%] 3 of 6
>  ...
> ```
>
> This run takes roughly **10–20 minutes** on the small test data — leave it running. The first time, Nextflow also downloads the containers, which adds a few minutes.

### Troubleshooting Step 5

If the run stops with an error, it's almost always one of these:

<details>
<summary>❌ <code>Missing required parameter: --input</code> / <code>--outdir</code></summary>

You didn't supply one of the required parameters. Check every `--input`, `--fasta`, `--gff` and `--outdir` is present and spelled correctly.
</details>

<details>
<summary>❌ <code>Not a valid path value: 'genes.gff.gz'</code></summary>

A path is wrong or not absolute. Provide the **full** path, e.g. `/workspaces/training/eco-flow-training/genes.gff.gz`, and confirm the file exists with `ls -l`.
</details>

<details>
<summary>❌ <code>.command.sh: line 7: fastqc: command not found</code> (exit status 127)</summary>

You forgot **`-profile docker`**. Without it, Nextflow looks for the tools installed locally — but they aren't. Adding `-profile docker` makes each step run inside a container that already has the tool.
</details>

If you get a different error, grab a tutor.

---

## Step 6 — Explore the results

Once the pipeline finishes (`Pipeline completed successfully`), look inside your `--outdir` folder (`my_results`).

> ▶️ **See what was produced**
>
> ```bash
> ls my_results
> ```
>
> <details>
> <summary>✅ Roughly what you'll see</summary>
>
> ```
> fastqc  multiqc  pipeline_info  star_salmon  trimgalore  ...
> ```
>
> Each folder holds the output of one stage of the pipeline.
> </details>

The full catalogue of outputs is documented here: https://nf-co.re/rnaseq/3.14.0/docs/output — spend ~10 minutes skimming it while the run finishes.

**The two things to look at first:**

1. **The MultiQC report** — `my_results/multiqc/star_salmon/multiqc_report.html`. This single HTML page summarises quality and alignment across *all* samples. To view it in Codespaces, right-click the file in the Explorer and choose **"Open with Live Server"** (the extension is pre-installed), or download it (right-click → Download) and open it in your browser.

2. **The FastQC results** — under `my_results/fastqc/`. Check whether the raw reads were good quality. This guide explains how to read the FastQC plots and quality scores: https://bioinfo.cd-genomics.com/quality-control-how-do-you-read-your-fastqc-results.html

> 🧬 **The key file for Part 4:** the gene-count table lives at
> `my_results/star_salmon/salmon.merged.gene_counts.tsv`.
> You'll load this into R in the next section to find differentially expressed genes.

We'll discuss the reports together in class.

---

## Step 7 — Resuming a run and changing options

Real analyses are rarely run just once — you tweak options and re-run. Two things make that painless.

### Changing an option

The pipeline has many options. For example, you can switch the alignment/quantification tools to STAR + RSEM with `--aligner star_rsem` (see the [alignment options docs](https://nf-co.re/rnaseq/3.14.0/docs/usage#alignment-options)). Work out how you'd modify your command — **but don't run it yet:**

<details>
<summary>Answer — the modified command</summary>

```bash
nextflow run nf-core/rnaseq \
-r 3.14.0 \
-profile docker \
-c /workspaces/training/eco-flow-training/codespaces.config \
--input /workspaces/training/eco-flow-training/samplesheet.csv \
--gff /workspaces/training/eco-flow-training/genes.gff.gz \
--fasta /workspaces/training/eco-flow-training/genome.fasta \
--outdir my_results \
--aligner star_rsem
```

(Note the `\` after `--outdir my_results` — every line except the last needs one, or the `--aligner` option would be dropped.)
</details>

### The `-resume` flag

Add **`-resume`** and Nextflow will reuse the **cached** results of any steps that haven't changed, instead of recomputing them from scratch. If you re-run the command above with `-resume`, only the steps affected by the new `--aligner` option need to re-run — everything before that is pulled from the cache.

> ✅ **What you'll see with `-resume`:** unchanged processes are marked as cached, e.g.
>
> ```
> [a1/b2c3d4] NFCORE_RNASEQ:...:FASTQC (CONTROL_REP1)  [100%] 6 of 6, cached: 6 ✔
> ```
>
> The word **`cached`** tells you Nextflow skipped the real work and reused the previous result — a huge time-saver during development.

---

## Finish

🎉 **You've finished the course!** You've run a complete, reproducible RNA-Seq pipeline — from raw reads to gene counts and quality reports — using industry-standard nf-core tooling.

**Next steps:**

- Continue to **[Part 4 · Differential expression ▶️](./differential.md)** to analyse the gene counts you just produced.
- Running on a cluster? See the bonus **[Running a pipeline on an HPC](./hpc.md)**.
- Learn to **write** your own Nextflow: the excellent [Seqera training](https://training.nextflow.io/).
- Eco-Flow will be providing more foundational Nextflow courses soon — email us to join the mailing list: **ecoflow . ucl @ gmail . com**

---

🧭 [◀️ Part 2 · Pipelines](./pipelines.md) &nbsp;|&nbsp; [🏠 Course menu](../README.md) &nbsp;|&nbsp; **Next:** [Part 4 · Differential expression ▶️](./differential.md)
