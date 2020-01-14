suppressMessages(library(hash))


splitthis1 = function(x) {return(strsplit(unlist(x), split = "/")[[1]][1])}
splitthis2 = function(x) {return(strsplit(unlist(x), split = "/")[[1]][2])}

args = commandArgs(T)
if (! file.exists(args[3])) {
	dir.create(args[3], recursive = T)
}

outcenpath = paste0(args[3], "/overallcorrelation")

cache <- read.table(args[1], header = TRUE, sep = '\t')
annotation_in <- read.table(args[2], header = FALSE, sep = '\t', stringsAsFactors = FALSE) 

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
	stop("error in input data format")
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


title = t(c("miRNA-NAME", "spearman-cor", "pearson-cor", "kendall-cor", "p-Value-spearman", "p-Value-pearson", "p-Value-kendall"))
write.table(title, file = paste0(outcenpath, '.txt'), row.names = FALSE, col.names = FALSE, append = FALSE, quote = FALSE, sep = "\t")
alllen = length(cache[,1])

for (i in 1:alllen) {

	a = apply(t(cache[i,]), 1, splitthis1)
	b = apply(t(cache[i,]), 1, splitthis2)
	a = as.numeric(a)
	b = as.numeric(b)
	
	if (length(unique(a)) < 10 ){
   		next
    }
    if (length(unique(b)) < 10 ){
   		next
    }
   	
    mirtruenum = sum(a != 0)
   	genetruenum = sum(b != 0)
   	mirzeronum = sum(a == 0)
   	genezeronum = sum(b == 0)

   
    
    a2 = (1/3*min(a[a != 0]) + a)
    b2 = (1/3*min(b[b != 0]) + b)

	if (mirzeronum > 0){
  		a = a2
    }
    if (genezeronum > 0){
  		b = b2
    }

	a = log(a,2)
	b = log(b,2)

   
	

	specor = cor(a, b, method = "spearman")
	norcor = cor(a, b)
	kencor = cor(a, b, method = "kendall")
	pvs = cor.test(a, b, method = 'spearman', exact = FALSE)$p.value
	pvp = cor.test(a, b)$p.value
	pvk = cor.test(a, b, method = 'kendall', exact = FALSE)$p.value
	
	res = t(c(rownames[i], specor, norcor, kencor, pvs, pvp, pvk))
	write.table(res, file = paste0(outcenpath, '.txt'), row.names = FALSE, col.names = FALSE, append = TRUE, quote = FALSE, sep = "\t")
}


gctrash = gc()

for (i in types) {

	title = t(c("miRNA-NAME", "spearman-cor", "pearson-cor", "kendall-cor", "p-Value-spearman", "p-Value-pearson", "p-Value-kendall"))

	filepath = paste0(outcenpath, i, ".txt")
	write.table(title, file = filepath, row.names = FALSE, col.names = FALSE, append = FALSE, quote = FALSE, sep = "\t")
	colone0 = as.data.frame(as.numeric(annotation_coluse == i))		
	
	posicol = which(colone0 == 1)
	if (length(posicol) <= 5) {
		stop(paste0("too small", i))
		next
	}
	cache0 = cache[,posicol]
	alllen = length(cache0[,1])

	for (i in 1:alllen) {

		a = apply(t(cache0[i,]), 1, splitthis1)
		b = apply(t(cache0[i,]), 1, splitthis2)
		a = as.numeric(a)
		b = as.numeric(b)
		if (length(unique(a)) < 10 ){
   			next
    	}
    	if (length(unique(b)) < 10 ){
   			next
    	}
		
		mirtruenum = sum(a != 0)
   		genetruenum = sum(b != 0)
   		mirzeronum = sum(a == 0)
   		genezeronum = sum(b == 0)
	
    	
    	a2 = (1/3*min(a[a != 0]) + a)
    	b2 = (1/3*min(b[b != 0]) + b)
	
		if (mirzeronum > 0){
  			a = a2
    	}
    	if (genezeronum > 0){
  			b = b2
    	}
	
		a = log(a,2)
		b = log(b,2)

		
			
		
		specor = cor(a, b, method = "spearman")
		norcor = cor(a, b)
		kencor = cor(a, b, method = "kendall")
		pvs = cor.test(a, b, method = 'spearman', exact = FALSE)$p.value
		pvp = cor.test(a, b)$p.value
		pvk = cor.test(a, b, method = 'kendall', exact = FALSE)$p.value
	
		res = t(c(rownames[i], specor, norcor, kencor, pvs, pvp, pvk))
		write.table(res, file = filepath, row.names = FALSE, col.names = FALSE, append = TRUE, quote = FALSE, sep = "\t")
	}
	rm(a)
	rm(b)
	rm(res)
	rm(norcor)
	gctrash = gc()
}

warnings()