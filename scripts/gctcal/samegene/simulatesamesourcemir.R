library(hash)
library(maxLik)


splitthis1 = function(x) {return(strsplit(unlist(x), split = "/")[[1]][1])}
splitthis2 = function(x) {return(strsplit(unlist(x), split = "/")[[1]][2])}
normalmulti <- function(theta){
    
    thisi = 3
    logL = 0
    for (idata in names(datain) ) {
        thismu    = theta[thisi]
        thissigma = theta[thisi + 1]
        thisdata = datain[[idata]]
        thismedian = mediandata[thisdata != 0]
        thisdata = thisdata[thisdata != 0]
        thiscor = cor(log(thisdata/thismedian), log(thismedian)) #multiple and add doesn't influence correlation
        theta[1]
        nologthis <- dnorm( log(thisdata), mean = thismu+theta[1], sd = ((theta[2])^2 + thissigma^2 + 2*thiscor*thissigma*theta[2])^(1/2)  )
        nologthis = nologthis / thisdata
        logL = sum(log(nologthis)) + logL
        thisi = thisi + 2;
    }

    return (logL)
}


arg = commandArgs(T)


cache <- read.table(arg[1], header = TRUE, sep = '\t')


mirnaname = as.character(cache[,1])
genename = as.character(cache[,2])
cache = cache[,-1]
cache = cache[,-1]

colall0 = colnames(cache)
colall0 = gsub(pattern = "\\.", replacement = '-', x = colall0)


annotation_in <- read.table(arg[2], header = FALSE, sep = '\t', stringsAsFactors = FALSE)
outpath = arg[3]


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



types = as.character(unique(unlist(genename)))


write.table(t(c('miR-name', 'host-name', 'mean', 'sigma')), file = outpath, row.names = FALSE, col.names = FALSE, append = FALSE, quote = FALSE, sep = "\t")

for (i in types) {


    mirnathistypenum = which(genename == i)

    datain = list()
    startin = c()
    meanc = c()
    sdc = c()

    for (imirna in mirnathistypenum) {
        mirnaonename = mirnaname[imirna]
        tempdata = apply(t(cache[imirna,]), 1, splitthis1)
        tempdata = as.numeric(tempdata)

        
        if (length(which(tempdata != 0)) <= 0.1*length(tempdata)) {
            next
        }else{
            tempdata2 = tempdata[tempdata != 0]
        }
        datain[[mirnaonename]] = tempdata
        tempmean = mean(log(tempdata2))
        tempsd  = sd(log(tempdata2))
        meanc = c(meanc, tempmean)
        sdc  = c(sdc, tempsd)
        startin = c(startin, tempmean, tempsd)
    }
    if (length(datain) <= 1) {
        next
    }
    startin = c(mean(meanc), mean(sdc), startin)

    datain <<- datain
    mediandata = apply(as.data.frame(datain), 1, median)
    mediandata = mediandata + (1/3)*min(mediandata[mediandata != 0])
    mediandata <<- mediandata

    diaga = diag(x = c(0,1), ncol = length(startin), nrow = length(startin) )
    diaga = diaga[-which(apply(diaga, 1, sum) == 0),]
    
    result <- maxLik(normalmulti, start=startin, constraints = list(ineqA= diaga, ineqB=rep(0, (length(startin)/2)  ) ) )
    #result <- maxLik(normalmulti, start=startin )

    result = result$estimate
    write.table(t(c(i, i, result[1], result[2])), file = outpath, row.names = FALSE, col.names = FALSE, append = TRUE, quote = FALSE, sep = "\t")
    result = result[-(1:2)]
    for (idata in names(datain) ) {
        write.table(t(c(idata, i, result[1], result[2])), file = outpath, row.names = FALSE, col.names = FALSE, append = TRUE, quote = FALSE, sep = "\t")
        result = result[-(1:2)]

    }

}



warnings()