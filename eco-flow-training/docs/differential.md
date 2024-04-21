# Differential gene expression

Now that we have run the nf-core RNA-Seq pipeline, we have the raw counts needed to run differential expression using DESeq2.

## Prerequisites

Before we start this section, we assume you know basic `R`. If not I would recommend (https://swirlstats.com/)

We also would recommend reading the full docs for DESeq2 [here](https://www.bioconductor.org/packages/release/bioc/vignettes/DESeq2/inst/doc/DESeq2.html)

## Our data

Following on from the previous section, we have 3 wild type and 3 manipulated cell samples. 

We want to normalise the effects of gene size and of total number of counts in each samples, in order to determin if there is a consistent difference in expression leves of all the genes in the genome.

We need to normalise:

* Gene size , as larger genes will be more likely to have mapped reads.
* Total counts, as some samples (n=6) could have more RNA-Seq reads than other others.

## How to get the data into `R`

### Load from nf-core output

The simplest way to get the data into R from nf-core RNA-Seq is to use the `load` function in R.
