tableGUI_getPalInfo <- function(palFullName) {
	posLeftB <- regexpr("(", palFullName, fixed=TRUE)
	palInfo <- list(
		palName=ifelse(posLeftB==-1, palFullName, substr(palFullName, 1, posLeftB-1)),
		palStartCol=ifelse(posLeftB==-1, 1, as.integer(substr(palFullName, posLeftB+1, nchar(palFullName)-1)))
	)
	return(palInfo)
}

tableGUI_setPalInfo <- function(palName, startCol=1) {
	ifelse(palName=="custom", 
		"custom", 
		paste(palName, "(", startCol, ")", sep=""))
}

## create the data.frame varTbl, containing the administration of the current dataframe
tableGUI_createVarTbl <- function(DF, vars, sorts, scales, palNames) {

	## create default settings for all variables
	dfNames <- names(get(DF, envir=.GlobalEnv))
	dfClasses <- getClasses(dfNames, DF)
	dfLevels <- sapply(dfNames, FUN=function(x){nlevels(get(DF,envir=.GlobalEnv)[[x]])})
	dfLevels[dfClasses=="logical"] <- 2
	
	dfTypes <- mapply(dfClasses, dfLevels, FUN=function(x,y) {
			ifelse(x=="factor", paste("categorical (", y, ")", sep=""),
				ifelse(x=="logical", "categorical (2)",
					ifelse(x %in% c("numeric", "integer"), "numeric", "unknown")))
		})
	
	dfSort <- rep("", length(dfNames))
	dfScale <- sapply(dfClasses, FUN=function(x) {
			ifelse(x %in% c("numeric", "integer"), "auto", "")
		})
	dfPalette <- rep("", length(dfNames))
	dfSelected <- rep(FALSE, length(dfNames))
	
	
	## modify settings for the variables in <vars>
	if (length(vars)!=0) {
		indices <- sapply(vars, FUN=function(x,y){which(x==y)}, dfNames)
		
		dfSort[indices] <- sorts
		
		#dfScales <- rep("", length(dfNames))
		dfScale[indices] <- scales
		dfPalette[indices] <- palNames
		dfSelected[indices] <- TRUE
	}
	
	## create data.frame and return it
	varTbl <- data.frame(Variable=dfNames, Class=dfClasses, Levels=dfLevels, Type=dfTypes, Scale=dfScale, Sort=dfSort, Palette=dfPalette, Selected = dfSelected, New = FALSE, stringsAsFactors=FALSE)
	return(varTbl)
}

	
## initiate data for GUI: all loaded data.frames, and select a current data.frame and its variables
tableGUI_init_data <- function(DF=character(0), vars=character(0), sorts=character(0), scales=character(0), palNames=character(0), customPals=list(), e=e) {
	## create list of data.frames and, if necessary select the first one
	datlist <- lsDF()
	if (length(datlist)==0) stop("No data.frames loaded.")
	if(length(DF)==0) DF <- datlist[1]
	
	## initiate GUI administration
	##
	## datlist: vector of loaded data.frames
	## currentDF: name of the current data.frame
	## varTbl: data.frame containing the settings of all variables
	## palettes: list of palettes (id's correspond with varTbl)
	currentDF <- list(name=DF,
		nrow=nrow(get(DF, envir=.GlobalEnv)),
		class=class(get(DF, envir=.GlobalEnv))[1])
	varTbl <- tableGUI_createVarTbl(DF, vars, sorts, scales, palNames)
	
	assign("customPals", customPals, envir=e)
	assign("datlist", datlist, envir=e)
	assign("currentDF", currentDF, envir=e)
	assign("varTbl", varTbl, envir=e)
	
}

## get selection of varTbl for first GUI table
tableGUI_getTbl1 <- function(vars=e$varTbl$Variable, cols=c("Variable", "Class"), e) {
	varTbl <- e$varTbl
	if (length(vars)==0) return(varTbl[NULL, cols])
	varTbl <- varTbl[sapply(vars, FUN=function(x,y){which(x==y)}, varTbl$Variable), ]
	return(varTbl[!varTbl$Selected, cols])
}

## get selection of varTbl for second GUI table
tableGUI_getTbl2 <- function(vars=e$varTbl$Variable, cols=c("Variable", "Type", "Scale", "Sort", "Palette"), e) {
	varTbl <- e$varTbl
	if (length(vars)==0) return(varTbl[NULL, cols])
	varTbl <- varTbl[sapply(vars, FUN=function(x,y){which(x==y)}, varTbl$Variable), ]
	return(varTbl[varTbl$Selected, cols])
}

## get current data.frame name
tableGUI_getCurrentDFname <- function(e) {
	return(e$currentDF$name)
}

