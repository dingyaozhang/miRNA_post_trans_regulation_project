library(VennDiagram)
tcgapostin <- read.table("result/mechanism/compare/tcgaregpost.txt", header = FALSE, sep = '\t', stringsAsFactors = FALSE)
tcgatransin <- read.table("result/mechanism/compare/tcgaregtrans.txt", header = FALSE, sep = '\t', stringsAsFactors = FALSE)
targetpostin <- read.table("result/mechanism/compare/targetregpost.txt", header = FALSE, sep = '\t', stringsAsFactors = FALSE)
targettransin <- read.table("result/mechanism/compare/targetregtrans.txt", header = FALSE, sep = '\t', stringsAsFactors = FALSE)
cclepostin <- read.table("result/mechanism/compare/ccleregpost.txt", header = FALSE, sep = '\t', stringsAsFactors = FALSE)
ccletransin <- read.table("result/mechanism/compare/ccleregtrans.txt", header = FALSE, sep = '\t', stringsAsFactors = FALSE)

tcgapostin <- tcgapostin[,1]
tcgatransin <- tcgatransin[,1]
targetpostin <- targetpostin[,1]
targettransin <- targettransin[,1]
cclepostin <- cclepostin[,1]
ccletransin <- ccletransin[,1]

alltcga <- unique(union(tcgapostin, tcgatransin))
alltarget <- unique(union(targetpostin, targettransin))
allccle <- unique(union(cclepostin, ccletransin))

alluse = intersect(alltcga, alltarget)
alluse = intersect(alluse, allccle)

tcgapostin <- intersect(tcgapostin, alluse)
tcgatransin <- intersect(tcgatransin, alluse)
targetpostin <- intersect(targetpostin, alluse)
targettransin <- intersect(targettransin, alluse)
cclepostin <- intersect(cclepostin, alluse)
ccletransin <- intersect(ccletransin, alluse)

venn.diagram(list(TARGET=targetpostin,TCGA=tcgapostin,CCLE=cclepostin), fill=c("red","green","blue"), alpha=c(0.5,0.5,0.5),  cat.cex = 1.75, cex=2,  filename = 'figure/result/vennpost.png', width = 3500)

venn.diagram(list(TARGET=targettransin,TCGA=tcgatransin,CCLE=ccletransin), fill=c("red","green","blue"), alpha=c(0.5,0.5,0.5),  cat.cex = 1.75, cex=2,  filename = 'figure/result/venntrans.png', width = 3500)
