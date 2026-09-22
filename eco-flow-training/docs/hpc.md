# Running a pipeline on an HPC

🧭 [◀️ Part 6 · GitHub](./github_basics.md) &nbsp;|&nbsp; [🏠 Course menu](../README.md) &nbsp;|&nbsp; **Next:** [Part 8 · Seqera Platform ▶️](./seqera_platform.md)

🚀 **Start now:** [![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/Eco-Flow/training) — *first launch takes a couple of minutes to build.*

---

⏱ **Estimated time:** ~30–40 minutes &nbsp;•&nbsp; 🟡 Practical · optional

> 🎯 **Who is this for?** Anyone who wants to run an nf-core pipeline on their institution's **High-Performance Computing (HPC) cluster**, where Nextflow is already available or your cluster already has a ready-made config on [nf-co.re/configs](https://nf-co.re/configs). You **don't** need to write a cluster config for this page.
>
> - 🖥️ **No cluster?** You can still do most of this page in Codespaces, on a tiny practice Slurm "cluster" you start with one command.
> - 🛠️ **Need to *build* a config for a cluster that doesn't have one yet?** That's the separate ★ [Advanced: setting up Nextflow for your HPC](./hpc_config.md) page.

Throughout this page, command blocks are marked:

- 🖥️ **Try it here in Codespaces**
- 🏢 **On your cluster**: for when you're logged in to a real HPC

### What you'll learn

- How Nextflow runs differently on a cluster (login node, scheduler, compute nodes)
- What to check before your first run, and where your files should live
- Two ways to get a pipeline: `nextflow run nf-core/…` vs `git clone`
- How a pipeline decides what resources each step asks for
- How to submit and watch jobs with a scheduler (Slurm, with SGE equivalents)
- How to smoke-test a run, then keep a long run alive after you log out
- The common gotchas, as a checklist

---

## Step 0 — How Nextflow runs on a cluster

> 🚧 **To be written.** Login node vs compute nodes, the scheduler, the long-lived Nextflow *driver*, and the shared `work/` directory, with one small diagram. Ties back to Part 2: the pipeline doesn't change, only *where* it runs.

---

## Step 1 — Before you start 🏢

> 🚧 **To be written.** A short checklist (log in with `ssh`, check Nextflow/Java, check Singularity/Apptainer, look for your institution on nf-co.re/configs) and a mini-table of where files should live (work dir, container cache, results).

---

## Step 2 — Getting a pipeline, and a quick look inside 🖥️

> 🚧 **To be written.**
> - **Way A:** `nextflow run nf-core/rnaseq -r 3.14.0`, where Nextflow downloads the pipeline for you.
> - **Way B:** `git clone` the pipeline and run `main.nf`, for when you need to edit it, run a non-nf-core pipeline, or have offline compute nodes.
> - A quick look inside: how a step's `label` decides the CPUs, memory and time it asks for.

---

## Step 3 — Practise on a mini-cluster in Codespaces 🖥️

> 🚧 **To be written.** Start a one-node Slurm "cluster" with `bash hpc/start_slurm.sh`, then try `sinfo`, `sbatch`, `squeue` and `scancel`.

---

## Step 4 — Smoke test: Nextflow submitting jobs

> 🚧 **To be written.** Run `nf-core/demo` with the Slurm executor (🖥️), then the same idea on your cluster (🏢). Check for `executor > slurm` (not `local`) and watch the jobs appear in the queue.

---

## Step 5 — A real run: keeping Nextflow alive

> 🚧 **To be written.** Submit the Nextflow driver itself as a job (🖥️ practice, then 🏢 Slurm/SGE scripts). Covers `tmux`/`screen` and `-bg`, plus stopping and `-resume`-ing a run.

---

## Step 6 — What to look out for ✅

> 🚧 **To be written.** A checklist of the common HPC gotchas.

---

## Finish

> 🚧 **To be written.**

**Next steps:**

- Continue to **[Part 8 · Seqera Platform ▶️](./seqera_platform.md)** to watch your runs live in the browser.
- Your cluster has no ready-made config? See ★ **[Advanced: setting up Nextflow for your HPC](./hpc_config.md)**.

---

🧭 [◀️ Part 6 · GitHub](./github_basics.md) &nbsp;|&nbsp; [🏠 Course menu](../README.md) &nbsp;|&nbsp; **Next:** [Part 8 · Seqera Platform ▶️](./seqera_platform.md)
