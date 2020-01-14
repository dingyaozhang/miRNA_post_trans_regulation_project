library(hash)

splitthis1 = function(x) {return(strsplit(unlist(x), split = "/")[[1]][1])}
splitthis2 = function(x) {return(strsplit(unlist(x), split = "/")[[1]][2])}
calculrela <- function(gene, mirnaone, mirnatwo) {
	
	
	a = as.numeric(unlist(gene))
	b = as.numeric(unlist(mirnaone))
	c = as.numeric(unlist(mirnatwo))

	usecols = intersect(which(a != 0), which(b != 0))
	usecols = intersect(usecols, which(c != 0))

	if (length(usecols) <=  1/8*length(a) ) {
   		return(c('NANA', 'NANA', 'NANA'))
   	}else{
   		a = a[usecols]
		b = b[usecols]
  		c = c[usecols]

  		a = log(a,2)
  		b = log(b,2)
  		c = log(c,2)
  		ratiob = b/a
  		ratioc = c/a
  		geneone = cor(a, b, method = "spearman")
		genetwo = cor(a, c, method = "spearman")
		geneone2 = cor(ratiob, b, method = "spearman")
		genetwo2 = cor(ratioc, c, method = "spearman")
		onetwo = cor(b, c, method = "spearman")
		geneone3 = cor(a, b)
		genetwo3 = cor(a, c)
		onetwo3 = cor(b, c)
		return(c(geneone, genetwo, geneone2, genetwo2, onetwo, geneone3, genetwo3, onetwo3, mean(b), mean(c), length(usecols) ))
   	}
 
}


arg = commandArgs(T)


cache <- read.table(arg[1], header = TRUE, sep = '\t')


mirnaname = as.character(cache[,1])
genename = as.character(cache[,2])
cache = cache[,-1]
cache = cache[,-1]

colall0 = colnames(cache)
colall0 = gsub(pattern = "\\.", replacement = '-', x = colall0)


annotation_in <- read.table(arg[2], header = FALSE, sep = '\t', stringsAsFactors = FALSE)
outpath = arg[3]


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



types = as.character(unique(unlist(genename)))

write.table(t(c("gene", "mirna1", "mirna2", "cor-mir1-gene-s", "cor-mir2-gene-s",  "cor-mir1-ratio-s", "cor-mir2-ratio-s", "cor-mir1-mir2-s", "cor-mir1-gene-p", "cor-mir2-gene-p", "cor-mir1-mir2-p", 'mir1mean', 'mir2mean', 'useful_values')), file = outpath, row.names = FALSE, col.names = FALSE, append = FALSE, quote = FALSE, sep = "\t")


for (i in types) {


	mirnathistypenum = which(genename == i)
	mirnathistype = mirnaname[mirnathistypenum]

	alllen = length(mirnathistypenum)
	mirnaprename = gsub(pattern = "-[0-9]p$", replacement = '', x = mirnathistype)
	tablein = combn(1:alllen, 2)
	result = apply(tablein, 2, FUN = function(x){
	
		mirnaonei = mirnathistypenum[x[1]]
		mirnatwoi = mirnathistypenum[x[2]]
		mirnaonename = mirnathistype[x[1]]
		mirnatwoname = mirnathistype[x[2]]
		if (mirnaprename[x[1]] == mirnaprename[x[2]]) {
			return(rep('NANA', 14))
		}else{
			mirnaone = apply(t(cache[mirnaonei,]), 1, splitthis1)
			mirnatwo = apply(t(cache[mirnatwoi,]), 1, splitthis1)
			gene = apply(t(cache[mirnatwoi,]), 1, splitthis2)

			out = calculrela(gene, mirnaone, mirnatwo)

			if (out[1] == 'NANA') {
				return(rep('NANA', 14))
			}else{
				
				return(c(i, mirnaonename, mirnatwoname, out ) ) 
			}
		}
	
	})
	result = t(result)
	result = as.data.frame(result, stringsAsFactors = FALSE)
	if (length(which(result[,1] != 'NANA')) >= 1) {
		result = result[which(result[,1] != 'NANA'), ]
		
		write.table(result, file = outpath, row.names = FALSE, col.names = FALSE, append = TRUE, quote = FALSE, sep = "\t")
	}

}



warnings()