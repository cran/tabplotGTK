## function that checks whether first argument, the tabplot object "tab", can be reused with the specifications according to the other arguments. Reusing a tabplot object is done by the function changeTabplot
isTabplotUsable <- function(tab, select_string, sortCol, decreasing, scales, nBins, from, to, filter) {
	## check number of row bins
	if (nBins!=tab$nBins) return(FALSE)

	## check from and to
	if (from!=tab$rows$from || to!=tab$rows$to) return(FALSE)
	
	## check filter
	if (length(tab$filter)==0) {
		if (filter!="") return(FALSE)
	} else {
		if (filter!=tab$filter) return(FALSE)
	}

	
	tabColNames <- sapply(tab$columns, function(col)col$name)
	colID <- match(select_string, tabColNames)
	tabNumberID <- colID[which(tab$isNumber)]
	
	## check is all column names are in tab
	if (any(is.na(colID))) return(FALSE)

	
	## check if the scales correspond
	if (any(tab$isNumber)) {
		tabColScales_init <- sapply(tab$columns, function(col)ifelse(is.null(x<-col$scale_init), NA, x))
		tabColScales_final <- sapply(tab$columns, function(col)ifelse(is.null(x<-col$scale_final), NA, x))

		colScales_init <- na.omit(tabColScales_init[colID])
		colScales_final <- na.omit(tabColScales_final[colID])

		if (!all(scales==colScales_init | scales==colScales_final)) return(FALSE)
	}
	
	
	sortColNames <- select_string[sortCol]

	tabSort <- sapply(1:length(tab$columns), function(id) tab$columns[[id]]$sort)
	tabSortCols <- which(tabSort!="")

	## check if sort columns correspond
	if (!identical(sortColNames, tabColNames[tabSortCols])) return(FALSE)
	
	tabDecreasing <- tabSort[tabSortCols]=="decreasing"

	## check if sorting order corresponds (or to the flipped case)
	if (!(identical(tabDecreasing, decreasing) || identical(!tabDecreasing, decreasing))) return(FALSE)

	return(TRUE)
}