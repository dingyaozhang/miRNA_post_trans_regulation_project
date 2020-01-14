suppressMessages(library(hash))

splitthis1 = function(x) {return(strsplit(unlist(x), split = "/")[[1]][1])}
splitthis2 = function(x) {return(strsplit(unlist(x), split = "/")[[1]][2])}

calcor <- function(mirna, host, factor, ratio){
	
	nm = cor.test(mirna, factor)
	nh = cor.test(host, factor)
	nr = cor.test(ratio, factor)
	sm = cor.test(mirna, factor, method = "spearman", exact = F)
	sh = cor.test(host, factor, method = "spearman", exact = F)
	sr = cor.test(ratio, factor, method = "spearman", exact = F)

	nmc = sign(nm$estimate)*(-log10(nm$p.value))
	nhc = sign(nh$estimate)*(-log10(nh$p.value))
	nrc = sign(nr$estimate)*(-log10(nr$p.value))
	smc = sign(sm$estimate)*(-log10(sm$p.value))
	shc = sign(sh$estimate)*(-log10(sh$p.value))
	src = sign(sr$estimate)*(-log10(sr$p.value))

	out = c(sm$p.value, sh$p.value, sr$p.value, sm$estimate, sh$estimate, sr$estimate, smc, shc, src, nm$p.value, nh$p.value, nr$p.value,  nm$estimate, nh$estimate, nr$estimate,  nmc, nhc, nrc )


	return(out)
}

calone <- function (sample, mir, host, factor, hashuse, name) {

	
	colallnum = as.numeric(unname(which(has.key(sample, hashuse))))
	
	annotation_coluse = unname(values(hashuse, sample[colallnum]))
	sample[colallnum] = annotation_coluse

	types = as.character(unique(annotation_coluse))
	mir2 = 1/3*min(mir[mir != 0]) + mir
	host2 = 1/3*min(host[host != 0]) + host
	if (sum(mir == 0) >= 1){
		mir = mir2
	}
	if (sum(host == 0) >= 1){
		host = host2
	}
	mir = log(mir, 2)
	host = log(host, 2)
	ratio = log((mir2/host2), 2)
	if (sum(factor == 0) >= 1){
		factor = 1/3*min(factor[factor != 0]) + factor
	}
	factor = log(factor, 2)


	outdata = calcor(mir, host, factor, ratio)
	outdata = c(name, 'all', outdata)
	write.table(t(outdata), file = finalout, row.names = FALSE, col.names = FALSE, append = TRUE, quote = FALSE, sep = "\t")
	gc()

	for (typei in types) {
		colsuse = which(sample == typei)

		outdata = calcor(mir[colsuse], host[colsuse], factor[colsuse], ratio[colsuse])
		outdata = c(name, typei, outdata)
		write.table(t(outdata), file = finalout, row.names = FALSE, col.names = FALSE, append = TRUE, quote = FALSE, sep = "\t")
		gc()
	}
		
	
}


arg = commandArgs(T)


finalout = arg[3]
annotation_in <- read.table(arg[2], header = FALSE, sep = '\t', stringsAsFactors = FALSE)
annohash = hash()
.set(annohash, keys = annotation_in[,1], values = annotation_in[,2])
write.table(t(c('Type', 'Tissue', 'spemirp.value', 'spehostp.value', 'speratiop.value', 'spemirestimate', 'spehostestimate', 'speratioestimate', 'spemirfulogp', 'spehostfulogp', 'speratiofulogp', 'normirp.value', 'norhostp.value', 'norratiop.value',  'normirestimate', 'norhostestimate', 'norratioestimate',  'normirfulogp', 'norhostfulogp', 'norratiofulogp')), file = finalout, row.names = FALSE, col.names = FALSE, append = FALSE, quote = FALSE, sep = "\t")


myinterestedlist <- c("ENSG00000131914", "ENSG00000187772", "hsa-let-7b-5p", "ENSG00000197182", "hsa-let-7c-5p", "ENSG00000215386", "hsa-let-7d-5p", "ENSG00000269946", "hsa-let-7e-5p", "ENSG00000182310", "hsa-let-7g-5p", "ENSG00000164091", "hsa-let-7i-5p", "ENSG00000257354")
inputhash = hash()

con <- file(arg[1], "r")
line =readLines(con,n=1)
therownames = unlist(strsplit(line, '\t'))
therownames = therownames[-(1:2)]

while( length(line) != 0 ) {
     
	lines = unlist(strsplit(line, '\t'))
    
    if (lines[1] %in% myinterestedlist) {
			.set(inputhash, keys = lines[1], values = lines[-(1:2)])
	}
    
    line=readLines(con,n=1)
   

     
}
close(con)

combines = c("ENSG00000131914", "ENSG00000187772")
combinelist <- list( c("hsa-let-7b-5p", "ENSG00000197182"), c("hsa-let-7c-5p", "ENSG00000215386"), c("hsa-let-7d-5p", "ENSG00000269946"), c("hsa-let-7e-5p", "ENSG00000182310"), c("hsa-let-7g-5p", "ENSG00000164091"), c("hsa-let-7i-5p", "ENSG00000257354") )

combinenames = list()

for (icc in combines) {
	combinenames = c(combinenames, lapply(combinelist, fun <- function(xx){return(c(icc, xx))}  ) )
}


nousecollect <- lapply(combinenames, fun <- function(xxx){
	lin28 = as.numeric(unname(values(inputhash, xxx[1]) ))
	let7g = as.numeric(apply(as.matrix(unname(values(inputhash, xxx[2]))), 1, splitthis1))
	hostlet7g = as.numeric(unname(values(inputhash, xxx[3])))

	

	calone(therownames, let7g, hostlet7g, lin28, annohash, paste0(xxx[1], xxx[2]) )
	gc()

	return(0)
})


