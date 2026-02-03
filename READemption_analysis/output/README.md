# READemption Output Directory

This directory contains all analysis results from the READemption pipeline.

## Directory Structure

```
output/
├── align/                           # Alignment results (~10-15 GB)
│   ├── alignments/                  # BAM files
│   ├── index/                       # Genome index
│   ├── reports_and_stats/           # Statistics (kept in Git)
│   └── unaligned_reads/             # Unaligned sequences
│
├── rhizobium_coverage-*/            # Coverage tracks (~2-3 GB)
│
├── rhizobium_gene_quanti_combined/  # Gene counts (kept in Git)
│
├── rhizobium_gene_quanti_per_lib/   # Per-library counts
│
├── rhizobium_deseq/                 # DESeq2 results (kept in Git)
│   ├── deseq_raw/                   # R scripts and raw data
│   └── deseq_with_annotations/      # Annotated results
│
├── rhizobium_viz_align/             # Alignment plots (kept in Git)
├── rhizobium_viz_gene_quanti/       # Expression heatmaps (kept in Git)
└── rhizobium_viz_deseq/             # DESeq2 plots (kept in Git)
```

## File Sizes

- **Total directory size**: ~15-20 GB
- **Excluded from Git**: BAM files, coverage files, index files
- **Kept in Git**: Statistics CSV, result CSV, visualizations (PNG/PDF)

## Regenerating All Outputs

To regenerate the complete output directory:

```bash
# Ensure input data exists
./01_download_data.sh

# Run complete pipeline
./02_bbmap_reademption_pipeline.sh
```

**Time required**: 2-3 hours

## Key Output Directories

### align/
Contains alignment results from SEGEMEHL aligner.
- See [align/README.md](align/README.md) for details

### Coverage
Multiple coverage directories with different normalizations:
- `rhizobium_coverage-raw` - Raw coverage
- `rhizobium_coverage-tnoar_mil_normalized` - Million-reads normalized
- `rhizobium_coverage-tnoar_min_normalized` - Minimum normalized

### Gene Quantification
- `rhizobium_gene_quanti_combined/` - Combined counts across samples
- `rhizobium_gene_quanti_per_lib/` - Individual library counts

### Differential Expression
- `rhizobium_deseq/` - DESeq2 statistical analysis results

### Visualizations
- `rhizobium_viz_align/` - Alignment quality plots
- `rhizobium_viz_gene_quanti/` - Expression heatmaps
- `rhizobium_viz_deseq/` - Differential expression plots

## Important Files

The following small result files are kept in the Git repository:

1. **Alignment statistics**:
   - `align/reports_and_stats/read_alignment_stats.csv`

2. **Gene expression**:
   - `rhizobium_gene_quanti_combined/gene_wise_quantifications_combined.csv`

3. **Differential expression**:
   - `rhizobium_deseq/deseq_with_annotations/*_with_annotation.csv`

4. **Visualizations**:
   - All PNG and PDF files in `*_viz_*` directories

## Disk Space Management

If disk space is limited, you can delete large intermediate files after analysis:

```bash
# Remove BAM files (can be regenerated)
rm -rf READemption_analysis/output/align/alignments/
rm -rf READemption_analysis/output/align/index/

# Remove coverage files (can be regenerated)
rm -rf READemption_analysis/output/rhizobium_coverage-*/

# Remove unaligned reads
rm -rf READemption_analysis/output/align/unaligned_reads/
```

**Keep**: Statistics, quantification results, DESeq2 results, and visualizations (typically <100 MB total).
