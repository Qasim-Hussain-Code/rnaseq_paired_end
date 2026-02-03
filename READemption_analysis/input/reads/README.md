# Reads Directory

This directory contains RNA-seq read files for READemption analysis.

## Contents

After running `02_bbmap_reademption_pipeline.sh`, this directory will contain:

- **control_r1.fastq.gz** - Control condition, biological replicate 1
- **control_r2.fastq.gz** - Control condition, biological replicate 2
- **apigennin_r1.fastq.gz** - Apigenin treatment, biological replicate 1
- **apigennin_r2.fastq.gz** - Apigenin treatment, biological replicate 2
- **salt_r1.fastq.gz** - Salt stress, biological replicate 1
- **salt_r2.fastq.gz** - Salt stress, biological replicate 2

## File Format

- **Format**: FASTQ (gzip compressed)
- **Type**: Single-end reads (merged from paired-end)
- **Encoding**: Phred+33 quality scores

## File Sizes

These files are excluded from Git:
- ~300-500 MB per file
- **Total: ~2-3 GB**

## Source

These files are automatically copied from `fastq_raw/merged/` directory after BBMap merging.

## Regenerating

Run the pipeline script:
```bash
./02_bbmap_reademption_pipeline.sh
```

Files are copied during the "READemption Project Setup" stage.
