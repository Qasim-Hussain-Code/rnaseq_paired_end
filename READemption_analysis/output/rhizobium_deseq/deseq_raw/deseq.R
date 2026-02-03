library('DESeq2')
library('RColorBrewer')
library('gplots')
library('ggplot2')
rawCountTable <- read.table('READemption_analysis/output/rhizobium_gene_quanti_combined/gene_wise_quantifications_combined.csv', skip=1, sep='\t', quote='', comment.char='', colClasses=c(rep('character',10), rep('numeric',6)))
countTable <- round(rawCountTable[,11:length(names(rawCountTable))])
colnames(countTable) <- c('apigennin_r1','apigennin_r2','control_r1','control_r2','salt_r1','salt_r2')
# Select only the libraries of this species
countTable <- countTable[, c('apigennin_r1','apigennin_r2','control_r1','control_r2','salt_r1','salt_r2')]
libs <- c('apigennin_r1','apigennin_r2','control_r1','control_r2','salt_r1','salt_r2')
conds <- c('apigennin', 'apigennin', 'control', 'control', 'salt', 'salt')
reps <- c('1', '2', '1', '2', '1', '2')
samples <- data.frame(row.names=libs, condition=conds, lib=libs, replicate=reps)
dds <- DESeqDataSetFromMatrix(countData=countTable, colData=samples, design=~condition)
dds <- DESeq(dds, betaPrior=TRUE)

# PCA plot
pdf('READemption_analysis/output/rhizobium_deseq/deseq_raw/sample_comparison_pca_heatmap.pdf')
rld <- rlog(dds)
pcaData <- plotPCA(rld, 'condition', intgroup=c('condition', 'replicate'), returnData=TRUE)
percentVar <- round(100 * attr(pcaData, 'percentVar'))
print(ggplot(pcaData, aes(PC1, PC2, color=condition, shape=replicate)) +
geom_point(size=3) +
xlab(paste0('PC1: ',percentVar[1],'% variance')) +
ylab(paste0('PC2: ',percentVar[2],'% variance')) +
coord_fixed())
# Heatmap
distsRL <- dist(t(assay(rld)))
mat <- as.matrix(distsRL)
rownames(mat) <- with(colData(dds), paste(lib, sep=' : '))
hmcol <- colorRampPalette(brewer.pal(9, 'GnBu'))(100)
heatmap.2(mat, trace='none', col = rev(hmcol), margin=c(13, 13))
comp0 <- results(dds, contrast=c('condition','apigennin', 'control'), cooksCutoff=FALSE)
write.table(comp0, file='READemption_analysis/output/rhizobium_deseq/deseq_raw/deseq_comp_apigennin_vs_control.csv', quote=FALSE, sep='\t')
comp1 <- results(dds, contrast=c('condition','apigennin', 'salt'), cooksCutoff=FALSE)
write.table(comp1, file='READemption_analysis/output/rhizobium_deseq/deseq_raw/deseq_comp_apigennin_vs_salt.csv', quote=FALSE, sep='\t')
comp2 <- results(dds, contrast=c('condition','control', 'apigennin'), cooksCutoff=FALSE)
write.table(comp2, file='READemption_analysis/output/rhizobium_deseq/deseq_raw/deseq_comp_control_vs_apigennin.csv', quote=FALSE, sep='\t')
comp3 <- results(dds, contrast=c('condition','control', 'salt'), cooksCutoff=FALSE)
write.table(comp3, file='READemption_analysis/output/rhizobium_deseq/deseq_raw/deseq_comp_control_vs_salt.csv', quote=FALSE, sep='\t')
comp4 <- results(dds, contrast=c('condition','salt', 'apigennin'), cooksCutoff=FALSE)
write.table(comp4, file='READemption_analysis/output/rhizobium_deseq/deseq_raw/deseq_comp_salt_vs_apigennin.csv', quote=FALSE, sep='\t')
comp5 <- results(dds, contrast=c('condition','salt', 'control'), cooksCutoff=FALSE)
write.table(comp5, file='READemption_analysis/output/rhizobium_deseq/deseq_raw/deseq_comp_salt_vs_control.csv', quote=FALSE, sep='\t')
