# Merged Reads Directory

This directory contains merged paired-end RNA-seq reads produced by BBMap.

## Contents

After running `02_bbmap_reademption_pipeline.sh`, this directory will contain:

- **control_r1.fastq.gz** - Control replicate 1 (merged from paired-end reads)
- **control_r2.fastq.gz** - Control replicate 2 (merged from paired-end reads)
- **apigennin_r1.fastq.gz** - Apigenin replicate 1 (merged from paired-end reads)
- **apigennin_r2.fastq.gz** - Apigenin replicate 2 (merged from paired-end reads)
- **salt_r1.fastq.gz** - Salt stress replicate 1 (merged from paired-end reads)
- **salt_r2.fastq.gz** - Salt stress replicate 2 (merged from paired-end reads)

## File Sizes

These files are excluded from Git due to size limitations:
- Each merged file: ~300-500 MB
- **Total directory size: ~2-3 GB**

## How Merging Works

BBMap's `bbmerge.sh` tool:
1. Identifies overlapping regions between paired-end reads
2. Merges overlapping pairs into single reads
3. Retains both reads for non-overlapping pairs
4. Improves alignment accuracy for short insert fragments

### Benefits
- Longer effective read length for overlapping fragments
- Reduced sequencing errors (consensus from overlap)
- Better alignment to short genes
- Simplified downstream analysis (single-end workflow)

## Regenerating Files

These files are automatically generated when you run:

```bash
./02_bbmap_reademption_pipeline.sh
```

The script will:
1. Repair corrupted read pairs (if any)
2. Merge overlapping paired-end reads
3. Output merged single-end reads to this directory

**Time required**: 30-60 minutes

## Manual Generation

If you need to regenerate only the merged reads:

```bash
# Activate BBMap environment
conda activate bbmap

# Create output directory
mkdir -p fastq_raw/merged

# Merge each sample
for sample in control_r1 control_r2 apigennin_r1 apigennin_r2 salt_r1 salt_r2; do
    echo "Merging ${sample}..."
    
    # Repair pairs first
    repair.sh \
        in1=fastq_raw/${sample}_p1.fastq.gz \
        in2=fastq_raw/${sample}_p2.fastq.gz \
        out1=fastq_raw/${sample}_p1_repaired.fastq.gz \
        out2=fastq_raw/${sample}_p2_repaired.fastq.gz \
        outs=fastq_raw/${sample}_singletons.fastq.gz \
        repair
    
    # Merge overlapping reads
    bbmerge.sh \
        in1=fastq_raw/${sample}_p1_repaired.fastq.gz \
        in2=fastq_raw/${sample}_p2_repaired.fastq.gz \
        out=fastq_raw/merged/${sample}.fastq.gz \
        outu1=fastq_raw/${sample}_unmerged_p1.fastq.gz \
        outu2=fastq_raw/${sample}_unmerged_p2.fastq.gz \
        tossbrokenreads=t
    
    # Clean up intermediate files
    rm -f fastq_raw/${sample}_p*_repaired.fastq.gz \
          fastq_raw/${sample}_singletons.fastq.gz \
          fastq_raw/${sample}_unmerged_p*.fastq.gz
done

conda deactivate
```

## Usage in Pipeline

These merged reads are:
1. Copied to `READemption_analysis/input/reads/`
2. Aligned to the reference genome by READemption
3. Used for all downstream analyses (coverage, quantification, DESeq2)

No manual file handling required when using the provided scripts.
