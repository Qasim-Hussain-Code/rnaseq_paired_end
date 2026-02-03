#!/bin/bash

################################################################################
# BBMap Merging + READemption RNA-Seq Analysis Pipeline
# 
# Description: Complete RNA-Seq analysis pipeline including:
#              1. Read merging with BBMap
#              2. READemption alignment
#              3. Coverage analysis
#              4. Gene quantification
#              5. Differential expression analysis (DESeq2)
#              6. Visualizations
#
# Author: Qasim Hussain
# Date: February 2026
# Project: Rhizobium tropici CIAT 899 RNA-Seq Analysis
#
# Prerequisites:
#   - Conda environments: bbmap, reademption
#   - Input files prepared by 01_download_data.sh
#   - At least 8GB RAM + 8GB swap space recommended
################################################################################

set -e  # Exit on error
set -u  # Exit on undefined variable

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

log_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

################################################################################
# CONFIGURATION
################################################################################

# Memory and resource monitoring functions
check_memory() {
    echo "----------------------------------------"
    echo "Memory Status:"
    free -h | grep -E 'Mem|Swap'
    echo "----------------------------------------"
}

check_disk_space() {
    local available_gb=$(df -BG . | tail -1 | awk '{print $4}' | sed 's/G//')
    echo "Available disk space: ${available_gb}GB"
    if [ $available_gb -lt 10 ]; then
        log_warn "Low disk space! Less than 10GB available."
    fi
}

check_memory_available() {
    local available_mb=$(free -m | awk 'NR==2{print $7}')
    echo "Available memory: ${available_mb}MB"
}

################################################################################
# STARTUP CHECKS
################################################################################

log_info "====================================================================="
log_info "BBMap + READemption RNA-Seq Analysis Pipeline"
log_info "====================================================================="
log_info "Started at: $(date)"
log_info ""

check_memory
check_disk_space
log_info ""

# Verify input files exist
log_info "Verifying input files..."
if [ ! -d "fastq_raw" ] || [ ! -f "fastq_raw/control_r1_p1.fastq.gz" ]; then
    log_error "Input files not found! Please run 01_download_data.sh first."
fi

if [ ! -f "reference_sequences/GCF_000330885.1_ASM33088v1_genomic.fna" ]; then
    log_error "Reference genome not found! Please run 01_download_data.sh first."
fi

if [ ! -f "reference_sequences/GCF_000330885.1_ASM33088v1_genomic.gff" ]; then
    log_error "Annotation file not found! Please run 01_download_data.sh first."
fi

log_info "All input files verified."
log_info ""

################################################################################
# SECTION 1: BBMap Read Merging
################################################################################

log_step "====================================================================="
log_step "SECTION 1: BBMap Read Merging"
log_step "====================================================================="
log_info "Started at: $(date)"
log_info ""

# Initialize conda
eval "$(conda shell.bash hook)"

# Activate BBMap environment (create if needed)
if ! conda env list | grep -q "^bbmap "; then
    log_info "Creating BBMap conda environment..."
    conda create -n bbmap bioconda::bbmap -y
fi

conda activate bbmap

# Create output directory
reads="fastq_raw"
merged="$reads/merged"
mkdir -p "$merged"

log_info "Processing samples with BBMap..."
log_info ""

