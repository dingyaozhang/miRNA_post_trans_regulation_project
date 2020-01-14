library(GenomicFeatures)
txdb <- makeTxDbFromGFF("data/gctcal/gencode.v28.gtf",format="gtf")
exons_gene <- exonsBy(txdb, by = "gene")
exons_gene_lens <- lapply(exons_gene,function(x){sum(width(reduce(x)))})

a = as.data.frame(matrix(ncol = 2, nrow = length(exons_gene_lens) ))
a[,2] = as.numeric(a[,2])
a[,1] = as.character(a[,1])

a[,1] = names(exons_gene_lens)
a[,2] = unlist(unname(exons_gene_lens))

write.table(a, file = "data/gctcal/exons_gene_lens.txt", row.names = FALSE, col.names = FALSE,sep="\t", quote = FALSE, append = FALSE)
