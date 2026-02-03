# RNA-Seq Analysis Pipeline

## Project Overview

This repository contains a comprehensive RNA-seq analysis pipeline. The pipeline processes paired-end RNA-seq data from raw reads through differential expression analysis and visualization.

### Data Source

- **Project**: PRJNA305690
- **Organism**: Rhizobium tropici CIAT 899
- **Sequencing**: Illumina paired-end RNA-seq
- **Samples**: 6 samples (3 conditions × 2 biological replicates)

## Pipeline Components

### 1. Data Download and Preparation (`01_download_data.sh`)

Downloads and prepares all necessary input files:

- Reference genome (Rhizobium tropici CIAT 899)
- Genome annotation (GFF format)
- Raw RNA-seq reads from ENA

**Samples**:
- Control: replicate 1 (SRR3036912), replicate 2 (SRR3031958)
- Apigenin: replicate 1 (SRR3036915), replicate 2 (SRR3031957)
- Salt: replicate 1 (SRR3062176), replicate 2 (SRR3032151)

### 2. Analysis Pipeline (`02_bbmap_reademption_pipeline.sh`)

Complete analysis workflow:

1. **Read Merging** (BBMap)
   - Merges overlapping paired-end reads
   - Repairs corrupted read pairs (if any)
   - Produces single-end merged reads for analysis

2. **Read Alignment** (SEGEMEHL via READemption)
   - Aligns reads to reference genome
   - High accuracy alignment (95%)
   - Poly-A tail clipping
   - Quality filtering (min Phred score: 20)

3. **Coverage Analysis** (READemption)
   - Generates coverage tracks
   - Strand-specific coverage information

4. **Gene Quantification** (READemption)
   - Counts reads per gene
   - Quantifies CDS, tRNA, and rRNA features

5. **Differential Expression** (DESeq2 via READemption)
   - Statistical analysis of gene expression changes
   - Multiple condition comparisons
   - Cooks cutoff disabled for small sample sizes

6. **Visualization** (READemption)
   - Alignment quality plots
   - Gene expression visualizations
   - Differential expression visualizations

## Requirements

### System Requirements

- **Operating System**: Linux (Ubuntu 20.04+ or similar)
- **RAM**: Minimum 8GB, 16GB recommended
- **Swap Space**: 8GB recommended (prevents OOM kills)
- **Disk Space**: ~50GB for full analysis
- **CPU**: Multi-core processor (4+ cores recommended)

### Software Requirements

#### Conda

Install Miniconda or Anaconda:

```bash
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh
```

#### Required Conda Environments

The scripts will automatically create these environments:

1. **bbmap**: For read merging and repair
   ```bash
   conda create -n bbmap bioconda::bbmap -y
   ```

2. **reademption**: For RNA-seq analysis
   ```bash
   conda create -n reademption bioconda::reademption -y
   ```

## Installation

1. Clone or download this repository:
   ```bash
   git clone <repository-url>
   cd rnaseq_paired_end
   ```

2. Make scripts executable:
   ```bash
   chmod u+x 01_download_data.sh
   chmod u+x 02_bbmap_reademption_pipeline.sh
   ```

3. Ensure conda is initialized in your shell:
   ```bash
   conda init bash
   source ~/.bashrc
   ```

## Usage

### Step 1: Download Data

Download reference genome, annotation, and raw reads:

```bash
./01_download_data.sh
```

This will create:
- `reference_sequences/` - Reference genome and annotation
- `fastq_raw/` - Raw paired-end RNA-seq reads

**Time**: 30-60 minutes (depending on internet connection)

### Step 2: Run Analysis Pipeline

Execute the complete analysis pipeline:

```bash
./02_bbmap_reademption_pipeline.sh
```

This will:
- Merge paired-end reads
- Align reads to the genome
- Calculate coverage
- Quantify gene expression
- Perform differential expression analysis
- Generate visualizations

**Time**: 2-3 hours on a modern system with sufficient RAM

### Running in Background

For long-running analyses, use nohup to run in the background:

```bash
nohup ./02_bbmap_reademption_pipeline.sh > pipeline.log 2>&1 &
```

Monitor progress:
```bash
tail -f pipeline.log
```

## Output Structure

```
READemption_analysis/
├── input/
│   ├── reads/                           # Input reads
│   ├── rhizobium_reference_sequences/   # Reference genome
│   └── rhizobium_annotations/           # GFF annotation
│
└── output/
    ├── align/
    │   ├── alignments/                  # BAM alignment files
    │   ├── reports_and_stats/           # Alignment statistics
    │   └── index/                       # Genome index
    │
    ├── coverage/
    │   └── coverage-tnoar_reverse/      # Coverage wiggle files
    │
    ├── rhizobium_gene_quanti_combined/
    │   └── gene_wise_quantifications_combined.csv  # Gene counts
    │
    ├── rhizobium_deseq/
    │   ├── deseq_raw/                   # DESeq2 R scripts and data
    │   └── deseq_extended/              # Extended DESeq2 results
    │
    ├── rhizobium_viz_align/             # Alignment visualizations
    ├── rhizobium_viz_gene_quanti/       # Expression heatmaps
    └── rhizobium_viz_deseq/             # Differential expression plots
```

