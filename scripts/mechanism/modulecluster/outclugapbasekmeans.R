suppressMessages(library(hash))


suppressMessages(library("doParallel"))
suppressMessages(library("foreach"))
suppressMessages(library("compiler"))
suppressMessages(library(cluster))

set.seed(9)


arg = commandArgs(T)

cache <- read.table(arg[1], header = FALSE, sep = '\t', stringsAsFactors = FALSE)
annotation_in <- read.table(arg[2], header = FALSE, sep = '\t', stringsAsFactors = FALSE)



outfile = arg[3]

write.table(t(c('tissue', 'cluster', 'mir')), file = outfile, row.names = FALSE, col.names = FALSE, sep="\t", quote = FALSE, append = FALSE)

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
		return(mean((sort(xx[xx != 0]))[1:5]) + xx)
		}) )
	genein <- t(apply(genein, 1, fun <- function(xx){
		return(mean((sort(xx[xx != 0]))[1:5]) + xx)
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
	
	
	userows <- which(apply(cachemirtemp, 1, FUN <- function(xx){length(unique(xx))} ) > 20)
	userows2 <- which(apply(cachegenetemp, 1, FUN <- function(xx){length(unique(xx))} ) > 20)
	userows = intersect(userows, userows2)
	if (length(userows) <= 10){
		return('0')
	}
	cachemirtemp  = cachemirtemp[userows,]
	cachegenetemp = cachegenetemp[userows,]
	ratioout <-  calratio(cachemirtemp, cachegenetemp)
	
	cachein = t(ratioout)

	
	matrixcache = cor(cachein, method = "spearman", use = 'all.obs')

	matrixcache = t(na.omit(matrixcache))
	gapsta <- clusGap(matrixcache, FUN=kmeans, K.max=15, verbose = F)
	gapbest <- with(gapsta, maxSE(Tab[,"gap"], Tab[,"SE.sim"]))

	kmenares <- kmeans(matrixcache, gapbest)
	moduleslist <- cbind(kmenares$cluster, rownames(matrixcache))
	moduleslist <- cbind(typei, moduleslist)
	write.table(t(c(typei, dim(matrixcache))), file = outfile, row.names = FALSE, col.names = FALSE, sep="\t", quote = FALSE, append = TRUE)
	write.table(moduleslist, file = outfile, row.names = FALSE, col.names = FALSE, sep="\t", quote = FALSE, append = TRUE)
	

	gctrash = gc()
}




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



cl <- makeCluster(4)
registerDoParallel(cl)


gctrash = gc()
nouse = foreach (i222 = 1:2) %dopar% {
	suppressMessages(library(cluster))
	if (i222 == 1) {
		corcalculate121.cmped(cache, 'ALL', outfile)
	}else {
		for (typei in types) {

			posicol = which(annotation_coluse == typei)
	
			cache0 = cache[,posicol]
			corcalculate121.cmped(cache0, typei, outfile)
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
