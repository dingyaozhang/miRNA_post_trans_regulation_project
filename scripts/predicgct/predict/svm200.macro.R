suppressMessages(library(e1071))
suppressMessages(library(ROCR))
suppressMessages(library(hash))
options(warn = 0)

arg = commandArgs(T)

set.seed(99)

summaryoutputpath = paste0(arg[3], 'summary.txt')
write.table( t(c("times", "corrected_ratio", 'f1macro')), file = summaryoutputpath, row.names = FALSE, col.names = FALSE, sep="\t", quote = FALSE, append = FALSE)
write.table( c("Tables"), file = paste0(summaryoutputpath, ".table"), 	row.names = FALSE, col.names = FALSE, sep="\t", quote = FALSE, append = FALSE)


CVgroup10 <- function(seed,datasize){
  cvlist <- list()
  set.seed(seed)
  n <- rep(1:10,ceiling(datasize/10))[1:datasize]
  temp <- sample(n,datasize)
  x <- 1:10
  dataseq <- 1:datasize
  cvlist <- lapply(x,function(x) dataseq[temp==x])
  return(cvlist)
  
}

pred <- function (real, predict) {
  

  real = as.character(real)
  predict = as.character(predict)
  correctnum = length(which(predict == real))
  table0 = table(real, predict)
  suppressWarnings(write.table(table0, file = paste0(summaryoutputpath, ".table"), 	row.names = TRUE, col.names = TRUE, sep="\t", quote = FALSE, append = TRUE))
  #suppress Warnings from rownames and append if you use appending =T and column names = T in the same time, there will be a warning message.
  correctratio = correctnum / length(real)
  correctratio
}

f1macro <- function(real, predict){
  real = as.character(real)
  predict = as.character(predict)
  class = sort(unique(real))
  macro= NA
  for(i in 1:length(class)){
    tp = sum(predict==class[i] & real==class[i])
    fp = sum(predict==class[i] & real!=class[i])
    fn = sum(predict!=class[i] & real==class[i])
    macro[i] = 2*tp/(2*tp+fp+fn)
  }
  resf1macro = mean(macro)
  return(resf1macro)
}

f1e <- function(truey, predy){
    real = as.character(truey)
    predict = as.character(predy)
    class = sort(unique(real))
    macro= NA
    for(i in 1:length(class)){
        tp = sum(predict==class[i] & real==class[i])
        fp = sum(predict==class[i] & real!=class[i])
        fn = sum(predict!=class[i] & real==class[i])
        macro[i] = 2*tp/(2*tp+fp+fn)
    }
    resf1macro = mean(macro)
    return(1-resf1macro)
}

cache <- read.table(arg[1], header = TRUE, sep = '\t')
annotation_in <- read.table(arg[2], header = FALSE, sep = '\t', stringsAsFactors = FALSE) 

cachename = as.vector(unlist( as.character(cache[,1]) ) )
rownames = make.names(cachename, unique = TRUE)
row.names(cache) = rownames


cache = cache[,-1]
cache = cache[,-1]

colall0 = colnames(cache)
colall0 = gsub(pattern = "\\.", replacement = '-', x = colall0)


if (length( (strsplit(annotation_in[1,1], '-'))[[1]]) == 4) {
	colall = colall0
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



lenrow = length(cache[1,])
cache = apply(cache, 1, fun <- function(xx){
	if (sum(xx != 0) > 0.9) {
		return(log(1/3*min(xx[xx != 0]) + xx))
	}else{
		return(rep('NANA', lenrow))
	}
})

cache = cache[,which(cache[1,] != 'NANA')]
cache = apply(cache, 2, as.numeric)

wholelengthcol = length(cache[,1])
datadimension = length(cache[1,])
costarray = 15^(0:4)
gammaarray = c(8^(-4:1), 1/datadimension)
gctrash = gc()




coloneuse = unname(unlist(annotation_coluse))
factorcoloneuse = as.factor(coloneuse)
factortypes = unique(unlist(factorcoloneuse))
factorcoloneuse = as.data.frame(factorcoloneuse)



for (inum in 1:200) {
	
	alluse = c()
	alltest = c()
	alllength = c()
	
	inumloop = floor((inum-1)/10) + 1
	inumnum = inum - inumloop*10 + 10
	
	for (i in types) {
	
	
		colone = as.data.frame(as.numeric(annotation_coluse == i))
		
	
		positiverow = which(colone == 1)
		positivenum = length(positiverow)
		if (positivenum >= 10) {
			
			posigroup <- CVgroup10(inumloop,positivenum)
			positest = posigroup[[inumnum]]
			
			
			posiuse = positiverow[-positest]
			positest = positiverow[positest]
			
		
			tempalllength = c(length(posiuse))
			names(tempalllength) = i
			alllength = c(alllength, tempalllength)
			alluse = c(alluse, posiuse)
			alltest = c(alltest, positest)
		}else{
			stop(paste0("too small samples", i))
		}
	}
	anotheruse = which(apply(cache[alluse,],2,fun <- function(xx) {length(unique(xx))}) >= 2)

	model = tune(svm, train.x = cache[alluse,anotheruse], train.y = factorcoloneuse[alluse,], ranges = list(gamma = gammaarray, cost = costarray), type = "C-classification", cachesize = 5000, scale = TRUE, class.weights = alllength, tunecontrol = tune.control(sampling = 'fix', error.fun = f1e))
	model = model$best.model

	
	results_predict <- predict(object = model, newdata = cache[alltest,anotheruse], type="class")
	real_result = unname(factorcoloneuse[alltest,])
	
	apred = pred(real_result, unname(results_predict))
	f1macrores = f1macro(real_result, results_predict)
	
	write.table( cbind(inum, apred, f1macrores), file = summaryoutputpath, 	row.names = FALSE, col.names = FALSE, sep="\t", quote = FALSE, append = TRUE)
	rm(model)
	rm(results_predict)
	rm(real_result)
	gctrash = gc()
}


warnres = warnings()
if (! is.null(warnres)) {
	print(arg)
	print(warnres)
}
