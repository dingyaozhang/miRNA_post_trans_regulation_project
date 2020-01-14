tran <- function(datain, dataout){
	datain <- read.table(datain, header = FALSE, sep = '\t', stringsAsFactors = FALSE)
	datain = datain[,-1]
	require("biomaRt")
	mart <- useMart("ENSEMBL_MART_ENSEMBL")
	mart <- useDataset("hsapiens_gene_ensembl", mart)
	annotLookup <- getBM(
	mart=mart,
	attributes=c("ensembl_gene_id", "external_gene_name"),
	filter="ensembl_gene_id",
	values=datain[,1],
	uniqueRows=TRUE)
	changedata <- annotLookup[match(datain[,1], annotLookup[,1]),]
	changedata = cbind(changedata, datain)
	changedata = na.omit(changedata)
	write.table(changedata[,c(2,4)], quote = F, row.names = F, file = dataout, col.names = F, sep = '\t')
}


arg = commandArgs(T)

tran(arg[1], arg[2])
