##############################################################################
# Snakemake wrapper for running HaploHammer
#
# HaploHammer was obtained from https://github.com/StructureFold2/HaploHammer
#
# Author: Kobie Kirven (kjk6173@psu.edu)
# Assmann Lab
# The Pennsylvania State University
##############################################################################

# Import packages
import os 

# Config file
configfile: "config.yaml"

# Get the prefix of the vcf file
if config["vcf"] != "NA":
    prefix = config["vcf"].split("/")[-1].split(".")[0]
    ids = [line.strip("\n") for line in open(config["sample_ids"]).readlines()]
    vcf_manager_in = f'{config["output_dir"]}/vcf_splits'
    end = ".vcf.gz"

# Check to make sure if we are running on a Single VCF file or on a directory of VCF files
else:
    vcf_manager_in = f'{config["vcf_dir"]}'
    ids = [x.strip(".vcf") for x in os.listdir(config["vcf_dir"])]
    end = ".vcf"

# Rule ALL
rule all:
    input:
        f'{config["output_dir"]}/allele_matrix.csv'

# Split the VCF file into individual VCF files
rule split_vcf_files:
    input:
        config["vcf"]
    output:
        f'{config["output_dir"]}/vcf_splits/{{samp_name}}.vcf.gz'
    shell:
        "bcftools view -c1 -Oz -s {wildcards.samp_name} -o {output} {input}"

# Run the VCF manager rule 
rule vcf_manager:
    input:
        f'{vcf_manager_in}/{{sample}}{end}'
    output:
        f'{config["output_dir"]}/vcf_splits_haplo/{{sample}}_fixed_minQ30.vcf'
    params:
        f'{config["output_dir"]}'
    conda:
        "environment.yaml"
    shell:
        "HaploHammer/vcf_manager.py -single {input} -outdir {params} -extension gz && mv {params}/vcf_splits/{wildcards.sample}_fixed_minQ30.vcf {output}"


# Run the HaploHammer tool
rule haplohammer:
    input:
        vcf = f'{config["output_dir"]}/vcf_splits_haplo/{{samp_id}}_fixed_minQ30.vcf',
        reference = config["reference_genome"],
        gene_model = config["gene_model"]
    output:
        f'{config["output_dir"]}/haplohammer_output/{{samp_id}}_fixed_minQ30_RNA.fa'
    params:
        config["output_dir"]
    conda:
        "environment.yaml"
    shell:
        f"HaploHammer/haplo_hammer.py -single {{input.vcf}} -outdir {{params}} {{input.reference}} {{input.gene_model}} RNA && mv {{params}}/vcf_splits_haplo/{{wildcards.samp_id}}_fixed_minQ30_RNA.fa {{output}}"


# Generate allele matrix
rule allele_matrix:
    input:
        expand(f'{config["output_dir"]}/haplohammer_output/{{id}}_fixed_minQ30_RNA.fa', id=ids)
    output:
        f'{config["output_dir"]}/allele_matrix.csv'
    params:
        output = config["output_dir"],
        matrix = f'{config["output_dir"]}/allele_matrix'
    conda:
        "environment.yaml"
    shell:
        "cd haplohammer_output && ../HaploHammer/allele_matrix.py -matrix {params.matrix}"