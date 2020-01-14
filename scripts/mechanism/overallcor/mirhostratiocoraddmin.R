suppressMessages(library(hash))


splitthis1 = function(x) {return(strsplit(unlist(x), split = "/")[[1]][1])}
splitthis2 = function(x) {return(strsplit(unlist(x), split = "/")[[1]][2])}

arg = commandArgs(T)
if (! file.exists(arg[3])) {
	dir.create(arg[3], recursive = T)
}
outcenpath = paste0(arg[3], "/overallcorrelation")


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


annotation_coluse = as.data.frame(annotation_coluse)
rownames(annotation_coluse) = colnames(cache)
colnames(annotation_coluse) = c('TCGA_project')

types = as.character(unique(unlist(annotation_coluse)))


title = t(c("miRNA-NAME", 'mirtruenum', 'meanmir', 'genetruenum', 'meangene', "nor-mir-ratio", "spe-mir-ratio", "ken-mir-ratio", "nor-gene-mirna", "spe-gene-mirna", "ken-gene-mirna", "nor-mir-fanratio", "spe-mir-fanratio", "ken-mir-fanratio", "nor-gene-ratio", "spe-gene-ratio", "ken-gene-ratio", "nor-gene-fanratio", "spe-gene-fanratio", "ken-gene-fanratio", 'genecontribute', 'ratiocontribute', "rsquareratio", "rsquarehost"))
write.table(title, file = paste0(outcenpath, ".txt"), row.names = FALSE, col.names = FALSE, append = FALSE, quote = FALSE, sep = "\t")
alllen = length(cache[,1])
lenrow = length(cache[1,])

for (i in 1:alllen) {

	a = apply(t(cache[i,]), 1, splitthis1)
	b = apply(t(cache[i,]), 1, splitthis2)
	a = as.numeric(a)
	b = as.numeric(b)
	
	if (sum(a != 0) == 0)  {
   		next
   	}
    if (sum(b != 0) == 0)  {
   		next
    }	

   	mirtruenum = sum(a != 0)
   	genetruenum = sum(b != 0)
   	mirzeronum = sum(a == 0)
   	genezeronum = sum(b == 0)

   	
    a2 = 1/3*min(a[a != 0]) + a
    b2 = 1/3*min(b[b != 0]) + b

	c = a2 / b2
	d = b2 / a2

	if (mirzeronum > 0){
  		a = a2
    }

    if (genezeronum > 0){
  		b = b2
    }

	a = log(a,2)
	b = log(b,2)
	c = log(c,2)
	d = log(d,2)
	
	
	norcor = cor(a, c)
	specor = cor(a, c, method = "spearman")
	kencor = cor(a, c, method = "kendall")
	norcor2 = cor(a, b)
	specor2 = cor(a, b, method = "spearman")
	kencor2 = cor(a, b, method = "kendall")
	norcor3 = cor(a, d)
	speco3 = cor(a, d, method = "spearman")
	kencor3 = cor(a, d, method = "kendall")
	norcor4 = cor(b, c)
	speco4 = cor(b, c, method = "spearman")
	kencor4 = cor(b, c, method = "kendall")
	norcor5 = cor(b, d)
	speco5 = cor(b, d, method = "spearman")
	kencor5 = cor(b, d, method = "kendall")

	tempframe <- as.data.frame(cbind(a, b, c))
	suppressWarnings(resbc <- anova(lm(a~b + c, tempframe))$`Sum Sq`)
	suppressWarnings(rescb <- anova(lm(a~c + b, tempframe))$`Sum Sq`)
	
	bunderbc = resbc[1] /(resbc[1] + resbc[2])
	cunderbc = resbc[2] /(resbc[1] + resbc[2])
	bundercb = rescb[2] /(rescb[1] + rescb[2])
	cundercb = rescb[1] /(rescb[1] + rescb[2])


	res = t(c(rownames[i], mirtruenum, mean(a), genetruenum, mean(b), norcor, specor, kencor, norcor2, specor2, kencor2, norcor3, speco3, kencor3, norcor4, speco4, kencor4, norcor5, speco5, kencor5, (bunderbc + bundercb)/2, (cunderbc + cundercb)/2, norcor^2, norcor2^2))
	write.table(res, file = paste0(outcenpath, ".txt"), row.names = FALSE, col.names = FALSE, append = TRUE, quote = FALSE, sep = "\t")
}


