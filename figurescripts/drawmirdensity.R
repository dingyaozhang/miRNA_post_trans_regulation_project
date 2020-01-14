library(ggplot2)
library(Cairo)
library(hash)

arg = commandArgs(T)



splitthis1 = function(x) {return(strsplit(unlist(x), split = "/")[[1]][1])}
splitthis2 = function(x) {return(strsplit(unlist(x), split = "/")[[1]][2])}



cache <- read.table(arg[1], header = FALSE, stringsAsFactors = FALSE, sep = '\t')


cachename = as.vector(unlist(as.character(cache[,1])))
rownames = make.names(cachename, unique = TRUE)
row.names(cache) = rownames

cachename2 = as.vector(unlist(as.character(cache[1,])))
colname = make.names(cachename2, unique = TRUE)
colnames(cache) = colname

rownames = rownames[-1]
cache = cache[-1,]
cachename = cachename[-1]
cache = cache[,-1]
cache = cache[,-1]
cachename2 = cachename2[-(1:2)]
colname = colname[-1]
colname = colname[-1]

annotation_in <- read.table(arg[2], header = FALSE, sep = '\t', stringsAsFactors = FALSE)
colall0 = colname
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


annotation_coluse = as.data.frame(annotation_coluse)
rownames(annotation_coluse) = colnames(cache)
colnames(annotation_coluse) = c('TCGA_project')
colone0 = as.data.frame(as.numeric(annotation_coluse[,1]))	




data = cache

i = grep(arg[4], cachename)
	
a1 = apply(t(data[i,]), 1, splitthis1)
b1 = apply(t(data[i,]), 1, splitthis2)
a1 = as.numeric(a1)
b1 = as.numeric(b1)

a2 = mean((sort(a1[a1 != 0]))[1:5]) + a1
b2 = mean((sort(b1[b1 != 0]))[1:5]) + b1
if (sum(a1 == 0) >= 1){
	a1 = a2
}
if (sum(b1 == 0) >= 1){
	b1 = b2
}


a = a2 / b2
	

thistable = as.data.frame(log(a))
colnames(thistable) = c('count')

	 
p = ggplot(thistable, aes(x = count)) + geom_density(color = 'black', size=1.25, fill="gray") + geom_histogram(aes(y=..count../sum(..count..)), colour="black", fill="white", bins =15, alpha = 0.2)
p = p + labs(x = 'log2(5p/3p ratio)', y= 'Proportion', title = arg[4])
#p = p + theme(panel.background = element_blank(), axis.line = element_line(colour = "black", size = 0.8), title = element_text(face="bold", size=10, color = 'black'), axis.title = element_text(face="bold", size=12, color = 'black'), axis.text.x = element_text(face="bold", size = 12, color = 'black'), axis.text.y = element_text(face="bold", size = 12, color = 'black') )

CairoPDF(file= arg[3])
print(p)
dev.off()