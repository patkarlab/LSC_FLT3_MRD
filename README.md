# FLT_MRD pipeline

## Introduction

**FLT3_MRD** is a modular, computational pipeline for detection of Minimal Residual Disease(MRD) in Acute Myeloid Leukemia. The pipeline is implemented in Nextflow. It aligns DNA sequencing reads to human hg19 reference genome and detects Internal Tandem Duplication(ITD) events in the FLT-3 gene. Coverage over target regions is calculated using bedtools. The pipeline integrates the results of ITD detection tools(getitd, FLT3_ITD_ext, FiLT3R and VarScan) as well as the coverage information, for each sample into a single spreadsheet. Additional outputs are sorted, indexed bam files. 

---

## Pipeline summary

<p align="center">
<img src="./img/flt3_pipeline.png" width="800">
</p>

---

## Usage

The following parameters need to be modified in the `params` section of the `nextflow.config` -

- *genome* = Complete path to the human genome fasta file(hg19_all.fasta). Please ensure the FASTA index file(hg19_all.fasta .fai) and BWA index files(hg19_all.fasta.amb, hg19_all.fasta.ann, hg19_all.fasta.bwt, hg19_all.fasta.pac, hg19_all.fasta.sa) are also present in the same genome folder 

- *filt3r_ref* = path to FiLT3r reference fasta 'flt3_exon14-15.fa'

- *genome_minimap_getitd* = Human reference genome for Minimap2(hg37.fa) and its indices (hg19_all.fasta.map-ont.mmi)

- *bedfile* = bedfile containing the target regions

- *annovar_db* = Complete path to the humandb database folder for ANNOVAR (refer https://annovar.openbioinformatics.org/en/latest/user-guide/startup/ )

---

The list of adaptors required by Trimmomatic, `NexteraPE-PE.fa` & `TruSeq2-PE.fa` should be placed in the `./assets` folder. 

---

## Running the pipeline

1. Transfer the `fastq.gz` files to the `sequences/` folder.

2. The samplesheet is `samplesheet.csv`. The sample_ids, without the file extension, should be mentioned in samplesheet in the following format-
sample1
sample2
sample3
Please check for empty lines in the samplesheet before running the pipeline.


3. The pipeline can be run by running the command-

```bash
nextflow run FLT3_MRD.nf -entry FLT3_MRD -profile docker -resume -bg
```

---

## Output
The outputs are saved in `Final_output/` folder.

