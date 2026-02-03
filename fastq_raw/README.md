# Raw FASTQ Reads Directory

This directory contains raw and merged RNA-seq reads for the transcriptome study.

## Contents

After running the pipeline scripts, this directory will contain:

### Raw Paired-End Reads (from `01_download_data.sh`)

- **control_r1_p1.fastq.gz** - Control replicate 1, read 1
- **control_r1_p2.fastq.gz** - Control replicate 1, read 2
- **control_r2_p1.fastq.gz** - Control replicate 2, read 1
- **control_r2_p2.fastq.gz** - Control replicate 2, read 2
- **apigennin_r1_p1.fastq.gz** - Apigenin replicate 1, read 1
- **apigennin_r1_p2.fastq.gz** - Apigenin replicate 1, read 2
- **apigennin_r2_p1.fastq.gz** - Apigenin replicate 2, read 1
- **apigennin_r2_p2.fastq.gz** - Apigenin replicate 2, read 2
- **salt_r1_p1.fastq.gz** - Salt stress replicate 1, read 1
- **salt_r1_p2.fastq.gz** - Salt stress replicate 1, read 2
- **salt_r2_p1.fastq.gz** - Salt stress replicate 2, read 1
- **salt_r2_p2.fastq.gz** - Salt stress replicate 2, read 2

### Merged Reads (from `02_bbmap_reademption_pipeline.sh`)

Located in `merged/` subdirectory:

- **control_r1.fastq.gz** - Control replicate 1, merged
- **control_r2.fastq.gz** - Control replicate 2, merged
- **apigennin_r1.fastq.gz** - Apigenin replicate 1, merged
- **apigennin_r2.fastq.gz** - Apigenin replicate 2, merged
- **salt_r1.fastq.gz** - Salt stress replicate 1, merged
- **salt_r2.fastq.gz** - Salt stress replicate 2, merged

## File Sizes

These files are excluded from Git due to size limitations:
- Raw paired-end files: ~500-800 MB each
- Merged files: ~300-500 MB each
- **Total directory size: ~10-15 GB**

## Obtaining Files

### Option 1: Run the Download Script

```bash
cd /path/to/rnaseq_paired_end
./01_download_data.sh
```

This will download all raw FASTQ files from ENA.

### Option 2: Manual Download

Download from ENA FTP server:

**Control Replicate 1 (SRR3036912):**
```bash
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR303/002/SRR3036912/SRR3036912_1.fastq.gz
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR303/002/SRR3036912/SRR3036912_2.fastq.gz
```

**Control Replicate 2 (SRR3031958):**
```bash
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR303/008/SRR3031958/SRR3031958_1.fastq.gz
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR303/008/SRR3031958/SRR3031958_2.fastq.gz
```

**Apigenin Replicate 1 (SRR3036915):**
```bash
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR303/005/SRR3036915/SRR3036915_1.fastq.gz
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR303/005/SRR3036915/SRR3036915_2.fastq.gz
```

**Apigenin Replicate 2 (SRR3031957):**
```bash
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR303/007/SRR3031957/SRR3031957_1.fastq.gz
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR303/007/SRR3031957/SRR3031957_2.fastq.gz
```

**Salt Replicate 1 (SRR3062176):**
```bash
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR306/006/SRR3062176/SRR3062176_1.fastq.gz
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR306/006/SRR3062176/SRR3062176_2.fastq.gz
```

**Salt Replicate 2 (SRR3032151):**
```bash
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR303/001/SRR3032151/SRR3032151_1.fastq.gz
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR303/001/SRR3032151/SRR3032151_2.fastq.gz
```

Then rename files according to the naming scheme used in the pipeline.

## Data Source

- **BioProject**: PRJNA305690
- **Database**: European Nucleotide Archive (ENA)
- **Sequencing Platform**: Illumina
- **Read Type**: Paired-end
- **Read Length**: Variable (typically 100-150 bp)

## Experimental Conditions

### Control
Normal growth conditions without stress or inducer treatment.

### Apigenin
Treatment with apigenin, a plant flavonoid that acts as a nod gene inducer in rhizobia.

### Salt Stress
Osmotic stress conditions to study salt tolerance mechanisms.

## File Format

FASTQ format (gzip compressed):
- **Line 1**: Sequence identifier (@)
- **Line 2**: Nucleotide sequence
- **Line 3**: Plus sign (+)
- **Line 4**: Quality scores (Phred+33 encoding)

## Read Merging

Paired-end reads are merged using BBMap's `bbmerge.sh`:
- Overlapping pairs are merged into single reads
- Non-overlapping pairs retain both reads
- Improves alignment accuracy for short fragments
- Merged reads stored in `merged/` subdirectory

## Quality Information

Expected quality metrics:
- **Phred Score**: >30 for most bases
- **Read Length**: 100-150 bp (before merging)
- **GC Content**: ~55-60% (Rhizobium tropici)
- **Duplication Rate**: Moderate (RNA-seq typically has some duplication)

## Usage in Pipeline

Raw reads are processed as follows:
1. Downloaded by `01_download_data.sh`
2. Merged by `02_bbmap_reademption_pipeline.sh` (BBMap)
3. Copied to `READemption_analysis/input/reads/`
4. Aligned by READemption (SEGEMEHL aligner)

No manual file manipulation required when using the provided scripts.

## Troubleshooting

### Large Download Times
- Downloads may take 1-2 hours depending on connection speed
- Consider using a download manager for resumable downloads

### Corrupted Files
- Verify file integrity with MD5 checksums if available
- Re-download individual files if corruption detected
- BBMap's repair.sh will detect and report corrupted read pairs

### Disk Space
- Ensure sufficient disk space (~20 GB) before downloading
- Merged files can be deleted after successful alignment if space is limited
