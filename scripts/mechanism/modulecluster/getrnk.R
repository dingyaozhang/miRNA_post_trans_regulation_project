tran <- function(datain, dataout){
	datain <- read.table(datain, header = FALSE, sep = '\t', stringsAsFactors = FALSE)
	annoin <- read.table("data/mechanism/gsea/humanensglookup.txt", header = FALSE, sep = '\t', stringsAsFactors = FALSE)
	datain = datain[,-1]
	#print(head(datain))
	#print(head(annoin))
	changedata <- annoin[match(datain[,1], annoin[,1]),]

	changedata = cbind(changedata, datain)
	changedata = na.omit(changedata)
	#print(dim(changedata))
	write.table(changedata[,c(2,4)], quote = F, row.names = F, file = dataout, col.names = F, sep = '\t')
}


arg = commandArgs(T)

tran(arg[1], arg[2])
