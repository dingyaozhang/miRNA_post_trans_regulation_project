library(hash)
arg = commandArgs(T)

set.seed(5)



splitthis1 = function(x) {
	outx = do.call(cbind, strsplit(unlist(x), split = "/"))
	return(as.numeric(unlist(outx[1,])))
}
splitthis2 = function(x) {
	outx = do.call(cbind, strsplit(unlist(x), split = "/"))
	return(as.numeric(unlist(outx[2,])))
}


cache <- read.table(arg[1], header = TRUE, sep = '\t', stringsAsFactors = FALSE)
annotation_in <- read.table(arg[2], header = FALSE, sep = '\t', stringsAsFactors = FALSE) 

cachename = as.vector(unlist( as.character(cache[,1]) ) )
rownames = make.names(cachename, unique = TRUE)
row.names(cache) = rownames

mirnagenehash = hash()
.set(mirnagenehash, keys = as.character(cache[,1]), values = as.character(cache[,2]))

cache = cache[,-1]
cache = cache[,-1]

colall0 = colnames(cache)
colall0 = gsub(pattern = "\\.", replacement = '-', x = colall0)


if (length( (strsplit(annotation_in[1,1], '-'))[[1]]) == 4) {

	colall = colall0

}else if (length( (strsplit(annotation_in[1,1], '-'))[[1]]) == 3) {

	
	colall = gsub(pattern = "-[^-]+$", replacement = '', x = colall0)
	
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



types = as.character(unique(annotation_coluse))


wholelengthcol = length(cache[1,])

cachemir = apply(cache, 1, splitthis1)
cachegene = apply(cache, 1, splitthis2)
colnames(cachemir) <- rownames(cache)
colnames(cachegene) <- rownames(cache)

rm(cache)


coluniquemir <- apply(cachemir, 2, FUN <- function(xx) {
		xx = unlist(xx)
		return(length(unique(xx)))
})

coluniquegene <- apply(cachegene, 2, FUN <- function(xx) {
		xx = unlist(xx)
		return(length(unique(xx)))
})


mingeneusenum <- 0.9*length(cachemir[,1])
colsave <- intersect(which(coluniquemir > mingeneusenum), which(coluniquegene > mingeneusenum))

if ( length(colsave)  >= 1 ) {
	minmirvalue <- median(unlist(cachemir[,colsave]))
	mingenevalue <- median(unlist(cachegene[,colsave]))
}else{
	stop("too less useful cols")
}

topreserve = c()

for (typei in types) {
	

	posicol = which(annotation_coluse == typei)
	if (length(posicol) == 1) {
		stop("too less this type")
	}else if (length(posicol) >= 100) {
		cachemir2 = cachemir[posicol,]
		cachegene2 = cachegene[posicol,]
		coluniquemir2 <- apply(cachemir2, 2, FUN <- function(xx) {
			xx = unlist(xx)
			return(length(unique(xx)))
		})
		coluniquegene2 <- apply(cachegene2, 2, FUN <- function(xx) {
			xx = unlist(xx)
			return(length(unique(xx)))
		})
		colmeangene = apply(cachegene2, 2, median)
		colmeanmir = apply(cachemir2, 2, median)
		cachemirpreserve2 = which( coluniquemir2 > 0.9*length(posicol)  & colmeanmir >= 0.8*minmirvalue )
		cachegenepreserve2 = which( coluniquegene2 > 0.9*length(posicol) & colmeangene >= 0.8*mingenevalue )
	}else{
		cachemir2 = cachemir[posicol,]
		cachegene2 = cachegene[posicol,]
		coluniquemir2 <- apply(cachemir2, 2, FUN <- function(xx) {
			xx = unlist(xx)
			return(length(unique(xx)))
		})
		coluniquegene2 <- apply(cachegene2, 2, FUN <- function(xx) {
			xx = unlist(xx)
			return(length(unique(xx)))
		})
		colmeangene = apply(cachegene2, 2, median)
		colmeanmir = apply(cachemir2, 2, median)
		cachemirpreserve2 = which(coluniquemir2 == 0.9*length(posicol) & colmeanmir >= 0.5*minmirvalue )
		cachegenepreserve2 = which(coluniquegene2 == 0.9*length(posicol) & colmeangene >= 0.5*mingenevalue )
	}
	
	tissuespecial = intersect(cachemirpreserve2, cachegenepreserve2)
	topreserve = union(topreserve, tissuespecial)
}

colsave = union(topreserve, colsave)

if ( length(colsave)  >= 2 ) {
	cachemir = cachemir[,colsave]
	cachegene = cachegene[,colsave]
}else{
	stop("too less useful cols")
}



outputcolgenes = colnames(cachemir)
outputcolgenes = gsub(pattern = "\\.", replacement = '-', x = outputcolgenes)
write.table(as.data.frame(outputcolgenes), file = paste0(arg[3], 'genelist.txt'), row.names = FALSE, col.names = FALSE, sep="\t", quote = FALSE)

warnings()



cache <- read.table(arg[4], header = TRUE, sep = '\t', stringsAsFactors = FALSE)
annotation_in <- read.table(arg[5], header = FALSE, sep = '\t', stringsAsFactors = FALSE) 

cachename = as.vector(unlist( as.character(cache[,1]) ) )
rownames = make.names(cachename, unique = TRUE)
row.names(cache) = rownames

mirnagenehash = hash()
.set(mirnagenehash, keys = as.character(cache[,1]), values = as.character(cache[,2]))

cache = cache[,-1]
cache = cache[,-1]

colall0 = colnames(cache)
colall0 = gsub(pattern = "\\.", replacement = '-', x = colall0)


if (length( (strsplit(annotation_in[1,1], '-'))[[1]]) == 4) {

	colall = colall0

}else if (length( (strsplit(annotation_in[1,1], '-'))[[1]]) == 3) {

	
	colall = gsub(pattern = "-[^-]+$", replacement = '', x = colall0)
	
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

minusenum <- 1/4*min(table(annotation_coluse))

types = as.character(unique(annotation_coluse))


wholelengthcol = length(cache[1,])

cachemir = apply(cache, 1, splitthis1)
cachegene = apply(cache, 1, splitthis2)
colnames(cachemir) <- rownames(cache)
colnames(cachegene) <- rownames(cache)

rm(cache)


coluniquemir <- apply(cachemir, 2, FUN <- function(xx) {
		xx = unlist(xx)
		return(length(unique(xx)))
})

coluniquegene <- apply(cachegene, 2, FUN <- function(xx) {
		xx = unlist(xx)
		return(length(unique(xx)))
})


colsave <- intersect(which(coluniquemir > minusenum), which(coluniquegene > minusenum))
if ( length(colsave)  >= 2 ) {
	cachemir = cachemir[,colsave]
	cachegene = cachegene[,colsave]
}else{
	stop("too less useful cols")
}





outputcolgenes = colnames(cachemir)
outputcolgenes = gsub(pattern = "\\.", replacement = '-', x = outputcolgenes)
write.table(as.data.frame(outputcolgenes), file = paste0(arg[6], 'genelist.txt'), row.names = FALSE, col.names = FALSE, sep="\t", quote = FALSE)

warnings()