## get nrow of current data.frame
tableGUI_getCurrentDFnrow <- function(e) {
	return(e$currentDF$nrow)
}

## get class of current data.frame
tableGUI_getCurrentDFclass <- function(e) {
	return(e$currentDF$class)
}

## get number of selected variables
tableGUI_getNumSel <- function(e) {
	return(sum(e$varTbl$Selected))
}

## set settings to varTbl
tableGUI_setVarTbl <- function(vars, cols, value, e) {
	varTbl <- e$varTbl
	varTbl[sapply(vars, FUN=function(x,y){which(x==y)}, varTbl$Variable), cols] <- value
	assign("varTbl", varTbl, envir=e)
}

## new data.frame is selected, or data is refreshed
tableGUI_refreshDF <- function(newDF=character(0), parent, e) {
	newvars <- tableGUI_saveVars(parent=parent, e=e)
	tableGUI_init_data(newDF, e=e)
	e$tab <- NULL
}


## should newly created variable be kept?
tableGUI_saveVars <- function(vars=e$varTbl$Variable, parent=NULL, e) {
	newvars <- intersect(vars, e$varTbl$Variable[e$varTbl$New])

	savevar <- TRUE
	if (length(newvars) != 0) {
		savevar <- gconfirm(message=paste("Do you want to keep the variable(s)", paste(newvars,collapse=", "), "?"), title="Save?", parent=parent, icon="question")
		if (!savevar) {
			tmpdat <- get(tableGUI_getCurrentDFname(e), envir=.GlobalEnv)
			for (x in newvars) {
				tmpdat[[x]] <- NULL
			}

			varTbl <- e$varTbl[!(e$varTbl$Variable %in% newvars),]
			assign("varTbl", varTbl, envir=e)
			assign(tableGUI_getCurrentDFname(e), tmpdat, envir=.GlobalEnv)
			return(character(0))
		} else {
			return(newvars)
		}
	}
}


## cast selected variable to a categorical variable
tableGUI_castToCat <- function(name, num_scale="", method="", n=0, brks=0, parent, e) {
	## add temporary column to data.frame
	currentDF <- tableGUI_getCurrentDFname(e)
	tmpdat <- get(currentDF, envir=.GlobalEnv)
	if (classSimplified(tmpdat[,name])[1] %in% c("numeric", "integer")) {
		tmpdat$tmptmp <- num2fac(tmpdat[, name], num_scale=num_scale, method=method, n=n, brks=brks)
		CLmethod <- paste("num2fac(", currentDF, "$", name,
						  ", num_scale=\"", num_scale, 
						  "\", method=\"", method, "\", n=", n, 
						  ifelse(length(brks)==1, ", brks=", ", brks=c("),
						  paste(brks,collapse=","), 
						  ifelse(length(brks)==1, "", ")"),
						  ")\n", sep="")
	} else if (classSimplified(tmpdat[,name])[1] %in% c("POSIXt", "Date")) {
		tmpdat$tmptmp <- datetime2fac(tmpdat[, name])
		CLmethod <- paste("datetime2fac(", currentDF, "$", name, ")\n", sep="")
	} else {
		tmpdat$tmptmp <- as.factor(tmpdat[, name])
		lvls <- length(levels(tmpdat$tmptmp))
		if (lvls > 30) {
			gmessage(paste("There are too many (", lvls, ") categories.", sep=""), title = "Error", icon = "error", parent=parent)
			tmpdat$tmptmp <- NULL
			return()
		}
		if (lvls > 15) {
			continue <- gconfirm(paste("There are", lvls, "categories. Do you want to continue?"), icon="question")
			if (!continue) {
				tmpdat$tmptmp <- NULL
				return()
			}
		}
		CLmethod <- paste("as.factor(", currentDF, "$", name, ")\n", sep="")
	}


	
	newname <- paste(name, length(levels(tmpdat$tmptmp)),sep="")
	## check whether new name does not exists in data.frame
	tryCatch(
		while (newname %in% colnames(tmpdat)) {
			tempname <- newname
			newname <- ginput(paste("The variable name ", newname, " is already occupied in ", currentDF,". Please enter a new name.", sep=""), text=newname, title="New variable name", icon = "question")
			if (is.na(newname)) newname <- tempname
		}, finally= {
			if (!(newname %in% colnames(tmpdat))) {
				colnames(tmpdat)[ncol(tmpdat)] <- newname
				assign(currentDF, tmpdat, envir=.GlobalEnv)
						
				newRow <- data.frame(Variable=newname, Class="factor", Levels=nlevels(tmpdat[[newname]]), Type=paste("categorical (", nlevels(tmpdat[[newname]]),")", sep=""), Scale="", Sort="", Palette="Set1", Selected=TRUE, New=TRUE, stringsAsFactors=FALSE)
				
				# print command line
				cat(paste(currentDF, "$", newname, " <- ", CLmethod, sep=""))
				
				# update varTbl
				varTbl <- e$varTbl
				varTbl <- rbind(varTbl, newRow)
				assign("varTbl", varTbl, envir=e)
				
				return(newname)
			} else {
				return()
			}
		})
}

