library(hash)

splitthis1 = function(x) {return(strsplit(unlist(x), split = "/")[[1]][1])}
splitthis2 = function(x) {return(strsplit(unlist(x), split = "/")[[1]][2])}

arg = commandArgs(T)


cache <- read.table(arg[1], header = TRUE, sep = '\t')
annotation_in <- read.table(arg[2], header = FALSE, sep = '\t', stringsAsFactors = FALSE) 

cachename = as.vector(unlist(as.character(cache[,1])))
rownames = make.names(cachename, unique = TRUE)
row.names(cache) = rownames
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


######
row584 = which(cachename == "hsa-miR-584-5p")

a = apply(t(cache[row584,]), 1, splitthis1)
b = apply(t(cache[row584,]), 1, splitthis2)
a = as.numeric(a)
b = as.numeric(b)

a2 = 1/3*min(a[a != 0]) + a
b2 = 1/3*min(b[b != 0]) + b

ratio = a2/b2

if (sum(a == 0) >= 1) {
	a = a2
}
if (sum(b == 0) >= 1) {
	b = b2
}

a = log(a, 2)
b = log(b, 2)
ratio = log(ratio,2)

out = rbind(a, b)
out = as.data.frame(rbind(out, ratio))
out = cbind(c('mir584mature', 'mir584host', 'mir584ratio'), out)
write.table(out, file = paste0(arg[3],'mir584adraw.txt'), row.names = FALSE, col.names = FALSE, append = FALSE, quote = FALSE, sep = "\t")


#######

row140 = which(cachename == "hsa-miR-140-5p")

a = apply(t(cache[row140,]), 1, splitthis1)
b = apply(t(cache[row140,]), 1, splitthis2)
a = as.numeric(a)
b = as.numeric(b)

a2 = 1/3*min(a[a != 0]) + a
b2 = 1/3*min(b[b != 0]) + b

ratio = a2/b2

if (sum(a == 0) >= 1) {
	a = a2
}
if (sum(b == 0) >= 1) {
	b = b2
}

a = log(a, 2)
b = log(b, 2)
ratio = log(ratio,2)

out = rbind(a, b)
out = as.data.frame(rbind(out, ratio))
out = cbind(c('mir140mature', 'mir140host', 'mir140ratio'), out)
write.table(out, file = paste0(arg[3],'mir140adraw.txt'), row.names = FALSE, col.names = FALSE, append = FALSE, quote = FALSE, sep = "\t")
