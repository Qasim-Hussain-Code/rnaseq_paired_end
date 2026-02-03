# Reference Sequences Directory

This directory contains the reference genome for READemption analysis.

## Contents

After running `02_bbmap_reademption_pipeline.sh`, this directory will contain:

- **GCF_000330885.1_ASM33088v1_genomic.fna** - *Rhizobium tropici* CIAT 899 reference genome

## File Information

- **Format**: FASTA nucleotide format
- **Size**: ~7 MB (excluded from Git)
- **Organism**: Rhizobium tropici CIAT 899
- **Assembly**: GCF_000330885.1 (ASM33088v1)
- **Genome Size**: ~6.69 Mb
- **Source**: NCBI RefSeq

## Source

This file is automatically copied from `reference_sequences/` directory.

## Regenerating

Run the pipeline script:
```bash
./02_bbmap_reademption_pipeline.sh
```

The file is copied during the "READemption Project Setup" stage.

## READemption Usage

This genome is used by READemption for:
1. Building alignment index (SEGEMEHL)
2. Read alignment
3. Coverage calculation
4. Feature quantification
