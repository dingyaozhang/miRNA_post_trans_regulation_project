library(hash)



splitthis1 = function(x) {return(strsplit(unlist(x), split = "/")[[1]][1])}
splitthis2 = function(x) {return(strsplit(unlist(x), split = "/")[[1]][2])}


set.seed(5)
arg = commandArgs(T)



cache <- read.table(arg[1], header = FALSE, sep = '\t',  stringsAsFactors = FALSE)
cache = as.matrix(cache)
gc()
annotation_in <- read.table(arg[2], header = FALSE, sep = '\t', stringsAsFactors = FALSE) 
outfile = arg[3]
dim(cache)

cachename = as.vector(unlist( as.character(cache[,1]) ) )
row.names(cache) = cachename



cache = cache[,-(1:2)]
colall = as.vector(as.character(unlist(cache[1,]) ) )
cache = cache[-1,]


if (length( (strsplit(annotation_in[1,1], '-'))[[1]]) != 4) {
	stop("error in input genelist format")
}

annohash = hash()
.set(annohash, keys = annotation_in[,1], values = annotation_in[,2])
colallnum = as.numeric(unname(which(has.key(colall, annohash))))
cache = cache[,colallnum]
colall = colall[colallnum]
cachename = gsub('\\..*', '', cachename)

dim(cache)
length(colall)
length(cachename)
cache = apply(cache, 2, as.character)
dim(t(colall))
tit = t(colall)
cache = rbind(tit, cache)

cache = cbind(cachename, cache)


write.table(cache, file = outfile, row.names = FALSE, col.names = FALSE, sep="\t", quote = FALSE, append = FALSE)