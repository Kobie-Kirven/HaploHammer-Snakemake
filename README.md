# HaploHammer-Snakemake
### A Snakemake wrapper for the HaploHammer pipeline 


The [HaploHammer](https://github.com/StructureFold2/HaploHammer) pipeline parses haplotypes from VCF files. The purpose of this Snakemake wrapper is to facilitate the use of HaploHammer for population-level VCF files and to eliminate the need to install any dependencies, including python 2. 

## Pre-requisites
Before running the pipeline, you must have the following installed:
* [Snakemake](https://snakemake.readthedocs.io/en/stable/getting_started/installation.html)
* [conda](https://docs.conda.io/projects/conda/en/latest/user-guide/install/index.html)

## Installation
To install the pipeline, simply clone the repository:
```
git clone https://github.com/Kobie-Kirven/HaploHammer-Snakemake.git
```

## Usage
Before running the pipeline, you must first edit the config file and fill in the fields. NOTE: All paths must be absolute paths (meaning they must start with a `/`).

Example:
```
# VCF file to be analyzed
vcf: /Users/path/to/vcf/file.vcf.gz
```

Once the config file is filled out, you can run the pipeline using the following command:
```
snakemake --use-conda --conda-frontend conda --cores <number of cores>
```

And that's it! The pipeline will run and output will be an `allele_matrix.csv` file in the specified output directory.


