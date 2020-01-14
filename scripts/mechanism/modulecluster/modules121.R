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

arg[3] = paste0(arg[3], '/')


cachename = as.vector(unlist(as.character(cache[,1])))
cachename2 = as.vector(unlist(as.character(cache[,2])))
cachename2 = make.names(cachename2, unique = TRUE)


row.names(cache) = cachename

splitthis1 = function(x) {
	outx = do.call(cbind, strsplit(unlist(x), split = "/"))
	return(unlist(outx[1,]))
}
splitthis2 = function(x) {
	outx = do.call(cbind, strsplit(unlist(x), split = "/"))
	return(unlist(outx[2,]))
}

calratio <- function(mirin, genein) {
	rownamesp = rownames(mirin)
	mirin <- t(apply(mirin, 1, fun <- function(xx){
		return(1/3*min(xx[xx != 0]) + xx)
		}) )
	genein <- t(apply(genein, 1, fun <- function(xx){
		return(1/3*min(xx[xx != 0]) + xx)
		}) )
	ratioout = mirin / genein
	return(ratioout)
}

corcalculate121 <- function(cachein, typei, outfile) {
	
	rownamesp = rownames(cachein)
	cachemirtemp = apply(cachein, 2, splitthis1)
	cachegenetemp = apply(cachein, 2, splitthis2)
	cachemirtemp = apply(cachemirtemp, 2, as.numeric)
	cachegenetemp = apply(cachegenetemp, 2, as.numeric)
	rownames(cachemirtemp)  <- rownamesp
	rownames(cachegenetemp) <- rownamesp
	thesamplenum = length(unlist(cachein[1,]))
	rm(cachein)
	
	
	#userows <- which(apply(cachemirtemp, 1, FUN <- function(xx){length(unique(xx))} ) > 20)
	#userows2 <- which(apply(cachegenetemp, 1, FUN <- function(xx){length(unique(xx))} ) > 20)
	userows <- which(apply(cachemirtemp, 1, FUN <- function(xx){sum(xx != 0)} ) >= 20)
	userows2 <- which(apply(cachegenetemp, 1, FUN <- function(xx){sum(xx != 0)} ) >= 20)
	userows = intersect(userows, userows2)
	if (length(userows) <= 10){
		return('NA')
	}
	cachemirtemp  = cachemirtemp[userows,]
	cachegenetemp = cachegenetemp[userows,]
	ratioout <-  calratio(cachemirtemp, cachegenetemp)
	
	cachein = t(ratioout)

	outmess = 'NA'
	matrixcache = cor(cachein, method = "spearman", use = 'all.obs')
	if (NA %in% unlist(matrixcache)) {
		outmess = paste0(typei, 'has NA')
		matrixcache2 <- apply(matrixcache, 2, FUN = function(xx){xxnum = xx[! is.na(xx)]; xx[is.na(xx)]<-mean(xxnum); return(xx) })
	}else{
		matrixcache2 <- matrixcache
	}
	
	hccache = hclust(as.dist( (1-matrixcache2)^(1/2) ), method = 'average')
	matrixcache2 = matrixcache2[,hccache$order]
	matrixcache2 = matrixcache2[hccache$order,]


	bk = unique(c(seq(-1,1, length=400)))
	CairoPNG(file = paste0(outfile, typei, "corheat.png"), width = 15000, height = 15000, pointsize = 3)
	heatmap = pheatmap(matrixcache2, show_colnames = TRUE, show_rownames = TRUE, breaks = bk, color = colorRampPalette(c("navy", "purple", "white", "orange", "firebrick3"))(400), cluster_rows = F, cluster_cols = F)
	print(heatmap)
	dev.off()
 
	rn_new <- rownames(matrixcache2)

	write.table(as.matrix(rn_new), file = paste0(outfile, typei, "rownamelist.txt"), row.names = FALSE, col.names = FALSE,sep="\t", quote = FALSE)

	matrixcache = matrixcache[,hccache$order]
	matrixcache = matrixcache[hccache$order,]
	write.table(matrixcache, file = paste0(outfile, typei, "mat.txt"), row.names = FALSE, col.names = FALSE, sep="\t", quote = FALSE, append = FALSE)
	gctrash = gc()
	
	return(outmess)
	
}


