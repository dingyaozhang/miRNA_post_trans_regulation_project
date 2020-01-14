suppressMessages(library(hash))
suppressMessages(library(Cairo))
#Rscript modulesignchange.R allmir test/ test/ test/123.txt

arg = commandArgs(T)



matfecdf <- function(figurepath, type, mirlist, figureout, outfile){
	

	mirprefix <- paste0(figurepath, 'mir', type)
	hostprefix <- paste0(figurepath, 'host', type)
	ratioprefix <- paste0(figurepath, type)
	mirorder <- unlist(read.table(paste0(ratioprefix, 'rownamelist.txt'), header = FALSE, stringsAsFactors = FALSE, sep = '\t'))
	
	matmir <- read.table(paste0(mirprefix, 'mat.txt'), header = FALSE, stringsAsFactors = FALSE, sep = '\t')
	mathost <- read.table(paste0(hostprefix, 'mat.txt'), header = FALSE, stringsAsFactors = FALSE, sep = '\t')
	matratio <- read.table(paste0(ratioprefix, 'mat.txt'), header = FALSE, stringsAsFactors = FALSE, sep = '\t')
	

	if (mirlist[1] != 'allmir') {
		usecols <- which(mirorder %in% mirlist)
		if (length(usecols) <= 2) {
			return(0)
		}
		matmir = matmir[,usecols]
		matmir = matmir[usecols,]
		mathost = mathost[,usecols]
		mathost = mathost[usecols,]
		matratio = matratio[,usecols]
		matratio = matratio[usecols,]
	}


	mathost[mathost == 1] <- NA
	mathost[is.na(matmir)] <- NA


	mathost = unlist(mathost)
	matmir = unlist(matmir)
	matratio = unlist(matratio)

	matmir = matmir[! is.na(mathost)]
	matratio = matratio[! is.na(mathost)]
	mathost = mathost[! is.na(mathost)]

	na.fail(matratio)
	
	suppressWarnings(wilphost <- ks.test(matratio, mathost, alternative = 'less', exact = TRUE)$p.value)
	suppressWarnings(wilpmir <- ks.test(matratio, matmir, alternative = 'less', exact = TRUE)$p.value)
	

	write.table(t(c(type, 'host', wilphost)), file = outfile, row.names = FALSE, col.names = FALSE, append = TRUE, quote = FALSE, sep = "\t")
	write.table(t(c(type, 'mir', wilpmir)), file = outfile, row.names = FALSE, col.names = FALSE, append = TRUE, quote = FALSE, sep = "\t")

	CairoPNG(file= paste0(figureout, type, "ecdf.png"))
	plot(ecdf(mathost), do.points=FALSE, col = rgb(255,0,0, maxColorValue = 255), main = type)
	lines(ecdf(matratio), do.points=FALSE, col = rgb(0,196,46, maxColorValue = 255))
	lines(ecdf(matmir), do.points=FALSE, col = rgb(0,178,239, maxColorValue = 255))
	dev.off()
	#xlim = c(-1,1) is useful for plot.ecdf
}

if (arg[1] != 'allmir') {
	mirlist <- read.table(arg[1], header = FALSE, stringsAsFactors = FALSE, sep = '\t')
	mirlist <- unlist(mirlist)
}else{
	mirlist = 'allmir'
}

figurepath = arg[2]
figurepath = gsub(pattern = "\\/$", replacement = '', x = figurepath)
figurepath = paste0(figurepath, '/')
figureout = arg[3]
outfile = arg[4]


allfiles <- list.files(figurepath)

allratiofiles <- allfiles[grep('rownamelist.txt$', allfiles)]

write.table(t(c('tissue', 'object', 'p-value')), file = outfile, row.names = FALSE, col.names = FALSE, append = FALSE, quote = FALSE, sep = "\t")

for (ppi in allratiofiles) {
	type = gsub(pattern = outfile, replacement = '', x = ppi)
	type = gsub(pattern = 'rownamelist.txt$', replacement = '', x = ppi)
	matfecdf(figurepath, type, mirlist, figureout, outfile)
}

warnres = warnings()
if (! is.null(warnres)) {
	print(arg)
	print(warnres)
}

