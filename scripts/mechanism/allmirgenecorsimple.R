suppressMessages(library(hash))
suppressMessages(library("doParallel"))
suppressMessages(library("foreach"))
suppressMessages(library("compiler"))

#Rscript draweach.R clu31.txt result/mechanism/modulecluster/select88/adjustfilter/figure/ test/
splitthis1 = function(x) {
	outx = do.call(cbind, strsplit(unlist(x), split = "/"))
	return(suppressWarnings(as.numeric(unlist(outx[1,]))))
}
splitthis2 = function(x) {
	outx = do.call(cbind, strsplit(unlist(x), split = "/"))
	return(suppressWarnings(as.numeric(unlist(outx[2,]))))
}

set.seed(5)
arg = commandArgs(T)

if (! is.na(arg[4])) {
	usefultypes <- read.table(arg[4], header = FALSE, sep = '\t', stringsAsFactors = FALSE)
	usefultypes = unlist(usefultypes)
}



outfile = arg[3]

numberit <- function(aa){
	aa = suppressWarnings(as.numeric(aa))
	return(aa)
}


calculateone <- function(mirmat, hostmat, ratiomat, genemat, cachenamemir, cachenamegene, tissuename, fileout) {
	cl <- makeCluster(3)
	registerDoParallel(cl)

	
	rownum <- dim(mirmat)[2]
	matcor = foreach (i222 = 1:3) %dopar% {

		if (i222 == 1) {
			matcorin = cor(mirmat, genemat, use = 'all.obs', method = "spearman")
		}else if (i222 == 2) {
			matcorin = cor(hostmat, genemat, use = 'all.obs', method = "spearman")
		}else if (i222 == 3) {
			matcorin = cor(ratiomat, genemat, use = 'all.obs', method = "spearman")
		}
		return(matcorin)
	}
	for (rowi in 1:rownum) {
		out = cbind(tissuename, cachenamemir[rowi], cachenamegene, unlist(matcor[[1]][rowi,]), unlist(matcor[[2]][rowi,]), unlist(matcor[[3]][rowi,]))
		out = na.omit(out)
		write.table(out, file = fileout, row.names = FALSE, col.names = FALSE, append = TRUE, quote = FALSE, sep = "\t")
	}

	stopCluster(cl)
}


calculateone.cmped = cmpfun(calculateone)

write.table(t(c("tissue", "miRNA_name", 'target_gene_name', "mir-statistic", "host-statistic", "ratio-statistic")), file = outfile, row.names = FALSE, col.names = FALSE, append = FALSE, quote = FALSE, sep = "\t")
cache <- read.table(arg[1], header = FALSE, sep = '\t', stringsAsFactors = FALSE)
cache = as.matrix(cache)
annotation_in <- read.table(arg[2], header = FALSE, sep = '\t', stringsAsFactors = FALSE) 

cachename = as.vector(unlist( as.character(cache[,1]) ) )
rownames = make.names(cachename, unique = TRUE)
row.names(cache) = rownames



cache = cache[,-(1:2)]
colall = as.vector(as.character(unlist(cache[1,]) ) )
cache = cache[-1,]
cachename = cachename[-1]



if (length( (strsplit(annotation_in[1,1], '-'))[[1]]) != 4) {
	stop("error in input data format")

}

annohash = hash()
.set(annohash, keys = annotation_in[,1], values = annotation_in[,2])
colallnum = as.numeric(unname(which(has.key(colall, annohash))))
cache = cache[,colallnum]
colall = colall[colallnum]
annotation_coluse = unname(values(annohash, colall))


types = as.character(unique(unlist(annotation_coluse)))

mirrows = grep('[^-]+-[^-]+-[^-]+', cachename)
generows = 1:length(cachename)
generows = generows[-mirrows]
cachenamemir = cachename[mirrows]
cachenamegene = cachename[generows]


if (length(mirrows) == 1) {
	stop('too s for r to deal with small matrix')
}else{
	cachemir = as.matrix(apply(cache[mirrows,], 2, as.character))
}

if (length(generows) == 1) {
	stop('too s for r to deal with small matrix')
}else{
	cachegene = as.matrix(apply(cache[generows,], 2, numberit))
}


rm(cache)
rm(cachename)
rm(generows)

gctrash = gc()

cachemirmir = as.matrix(apply(cachemir[mirrows,], 2, splitthis1))
cachemirhost = as.matrix(apply(cachemir[mirrows,], 2, splitthis2))

mirselect <- which(apply(cachemirmir, 1, FUN <- function(xx){length(which(xx > 0))}) >= 8)
hostselect <- which(apply(cachemirhost, 1, FUN <- function(xx){length(which(xx > 0))}) >= 8) 
finalselect <- intersect(mirselect, hostselect)
cachemirmir <- cachemirmir[finalselect,]
cachemirhost <- cachemirhost[finalselect,]
mirfactor <- apply(cachemirmir, 1, FUN <- function(xx){ 1/3*min(xx[xx != 0]) })
hostfactor <- apply(cachemirhost, 1, FUN <- function(xx){ 1/3*min(xx[xx != 0]) })

cacheratio = (cachemirmir+mirfactor)/(cachemirhost+hostfactor)

userows <- which(apply(cachegene, 1, FUN <- function(xx){length(unique(xx))} ) > 1/10*dim(cachegene)[2])

rm(mirrows)
rm(cachemir)
gctrash = gc()

cachenamemir = cachenamemir[finalselect]


#cachemirmir = log(cachemirmir, 2)
#cachemirhost = log(cachemirhost, 2)
#cacheratio = log(cacheratio, 2)

gctrash = gc()

cachemirhost = t(cachemirhost)
cacheratio = t(cacheratio)
cachemirmir = t(cachemirmir)

cachegene = t(cachegene)



calculateone.cmped(cachemirmir, cachemirhost, cacheratio, cachegene[,userows], cachenamemir, cachenamegene[userows], 'ALL', outfile)

for (typei in types) {

	if (! is.na(arg[4])) {
		if (! typei %in% usefultypes) {
			next
		}
	}

	posicol = which(annotation_coluse == typei)
	
	cachemirhost0 = cachemirhost[posicol,]
	cacheratio0 = cacheratio[posicol,]
	cachemirmir0 = cachemirmir[posicol,]
	cachegene0 = cachegene[posicol,]

	mirselect0 <- which(apply(cachemirmir, 2,  FUN <-  function(xx){length(which(xx > 0))}) >= 8)
	hostselect0 <- which(apply(cachemirhost, 2,  FUN <-  function(xx){length(which(xx > 0))}) >= 8) 
	finalselect0 <- intersect(mirselect0, hostselect0)
	cachemirmir0 <- cachemirmir0[,finalselect0]
	cachemirhost0 <- cachemirhost0[,finalselect0]
	cacheratio0 <- cacheratio0[,finalselect0]

	usecols <- which(apply(cachegene0, 2, FUN <- function(xx){length(unique(xx))} ) > 1/10*dim(cachegene0)[1])

	cachenamemir0 = cachenamemir[finalselect0]
	cachenamegene0 = cachenamegene[usecols]
	
	calculateone.cmped(cachemirmir0, cachemirhost0, cacheratio0, cachegene0[,usecols], cachenamemir0, cachenamegene0, typei, outfile)


}



warnres = warnings()
if (! is.null(warnres)) {
	print(arg)
	print(warnres)
}