## Key Output Files

### Alignment Statistics
- `READemption_analysis/output/align/reports_and_stats/read_alignment_stats.csv`
  - Mapping rates, uniquely mapped reads, multi-mappers

### Gene Expression
- `READemption_analysis/output/rhizobium_gene_quanti_combined/gene_wise_quantifications_combined.csv`
  - Read counts per gene for all samples

### Differential Expression
- `READemption_analysis/output/rhizobium_deseq/deseq_extended/`
  - Contains pairwise comparisons (e.g., apigennin_vs_control)
  - Fold changes, p-values, adjusted p-values
  - Files: `*_with_annotation.csv`

### Visualizations
- Alignment quality plots (PNG format)
- Expression plots
- MA plots and volcano plots

## Interpreting Results

### 1. Check Alignment Quality

Review `read_alignment_stats.csv`:
- Target: >95% aligned reads
- Low alignment may indicate contamination or wrong reference

### 2. Gene Expression Analysis

Examine `gene_wise_quantifications_combined.csv`:
- Compare read counts across conditions
- Look for genes with high variation between conditions

### 3. Differential Expression

Navigate to `rhizobium_deseq/deseq_extended/`:
- **Significant genes**: padj < 0.05 (adjusted p-value)
- **Strong effects**: abs(log2FoldChange) > 1 (2-fold change)
- **Upregulated**: log2FoldChange > 0
- **Downregulated**: log2FoldChange < 0

Example filtering in R:
```R
# Read results
results <- read.csv("apigennin_vs_control_with_annotation.csv")

# Filter significant genes (padj < 0.05, |log2FC| > 1)
significant <- subset(results, padj < 0.05 & abs(log2FoldChange) > 1)

# Upregulated in apigennin
upregulated <- subset(significant, log2FoldChange > 1)

# Downregulated in apigennin
downregulated <- subset(significant, log2FoldChange < -1)
```

## Troubleshooting

```
### Low Alignment Rates

**Possible causes**:
- Contamination
- Poor quality reads
- Wrong reference genome

**Diagnostics**:
1. Check FASTQ quality with FastQC
2. Verify reference genome identity
3. Check for adapter sequences

### Conda Environment Issues

If conda environments fail to activate:

```bash
# Reinitialize conda
conda init bash
source ~/.bashrc

# Recreate environments
conda env remove -n bbmap
conda env remove -n reademption
conda create -n bbmap bioconda::bbmap -y
conda create -n reademption bioconda::reademption -y
```

### Disk Space Issues

Monitor disk usage:
```bash
df -h
du -sh READemption_analysis/output/*
```

Large intermediate files are automatically cleaned during the pipeline.

## Pipeline Optimization

### For Systems with More RAM (>16GB)

Edit `02_bbmap_reademption_pipeline.sh` and increase processes:

```bash
# Change from:
--processes 1

# To:
--processes 2  # or more, depending on available cores
```

### For Faster Analysis

Use SSD storage for better I/O performance.

## Citation

If you use this pipeline, please cite:

### READemption
- Förstner KU, Vogel J, Sharma CM. READemption - a tool for the computational analysis of deep-sequencing-based transcriptome data. Bioinformatics. 2014;30(23):3421-3423.

### BBMap
- Bushnell B. BBMap: A Fast, Accurate, Splice-Aware Aligner. Lawrence Berkeley National Lab, 2014.

### DESeq2
- Love MI, Huber W, Anders S. Moderated estimation of fold change and dispersion for RNA-seq data with DESeq2. Genome Biology. 2014;15(12):550.

### SEGEMEHL
- Hoffmann S, Otto C, Kurtz S, et al. Fast mapping of short sequences with mismatches, insertions and deletions using index structures. PLoS Comput Biol. 2009;5(9):e1000502.

## Project Structure

```
rnaseq_paired_end/
├── 01_download_data.sh              # Data download script
├── 02_bbmap_reademption_pipeline.sh # Analysis pipeline
├── README.md                         # This file
├── .gitignore                        # Git ignore rules
│
├── reference_sequences/              # Reference genome and annotation
│   ├── GCF_000330885.1_ASM33088v1_genomic.fna
│   ├── GCF_000330885.1_ASM33088v1_genomic.gff
│   └── README.md                     # Placeholder for large files
│
├── fastq_raw/                        # Raw and merged reads
│   ├── merged/                       # Merged single-end reads
│   └── README.md                     # Placeholder for large files
│
├── READemption_analysis/             # Analysis outputs
│   └── README.md                     # Placeholder for large files
│
└── manuscript/                       # Documentation and reports
```

## License

This pipeline is provided as-is for academic and research purposes.

## Acknowledgments

- Data from NCBI BioProject PRJNA305690
- Tools: READemption, BBMap, DESeq2, SEGEMEHL
- Reference genome: NCBI RefSeq GCF_000330885.1
---

**Note**: This pipeline was optimized for systems with 8-16GB RAM. The single-process execution prevents memory issues and BAM file corruption that can occur with parallel processing on limited-RAM systems.