corcalculate <- function(cachein, typei, outfile) {

	if (! (file.exists(paste0(arg[3], 'figure/', typei, "rownamelist.txt") ) ) ) {
		print(paste0(arg[3], 'figure/', typei, "rownamelist.txt"))
		next
	}
	clusterorder <- read.table(paste0(arg[3], 'figure/', typei, "rownamelist.txt"), header = FALSE, sep = '\t', stringsAsFactors = FALSE)
	clusterorder = clusterorder[,1]
	rownamescachein = gsub(pattern = '\\.', replacement = '-', x = rownames(cachein))
	clusterordernum = match(clusterorder, rownamescachein)
	cachein = cachein[clusterordernum,]
	
	cachein = t(cachein)


	matrixcache = cor(cachein, method = "spearman", use = 'all.obs')
	
	
	write.table(matrixcache, file = paste0(outfile, typei, "mat.txt"), row.names = FALSE, col.names = FALSE, sep="\t", quote = FALSE, append = FALSE)
	bk = unique(c(seq(-1,1, length=400)))
	CairoPNG(file = paste0(outfile, typei, "corheat.png"), width = 15000, height = 15000, pointsize = 3)
	heatmap = pheatmap(matrixcache, show_colnames = TRUE, show_rownames = TRUE, cluster_rows = FALSE, cluster_cols = FALSE,breaks = bk, color = colorRampPalette(c("navy", "purple", "white", "orange", "firebrick3"))(400), treeheight_row = 0, treeheight_col = 0)
	print(heatmap)
	dev.off()

}

corcalculate.cmped = cmpfun(corcalculate)
corcalculate121.cmped = cmpfun(corcalculate121)
	

cache = cache[,-(1:2)]
colall0 = as.vector(as.character(unlist(cache[1,]) ) )
cache = cache[-1,]
cachename = cachename[-1]
cachename2 = cachename2[-1]

if (length( (strsplit(annotation_in[1,1], '-'))[[1]]) == 4) {
	colall = colall0
}else{
	stop("error in input data format")
}

annohash = hash()
.set(annohash, keys = annotation_in[,1], values = annotation_in[,2])
colallnum = as.numeric(unname(which(has.key(colall, annohash))))
cache = cache[,colallnum]
colall = colall[colallnum]
annotation_coluse = unname(values(annohash, colall))
colnames(cache) = colall



types = as.character(unique(unlist(annotation_coluse)))

rownamesp = rownames(cache)

rownamesp = rownames(cache)
cachemir = apply(cache, 2, splitthis1)
cachegene = apply(cache, 2, splitthis2)
cachemir = apply(cachemir, 2, as.numeric)
cachegene = apply(cachegene, 2, as.numeric)
rownames(cachemir)  <- cachename
rownames(cachegene) <- cachename

cl <- makeCluster(4)
registerDoParallel(cl)


gctrash = gc()
nouse = foreach (i222 = 1:2) %dopar% {
	suppressMessages(library(Cairo))
	suppressMessages(library(pheatmap))
	
	if (i222 == 1) {
		outmess = corcalculate121.cmped(cache, 'ALL', paste0(arg[3], 'figure/'))
	}else {
		outmess = c()
		for (typei in types) {

			posicol = which(annotation_coluse == typei)
	
			cache0 = cache[,posicol]
			outmess = c(outmess, corcalculate121.cmped(cache0, typei, paste0(arg[3], 'figure/')))
			rm(cache0)
			gctrash = gc()
		}
		
	}
	if (length(outmess[outmess != 'NA']) >= 1) {
		return(outmess[outmess != 'NA'])
	}else{
		return('NA')
	}

}

nouse = unlist(nouse)
if (length(nouse[nouse != 'NA']) >= 1) {
	nouse = nouse[nouse != 'NA']
	for (iit in 1:length(nouse)) {
		print(nouse[iit])
	}
}



gctrash = gc()

nouse = foreach (i222 = 1:4) %dopar% {
	library(Cairo)
	library(pheatmap)

	if (i222 == 1) {
		corcalculate.cmped(cachemir, 'ALL', paste0(arg[3], 'figure/', 'mir'))
		

	}else if (i222 == 2) {
		for (typei in types) {

			posicol = which(annotation_coluse == typei)
	
			cache0 = cachemir[,posicol]
			corcalculate.cmped(cache0, typei, paste0(arg[3], 'figure/', 'mir'))
			rm(cache0)
			gctrash = gc()
		}
	}else if (i222 == 3) {
		corcalculate.cmped(cachegene, 'ALL', paste0(arg[3], 'figure/', 'host'))
		
	}else{
		for (typei in types) {

			posicol = which(annotation_coluse == typei)
	
			cache0 = cachegene[,posicol]
			corcalculate.cmped(cache0, typei, paste0(arg[3], 'figure/', 'host'))
			rm(cache0)
			gctrash = gc()
		}

	}

}

stopCluster(cl)
gctrash = gc()


warnres = warnings()
if (! is.null(warnres)) {
	print(arg)
	print(warnres)
}
