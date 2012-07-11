#' A graphical user interface for the tabplot package
#'
#' \tabular{ll}{
#' Package: \tab tabplotGTK\cr
#' Type: \tab Package\cr
#' Version: \tab 0.6\cr
#' Date: \tab 2012-07-11\cr
#' License: \tab GPL-3\cr
#' LazyLoad: \tab yes\cr
#' }
#'
#' This package offers a GTK graphical user interface for the creation of tableplots with the \code{\link{tabplot}} package.
#'
#' The function \code{\link{tableGUI}} is used to start the graphical user interface. This interface does not support all features that are available in \code{\link{tabplot}}, for instance the saving possibilities. However, for each created tableplot, the code to regenerate it is returned to the output console. Furthermore, the output can be saved into workspace as a \link{tabplot-object}, which can be edited and which can be used as input for \code{\link{tableSave}}. Note regarding RStudio: after pressing the Run button, press enter in the console to show the tableplot.
#'
#' @name tabplotGTK-package
#' @aliases tabplotGTK
#' @docType package
#' @author Martijn Tennekes \email{mtennekes@@gmail.com} and Edwin de Jonge
#' @keywords visualization, large datasets, GTK, GUI
#' @example ../examples/pkg.R
{}