# Annotations Directory

This directory contains genome annotation for READemption analysis.

## Contents

After running `02_bbmap_reademption_pipeline.sh`, this directory will contain:

- **GCF_000330885.1_ASM33088v1_genomic.gff** - *Rhizobium tropici* CIAT 899 genome annotation

## File Information

- **Format**: GFF3 (General Feature Format version 3)
- **Size**: ~3 MB (excluded from Git)
- **Organism**: Rhizobium tropici CIAT 899
- **Features**: Genes, CDS, tRNA, rRNA, and other genomic features
- **Genes**: ~6,289 protein-coding genes
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

This annotation is used by READemption for:
1. Gene quantification (counting reads per gene)
2. Feature-specific analysis (CDS, tRNA, rRNA)
3. Annotating differential expression results
4. Generating gene-level visualizations
