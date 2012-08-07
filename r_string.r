data = read.table("#table#.txt",sep = ",")
barplot(data[[1]],names.arg=data[[2]],horiz=FALSE,beside=TRUE,cex.names=0.90,xlab="#xlab#",ylab="#ylab#",ylim=c(0,#ylim#))
title(main="#title#")
