splitthis1 = function(x) {return(strsplit(unlist(x), split = "/")[[1]][1])}
splitthis2 = function(x) {return(strsplit(unlist(x), split = "/")[[1]][2])}

cache <- read.table('figure/exact34a.txt', header = FALSE, sep = '\t')
annotation_in <- read.table('figure/p53mutlist.txt', header = FALSE, sep = '\t', stringsAsFactors = FALSE) 


cache = cache[,-(1:2)]

mutationsamples <- annotation_in[which(annotation_in[,2] %in% 'mutation'),1]
normalsamples <- annotation_in[which(annotation_in[,2] %in% 'normal'),1]

mutcols = which(unlist(cache[1,]) %in% mutationsamples)
norcols = which(unlist(cache[1,]) %in% normalsamples)

mir = as.numeric(apply(t(cache[2,]), 1, splitthis1))
mirhost = as.numeric(apply(t(cache[2,]), 1, splitthis2))

ratio = (1/3*min(mir[mir != 0]) + mir) / (1/3*min(mirhost[mirhost != 0]) + mirhost)

print('exact')
log(wilcox.test(mirhost[mutcols], mirhost[norcols], alternative = 'less')$p.value, 2)
log(wilcox.test(ratio[mutcols], ratio[norcols], alternative = 'less')$p.value,2)
if (sum(mir == 0) >= 1) {
	mir = 1/3*min(mir[mir != 0]) + mir
}
if (sum(mirhost == 0) >= 1) {
	mirhost = 1/3*min(mirhost[mirhost != 0])+mirhost
}
log(t.test(log(mirhost[mutcols],2), log(mirhost[norcols],2), alternative = 'less')$p.value, 2)
log(t.test(log(ratio[mutcols],2), log(ratio[norcols],2), alternative = 'less')$p.value,2)

log(t.test(mirhost[mutcols], mirhost[norcols], alternative = 'less')$p.value, 2)
log(t.test(ratio[mutcols], ratio[norcols], alternative = 'less')$p.value,2)



splitthis1 = function(x) {return(strsplit(unlist(x), split = "/")[[1]][1])}
splitthis2 = function(x) {return(strsplit(unlist(x), split = "/")[[1]][2])}

cache <- read.table('figure/fpkm34a.txt', header = FALSE, sep = '\t')
annotation_in <- read.table('figure/p53mutlist.txt', header = FALSE, sep = '\t', stringsAsFactors = FALSE) 


cache = cache[,-(1:2)]

mutationsamples <- annotation_in[which(annotation_in[,2] %in% 'mutation'),1]
normalsamples <- annotation_in[which(annotation_in[,2] %in% 'normal'),1]

mutcols = which(unlist(cache[1,]) %in% mutationsamples)
norcols = which(unlist(cache[1,]) %in% normalsamples)

mir = as.numeric(apply(t(cache[2,]), 1, splitthis1))
mirhost = as.numeric(apply(t(cache[2,]), 1, splitthis2))

ratio = (1/3*min(mir[mir != 0]) + mir) / (1/3*min(mirhost[mirhost != 0]) + mirhost)


print('fpkm')
log(wilcox.test(mirhost[mutcols], mirhost[norcols], alternative = 'less')$p.value,2)
log(wilcox.test(ratio[mutcols], ratio[norcols], alternative = 'less')$p.value,2)
if (sum(mir == 0) >= 1) {
	mir = 1/3*min(mir[mir != 0]) + mir
}
if (sum(mirhost == 0) >= 1) {
	mirhost = 1/3*min(mirhost[mirhost != 0])+mirhost
}
log(t.test(log(mirhost[mutcols],2), log(mirhost[norcols],2), alternative = 'less')$p.value, 2)
log(t.test(log(ratio[mutcols],2), log(ratio[norcols],2), alternative = 'less')$p.value,2)

log(t.test(mirhost[mutcols], mirhost[norcols], alternative = 'less')$p.value, 2)
log(t.test(ratio[mutcols], ratio[norcols], alternative = 'less')$p.value,2)


