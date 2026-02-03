#!/bin/bash

################################################################################
# RNA-Seq Data Download and Preparation Script
# 
# Description: Downloads raw RNA-seq reads, reference genome, and annotation
#              files. Organizes them into appropriate directories for analysis.
#
# Author: Qasim Hussain
# Date: February 2026
# Project: Rhizobium tropici CIAT 899 RNA-Seq Analysis
################################################################################

set -e  # Exit on error
set -u  # Exit on undefined variable

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging function
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

################################################################################
# SECTION 1: Download Reference Genome and Annotation
################################################################################

log_info "====================================================================="
log_info "RNA-Seq Data Download and Preparation"
log_info "====================================================================="
log_info "Started at: $(date)"
log_info ""

# Create reference_sequences directory
log_info "Creating reference_sequences directory..."
mkdir -p reference_sequences

# Download reference genome
log_info "Downloading reference genome..."
if [ ! -f "reference_sequences/GCF_000330885.1_ASM33088v1_genomic.fna.gz" ]; then
    wget -nc -P reference_sequences \
        https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/330/885/GCF_000330885.1_ASM33088v1/GCF_000330885.1_ASM33088v1_genomic.fna.gz
    log_info "Reference genome downloaded."
else
    log_info "Reference genome already exists. Skipping download."
fi

# Download annotation file
log_info "Downloading annotation file..."
if [ ! -f "reference_sequences/GCF_000330885.1_ASM33088v1_genomic.gff.gz" ]; then
    wget -nc -P reference_sequences \
        https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/330/885/GCF_000330885.1_ASM33088v1/GCF_000330885.1_ASM33088v1_genomic.gff.gz
    log_info "Annotation file downloaded."
else
    log_info "Annotation file already exists. Skipping download."
fi

# Decompress reference genome
log_info "Decompressing reference genome..."
if [ ! -f "reference_sequences/GCF_000330885.1_ASM33088v1_genomic.fna" ]; then
    gunzip -c reference_sequences/GCF_000330885.1_ASM33088v1_genomic.fna.gz > \
        reference_sequences/GCF_000330885.1_ASM33088v1_genomic.fna
    log_info "Reference genome decompressed."
else
    log_info "Reference genome already decompressed. Skipping."
fi

# Decompress annotation file
log_info "Decompressing annotation file..."
if [ ! -f "reference_sequences/GCF_000330885.1_ASM33088v1_genomic.gff" ]; then
    gunzip -c reference_sequences/GCF_000330885.1_ASM33088v1_genomic.gff.gz > \
        reference_sequences/GCF_000330885.1_ASM33088v1_genomic.gff
    log_info "Annotation file decompressed."
else
    log_info "Annotation file already decompressed. Skipping."
fi

################################################################################
# SECTION 2: Download Raw Reads from ENA
################################################################################

log_info ""
log_info "====================================================================="
log_info "Downloading Raw RNA-Seq Reads"
log_info "====================================================================="

# Create fastq_raw directory
log_info "Creating fastq_raw directory..."
mkdir -p fastq_raw
cd fastq_raw

# Download raw reads from ENA (European Nucleotide Archive)
# Project: PRJNA305690
# Rhizobium tropici CIAT 899 response to apigenin and salt stress

log_info "Downloading paired-end reads..."
log_info "This may take some time depending on your connection speed."
log_info ""

# Control replicate 1 (SRR3036912)
if [ ! -f "SRR3036912_1.fastq.gz" ] && [ ! -f "control_r1_p1.fastq.gz" ]; then
    log_info "Downloading Control Replicate 1..."
    wget -nc ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR303/002/SRR3036912/SRR3036912_1.fastq.gz
    wget -nc ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR303/002/SRR3036912/SRR3036912_2.fastq.gz
fi

# Control replicate 2 (SRR3031958)
if [ ! -f "SRR3031958_1.fastq.gz" ] && [ ! -f "control_r2_p1.fastq.gz" ]; then
    log_info "Downloading Control Replicate 2..."
    wget -nc ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR303/008/SRR3031958/SRR3031958_1.fastq.gz
    wget -nc ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR303/008/SRR3031958/SRR3031958_2.fastq.gz
fi

# Apigenin replicate 1 (SRR3036915)
if [ ! -f "SRR3036915_1.fastq.gz" ] && [ ! -f "apigennin_r1_p1.fastq.gz" ]; then
    log_info "Downloading Apigenin Replicate 1..."
    wget -nc ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR303/005/SRR3036915/SRR3036915_1.fastq.gz
    wget -nc ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR303/005/SRR3036915/SRR3036915_2.fastq.gz
fi

# Apigenin replicate 2 (SRR3031957)
if [ ! -f "SRR3031957_1.fastq.gz" ] && [ ! -f "apigennin_r2_p1.fastq.gz" ]; then
    log_info "Downloading Apigenin Replicate 2..."
    wget -nc ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR303/007/SRR3031957/SRR3031957_1.fastq.gz
    wget -nc ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR303/007/SRR3031957/SRR3031957_2.fastq.gz
fi

# Salt replicate 1 (SRR3062176)
if [ ! -f "SRR3062176_1.fastq.gz" ] && [ ! -f "salt_r1_p1.fastq.gz" ]; then
    log_info "Downloading Salt Replicate 1..."
    wget -nc ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR306/006/SRR3062176/SRR3062176_1.fastq.gz
    wget -nc ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR306/006/SRR3062176/SRR3062176_2.fastq.gz
fi

# Salt replicate 2 (SRR3032151)
if [ ! -f "SRR3032151_1.fastq.gz" ] && [ ! -f "salt_r2_p1.fastq.gz" ]; then
    log_info "Downloading Salt Replicate 2..."
    wget -nc ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR303/001/SRR3032151/SRR3032151_1.fastq.gz
    wget -nc ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR303/001/SRR3032151/SRR3032151_2.fastq.gz
