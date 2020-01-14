suppressMessages(library(hash))

splitthis1 = function(x) {return(strsplit(unlist(x), split = "/")[[1]][1])}
splitthis2 = function(x) {return(strsplit(unlist(x), split = "/")[[1]][2])}

calabc <- function(aa, bb, cc, filepath) {

    aa = as.numeric(aa)
    bb = as.numeric(bb)
    cc = as.numeric(cc)
    meanaa = mean(aa)
    meanbb = mean(bb)
    meancc = mean(cc)
  
    
    mirtruenum = sum(aa != 0)
    mirzeronum = sum(aa == 0)
    mir2truenum = sum(bb != 0)
    mir2zeronum = sum(bb == 0)
    genetruenum = sum(cc != 0)
    genezeronum = sum(cc == 0)
  
    if (sum(aa != 0) < 9.9)  {
      return(0)
    }
    if (sum(bb != 0) < 9.9)  {
      return(0)
    }
    if (sum(cc != 0) < 9.9)  {
      return(0)
    }


    a2 = (1/3*min(aa[aa != 0]) + aa)
    b2 = (1/3*min(bb[bb != 0]) + bb)
    c2 = (1/3*min(cc[cc != 0]) + cc)
  
    ratioa = a2/c2
    ratiob = b2/c2
    ratioab = a2/b2
    ratioba = b2/a2
  
    if (mirzeronum > 0){
      aa = a2
    }
    if (mir2zeronum > 0){
      bb = b2
    }
    if (genezeronum > 0){
      cc = c2
    }
    
    
  
    speratioab = cor(ratioab, ratioa, method = "spearman")
    speratioba = cor(ratioba, ratiob, method = "spearman")
    norratioab = cor(log(ratioab), log(ratioa), method = "pearson")
    norratioba = cor(log(ratioba), log(ratiob), method = "pearson")

    spe5p3p = cor(aa, bb, method = "spearman")
    spe5phost = cor(aa, cc, method = "spearman")
    spe3phost = cor(bb, cc, method = "spearman")
    nor5p3p = cor(aa, bb, method = "pearson")
    nor5phost = cor(aa, cc, method = "pearson")
    nor3phost = cor(bb, cc, method = "pearson")

    normatureab = cor(log(ratioab), log(aa), method = "pearson")
    normatureba = cor(log(ratioba), log(bb), method = "pearson")
    spematureab = cor(ratioab, aa, method = "spearman")
    spematureba = cor(ratioba, bb, method = "spearman")

    
    res = t(c(hairi, meanaa, meanbb, meancc, norratioab^2, norratioba^2, speratioab, speratioba, normatureab^2, normatureba^2, spematureab, spematureba, spe5p3p, spe5phost, spe3phost, nor5p3p, nor5phost, nor3phost))
    write.table(res, file = filepath, row.names = FALSE, col.names = FALSE, append = TRUE, quote = FALSE, sep = "\t")
}

calabc0 <- function(aa, bb, cc, filepath) {

    aa = as.numeric(aa)
    bb = as.numeric(bb)
    cc = as.numeric(cc)
    meanaa = mean(aa)
    meanbb = mean(bb)
    meancc = mean(cc)

    if (sum(aa != 0) < 0.1)  {
      return(0)
    }
    if (sum(bb != 0) < 0.1)  {
      return(0)
    }
    if (sum(cc != 0) < 0.1)  {
      return(0)
    }
    
  
    mirtruenum = sum(aa != 0)
    mirzeronum = sum(aa == 0)
    mir2truenum = sum(bb != 0)
    mir2zeronum = sum(bb == 0)
    genetruenum = sum(cc != 0)
    genezeronum = sum(cc == 0)
  
    
    a2 = (1/3*min(aa[aa != 0]) + aa)
    b2 = (1/3*min(bb[bb != 0]) + bb)
    c2 = (1/3*min(cc[cc != 0]) + cc)
  
    ratioa = a2/c2
    ratiob = b2/c2
    ratioab = a2/b2
    ratioba = b2/a2
  
    if (mirzeronum > 0){
      aa = a2
    }
    if (mir2zeronum > 0){
      bb = b2
    }
    if (genezeronum > 0){
      cc = c2
    }
    
    
  
    speratioab = cor(ratioab, ratioa, method = "spearman")
    speratioba = cor(ratioba, ratiob, method = "spearman")
    norratioab = cor(log(ratioab), log(ratioa), method = "pearson")
    norratioba = cor(log(ratioba), log(ratiob), method = "pearson")

    spe5p3p = cor(aa, bb, method = "spearman")
    spe5phost = cor(aa, cc, method = "spearman")
    spe3phost = cor(bb, cc, method = "spearman")
    nor5p3p = cor(aa, bb, method = "pearson")
    nor5phost = cor(aa, cc, method = "pearson")
    nor3phost = cor(bb, cc, method = "pearson")

    normatureab = cor(log(ratioab), log(aa), method = "pearson")
    normatureba = cor(log(ratioba), log(bb), method = "pearson")
    spematureab = cor(ratioab, aa, method = "spearman")
    spematureba = cor(ratioba, bb, method = "spearman")

    
    res = t(c(hairi, meanaa, meanbb, meancc, norratioab^2, norratioba^2, speratioab, speratioba, normatureab^2, normatureba^2, spematureab, spematureba, spe5p3p, spe5phost, spe3phost, nor5p3p, nor5phost, nor3phost))
    write.table(res, file = filepath, row.names = FALSE, col.names = FALSE, append = TRUE, quote = FALSE, sep = "\t")
}