## function to transfer variables from table1 to table2
tableGUI_selectVars <- function(vars, parent, e) {

	varTbl <- e$varTbl
	
	## determine incides of selected variables
	varId <- sapply(vars, FUN=function(x,y){which(x==y)}, varTbl$Variable)
	
	## exclude variables of unknown classes
	unknownId <- varId[which(varTbl$Type[varId]=="unknown")]
	varId <- setdiff(varId, unknownId)

	## count number of categorical variables
	numOfCat <- sum(varTbl$Selected & substr(varTbl$Type, 1, 3)=="cat")
	
	## count number of selected variables
	numSelected <- sum(varTbl$Selected)


	
	
	## select variables of unknown classes, and ask to convert them
	newVars <- character(0)
	if (e$currentDF$class=="ffdf") {
		if (length(unknownId!=0)) gmessage(paste("The variable(s) ", varTbl$Variable[unknownId], " are not recognized as numeric or categorical.", sep=""), icon = "error", parent=parent)
	} else {
		for (i in varTbl$Variable[unknownId]) {
			cast <- gconfirm(paste("The variable ", i, " is not recognized as numeric or categorical. Do you want to cast it to a categorical?", sep=""), icon="question", parent=parent)
			if (cast) {
				newVars <- c(newVars, tableGUI_castToCat(i, parent=parent, e=e))
			}
		}
		# refresh varTbl
		varTbl <- e$varTbl
	}

    ## set selected variables to selected
	varTbl[varId, "Selected"] <- TRUE


	if (length(newVars)!=0) varId <- c(varId, sapply(newVars, 
		FUN=function(x,y){which(x==y)}, varTbl$Variable))
	
	## set sorting variable (if necessary)
	if ((length(varId)!=0) && numSelected==0) {
		varTbl[varId[1], "Sort"] <- "\\/"
	}

	## determine palette
	varIdCat <- varId[which(substr(varTbl[varId, "Type"],1 ,3)=="cat")]
	numOfNewCat <- length(varIdCat)
	if (numOfNewCat!=0) {
		palNrs <- rep(c("Set1", "Set2", "Set3", "Set4"), length.out=numOfCat+numOfNewCat)
		if (numOfCat!=0) palNrs <- palNrs[-(1:numOfCat)]
		varTbl[varIdCat, "Palette"] <- palNrs #sapply(palNrs, FUN=function(x){paste("default(", x, ")", sep="")})
		
		palettes <- e$palettes
		for (i in 1:numOfNewCat) {
			palettes[varIdCat[i]] <- palNrs[i]
		}	
		assign("palettes", palettes, envir=e)
	}

	
	assign("varTbl", varTbl, envir=e)
	
	return(varTbl[varId, "Variable"])
}


## function to transfer variables from table2 back to table1
tableGUI_unselectVars <- function(vars, parent, e) {
	
	varTbl <- e$varTbl
	
	varId <- sapply(vars, FUN=function(x,y){which(x==y)}, varTbl$Variable)

	varTbl$Selected[varId] <- FALSE
	varTbl$Sort[varId] <- ""

	
	assign("varTbl", varTbl, envir=e)
	
	return(vars)
}


## function to test filter
tableGUI_filter <- function(filter, e) {

	if (filter=="") {
		assign("correctFilter", TRUE, envir=e)
		return(TRUE)
	}

	filter <- gsub("\u00c2.", "'", filter)
	
	varTable <- tableGUI_getTbl2(cols=c("Variable", "Class"), e=e)
	if (filter %in% varTable$Variable) {
		if (varTable$Class[varTable$Variable==filter]=="factor") {
			assign("correctFilter", TRUE, envir=e)
			return(TRUE)
		} else {
			gmessage("Filter variable is not a categorical variable", title = "Error", icon = "error")	
			assign("correctFilter", FALSE, envir=e)
			return(FALSE)
		}
	} 
	
	currentDFname <- tableGUI_getCurrentDFname(e)
	dat <- get(currentDFname, envir=.GlobalEnv)[1:5, ]

	
	if (class(try({
		filterExpr <- parse(text=filter)
		sel <- eval(filterExpr, dat)
		dat <- dat[sel,]}, silent=TRUE))=="try-error") {
		gmessage("Filter is not correct", title = "Error", icon = "error")	
		assign("correctFilter", FALSE, envir=e)
		return(FALSE)
	} else {
		assign("correctFilter", TRUE, envir=e)
		return(TRUE)
	}
}


