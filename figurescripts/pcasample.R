library(ggplot2)
library(ggfortify)
library(devtools)
library(scatterplot3d)
library(dendextend)

library(Cairo)
library(pheatmap)

arg = commandArgs(T)
#Rscript figure/scripts/pcasample.R result/gctcal/order/filtered88ratioadjust.great.order.gct result/gctcal/order/filtered88ratioadjust.great.orderlist.txt figure/result/addmin88

cache <- read.table(arg[1], header = TRUE, sep = '\t', stringsAsFactors = FALSE)
cacherow <- read.table(arg[2], header = FALSE, sep = '\t', stringsAsFactors = FALSE)


cachename = as.vector(unlist(as.character(cache[,1])))
rownames = make.names(cachename, unique = TRUE)
row.names(cache) = rownames
cache = cache[,-1]
cache = cache[,-1]

cachecolname = colnames(cache) 
cachecolname2 = unlist(lapply(strsplit(cachecolname, '\\.'), FUN <- function(datain) {return(datain[4])}))
cachecolname2 = gsub(pattern = '[A-Za-z]$', replacement = '', x = cachecolname2)
usecols = which(as.numeric(cachecolname2) < 10)
cache = cache[,usecols]
cacherow = cacherow[usecols,]


#cache = log(cache + 0.00000001)
cache = log(cache)
cache = as.data.frame(t(cache))


mtcars.pca <- prcomp(cache, center = TRUE, scale = TRUE, retx = TRUE)
pcares = mtcars.pca$x


set.seed(1)
important = sample(which(cacherow == 'TCGA-LAML'), 50)
important2 = sample(which(cacherow == "TARGET-AML"), 50)
othernormal = intersect(which(cacherow != 'TCGA-LAML'), which(cacherow != "TARGET-AML"))
othernormal = sample(othernormal, 200)

important = c(important, important2, othernormal)

smallpca = pcares[important,]
cacherow2 = cacherow[important]



show = c("TCGA-LAML", "TARGET-AML", 'TCGA-BRCA',  'TCGA-UCEC', 'TCGA-LGG')


unshowrows = which(! cacherow2 %in% show)
cacherow2[unshowrows] = 'Other'
annotation_coluse = as.data.frame(cacherow2, stringsAsFactors = FALSE)

heatdata = as.data.frame(smallpca[,1:100])
rownames(annotation_coluse) = rownames(heatdata)
colnames(annotation_coluse) = c('TCGA_project')


heatmap = pheatmap(heatdata, cluster_cols = TRUE, show_colnames = FALSE, show_rownames = FALSE, treeheight_row = 100, annotation_row = annotation_coluse, silent=T)

CairoPDF(file= paste0(arg[3], "heatmapfordent.pdf"), pointsize = 2)
print(heatmap)
dev.off()

####more
dim(cacherow)
dim(pcares)
unshowrows = which(! cacherow %in% c("TCGA-LAML", "TARGET-AML"))
cacherow[unshowrows] = 'Other'
annocol = as.data.frame(cacherow, stringsAsFactors = FALSE)

rownames(annocol) = rownames(pcares)
colnames(annocol) = c('TCGA_project')




annocol[annocol == 'TCGA-LAML'] <- 'firebrick3'

annocol[annocol == 'TARGET-AML'] <- 'dodgerblue'
annocol[annocol == 'Other'] <- 'gray'

heatmap2 = pheatmap(as.data.frame(pcares[,1:20]), cluster_cols = TRUE, show_colnames = FALSE, show_rownames = FALSE, treeheight_row = 6000, annotation_row = annocol, silent=T)
CairoTIFF(file=paste0(arg[3], "heatmapall.tiff"), width = 30000, height = 15000, pointsize = 1)
par(mar = c(10, 10, 10, 10), xpd = NA, lwd = 2)
plot(heatmap2$tree_row, labels=FALSE, hang = -1)
colored_bars(colors = annocol, heatmap2$tree_row, y_scale = 3, y_shift = 1)
legend("topright", legend = c("TCGA-LAML","TARGET-AML", "Other"), fill = c("firebrick3", "dodgerblue", 'gray'), cex = 400)
dev.off() 
write.table(rownames(pcares)[heatmap2$tree_row$order], file = paste0(arg[3], "heatmapall.txt"), row.names = FALSE, col.names = FALSE, sep="\t", quote = FALSE, append = FALSE)
