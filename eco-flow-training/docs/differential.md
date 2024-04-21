# Differential gene expression

Now that we have run the nf-core RNA-Seq pipeline, we have the raw counts needed to run differential expression using DESeq2.

## Prerequisites

Before we start this section, we assume you know basic `R`. 
If not I would recommend [swirl](https://swirlstats.com/)

We also would recommend reading the full docs for DESeq2 [here](https://www.bioconductor.org/packages/release/bioc/vignettes/DESeq2/inst/doc/DESeq2.html)

## Our data

Following on from the previous section, we have 3 wild type and 3 manipulated cell samples. 

We want to normalise the effects of gene size and of total number of counts in each samples, in order to determin if there is a consistent difference in expression leves of all the genes in the genome.

We need to normalise:

* Gene size , as larger genes will be more likely to have mapped reads.
* Total counts, as some samples (n=6) could have more RNA-Seq reads than other others.

## How to get the data into `R`

To get the data into R from nf-core RNA-Seq, we can use either the `load` function in R or `read.csv`.

### Load from nf-core output

nf-core has a Rdata file, which can be loaded into R: `<outdir_name>/Salmon/Rdata`. If you used the default settings in nfcore rnaseq, if you chose a different aligner (e.g. `--aligner star_rsem`), then you would look in the `rsem` folder.

Then in `R`, type:

`load ("star_salmon/deseq2_qc/deseq2_dds.Rdata")`

Now you have the `dds` and `coldata` input required by DESeq2.

### Load from the raw counts

The raw counts that DESeq2 requires are here: `<outdir_name>/salmon/salmon.merged.gene_counts.tsv`. If you used the default settings in nf-core rnaseq, if you chose a different aligner (e.g. `--aligner star_rsem`), then you would look in the `rsem` folder.

`cts <- read.csv("salmon.merged.gene_counts.tsv", h=T, row.names=1, sep="\t")`
#Read in the tab separated file, with first line as header, and first row as row names.


## Running differential expression


```
#Load the DEseq2 library
library(DESeq2)

# Load the data into a DESeq data object, including the counts, column data (groups) and experimental design.
dds <- DESeqDataSetFromMatrix(countData = cts,
                              colData = coldata,
                              design= ~ batch + condition)
```


R
```
# Run DEseq
dds <- DESeq(dds)
resultsNames(dds) # lists the coefficients
res <- results(dds, name="condition_trt_vs_untrt")
# or to shrink log fold changes association with condition:
res <- lfcShrink(dds, coef="condition_trt_vs_untrt", type="apeglm")
```
