suppressMessages(library(hash))
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





myperiso = c()

colmirnapre = gsub(pattern = "\\.", replacement = '-', x = colnames(cachemir))
colgenepre = unname(values(mirnagenehash, colmirnapre))
colgenetypes = as.character(unique(colgenepre))
for (i in colgenetypes) {
	if (is.na(i)) {
		stop("die error i")
	}
	thistypecache = as.data.frame(cachemir[,which(colgenepre == i)])
	mycolmax = unname(which.max(apply(thistypecache, 2, mean)))
	mycolmax = (which(colgenepre == i))[mycolmax]

	myperiso = c(myperiso, mycolmax)
}
cachemir = cachemir[,myperiso]


outputcolgenes = colnames(cachemir)
outputcolgenes = gsub(pattern = "\\.", replacement = '-', x = outputcolgenes)
write.table(as.data.frame(outputcolgenes), file = paste0(arg[3], 'genelist.txt'), row.names = FALSE, col.names = FALSE, sep="\t", quote = FALSE)

warnings()