## applied when clicked on run button 
tableGUI_run <- function(vars, gui_from, gui_to, gui_nBins, gui_filter, e) {
	currentDFname <- tableGUI_getCurrentDFname(e)
	
	nBins <- min(gui_nBins, tableGUI_getCurrentDFnrow(e))
	
	varTable <- tableGUI_getTbl2(vars=vars, cols=c("Variable", "Scale", "Sort", "Palette"), e=e)


	createVector <- function(x, quotes=FALSE) {
		if (length(x)==1) {
			return(as.character(ifelse(quotes, paste("\"", x, "\"", sep=""), x)))
		} else if (quotes) {
			return(paste("c(\"", paste(x,collapse="\",\""),"\")", sep=""))
		} else {
			return(paste("c(", paste(x,collapse=","),")", sep=""))
		}
	}

	
	# prepare scales
	isCat <- varTable$Palette!=""
	scales <- varTable$Scale[!isCat]
	
	if (length(scales)==0) scales <- "auto"
	
	# prepare sortCol and decreasing
	sorts <- varTable$Sort
	sortID <- sorts!=""
	sortColNames <- vars[sortID]
	
	sortCol <- sapply(sortColNames, FUN=function(x, y) which(x==y), vars)
	
	sortColPrint <- createVector(sortCol)

	
	decreasing <- sorts[sortID]=="\\/"
	decreasingPrint <- createVector(decreasing)

	# filter
	gui_filter <- gsub("\u00c2.", "'", gui_filter)
	gui_filter2 <- gsub("\"", "\\\\\"", gui_filter)
	filterPrint <- ifelse(gui_filter=="", "", paste("subset=",gui_filter2, ", ", sep=""))
	if (gui_filter=="") gui_filter3 <- TRUE else gui_filter3 <- gui_filter
	
	# palettes	
	isCat <- varTable$Palette!=""
	palettes <- as.list(varTable$Palette[isCat])
	names(palettes) <- varTable$Variable[isCat]
	customNames <- names(palettes)[varTable$Palette[isCat]=="custom"]
	
	
	for (i in customNames) {
		palettes[[i]] <- e$customPals[[i]]
	}
	
	palPrint <- paste("list(", paste(sapply(palettes, createVector, quotes=TRUE), collapse=","), ")", sep="")
		
	if (dev.cur()==1) {
		dev.new(width=min(11, 2+2*tableGUI_getNumSel(e)), height=7, rescale="fixed")
	}
	if (!is.null(e$tab) && class(e$tab)=="tabplot") { ##second check needed since tab can be a list of tabplots
		## check whether existing tabplot object is usable
		tab <- e$tab
		isUsable <- isTabplotUsable(tab, vars, sortCol, decreasing, scales, nBins, gui_from, gui_to, gui_filter)
	} else {
		isUsable <- FALSE
	}
	 
	## simplify scales vector
	if (all(scales==scales[1])) scales <- scales[1]
	scalesPrint <- createVector(scales, quotes=TRUE)

	if (isUsable) {
		firstSortColID <- match(vars[sortCol[1]], sapply(tab$columns, function(col)col$name))
		flip <- (tab$columns[[firstSortColID]]$sort=="decreasing") != decreasing[1]
		tab <- tableChange(tab, select_string=vars, flip=flip, pals=palettes)
	} else {
		if (tableGUI_getCurrentDFclass(e)=="data.table") {
			tab <- tableplot(get(currentDFname, envir=.GlobalEnv)[, vars, with=FALSE], sortCol=sortCol, decreasing=decreasing, nBins=nBins, from=gui_from, to=gui_to, subset_string=gui_filter3, scales=scales, pals=palettes, plot=FALSE)
		} else 
		{
			tab <- tableplot(get(currentDFname, envir=.GlobalEnv)[vars], sortCol=sortCol, decreasing=decreasing, nBins=nBins, from=gui_from, to=gui_to, subset_string=gui_filter3, scales=scales, pals=palettes, plot=FALSE)
		}
	}

	
	## print commandline to reproduce tableplot
	cat("tableplot(", currentDFname, ", select=c(", paste(vars,collapse=", "), "), ", filterPrint, "sortCol=", sortColPrint, ", decreasing=", decreasingPrint, ", nBins=", nBins, ", from=", gui_from, ", to=", gui_to, ", scales=", scalesPrint, ", pals=", palPrint, ")\n", sep="")

	
	assign("tab", tab, envir=e)	
	if(class(tab)=="tabplot")
		plot(tab)
	else
		lapply(tab, plot)
}





