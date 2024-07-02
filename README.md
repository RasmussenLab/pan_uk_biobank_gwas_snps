# MOVE on UK Biobank

This repository aggregates SNPs across the high-quality GWAS results of the Pan-UK Biobank project.
Using a threshold of `-log10(p-value) > 16`, and using all high-quality GWAS the aggregated 
file with -log10 pvalues contains X SNPs from Y studies.


## Setup

Using anaconda for environments

```bash
conda create -n ukbio python pip pandas ipykernel
conda install -c conda-forge -c bioconda snakemake
```

## Single GWAS results

The high-quality GWAS can be downloaded using the [Snakemake workflow](Snakefile). An overview
of the single GWAS results of the 
[Pan-UK Biobank project](https://pan.ukbb.broadinstitute.org/docs/per-phenotype-files/index.html#high-quality-meta-analysis-fields)
can be found
[here](https://docs.google.com/spreadsheets/d/1AeeADtT0U1AukliiNyiVzVRdLYPkTbruQSk38DeutU8/edit#gid=1450719288)

I provided a brief script which creates a `config/high_quality_gwas.yaml` file for 
the [Snakemake workflow](Snakefile) in [`0_get_high_quality_gwas.py`](0_get_high_quality_gwas.py).

## Snakemake

The Snakemake workflow can be executed using the following command with one job at a time:

```bash
snakemake -c1 -n # dry-run
snakemake -c1 # run
```

## Slurm cluster script

The slurm script can be used to run the Snakemake workflow on a slurm cluster:
[`bin/slurm_execute.sh`](bin/slurm_execute.sh).

