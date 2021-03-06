#' Start a GUI
#'
#' There are three options to start the GUI:
#' \enumerate{
#' \item Without any arguments. The GUI is initialized empty.
#' \item With \code{dat} being a \link{tabplot-object}. The GUI is initialized according to the settings of \code{dat}.
#' \item With the same set of arguments as \code{\link{tableplot}}. The GUI is initialized according to these arguments.}
#' General work flow: 
#' \enumerate{
#' \item select a loaded dataset 
#' \item select variables
#' \item configure the tableplot: determine the sorted variable, the scales, palettes, number of bins, etc.
#' \item create the tableplot, and if needed, save it}
#' Actions, such as generating and saving tableplots, are printed in the console for reproducibility.
#' Note regarding RStudio: after pressing the Run button, press enter in the console to show the tableplot.
#'	
#' @aliases tableGUI
#' @param dat either a \link{tabplot-object} or a dataset (see \code{\link{tableplot}})
#' @param colNames see \code{\link{tableplot}}
#' @param sortCol see \code{\link{tableplot}}
#' @param decreasing see \code{\link{tableplot}}
#' @param nBins see \code{\link{tableplot}}
#' @param from see \code{\link{tableplot}}
#' @param to see \code{\link{tableplot}}
#' @param filter see \code{\link{tableplot}}
#' @param scales see \code{\link{tableplot}}
#' @param pals see \code{\link{tableplot}}
#' @param ... other arguments of \code{\link{tableplot}} are currently ignored
#' @export
#' @example ../examples/tableGUI.R
tableGUI <-
function(dat=NULL, colNames=names(dat), sortCol=1,  decreasing=TRUE, nBins=100, from=0, to=100, filter=NULL, scales="auto", pals=list("Set1", "Set2", "Set3", "Set4"), ...) {
    if (!require(gWidgetsRGtk2)){
		stop("This function requires gWidgetsRGtk2")
	}
	
	options("guiToolkit"="RGtk2")

	e <- environment()
	
	#####################################
	## Check arguments
	#####################################

    if (is.null(filter)) filter <- ""
    
	## check datName
	if (!is.null(dat)) {
		if (class(dat)=="tabplot") {
			datName <- dat$dataset
			# check if dataset still exists
			if (!exists(datName)) stop(paste(datName, "not loaded"))
			if(!(class(get(datName, envir=.GlobalEnv))%in% c("data.table", "data.frame", "ffdf"))) stop(paste(datName, "not a data.frame or an ffdf object"))

			
			## Check nBins
			nBins <- dat$nBins
			nBins <- tableplot_checkBins(nBins, nrow(get(datName, envir=.GlobalEnv)))

			from <- dat$rows$from
			to <- dat$rows$to
			
			filter <- dat$filter
			if (length(filter)==0) filter <- ""
			
			# colNames
			colNames <- sapply(dat$columns, FUN=function(x)x$name)
			if (class(colNames)[1]!="character") stop("<colNames> is not a character(vector)")
			if (!all(colNames %in% names(get(datName, envir=.GlobalEnv)))) stop("<colNames> contains column names that are not found in <datName>")

			## get classes
			classes <- getClasses(colNames, datName)	
			isCat <- classes %in% c("factor", "logical", "POSIXt", "Date")
			if (!(identical(!isCat, dat$isNumber))) stop("<colNames> classes do not correspond with the tabplot-object")

			## get palettes
			palList <- lapply(dat$columns[isCat], FUN=function(x)x$palet)
			
			pal_names <- sapply(dat$columns[isCat], FUN=function(x)x$paletname)
			palNames <- rep("", length(colNames))
			palNames[isCat] <- pal_names
			
			customPals <- palList[which((palNames=="custom")[isCat])]
			names(customPals) <- colNames[which(palNames=="custom")]
	
			# decreasing vector
			sortCol <- sapply(dat$columns[!isCat], FUN=function(x)x$sort)
			sortColFull <- rep("", length(colNames))
			sortColFull[!isCat] <- sortCol
			sortColFull[sortColFull=="decreasing"] <- "\\/"
			sortColFull[sortColFull=="increasing"] <- "/\\"

			# scales
			scalesTemp <- sapply(dat$columns[!isCat], FUN=function(x)x$scale_init)
			scales <- rep("", length(colNames))
			scales[!isCat] <- rep(scalesTemp, length.out=sum(!isCat))
			
			
		} else {
			datName <- deparse(substitute(dat))
			# check if dataset exists
			if (!exists(datName)) stop(paste(datName, "not loaded"))
			if(!(class(get(datName, envir=.GlobalEnv))%in% c("data.table", "data.frame", "ffdf"))) stop(paste(datName, "not a data.frame or an ffdf object"))

			## Check nBins
			nBins <- tableplot_checkBins(nBins, nrow(get(datName, envir=.GlobalEnv)))

			## Check colNames
			if (class(colNames)[1]!="character") stop("<colNames> is not a character(vector)")
			if (!all(colNames %in% names(get(datName, envir=.GlobalEnv)))) stop("<colNames> contains column names that are not found in <datName>")
			
			## get classes
			classes <- getClasses(colNames, datName)	
			isCat <- classes %in% c("factor", "logical", "POSIXt", "Date")
			
			## Check sortCol, and (if necessary) cast it to indices
			sortCol <- tableplot_checkCols(sortCol, colNames)

			## Check decreasing vector
			decreasing <- tableplot_checkDecreasing(decreasing, sortCol)

			sortColFull <- rep("", length(colNames))
			sortColFull[sortCol] <- ifelse(decreasing, "\\/", "/\\")
			
			## Check scales
			scalesTemp <- tableplot_checkScales(scales)
			scales <- rep("", length(colNames))
			scales[!isCat] <- rep(scalesTemp, length.out=sum(!isCat))
			
			## Check palet indices
			palList <- tableplot_checkPals(pals)
			
			pal_names <- rep(palList$name, length.out=sum(isCat))
			isCustom <- pal_names=="custom"

			customPals <- rep(palList$palette, length.out=sum(isCat))[isCustom]
			names(customPals) <- colNames[isCat][isCustom]
			
			palNames <- rep("", length(colNames))
			palNames[isCat] <- pal_names
		}
		sorted <- order(order(match(colNames, names(get(datName, envir=.GlobalEnv)))))
	} else {
		datName <- character(0)
		sortColFull <- character(0)
		palNames <- character(0)
		customPals <- list()
		sorted <- integer(0)

	}

	## Check from and to
	tableplot_checkFromTo(from, to)



	# load palettes
	#data("tabplotPalettes")
	tabplotPalettes <- tablePalettes(plot=FALSE)
	
	#' load information about loaded data.frames
	tableGUI_init_data(DF=datName, vars=colNames, sorts=sortColFull, scales=scales, palNames=palNames, customPals=customPals, e=e)
	

	#' create main GUI
	tableGUI_main_layout(e)
		
	## create window for num2fac  
	tableGUI_n2f_layout(e)

	## create window for color palettes 
	tableGUI_pal_layout(e)

	## create window for saving
	tableGUI_save_layout(e)
	
	#' functions and handlers
    tableGUI_main_handlers(e)
	
	tableGUI_n2f_handlers(e)
   
	tableGUI_pal_handlers(e)

	tableGUI_save_handlers(e)

	######################################################
	## activate GUI
	######################################################
	#'tbl2[] <- data.frame(Variable=character(0), Type=character(0), Scale=character(0), Sort=character(0), stringsAsFactors=FALSE)
	svalue(sbr) <- "Ready"
	visible(wdw) <- TRUE
}