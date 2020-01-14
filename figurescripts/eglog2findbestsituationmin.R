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

	#for (typei in types) {
	#	colsuse = which(sample == typei)
#
	#	outdata = calcor(mir[colsuse], host[colsuse], factor[colsuse], ratio[colsuse])
	#	outdata = c(name, typei, outdata)
	#	write.table(t(outdata), file = finalout, row.names = FALSE, col.names = FALSE, append = TRUE, quote = FALSE, sep = "\t")
	#	gc()
	#}
		
	
}


arg = commandArgs(T)


finalout = arg[3]
annotation_in <- read.table(arg[2], header = FALSE, sep = '\t', stringsAsFactors = FALSE)
annohash = hash()
.set(annohash, keys = annotation_in[,1], values = annotation_in[,2])
write.table(t(c('Type', 'Tissue', 'spemirp.value', 'spehostp.value', 'speratiop.value', 'spemirestimate', 'spehostestimate', 'speratioestimate', 'spemirfulogp', 'spehostfulogp', 'speratiofulogp', 'normirp.value', 'norhostp.value', 'norratiop.value',  'normirestimate', 'norhostestimate', 'norratioestimate',  'normirfulogp', 'norhostfulogp', 'norratiofulogp')), file = finalout, row.names = FALSE, col.names = FALSE, append = FALSE, quote = FALSE, sep = "\t")


myinterestedlist <- c("hsa-let-7g-5p", "hsa-miR-17-5p", "hsa-miR-18a-5p", "hsa-miR-19a-3p", "hsa-miR-20a-5p", "ENSG00000215417", "ENSG00000136997", "ENSG00000164091", "ENSG00000131914")
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


lin28 = as.numeric(unname(values(inputhash, "ENSG00000131914")))

hostlet7g = as.numeric(unname(values(inputhash, "ENSG00000164091")))

let7g = as.numeric(apply(as.matrix(unname(values(inputhash, "hsa-let-7g-5p"))), 1, splitthis1))


calone(therownames, let7g, hostlet7g, lin28, annohash, 'lin28let7g')


gc()

myc = as.numeric(unname(values(inputhash, "ENSG00000136997")))


mir17host = as.numeric(unname(values(inputhash, "ENSG00000215417")))

mir17 = as.numeric(apply(as.matrix(unname(values(inputhash, "hsa-miR-17-5p"))), 1, splitthis1))


mir18 = as.numeric(apply(as.matrix(unname(values(inputhash, "hsa-miR-18a-5p"))), 1, splitthis1))

mir19 = as.numeric(apply(as.matrix(unname(values(inputhash, "hsa-miR-19a-3p"))), 1, splitthis1))

mir20 = as.numeric(apply(as.matrix(unname(values(inputhash, "hsa-miR-20a-5p"))), 1, splitthis1))



calone(therownames, mir17, mir17host, myc, annohash, 'mycmir17')
calone(therownames, mir18, mir17host, myc, annohash, 'mycmir18')
calone(therownames, mir19, mir17host, myc, annohash, 'mycmir19')
calone(therownames, mir20, mir17host, myc, annohash, 'mycmir20')


warnings()