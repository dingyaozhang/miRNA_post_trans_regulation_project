library(hash)
library("doParallel")
library("foreach")
library("compiler")


splitthis1 <- function(x) {return(strsplit(unlist(x), split = "/")[[1]][1])}
splitthis2 <- function(x) {return(strsplit(unlist(x), split = "/")[[1]][2])}


set.seed(5)
arg = commandArgs(T)
outfile = arg[3]




calculate1circle <- function(genei, ares, bres, ratio, usecols, description) {
	usecols2 = intersect(usecols, which(genei != 'NA'))
	mir = as.numeric(ares[usecols2])
	host = as.numeric(bres[usecols2])
	ratio2 = as.numeric(ratio[usecols2])
	agene = as.numeric(genei[usecols2])

	if (length(usecols2) <= 5) {
		return(rep("NANA", 9))
	}else{
		specor = cor.test(ratio2, agene, method = "spearman", exact = FALSE)
		specora = cor.test(mir, agene, method = "spearman", exact = FALSE)
		specorb = cor.test(host, agene, method = "spearman", exact = FALSE)
		outout = c(description, unname(specor$estimate), unname(specor$p.value), unname(specora$estimate), unname(specora$p.value), unname(specorb$estimate), unname(specorb$p.value))
		return(outout)
	}
}
calculate1circle.cmped = cmpfun(calculate1circle)

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

		
		gctrash = gc()
		
		for (i in 1:(length(cachenamemir)) ) {
	
				
			mirname = cachenamemir[i]
			ares = apply(as.matrix(cachemir[i,]), 1, splitthis1)
			bres = apply(as.matrix(cachemir[i,]), 1, splitthis2)

			usecols = intersect(which(ares != 'NA'), which(bres != 'NA'))
			nacols = union(which(ares == 'NA'), which(bres == 'NA'))
			if (length(usecols) <= 5) {
				next
			}
			ratio = ares
			ratio[usecols] = log(as.numeric(ares[usecols])/as.numeric(bres[usecols]), 2)
			ratio[nacols] = 'NA'

			ares[usecols] <- log(as.numeric(ares[usecols]), 2)
			bres[usecols] <- log(as.numeric(bres[usecols]), 2)
			ares[nacols] = 'NA'
			bres[nacols] = 'NA'
			
			cl <- makeCluster(4)
			registerDoParallel(cl)
			outframe = foreach (i2 = 1:(dim(cachegene)[1]),.combine = 'rbind', .export = "calculate1circle.cmped") %dopar% {
				desin = c(tissuename, mirname, cachenamegene[i2])
				return(calculate1circle.cmped(unlist(cachegene[i2,]), ares, bres, ratio, usecols, desin))
			
			}
			stopCluster(cl)
			theuserow = which(outframe[,1] != 'NANA')
			if ( length(theuserow) == 1) {
				outframe = t(outframe[theuserow,])
				write.table(outframe, file = fileout, row.names = FALSE, col.names = FALSE, append = TRUE, quote = 	FALSE, sep = "\t")
			}else if ( length(theuserow) >= 2) {
				outframe = outframe[theuserow,]
				write.table(outframe, file = fileout, row.names = FALSE, col.names = FALSE, append = TRUE, quote = 	FALSE, sep = "\t")
			}
				
				
			rm(mirname)
			rm(ares)
			rm(bres)
			rm(usecols)
			rm(nacols)
			rm(ratio)
			rm(outframe)
			rm(theuserow)
			rm(outframe)
			gctrash = gc()
		}
	
		
	}
	warnings()

	
}


calculateone.cmped = cmpfun(calculateone)

write.table(t(c("tissue", "miRNA_name", 'target_gene_name', "ratio-statistic", "ratio-p-value", "mir-statistic", "mir-p-value", "host-statistic", "host-p-value")), file = outfile, row.names = FALSE, col.names = FALSE, append = FALSE, quote = FALSE, sep = "\t")
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
	cachemir = t(apply(t(cache[mirrows,]), 2, as.character))
}else{
	cachemir = as.matrix(apply(cache[mirrows,], 2, as.character))
}

if (length(generows) == 1) {
	stop('too s for r to deal with small matrix')
	cachegene = t(apply(t(cache[generows,]), 2, as.character))
}else{
	cachegene = as.matrix(apply(cache[generows,], 2, as.character))
}

dim(cachemir)
dim(cachegene)

rm(cache)
rm(cachename)
rm(generows)
rm(mirrows)
gc()
gc()

calculateone.cmped(cachemir, cachegene, cachenamemir, cachenamegene, 'ALL', outfile)

for (typei in types) {

	posicol = which(annotation_coluse == typei)
	print(posicol)
	cachemir0 = cachemir[,posicol]
	cachegene0 = cachegene[,posicol]

	calculateone.cmped(cachemir0, cachegene0, cachenamemir, cachenamegene, typei, outfile)


}



