<div align="center">

<img src="https://github.com/Eco-Flow/training/assets/9978862/93440255-55bc-4769-9b47-c49fafc161d3" width="90" alt="Eco-Flow logo">

# Eco-Flow Basic Nextflow Training

**A hands-on course that takes you from limited bioinformatics experience to running your own nf-core pipelines.**

Everything runs in the browser via GitHub Codespaces — nothing to install.

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/Eco-Flow/training)

🌐 **Prefer a rendered site?** [Take the course at eco-flow.github.io/training](https://eco-flow.github.io/training/)

</div>

---

## 📚 Course outline

Work through it top to bottom — or jump to whatever you need.

| Part | Lesson | Type | What you'll do |
| :--: | :----- | :--- | :------------- |
| **0** | [Setup](./eco-flow-training/docs/setup.md) | Practical | Get your environment ready with GitHub Codespaces, so you can run everything from your browser. |
| **1** | [Command line basics](./eco-flow-training/docs/commandline.md) | Practical · optional | A gentle introduction to the command line. Skip this part if you're already comfortable in a terminal. |
| **2** | [Pipelines with Nextflow](./eco-flow-training/docs/pipelines.md) | Lecture | What Nextflow and nf-core are, and why pipelines matter for reproducible, scalable science. |
| **3** | [Run an nf-core RNA-Seq pipeline](./eco-flow-training/docs/nfcore_rnaseq.md) | Practical | Hands-on — run a real nf-core/rnaseq analysis end to end, from raw reads to results. |
| **4** | [Differential expression](./eco-flow-training/docs/differential.md) | Practical · R | Analyse the gene counts from Part 3 with DESeq2 to find differentially expressed genes. |
| **5** | [Run an nf-core ampliseq pipeline](./eco-flow-training/docs/nfcore_ampliseq.md) | Practical · 🚧 draft | Run a real nf-core/ampliseq analysis on amplicon sequencing data. |
| **6** | [Run nanoporemetabarcoding pipeline](./eco-flow-training/docs/nanopore_metabarcoding.md) | Practical | Run the nanopore metabarcoding pipeline. |
| **7** | [Interacting with code on GitHub](./eco-flow-training/docs/github_basics.md) | Practical | Issues, Pull Requests, READMEs and Claude Code — how to report, fix and contribute changes, using the nanopore pipeline as the example. |
| **8** | [Running a pipeline on an HPC](./eco-flow-training/docs/hpc.md) | Practical · optional | Turn your Codespace into a working Slurm cluster and run an nf-core pipeline through it — submit and watch jobs, let Nextflow do the submitting, keep a run alive, then see what changes on your own cluster. No HPC account needed. |
| **9** | [Monitoring runs with Seqera Platform](./eco-flow-training/docs/seqera_platform.md) | Practical · optional | Follow your runs live in the browser with Seqera Platform, from Codespaces or your HPC, plus an overview of launching pipelines from it. |
| **★** | [Advanced: setting up Nextflow for your HPC](./eco-flow-training/docs/hpc_config.md) | Advanced · optional | Write a config for a Slurm/SGE cluster that doesn't have one yet — talk to your admin, adapt a config, and test it. |

> 🚧 **Part 5** is still a draft, and the **★ Advanced HPC** page is optional reference material for people setting up a cluster config — if you just want to run a pipeline on your cluster, start with **Part 8**.

---

## 🚀 Get started

1. Click **[Open in GitHub Codespaces](https://codespaces.new/Eco-Flow/training)** above (or use the green **Code → Codespaces** button).
2. Wait a minute or two for the environment to build — Nextflow, Java, Docker and all the data are pre-installed.
3. Begin with **[Part 0 · Setup](./eco-flow-training/docs/setup.md)**.

## 🌱 About Eco-Flow

Eco-Flow builds reproducible bioinformatics pipelines and provides foundational, hands-on Nextflow and nf-core training. Want to hear about future courses? Email us to join the mailing list: **ecoflow . ucl @ gmail . com**

## 📖 Further learning

- **Official Nextflow training** — https://training.nextflow.io/
- **nf-core community & pipelines** — https://nf-co.re/

<div align="center">

🌳 🌳 🌳

</div>
