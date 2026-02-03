# READemption Input Directory

This directory contains all input files required for the READemption RNA-seq analysis pipeline.

## Directory Structure

```
input/
├── reads/                           # RNA-seq reads (FASTQ)
├── rhizobium_reference_sequences/   # Reference genome (FASTA)
└── rhizobium_annotations/           # Genome annotation (GFF)
```

## Contents

These subdirectories are automatically populated by `02_bbmap_reademption_pipeline.sh`:

### reads/
Contains merged single-end FASTQ files:
- control_r1.fastq.gz
- control_r2.fastq.gz
- apigennin_r1.fastq.gz
- apigennin_r2.fastq.gz
- salt_r1.fastq.gz
- salt_r2.fastq.gz

**Source**: Copied from `fastq_raw/merged/` after BBMap merging

### rhizobium_reference_sequences/
Contains reference genome:
- GCF_000330885.1_ASM33088v1_genomic.fna

**Source**: Copied from `reference_sequences/`

### rhizobium_annotations/
Contains genome annotation:
- GCF_000330885.1_ASM33088v1_genomic.gff

**Source**: Copied from `reference_sequences/`

## File Sizes

All files are excluded from Git due to size limitations:
- Reads: ~2-3 GB total
- Reference genome: ~7 MB
- Annotation: ~3 MB

**Total directory size: ~2-3 GB**

## Regenerating Files

Run the complete pipeline:

```bash
./01_download_data.sh          # Downloads raw data
./02_bbmap_reademption_pipeline.sh  # Creates input structure
```

The pipeline script automatically:
1. Creates the input directory structure
2. Copies reference sequences and annotation
3. Copies merged reads
4. Validates all files are present

## READemption Requirements

READemption expects:
- Species-specific subdirectory for reference sequences (e.g., `rhizobium_reference_sequences/`)
- Species-specific subdirectory for annotations (e.g., `rhizobium_annotations/`)
- Read files directly in `reads/` (no subdirectories)
- FASTQ or FASTA format for reads (gzipped or uncompressed)

The naming convention used here (`rhizobium_*`) matches the species name used throughout the pipeline.
