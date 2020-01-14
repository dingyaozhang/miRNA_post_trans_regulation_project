library(hash)


cache <- read.table("result/mechanism/overallcor/addmin88/tcgacor/overallcorrelation.txt", header = TRUE, sep = '\t', stringsAsFactors = FALSE)
annotation_in <- read.table("result/mechanism/evolution/boardgene.gct", header = FALSE, sep = '\t', stringsAsFactors = FALSE)



evoratio <- function(datain){
 	ratiodepend = datain[5]
 	genedepend = datain[8]
	if (ratiodepend >= genedepend) {
		ratiogene = 1
	}else{
		ratiogene = 0
	}

	return(ratiogene)
  
}
ratioout = apply(cache[,-1],1, evoratio)
mirnanames = gsub(pattern = "\\.", replacement = '-', x = cache[,1])
ratioout = cbind(mirnanames, ratioout)

annohash = hash()
.set(annohash, keys = ratioout[,1], values = ratioout[,2])

rowuse = as.numeric(unname(which(has.key(annotation_in[,1], annohash))))
annotation_in = annotation_in[rowuse,]

annotation_coluse = unname(values(annohash, annotation_in[,1]))
ratiodependgroup = annotation_in[which((annotation_coluse == 1) & (annotation_in[,4] == 0)), 3]
genedependgroup = annotation_in[which((annotation_coluse == 0) & (annotation_in[,4] == 0)), 3]

wilcox.test(ratiodependgroup, genedependgroup, alternative = 'less')
print(median(ratiodependgroup))
print(median(genedependgroup))

fisher.test(annotation_coluse, as.numeric(annotation_in[,4] == 0), alternative = 'greater')
print(length(annotation_coluse))
table(annotation_coluse, as.numeric(annotation_in[,4] == 0))

fisher.test(table(annotation_coluse, as.numeric(annotation_in[,4] == 0)))


#########
print("now is fpkm")

cache <- read.table("result/mechanism/overallcor/addmin88/tcgafpkmcor/overallcorrelation.txt", header = TRUE, sep = '\t', stringsAsFactors = FALSE)
annotation_in <- read.table("result/mechanism/evolution/boardgene.gct", header = FALSE, sep = '\t', stringsAsFactors = FALSE)



evoratio <- function(datain){
 	ratiodepend = datain[5]
 	genedepend = datain[8]
	if (ratiodepend >= genedepend) {
		ratiogene = 1
	}else{
		ratiogene = 0
	}

	return(ratiogene)
  
}
ratioout = apply(cache[,-1],1, evoratio)
mirnanames = gsub(pattern = "\\.", replacement = '-', x = cache[,1])
ratioout = cbind(mirnanames, ratioout)

annohash = hash()
.set(annohash, keys = ratioout[,1], values = ratioout[,2])

rowuse = as.numeric(unname(which(has.key(annotation_in[,1], annohash))))
annotation_in = annotation_in[rowuse,]

annotation_coluse = unname(values(annohash, annotation_in[,1]))
ratiodependgroup = annotation_in[which((annotation_coluse == 1) & (annotation_in[,4] == 0)), 3]
genedependgroup = annotation_in[which((annotation_coluse == 0) & (annotation_in[,4] == 0)), 3]

wilcox.test(ratiodependgroup, genedependgroup, alternative = 'less')
print(median(ratiodependgroup))
print(median(genedependgroup))

fisher.test(annotation_coluse, as.numeric(annotation_in[,4] == 0), alternative = 'greater')
print(length(annotation_coluse))
table(annotation_coluse, as.numeric(annotation_in[,4] == 0))

fisher.test(table(annotation_coluse, as.numeric(annotation_in[,4] == 0)))
