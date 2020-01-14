suppressMessages(library(ggplot2))
suppressMessages(library(pheatmap))
suppressMessages(library(Cairo))
suppressMessages(library(hash))

#Rscript scripts/mechanism/modulecluster/drawheatmapforacluineachtissue.R result/mechanism/modulecluster/namark88/adjustnamark/clusters/clu1.txt result/mechanism/modulecluster/namark88/adjustnamark/figure/ result/mechanism/modulecluster/namark88/adjustnamark/subclus/

arg = commandArgs(T)

matfromprefix <- function(prefixone, mirlist, outname){
	matdata <- read.table(paste0(prefixone, 'mat.txt'), header = FALSE, stringsAsFactors = FALSE, sep = '\t')
	mirorder <- unlist(read.table(paste0(prefixone, 'rownamelist.txt'), header = FALSE, stringsAsFactors = FALSE, sep = '\t'))
	if (length(which(mirlist %in% mirorder)) <= 2) {
		return(0)
	}
	mirlist <- mirlist[which(mirlist %in% mirorder)]
	usecols = match(mirlist, mirorder)
	matdata0 = matdata
	matdata = matdata[,usecols]
	matdata = matdata[usecols,]
	bk = unique(c(seq(-1,1, length=400)))
	thenames = mirorder[usecols]
	row.names(matdata) = thenames
	colnames(matdata) = thenames
	CairoPNG(file = outname, width = 15000, height = 15000, pointsize = 3)
	heatmap = pheatmap(matdata, show_colnames = TRUE, show_rownames = TRUE, breaks = bk, color = colorRampPalette(c("navy", "purple", "white", "orange", "firebrick3"))(400), cluster_cols = F, cluster_rows = F)
	print(heatmap)
	dev.off()
	matdata = unlist(matdata)
	matdata0 = unlist(matdata0)
	pv <- wilcox.test(matdata, matdata0)$p.value
	return(c(mean(matdata, na.rm = T), mean(matdata0, na.rm = T), pv))
}

matfromprefix2 <- function(prefixone, prefixtwo, mirlist, outname){
	matdata <- read.table(paste0(prefixone, 'mat.txt'), header = FALSE, stringsAsFactors = FALSE, sep = '\t')
	mirorder <- unlist(read.table(paste0(prefixtwo, 'rownamelist.txt'), header = FALSE, stringsAsFactors = FALSE, sep = '\t'))
	if (length(which(mirlist %in% mirorder)) <= 2) {
		return(0)
	}
	mirlist <- mirlist[which(mirlist %in% mirorder)]
	usecols = match(mirlist, mirorder)
	matdata0 = matdata
	matdata = matdata[,usecols]
	matdata = matdata[usecols,]
	bk = unique(c(seq(-1,1, length=400)))
	thenames = mirorder[usecols]
	row.names(matdata) = thenames
	colnames(matdata) = thenames
	CairoPNG(file = outname, width = 15000, height = 15000, pointsize = 3)
	heatmap = pheatmap(matdata, show_colnames = TRUE, show_rownames = TRUE, breaks = bk, color = colorRampPalette(c("navy", "purple", "white", "orange", "firebrick3"))(400), cluster_cols = F, cluster_rows = F)
	print(heatmap)
	dev.off()
	
	matdata = unlist(matdata)
	matdata0 = unlist(matdata0)
	pv <- wilcox.test(matdata, matdata0)$p.value
	return(c(mean(matdata, na.rm = T), mean(matdata0, na.rm = T), pv))
}


mirlist <- read.table(arg[1], header = FALSE, stringsAsFactors = FALSE, sep = '\t')
mirlist <- unlist(mirlist)
datafile = arg[2]
datafile = gsub(pattern = "\\/$", replacement = '', x = datafile)
datafile = paste0(datafile, '/')
outfile = arg[3]
#outfile = gsub(pattern = "\\/$", replacement = '', x = outfile)
#outfile = paste0(outfile, '/')

allfiles <- list.files(datafile)
#allmirfiles <- allfiles[grep('mir.*rownamelist.txt$', allfiles)]
#allfiles <- allfiles[-grep('mir.*rownamelist.txt$', allfiles)]
#allhostfiles <- allfiles[grep('host.*rownamelist.txt$', allfiles)]
#allfiles <- allfiles[-grep('host.*rownamelist.txt$', allfiles)]
allratiofiles <- allfiles[grep('rownamelist.txt$', allfiles)]
#print(allfiles)
summaryfile <- paste0(outfile, 'subclusummary.txt')
write.table( t(c('tissue_type', 'cluster_mean', 'overall_mean', 'p-value')), file = summaryfile, row.names = FALSE, col.names = FALSE, sep="\t", quote = FALSE, append = FALSE)

for (ppi in allratiofiles) {
	type = gsub(pattern = outfile, replacement = '', x = ppi)
	type = gsub(pattern = 'rownamelist.txt$', replacement = '', x = ppi)


	ratiores <- matfromprefix(paste0(datafile, type), mirlist, paste0(outfile, type, 'ratiosmall.png'))
	mirnares <- matfromprefix2(paste0(datafile, 'mir', type), paste0(datafile, type), mirlist, paste0(outfile, type, 'mirsmall.png'))
	generes <- matfromprefix2(paste0(datafile, 'host', type), paste0(datafile, type), mirlist, paste0(outfile, type, 'hostsmall.png'))

	write.table(t(c(ppi,ratiores)), file = summaryfile, row.names = FALSE, col.names = FALSE, sep="\t", quote = FALSE, append = TRUE)
}

