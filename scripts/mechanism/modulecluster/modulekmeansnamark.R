suppressMessages(library(hash))
suppressMessages(library(Cairo))
suppressMessages(library(pheatmap))

suppressMessages(library("doParallel"))
suppressMessages(library("foreach"))
suppressMessages(library("compiler"))

set.seed(9)

arg = commandArgs(T)

cache <- read.table(arg[1], header = FALSE, sep = '\t', stringsAsFactors = FALSE)
annotation_in <- read.table(arg[2], header = FALSE, sep = '\t', stringsAsFactors = FALSE)

arg[3] = gsub(pattern = '\\/$', replacement = '', x = arg[3])




if (! file.exists(arg[3])) {
	dir.create(arg[3], recursive = TRUE)
}
if (! file.exists( paste0(arg[3], '/figure')  )) {
	dir.create(paste0(arg[3], '/figure'))
}

originalpath = getwd()
setwd(arg[3])
absoluteoutpath = getwd()
setwd(originalpath)
absoluteoutpath = gsub(pattern = '\\/$', replacement = '', x = absoluteoutpath)
absoluteoutpath = paste0(absoluteoutpath, '/')

cachename = as.vector(unlist(as.character(cache[,1])))
row.names(cache) = cachename

corcalculate <- function(cachein, typei) {

	mirsamplenum = length(unlist(cachein[1,]))
	thresholdit = max(20, 1/9*mirsamplenum)
	userows <- which(apply(cachein, 1, FUN <- function(xx){length(unique(xx))} ) >= thresholdit)
	if (length(userows) <= 10){
		return('0')
	}
	cachein =cachein[userows,]
	cachein = t(cachein)

	
	matrixcache = cor(cachein, method = "spearman", use="pairwise.complete.obs")
	if (NA %in% unlist(matrixcache)) {
		print(c(typei, 'has NA'))
		matrixcache2 <- apply(matrixcache, 2, FUN = function(xx){xxnum = xx[! is.na(xx)]; xx[is.na(xx)]<-mean(xxnum); return(xx) })
	}else{
		matrixcache2 <- matrixcache
	}

	hccache = hclust(as.dist( (1-matrixcache2)^(1/2) ), method = 'average')
	matrixcache2 = matrixcache2[,hccache$order]
	matrixcache2 = matrixcache2[hccache$order,]

	bk = unique(c(seq(-1,1, length=200)))
	CairoPNG(file = paste0(absoluteoutpath, 'figure/', typei, "corheat.png"), width = 15000, height = 15000, pointsize = 3)
	heatmap = pheatmap(matrixcache2, show_colnames = TRUE, show_rownames = TRUE, breaks = bk, color = colorRampPalette(c("navy", "white", "firebrick3"))(200), cluster_cols = FALSE, cluster_rows = FALSE, treeheight_row = 0, treeheight_col = 0)
	print(heatmap)
	dev.off()

	rn_new <- rownames(matrixcache2)
	write.table(as.matrix(rn_new), file = paste0(absoluteoutpath, 'figure/', typei, "rownamelist.txt"), row.names = FALSE, col.names = FALSE,sep="\t", quote = FALSE)

	matrixcache = matrixcache[,hccache$order]
	matrixcache = matrixcache[hccache$order,]
	write.table(matrixcache, file = paste0(absoluteoutpath, 'figure/', typei, "mat.txt"), row.names = FALSE, col.names = FALSE, sep="\t", quote = FALSE, append = FALSE)

	gctrash = gc()

}
corcalculate.cmped = cmpfun(corcalculate)


cache = cache[,-(1:2)]
colall0 = as.vector(as.character(unlist(cache[1,]) ) )
cache = cache[-1,]
cachename = cachename[-1]

if (length( (strsplit(annotation_in[1,1], '-'))[[1]]) == 4) {

	colall = colall0

}else{
	print("error in input data format")
	quit(save = FALSE)
}

annohash = hash()
.set(annohash, keys = annotation_in[,1], values = annotation_in[,2])
colallnum = as.numeric(unname(which(has.key(colall, annohash))))
cache = cache[,colallnum]
colall = colall[colallnum]
annotation_coluse = unname(values(annohash, colall))
colnames(cache) = colall


rowtemp = rownames(cache)

cachenapos <- (cache == 'NA/NA') ####does it influence?
cache[cachenapos] <- 0
cache = apply(cache, 2, as.numeric)
rownames(cache) = rowtemp
cache[cachenapos] <- NA
gctrash = gc()

types = as.character(unique(unlist(annotation_coluse)))


cl <- makeCluster(4)
registerDoParallel(cl)



nouse = foreach (i222 = 1:2) %dopar% {
	library(Cairo)
	library(pheatmap)

	if (i222 == 1) {
		corcalculate.cmped(cache, 'ALL')
	}else {
		for (typei in types) {
		
			posicol = which(annotation_coluse == typei)
			if (length(posicol) >= 	1) {
				cache0 = cache[,posicol]
				corcalculate.cmped(cache0, typei)
				rm(cache0)
			}
			
		}
		
	}
}

stopCluster(cl)


warnres = warnings()
if (! is.null(warnres)) {
	print(arg)
	print(warnres)
}
