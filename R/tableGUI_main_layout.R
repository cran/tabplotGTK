tableGUI_main_layout <- function(e) {
#	browser()
	with(e, {

	
		######################################################
		## create GUI
		######################################################
		## create window
		wdw <- gwindow("Tableplot",visible=FALSE)
		sbr <- gstatusbar("Preparing...", cont=wdw)
		g <- gpanedgroup(cont=wdw)

		## create source frame
		ggg <- ggroup(horizontal = TRUE, cont = g, expand=TRUE)
		frm2 <- gframe(text="Source",horizontal = FALSE, cont = ggg) 
		size(frm2) <- c(350,400)
		grp4 <- ggroup(horizontal = FALSE, cont = frm2, expand=TRUE)
		grp9 <- ggroup(horizontal = TRUE, cont = grp4, expand=FALSE)
		lbl3 <- glabel("Data.frame:", cont=grp9)
		cmb <- gcombobox(datlist, cont=grp9)
		svalue(cmb) <- tableGUI_getCurrentDFname(e)
		blockCmbHandler <- FALSE
		
		#addSpring(grp9)
		btnReload <- gbutton("Reload", cont=grp9, expand=FALSE)

		######## temp
# 		btnTemp <- gbutton("varTbl", cont=grp9, expand=FALSE)
# 
# 		addHandlerClicked(btnTemp, function(h,...) {
# 			print(e$varTbl)
# 		})
		########
		
		
		## fill table 1
		tbl1 <- gtable(tableGUI_getTbl1(e=e), multiple=TRUE, cont=grp4, expand=TRUE)

		grp10 <- ggroup(horizontal = TRUE, cont = grp4, expand=FALSE)
		lbl4 <- glabel("Number of Objects:", cont=grp10)
		lbl5 <- glabel(nrow(get(svalue(cmb), envir=.GlobalEnv)), cont=grp10) 

		## create transfer button
		grp8 <- ggroup(horizontal = FALSE, cont = ggg, anchor=c(-1, -1),expand=TRUE)
		addSpring(grp8)
		btnTransfer <- gbutton(">", cont=grp8, expand=TRUE); enabled(btnTransfer) <- FALSE
		addSpace(grp8, 100, horizontal=FALSE)

		## create config frame
		frm <- gframe(text="Tableplot Configuration",horizontal = FALSE, cont = g) 
		size(frm) <- c(350,400)
		grp6 <- ggroup(horizontal = FALSE, cont = frm, expand=TRUE) 
		#lbl3 <- glabel("Columns", cont=grp6)

		table2content <- tableGUI_getTbl2(e=e)
		
		
		table2content <- table2content[sorted, ]
		
		tbl2 <- gtable(table2content, multiple=TRUE, cont=grp6, expand=TRUE)

		grp7 <- ggroup(horizontal = TRUE, cont = grp6, expand=FALSE) 
		btnUp <- gbutton("Up", cont=grp7, expand=TRUE); enabled(btnUp) <- FALSE
		btnDown <- gbutton("Down", cont=grp7, expand=TRUE); enabled(btnDown) <- FALSE
		btnScale <- gbutton("Scale", cont=grp7, expand=TRUE); enabled(btnScale) <- FALSE
		btnSort <- gbutton("Sort", cont=grp7, expand=TRUE); enabled(btnSort) <- FALSE
		btnAsCategory <- gbutton("As Categorical", cont=grp7, expand=TRUE); enabled(btnAsCategory) <- FALSE
		btnPal <- gbutton("Palette", cont=grp7, expand=TRUE); enabled(btnPal) <- FALSE

		ready <- nrow(table2content)!=0 
		
		
		grp2 <- ggroup(horizontal = TRUE, cont = grp6) 
		showZoom <- (from!=0 || to!=100) & ready
		cbx <- gcheckbox(text="Zoom in", checked = showZoom, cont= grp2)
		
		lbl7 <- glabel("from", cont=grp2)
		spbBinsFrom <- gspinbutton(0, 100, by = 10, cont=grp2, expand=FALSE)
		svalue(spbBinsFrom) <- from
		
		lbl8 <- glabel("percent to", cont=grp2)
		spbBinsTo <- gspinbutton(0, 100, by = 10, cont=grp2, expand=FALSE)
		svalue(spbBinsTo) <- to
		lbl9 <- glabel("percent", cont=grp2)
		enabled(cbx) <- ready
		enabled(lbl7) <- showZoom
		enabled(spbBinsFrom) <- showZoom
		enabled(lbl8) <- showZoom
		enabled(spbBinsTo) <- showZoom
		enabled(lbl9) <- showZoom

		
		correctFilter <- tableGUI_filter(filter, e)
		grp3 <- ggroup(horizontal = TRUE, cont = grp6) 
		lbl10 <- glabel("Filter:", cont=grp3)
		gtxtFilter <- gedit(text= filter, cont=grp3)
		enabled(lbl10) <- enabled(gtxtFilter) <- ready
		
		grp1 <- ggroup(horizontal = TRUE, cont = grp6) 
		lbl1 <- glabel("Number of Row Bins:", cont=grp1)
		spbBins <- gspinbutton(0, 1000, by = 10, cont=grp1, expand=TRUE)
		svalue(spbBins) <- nBins
		enabled(lbl1) <- enabled(spbBins) <- ready
		
		btnSave <- gbutton("Save", cont=grp1, expand=TRUE); enabled(btnSave) <- FALSE
		btnRun <- gbutton("Run", cont=grp1, expand=TRUE); enabled(btnRun) <- ready
	})
}