fi

################################################################################
# SECTION 3: Rename Files for Analysis
################################################################################

log_info ""
log_info "====================================================================="
log_info "Renaming Files for Analysis"
log_info "====================================================================="

# Rename files to descriptive names
# Format: condition_replicate_pair.fastq.gz

# Control
if [ -f "SRR3036912_1.fastq.gz" ] && [ ! -f "control_r1_p1.fastq.gz" ]; then
    log_info "Renaming control replicate 1..."
    mv SRR3036912_1.fastq.gz control_r1_p1.fastq.gz
    mv SRR3036912_2.fastq.gz control_r1_p2.fastq.gz
fi

if [ -f "SRR3031958_1.fastq.gz" ] && [ ! -f "control_r2_p1.fastq.gz" ]; then
    log_info "Renaming control replicate 2..."
    mv SRR3031958_1.fastq.gz control_r2_p1.fastq.gz
    mv SRR3031958_2.fastq.gz control_r2_p2.fastq.gz
fi

# Apigenin
if [ -f "SRR3036915_1.fastq.gz" ] && [ ! -f "apigennin_r1_p1.fastq.gz" ]; then
    log_info "Renaming apigenin replicate 1..."
    mv SRR3036915_1.fastq.gz apigennin_r1_p1.fastq.gz
    mv SRR3036915_2.fastq.gz apigennin_r1_p2.fastq.gz
fi

if [ -f "SRR3031957_1.fastq.gz" ] && [ ! -f "apigennin_r2_p1.fastq.gz" ]; then
    log_info "Renaming apigenin replicate 2..."
    mv SRR3031957_1.fastq.gz apigennin_r2_p1.fastq.gz
    mv SRR3031957_2.fastq.gz apigennin_r2_p2.fastq.gz
fi

# Salt
if [ -f "SRR3062176_1.fastq.gz" ] && [ ! -f "salt_r1_p1.fastq.gz" ]; then
    log_info "Renaming salt replicate 1..."
    mv SRR3062176_1.fastq.gz salt_r1_p1.fastq.gz
    mv SRR3062176_2.fastq.gz salt_r1_p2.fastq.gz
fi

if [ -f "SRR3032151_1.fastq.gz" ] && [ ! -f "salt_r2_p1.fastq.gz" ]; then
    log_info "Renaming salt replicate 2..."
    mv SRR3032151_1.fastq.gz salt_r2_p1.fastq.gz
    mv SRR3032151_2.fastq.gz salt_r2_p2.fastq.gz
fi

cd ..

################################################################################
# SECTION 4: Verify Downloads
################################################################################

log_info ""
log_info "====================================================================="
log_info "Verifying Downloads"
log_info "====================================================================="

# Check reference files
if [ -f "reference_sequences/GCF_000330885.1_ASM33088v1_genomic.fna" ]; then
    log_info "✓ Reference genome: OK"
else
    log_error "✗ Reference genome: MISSING"
fi

if [ -f "reference_sequences/GCF_000330885.1_ASM33088v1_genomic.gff" ]; then
    log_info "✓ Annotation file: OK"
else
    log_error "✗ Annotation file: MISSING"
fi

# Check raw reads
log_info ""
log_info "Checking raw reads..."
reads_ok=0
reads_total=12

for sample in control_r1 control_r2 apigennin_r1 apigennin_r2 salt_r1 salt_r2; do
    if [ -f "fastq_raw/${sample}_p1.fastq.gz" ] && [ -f "fastq_raw/${sample}_p2.fastq.gz" ]; then
        log_info "✓ ${sample}: OK"
        ((reads_ok+=2))
    else
        log_error "✗ ${sample}: MISSING"
    fi
done

################################################################################
# SECTION 5: Summary
################################################################################

log_info ""
log_info "====================================================================="
log_info "Download and Preparation Summary"
log_info "====================================================================="
log_info "Reference files: 2/2"
log_info "Raw read files: ${reads_ok}/${reads_total}"
log_info ""

if [ $reads_ok -eq $reads_total ]; then
    log_info "All files downloaded successfully!"
    log_info ""
    log_info "File Structure:"
    log_info "  reference_sequences/"
    log_info "    ├── GCF_000330885.1_ASM33088v1_genomic.fna    (reference genome)"
    log_info "    ├── GCF_000330885.1_ASM33088v1_genomic.gff    (annotation)"
    log_info "    ├── GCF_000330885.1_ASM33088v1_genomic.fna.gz (compressed)"
    log_info "    └── GCF_000330885.1_ASM33088v1_genomic.gff.gz (compressed)"
    log_info ""
    log_info "  fastq_raw/"
    log_info "    ├── control_r1_p1.fastq.gz & control_r1_p2.fastq.gz"
    log_info "    ├── control_r2_p1.fastq.gz & control_r2_p2.fastq.gz"
    log_info "    ├── apigennin_r1_p1.fastq.gz & apigennin_r1_p2.fastq.gz"
    log_info "    ├── apigennin_r2_p1.fastq.gz & apigennin_r2_p2.fastq.gz"
    log_info "    ├── salt_r1_p1.fastq.gz & salt_r1_p2.fastq.gz"
    log_info "    └── salt_r2_p1.fastq.gz & salt_r2_p2.fastq.gz"
    log_info ""
    log_info "Next step: Run 02_bbmap_reademption_pipeline.sh"
else
    log_warn "Some files are missing. Please check the errors above."
    exit 1
fi

log_info "====================================================================="
log_info "Completed at: $(date)"
log_info "====================================================================="
