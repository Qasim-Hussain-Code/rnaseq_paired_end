# Alignment Results Directory

This directory contains read alignment results from SEGEMEHL aligner via READemption.

## Directory Structure

```
align/
├── alignments/              # BAM alignment files (~10-12 GB)
├── index/                   # Genome index files (~2 GB)
├── processed_reads/         # Processed read files
├── reports_and_stats/       # Statistics and reports (kept in Git)
└── unaligned_reads/         # Unaligned sequences (~500 MB)
```

## Contents

### alignments/
BAM files for each sample (excluded from Git):
- control_r1_alignments_final.bam
- control_r1_alignments_final.bam.bai
- control_r2_alignments_final.bam
- control_r2_alignments_final.bam.bai
- apigennin_r1_alignments_final.bam
- apigennin_r1_alignments_final.bam.bai
- apigennin_r2_alignments_final.bam
- apigennin_r2_alignments_final.bam.bai
- salt_r1_alignments_final.bam
- salt_r1_alignments_final.bam.bai
- salt_r2_alignments_final.bam
- salt_r2_alignments_final.bam.bai

**Size**: ~1-2 GB per BAM file

### index/
Genome index files created by SEGEMEHL (excluded from Git):
- index.idx

**Size**: ~2 GB

### reports_and_stats/
Alignment statistics and reports (kept in Git):
- read_alignment_stats.csv - Summary statistics for all samples
- stats_data_json/ - JSON format statistics

### unaligned_reads/
FASTA files with reads that failed to align (excluded from Git):
- control_r1_unaligned.fa
- control_r2_unaligned.fa
- apigennin_r1_unaligned.fa
- apigennin_r2_unaligned.fa
- salt_r1_unaligned.fa
- salt_r2_unaligned.fa

**Size**: Variable depending on alignment rate

## Expected Results

From the successful pipeline run:
- **Alignment rate**: 99.91-99.95%
- **Uniquely mapped**: >95%
- **Multi-mapped**: <5%
- **Unaligned**: <1%

## File Formats

### BAM (.bam)
Binary Alignment/Map format - compressed, indexed alignment files.

### BAI (.bam.bai)
BAM index files for fast random access.

### FASTA (.fa)
Unaligned sequences in FASTA format.

### CSV (.csv)
Comma-separated statistics files (kept in Git).

## Regenerating

Run the pipeline:
```bash
./02_bbmap_reademption_pipeline.sh
```

Alignment is performed in the "Read Alignment" stage with:
- SEGEMEHL aligner
- 95% accuracy
- Poly-A clipping enabled
- Minimum Phred score: 20
- Single process (prevents BAM corruption)

**Time**: 60-90 minutes

## Using BAM Files

### View with IGV
1. Download Integrative Genomics Viewer (IGV)
2. Load reference genome
3. Load BAM files
4. Visualize alignments

### Command-line tools
```bash
# View BAM header
samtools view -H control_r1_alignments_final.bam

# Count aligned reads
samtools view -c control_r1_alignments_final.bam

# Convert to SAM
samtools view control_r1_alignments_final.bam > control_r1.sam

# Get alignment statistics
samtools flagstat control_r1_alignments_final.bam
```