arg = commandArgs(T)
if (! file.exists(arg[3])) {
  dir.create(arg[3], recursive=T)
}

outcenpath = paste0(arg[3], "/overallcorrelation")

cache <- read.table(arg[1], header = TRUE, sep = '\t')
annotation_in <- read.table(arg[2], header = FALSE, sep = '\t', stringsAsFactors = FALSE) 

cachename = as.vector(unlist(as.character(cache[,2])))
row.names(cache) = cachename
hairpinnames = as.vector(unlist(as.character(cache[,1])))

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


alllen = length(cache[,1])
hairpins = unique(hairpinnames)
title = t(c("hairpin-name", "mean5p", "mean3p", "meanhost", "nor-ratio-5p^2", "nor-ratio-3p^2", "spe-ratio-5p", "spe-ratio-3p", "nor-mature-5p^2", "nor-mature-3p^2", "spe-mature-5p", "spe-mature-3p", "spe5p3p", "spe5phost", "spe3phost", "nor5p3p", "nor5phost", "nor3phost"))
write.table(title, file = paste0(outcenpath, '.txt'), row.names = FALSE, col.names = FALSE, append = FALSE, quote = FALSE, sep = "\t")

for (hairi in hairpins) {
  rowsi = which(hairpinnames == hairi)
  aa = apply(t(cache[rowsi[1],]), 1, splitthis1)
  bb = apply(t(cache[rowsi[2],]), 1, splitthis1)
  cc = apply(t(cache[rowsi[2],]), 1, splitthis2)
  calabc0(aa, bb, cc, paste0(outcenpath, '.txt'))
}


gctrash = gc()

for (i in types) {

  colone0 = as.numeric(annotation_coluse == i) 
  filepath = paste0(outcenpath, i, ".txt")
  posicol = which(colone0 == 1)
  if (length(posicol) <= 5) {
    stop(paste0("too small", i))
    next
  }
  cache0 = cache[,posicol]
  alllen = length(cache0[,1])
  title = t(c("hairpin-name", "mean5p", "mean3p", "meanhost", "nor-ratio-5p^2", "nor-ratio-3p^2", "spe-ratio-5p", "spe-ratio-3p", "nor-mature-5p^2", "nor-mature-3p^2", "spe-mature-5p", "spe-mature-3p", "spe5p3p", "spe5phost", "spe3phost", "nor5p3p", "nor5phost", "nor3phost"))
  write.table(title, file = filepath, row.names = FALSE, col.names = FALSE, append = FALSE, quote = FALSE, sep = "\t")
  for (hairi in hairpins) {
    rowsi = which(hairpinnames == hairi)

    aa = apply(t(cache0[rowsi[1],]), 1, splitthis1)
    bb = apply(t(cache0[rowsi[2],]), 1, splitthis1)
    cc = apply(t(cache0[rowsi[2],]), 1, splitthis2)
    
    calabc(aa, bb, cc, filepath)

  }
  gctrash = gc()
}

warnings()


