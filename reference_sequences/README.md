# Reference Sequences Directory

This directory contains the reference genome and annotation files.

## Contents

After running `01_download_data.sh`, this directory will contain:

- **GCF_000330885.1_ASM33088v1_genomic.fna** - Reference genome sequence (FASTA format)
- **GCF_000330885.1_ASM33088v1_genomic.gff** - Genome annotation (GFF3 format)

## File Sizes

- Genome FASTA: ~6.9 MB
- Annotation GFF: ~3.3 MB

## Obtaining Files

### Option 1: Run the Download Script

```bash
cd /path/to/rnaseq_paired_end
./01_download_data.sh
```

The script will automatically download and decompress the files.

### Option 2: Manual Download

Download directly from NCBI:

**Reference Genome:**
```bash
wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/330/885/GCF_000330885.1_ASM33088v1/GCF_000330885.1_ASM33088v1_genomic.fna.gz
gunzip GCF_000330885.1_ASM33088v1_genomic.fna.gz
```

**Annotation:**
```bash
wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/330/885/GCF_000330885.1_ASM33088v1/GCF_000330885.1_ASM33088v1_genomic.gff.gz
gunzip GCF_000330885.1_ASM33088v1_genomic.gff.gz
```

## Reference Information

- **Organism**: Rhizobium tropici CIAT 899
- **Assembly**: GCF_000330885.1 (ASM33088v1)
- **Source**: NCBI RefSeq
- **Genome Size**: ~6.69 Mb
- **Genes**: ~6,289 protein-coding genes
- **Replicons**: Chromosome and plasmids

## File Format Details

### FASTA (.fna)
Standard nucleotide FASTA format with sequence headers and nucleotide sequences.

### GFF3 (.gff)
Tab-delimited annotation file with columns:
1. Sequence ID
2. Source
3. Feature type (gene, CDS, tRNA, rRNA, etc.)
4. Start position
5. End position
6. Score
7. Strand (+/-)
8. Phase
9. Attributes (ID, Name, product, etc.)

## Usage in Pipeline

These files are automatically copied to the READemption input directories:
- Genome → `READemption_analysis/input/rhizobium_reference_sequences/`
- Annotation → `READemption_analysis/input/rhizobium_annotations/`

No manual intervention required when using the provided scripts.