gctrash = gc()

for (typei in types) {

	title = t(c("miRNA-NAME", 'mirtruenum', 'meanmir', 'genetruenum', 'meangene', "nor-mir-ratio", "spe-mir-ratio", "ken-mir-ratio", "nor-gene-mirna", "spe-gene-mirna", "ken-gene-mirna", "nor-mir-fanratio", "spe-mir-fanratio", "ken-mir-fanratio", "nor-gene-ratio", "spe-gene-ratio", "ken-gene-ratio", "nor-gene-fanratio", "spe-gene-fanratio", "ken-gene-fanratio", 'genecontribute', 'ratiocontribute', "rsquareratio", "rsquarehost"))
	filepath = paste0(outcenpath, typei, ".txt")
	write.table(title, file = filepath, row.names = FALSE, col.names = FALSE, append = FALSE, quote = FALSE, sep = "\t")
	colone0 = as.data.frame(as.numeric(annotation_coluse == typei))		
	
	posicol = which(colone0 == 1)
	if (length(posicol) <= 5) {
		print(paste0("too small", typei))
		next
	}
	cache0 = cache[,posicol]

	alllen = length(cache0[,1])

	for (i in 1:alllen) {

		a = apply(t(cache0[i,]), 1, splitthis1)
		b = apply(t(cache0[i,]), 1, splitthis2)
		a = as.numeric(a)
		b = as.numeric(b)


		if (sum(a != 0) < 10)  {
   			next
   		}
    	if (sum(b != 0) < 10)  {
   			next
    	}
		
		mirtruenum = sum(a != 0)
	   	genetruenum = sum(b != 0)
	   	mirzeronum = sum(a == 0)
	   	genezeronum = sum(b == 0)
	
	    
	    a2 = 1/3*min(a[a != 0]) + a
    	b2 = 1/3*min(b[b != 0]) + b
	
		c = a2 / b2
		d = b2 / a2
	
		if (mirzeronum > 0){
	  		a = a2
	    }
	
	    if (genezeronum > 0){
	  		b = b2
	    }
	
		a = log(a,2)
		b = log(b,2)
		c = log(c,2)
		d = log(d,2)
			
		norcor = cor(a, c)
		specor = cor(a, c, method = "spearman")
		kencor = cor(a, c, method = "kendall")
		norcor2 = cor(a, b)
		specor2 = cor(a, b, method = "spearman")
		kencor2 = cor(a, b, method = "kendall")
		norcor3 = cor(a, d)
		speco3 = cor(a, d, method = "spearman")
		kencor3 = cor(a, d, method = "kendall")
		norcor4 = cor(b, c)
		speco4 = cor(b, c, method = "spearman")
		kencor4 = cor(b, c, method = "kendall")
		norcor5 = cor(b, d)
		speco5 = cor(b, d, method = "spearman")
		kencor5 = cor(b, d, method = "kendall")

		tempframe <- as.data.frame(cbind(a, b, c))
		suppressWarnings(resbc <- anova(lm(a~b + c, tempframe))$`Sum Sq`)
		suppressWarnings(rescb <- anova(lm(a~c + b, tempframe))$`Sum Sq`)
		bunderbc = resbc[1] /(resbc[1] + resbc[2])
		cunderbc = resbc[2] /(resbc[1] + resbc[2])
		bundercb = rescb[2] /(rescb[1] + rescb[2])
		cundercb = rescb[1] /(rescb[1] + rescb[2])

		res = t(c(rownames[i], mirtruenum, mean(a), genetruenum, mean(b), norcor, specor, kencor, norcor2, specor2, kencor2, norcor3, speco3, kencor3, norcor4, speco4, kencor4, norcor5, speco5, kencor5, (bunderbc + bundercb)/2, (cunderbc + cundercb)/2, norcor^2, norcor2^2))
		write.table(res, file = filepath, row.names = FALSE, col.names = FALSE, append = TRUE, quote = FALSE, sep = "\t")
	}

	rm(a)
	rm(b)
	rm(c)
	rm(d)
	rm(res)
	rm(norcor)
	rm(cache0)
	rm(colone0)
	gctrash = gc()
}

warnings()
