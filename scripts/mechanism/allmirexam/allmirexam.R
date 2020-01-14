library(hash)
library("doParallel")
library("foreach")
library("compiler")


splitthis1 <- function(x) {return(strsplit(unlist(x), split = "/")[[1]][1])}
splitthis2 <- function(x) {return(strsplit(unlist(x), split = "/")[[1]][2])}


set.seed(5)
arg = commandArgs(T)

if (length(arg) == 0) {
	outfile = c('explain5p3pbytarget.txt', "cache/cumu-count.txt")
}else{
	outfile = arg[1]
	if (is.na(arg[2])) {
		outfile[2] = "cache/cumu-count.txt"
	}else{
		outfile[2] = arg[2]
	}

}

cl <- makeCluster(4)
registerDoParallel(cl)

calculateone <- function(cachemir, cachegene, cachenamemir, cachenamegene, tissuename, fileout) {

	
	
	

	usegene = which(apply(cachegene, 1, FUN = function(xx){length(unique(xx))}  ) > 1)

	if ( length(usegene) >= 1) {

		if ( length(usegene) == 1) {
			cachegene = t(cachegene[usegene,])
			cachenamegene = cachenamegene[usegene]
		}else{
			cachegene = cachegene[usegene,]
			cachenamegene = cachenamegene[usegene]
		}


		
		genemedium = apply(cachegene, 1, mean)
		
		gc()
		
		for (i in 1:(length(cachenamemir)) ) {
	
				
				mirname = cachenamemir[i]
				ares = apply(as.matrix(cachemir[i,]), 1, splitthis1)


				bres = apply(as.matrix(cachemir[i,]), 1, splitthis2)
				ares = as.numeric(ares)
				bres = as.numeric(bres)
				if (length(unique(ares))  == 1) {
					next
				}
				if (length(unique(bres))  == 1) {
					next
				}
				ares = ares + 1/3*min(ares[ares != 0])
				bres = bres + 1/3*min(bres[bres != 0])
				ratio = ares / bres
				mirmedium = mean(ares)
	
	
				
	
				
				
				
				outframe = foreach (i2 = 1:(dim(cachegene)[1]),.combine = 'rbind') %dopar% {
			
					genei2num = cachegene[i2,]
					
					specor = cor.test(ratio, genei2num, method = "spearman", exact = FALSE)
					specora = cor.test(ares, genei2num, method = "spearman", exact = FALSE)
					specorb = cor.test(bres, genei2num, method = "spearman", exact = FALSE)
			
					return(c(tissuename, mirname, cachenamegene[i2], mirmedium, 'genemedium', unname(specor$estimate), 	unname(specor$p.value), unname(specora$estimate), unname(specora$p.value), unname(specorb$	estimate), unname(specorb$p.value) ))
	
					
			
				}
				outframe[,5] = genemedium
				write.table(outframe, file = fileout, row.names = FALSE, col.names = FALSE, append = TRUE, quote = 	FALSE, sep = "\t")
	
				
		}
	
		gc()
	}
	warnings()

	
}

calculateone.cmped = cmpfun(calculateone)

write.table(t(c("tissue", "miRNA_name", 'target_gene_name', "logmiR_mean", 'loggene_mean', "ratio-statistic", "ratio-p-value", "mir-statistic", "mir-p-value", "host-statistic", "host-p-value")), file = outfile[1], row.names = FALSE, col.names = FALSE, append = FALSE, quote = FALSE, sep = "\t")
cache <- read.table(outfile[2], header = FALSE, sep = '\t', stringsAsFactors = FALSE)
annotation_in <- read.table("../predicgct/data/realtcgaprojectlist.txt", header = FALSE, sep = '\t', stringsAsFactors = FALSE) 

cachename = as.vector(unlist( as.character(cache[,1]) ) )
rownames = make.names(cachename, unique = TRUE)
row.names(cache) = rownames



cache = cache[,-(1:2)]
colall0 = as.vector(as.character(unlist(cache[1,]) ) )
cache = cache[-1,]
cachename = cachename[-1]



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


types = as.character(unique(unlist(annotation_coluse)))

mirrows = grep('[^-]+-[^-]+-[^-]+', cachename)
generows = 1:length(cachename)
generows = generows[-mirrows]
cachenamemir = cachename[mirrows]
cachenamegene = cachename[generows]

if (length(mirrows) == 1) {
	cachemir = t(apply(cache[mirrows,], 2, as.character))
}else{
	cachemir = as.matrix(apply(cache[mirrows,], 2, as.character))
}

if (length(generows) == 1) {
	cachegene = t(apply(cache[generows,], 2, as.numeric))
}else{
	cachegene = as.matrix(apply(cache[generows,], 2, as.numeric))
}

rm(cache)
rm(cachename)
rm(generows)
rm(mirrows)
gc()
gc()

calculateone.cmped(cachemir, cachegene, cachenamemir, cachenamegene, 'ALL', outfile[1])

for (typei in types) {

	colone0 = as.data.frame(as.numeric(annotation_coluse == typei))		
	posicol = which(colone0 == 1)
	cachemir0 = cachemir[,posicol]
	cachegene0 = cachegene[,posicol]

	calculateone.cmped(cachemir0, cachegene0, cachenamemir, cachenamegene, typei, outfile[1])


}


stopCluster(cl)
