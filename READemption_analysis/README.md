# READemption Analysis Output

This directory contains all outputs from the RNA-seq analysis pipeline using READemption.

## Contents

After running `02_bbmap_reademption_pipeline.sh`, this directory will contain:

### Directory Structure

```
READemption_analysis/
├── config.json                          # READemption configuration
├── input/                               # Input files (kept in Git)
│   ├── reads/                          # Merged FASTQ reads
│   ├── rhizobium_reference_sequences/  # Reference genome
│   └── rhizobium_annotations/          # GFF annotation
│
└── output/                              # Analysis outputs (excluded from Git)
    ├── align/                          # Alignment results
    ├── coverage/                       # Coverage tracks
    ├── rhizobium_gene_quanti_combined/ # Gene quantification
    ├── rhizobium_deseq/                # Differential expression
    ├── rhizobium_viz_align/            # Alignment visualizations
    ├── rhizobium_viz_gene_quanti/      # Expression heatmaps
    └── rhizobium_viz_deseq/            # DESeq2 visualizations
```

## File Sizes

Output files are excluded from Git due to size limitations:

- **align/**: ~10-15 GB (BAM files, index, unaligned reads)
- **coverage/**: ~2-3 GB (wiggle files)
- **gene_quanti_combined/**: ~1 MB (CSV files, kept in Git)
- **deseq/**: ~5-10 MB (results CSV, kept in Git)
- **visualizations/**: ~10-50 MB (PNG/PDF, kept in Git)

**Total directory size: ~15-20 GB**

## Regenerating Outputs

To regenerate all analysis outputs:

```bash
cd /path/to/rnaseq_paired_end

# First, ensure raw data is downloaded
./01_download_data.sh

# Then run the complete analysis pipeline
./02_bbmap_reademption_pipeline.sh
```

**Time required**: 2-3 hours on a system with 8-16 GB RAM

## Key Output Files

### 1. Alignment Statistics

**Location**: `output/align/reports_and_stats/read_alignment_stats.csv`

Contains:
- Number of reads processed
- Aligned reads (uniquely and multi-mapped)
- Unaligned reads
- Alignment rate percentage

Expected alignment rates: >95%

### 2. BAM Alignment Files

**Location**: `output/align/alignments/*.bam`

Files:
- `control_r1_alignments_final.bam`
- `control_r2_alignments_final.bam`
- `apigennin_r1_alignments_final.bam`
- `apigennin_r2_alignments_final.bam`
- `salt_r1_alignments_final.bam`
- `salt_r2_alignments_final.bam`

Each BAM file has a corresponding `.bam.bai` index file for fast access.

**Size**: ~1-2 GB per file

### 3. Coverage Tracks

**Location**: `output/coverage/coverage-tnoar_reverse/`

Wiggle format files showing coverage across the genome for each sample.

**Size**: ~300-500 MB per file

### 4. Gene Quantification

**Location**: `output/rhizobium_gene_quanti_combined/gene_wise_quantifications_combined.csv`

CSV file with read counts for each gene across all samples.

Columns:
- Feature (gene ID)
- Attributes (gene name, product)
- Counts for each sample

**This file is kept in Git** (usually <1 MB)

### 5. Differential Expression Results

**Location**: `output/rhizobium_deseq/deseq_extended/`

Pairwise comparison files:
- `apigennin_vs_control_with_annotation.csv`
- `salt_vs_control_with_annotation.csv`
- `salt_vs_apigennin_with_annotation.csv`

Each file contains:
- Gene ID and annotation
- Base mean expression
- Log2 fold change
- Standard error
- p-value
- Adjusted p-value (padj)

**These files are kept in Git** (typically 1-5 MB each)

### 6. Visualizations

**Alignment Quality** (`output/rhizobium_viz_align/`)
- Read alignment statistics
- Alignment rate plots
- Multi-mapping statistics

**Expression Heatmaps** (`output/rhizobium_viz_gene_quanti/`)
- Gene expression patterns across samples
- Hierarchical clustering
- Sample correlation heatmaps

**Differential Expression** (`output/rhizobium_viz_deseq/`)
- MA plots (log fold change vs. mean expression)
- Volcano plots (fold change vs. p-value)
- PCA plots

**Visualization files are kept in Git** (PNG/PDF format, typically 100-500 KB each)

## File Formats

### BAM (.bam)
Binary Alignment/Map format - compressed SAM files containing aligned reads.

### Wiggle (.wig)
Text-based format for genome coverage data, viewable in genome browsers.

### CSV (.csv)
Comma-separated values for quantification and statistical results.

### PNG/PDF
Image formats for visualizations.

## Using the Results

### Viewing Alignments

Use IGB (Integrative Genomics Browser) or similar tools:

1. Load reference genome (`.fna` file)
2. Load annotation (`.gff` file)
3. Load BAM files
4. Visualize coverage tracks

### Analyzing Differential Expression

In R:
```R
# Load results
results <- read.csv("output/rhizobium_deseq/deseq_extended/apigennin_vs_control_with_annotation.csv")

# Filter significant genes (adjusted p-value < 0.05)
significant <- subset(results, padj < 0.05)

# Filter for strong effects (|log2FC| > 1)
strong_effects <- subset(significant, abs(log2FoldChange) > 1)

# Upregulated genes
upregulated <- subset(strong_effects, log2FoldChange > 0)

# Downregulated genes
downregulated <- subset(strong_effects, log2FoldChange < 0)
```

In Python:
```python
import pandas as pd

# Load results
results = pd.read_csv("output/rhizobium_deseq/deseq_extended/apigennin_vs_control_with_annotation.csv")

# Filter significant genes
significant = results[results['padj'] < 0.05]

# Strong effects
strong_effects = significant[abs(significant['log2FoldChange']) > 1]

# Upregulated
upregulated = strong_effects[strong_effects['log2FoldChange'] > 0]

# Downregulated
downregulated = strong_effects[strong_effects['log2FoldChange'] < 0]
```

### Creating Custom Visualizations

Gene expression heatmaps, volcano plots, and pathway enrichment analyses can be created using the quantification and DESeq2 result files.

## Disk Space Management

If disk space is limited:

1. **Keep essential files**:
   - Gene quantification CSV
   - DESeq2 results CSV
   - Visualizations (PNG/PDF)

2. **Delete if needed**:
   - BAM files (can be regenerated)
   - Coverage wiggle files (can be regenerated)
   - Unaligned reads (usually not needed)
   - Index files (can be regenerated)

To clean up large intermediate files:
```bash
# Remove BAM files (keep statistics)
rm -f READemption_analysis/output/align/alignments/*.bam*

# Remove coverage files
rm -rf READemption_analysis/output/coverage/

# Remove unaligned reads
rm -f READemption_analysis/output/align/unaligned_reads/*.fa
```

## Troubleshooting

### Missing Output Files

If expected outputs are missing:
1. Check the pipeline log for errors
2. Verify input files are present
3. Ensure sufficient disk space
4. Re-run the pipeline script

### Corrupted BAM Files

If BAM files are corrupted:
- Usually caused by insufficient memory or interrupted processes
- Ensure 8 GB swap space is configured
- Re-run the alignment step

### Low Alignment Rates

If alignment rates are <80%:
- Check FASTQ quality (run FastQC)
- Verify reference genome is correct
- Check for adapter contamination
- Review trimming parameters

## Pipeline Performance

Typical processing times (system with 8-16 GB RAM):
- **Read merging**: 30-60 minutes
- **Alignment**: 60-90 minutes
- **Coverage**: 10-20 minutes
- **Quantification**: 5-10 minutes
- **DESeq2**: 5-10 minutes
- **Visualizations**: 10-20 minutes

**Total**: 2-3 hours

## Memory Requirements

- **Alignment**: 5-8 GB RAM (peak)
- **Coverage**: 2-4 GB RAM
- **Quantification**: 1-2 GB RAM
- **DESeq2**: 1-2 GB RAM

**Recommended**: 16 GB RAM + 8 GB swap for smooth operation

## Additional Resources

- READemption documentation: https://reademption.readthedocs.io/
- SEGEMEHL aligner: https://www.bioinf.uni-leipzig.de/Software/segemehl/
- DESeq2 manual: https://bioconductor.org/packages/release/bioc/html/DESeq2.html