# Process each sample
for r1 in "$reads"/*_p1.fastq.gz; do
    sample=$(basename "$r1" _p1.fastq.gz)
    r2="$reads/${sample}_p2.fastq.gz"
    
    [ -f "$r2" ] || { log_warn "Missing pair for $r1"; continue; }

    # Output paths
    out_merged="$merged/${sample}_merged.fastq.gz"
    out_u1="$merged/${sample}_unmerged_1.fastq.gz"
    out_u2="$merged/${sample}_unmerged_2.fastq.gz"

    # Skip if already processed
    if [ -f "$merged/${sample}.fastq.gz" ]; then
        log_info "Sample $sample already merged. Skipping."
        continue
    fi

    log_info "Processing $sample..."
    check_memory_available

    # Check and repair corrupted paired files
    log_info "  Checking paired files for corruption..."
    repair.sh in1="$r1" in2="$r2" \
        out1="${reads}/${sample}_p1_repaired.fastq.gz" \
        out2="${reads}/${sample}_p2_repaired.fastq.gz" \
        outs="${reads}/${sample}_singletons.fastq.gz" \
        repair -Xmx4g 2>&1 | tee "${merged}/${sample}_repair.log" > /dev/null
    
    # Use repaired files if they exist
    if [ -f "${reads}/${sample}_p1_repaired.fastq.gz" ]; then
        r1_use="${reads}/${sample}_p1_repaired.fastq.gz"
        r2_use="${reads}/${sample}_p2_repaired.fastq.gz"
    else
        r1_use="$r1"
        r2_use="$r2"
    fi

    # Merge reads
    log_info "  Merging paired-end reads..."
    bbmerge.sh in1="$r1_use" in2="$r2_use" \
        out="$out_merged" outu1="$out_u1" outu2="$out_u2" \
        threads=1 tossbrokenreads=t 2>&1 | tee "${merged}/${sample}_merge.log" > /dev/null
    
    if [ $? -ne 0 ]; then
        log_error "Merging failed for $sample. Check ${merged}/${sample}_merge.log"
    fi
    
    # Rename merged file
    mv "$out_merged" "$merged/${sample}.fastq.gz"
    
    # Cleanup intermediate files
    rm -f "$out_u1" "$out_u2" "${merged}/${sample}_merge.log" "${merged}/${sample}_repair.log"
    if [ -f "$r1_use" ] && [ "$r1_use" != "$r1" ]; then
        rm -f "$r1_use" "$r2_use" "${reads}/${sample}_singletons.fastq.gz"
    fi
    
    log_info "  Completed $sample"
done

log_info ""
log_info "BBMap merging completed."
log_info "Merged reads: $merged/*.fastq.gz"
check_memory
log_info ""

################################################################################
# SECTION 2: READemption Project Setup
################################################################################

log_step "====================================================================="
log_step "SECTION 2: READemption Project Setup"
log_step "====================================================================="
log_info "Started at: $(date)"
log_info ""

conda activate reademption

# Remove existing READemption directory if it exists
if [ -d "READemption_analysis" ]; then
    log_warn "Removing existing READemption_analysis directory..."
    rm -rf READemption_analysis
fi

# Create READemption project structure
log_info "Creating READemption project..."
reademption create --project_path READemption_analysis \
    --species rhizobium="Rhizobium tropici CIAT 899"

# Copy reference files
log_info "Copying reference genome and annotation..."
cp reference_sequences/GCF_000330885.1_ASM33088v1_genomic.fna \
   READemption_analysis/input/rhizobium_reference_sequences/

cp reference_sequences/GCF_000330885.1_ASM33088v1_genomic.gff \
   READemption_analysis/input/rhizobium_annotations/

# Copy merged reads and rename
log_info "Copying merged reads..."
if ls "$merged"/*.fastq.gz 1> /dev/null 2>&1; then
    cp "$merged"/*.fastq.gz READemption_analysis/input/reads/
    log_info "Merged reads copied successfully."
else
    log_error "No merged files found in $merged/"
fi

log_info "READemption project setup complete."
log_info ""

################################################################################
# SECTION 3: Read Alignment
################################################################################

log_step "====================================================================="
log_step "SECTION 3: Read Alignment with SEGEMEHL"
log_step "====================================================================="
log_info "Started at: $(date)"
log_info ""

check_memory_available
check_disk_space

log_info "Running alignment (single process for stability)..."
log_info "This step may take 1-2 hours depending on your system."
log_info ""

reademption align --project_path READemption_analysis \
    --processes 1 \
    --segemehl_accuracy 95 \
    --poly_a_clipping \
    --fastq \
    --min_phred_score 20 \
    --progress

if [ $? -ne 0 ]; then
    log_error "Alignment failed. Check logs in READemption_analysis/output/align/"
fi

log_info "Alignment completed successfully."
check_memory
log_info ""

################################################################################
# SECTION 4: Coverage Analysis
################################################################################

log_step "====================================================================="
log_step "SECTION 4: Coverage Analysis"
log_step "====================================================================="
log_info "Started at: $(date)"
log_info ""

check_memory_available

log_info "Running coverage analysis..."
reademption coverage --project_path READemption_analysis --processes 1

if [ $? -ne 0 ]; then
    log_error "Coverage analysis failed."
fi

log_info "Coverage completed successfully."
check_memory
log_info ""

################################################################################
# SECTION 5: Gene Quantification
################################################################################

log_step "====================================================================="
log_step "SECTION 5: Gene-wise Quantification"
log_step "====================================================================="
log_info "Started at: $(date)"
log_info ""

check_memory_available

log_info "Running gene quantification..."
reademption gene_quanti \
    --project_path READemption_analysis \
    --processes 1 \
    --features CDS,tRNA,rRNA

if [ $? -ne 0 ]; then
    log_error "Gene quantification failed."
fi

log_info "Gene quantification completed successfully."
check_memory
log_info ""

################################################################################
# SECTION 6: Differential Expression Analysis (DESeq2)
################################################################################

log_step "====================================================================="
log_step "SECTION 6: Differential Expression Analysis (DESeq2)"
log_step "====================================================================="
log_info "Started at: $(date)"
log_info ""

check_memory_available

log_info "Running DESeq2 analysis..."
reademption deseq \
    --project_path READemption_analysis \
    --libs control_r1,control_r2,apigennin_r1,apigennin_r2,salt_r1,salt_r2 \
    --conditions control,control,apigennin,apigennin,salt,salt \
    --replicates 1,2,1,2,1,2 \
    --libs_by_species rhizobium=control_r1,control_r2,apigennin_r1,apigennin_r2,salt_r1,salt_r2 \
    --cooks_cutoff_off

if [ $? -ne 0 ]; then
    log_error "DESeq2 analysis failed."
fi

log_info "DESeq2 analysis completed successfully."
check_memory
log_info ""

################################################################################
# SECTION 7: Visualizations
################################################################################

log_step "====================================================================="
log_step "SECTION 7: Generating Visualizations"
log_step "====================================================================="
log_info "Started at: $(date)"
log_info ""

check_memory_available

log_info "Generating alignment visualizations..."
reademption viz_align --project_path READemption_analysis

log_info "Generating gene quantification visualizations..."
reademption viz_gene_quanti --project_path READemption_analysis

log_info "Generating DESeq visualizations..."
reademption viz_deseq --project_path READemption_analysis

log_info "All visualizations completed successfully."
check_memory
log_info ""

################################################################################
# COMPLETION SUMMARY
################################################################################

conda deactivate

log_info "====================================================================="
log_info "PIPELINE COMPLETED SUCCESSFULLY!"
log_info "====================================================================="
log_info "Finished at: $(date)"
log_info ""
log_info "Results are in: READemption_analysis/output/"
log_info ""
log_info "Key Output Directories:"
log_info "  1. Alignments:"
log_info "     READemption_analysis/output/align/alignments/"
log_info "     READemption_analysis/output/align/reports_and_stats/"
log_info ""
log_info "  2. Coverage:"
log_info "     READemption_analysis/output/coverage/"
log_info ""
log_info "  3. Gene Quantification:"
log_info "     READemption_analysis/output/rhizobium_gene_quanti_combined/"
log_info ""
log_info "  4. Differential Expression:"
log_info "     READemption_analysis/output/rhizobium_deseq/"
log_info ""
log_info "  5. Visualizations:"
log_info "     READemption_analysis/output/rhizobium_viz_align/"
log_info "     READemption_analysis/output/rhizobium_viz_gene_quanti/"
log_info "     READemption_analysis/output/rhizobium_viz_deseq/"
log_info ""
log_info "Final System Status:"
check_memory
echo ""
check_disk_space
log_info ""
log_info "====================================================================="
log_info "Analysis Complete"
log_info "====================================================================="
