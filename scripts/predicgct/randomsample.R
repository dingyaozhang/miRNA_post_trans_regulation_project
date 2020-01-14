set.seed(9)

arg = commandArgs(T)

data <- read.table(arg[1], header = FALSE, sep = '\t', stringsAsFactors = FALSE)


types = unique(as.character(data[,2]))
colone = 1:length(data[,2])
alldata = t(c("NNN", "NNN"))
for (i in types) {
	number = length(which(data[,2] == i))
	if (length(colone) >= 2) {
		once = sample(colone, number)
		colone = setdiff(colone, once)
	} else if (number == 1) {
		once = colone
		colone = c()
	} else{
		print("something wrong anyway")
	}
	
	once = cbind((data[,1])[once], paste0("group", i))
	alldata = rbind(alldata, once)
	rm(once)
}
alldata = alldata[-1,]
write.table(alldata, file = arg[2], row.names = FALSE, col.names = FALSE,sep="\t", quote = FALSE, append = FALSE)
if (length(colone) != 0) {
	print("randomized result has problems, it is not equal to 0!!!")
}



