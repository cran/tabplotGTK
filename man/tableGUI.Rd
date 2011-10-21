\name{tableGUI}
\alias{tableGUI}
\title{Start a GUI}
\usage{
  tableGUI(dat = NULL, colNames = names(dat), sortCol = 1,
  decreasing = TRUE, nBins = 100, from = 0, to = 100,
  filter = NULL, scales = "auto", pals = list("Set1",
  "Set2", "Set3", "Set4"), ...)
}
\arguments{
  \item{dat}{either a \link{tabplot-object} or a dataset
  (see \code{\link{tableplot}})}

  \item{colNames}{see \code{\link{tableplot}}}

  \item{sortCol}{see \code{\link{tableplot}}}

  \item{decreasing}{see \code{\link{tableplot}}}

  \item{nBins}{see \code{\link{tableplot}}}

  \item{from}{see \code{\link{tableplot}}}

  \item{to}{see \code{\link{tableplot}}}

  \item{filter}{see \code{\link{tableplot}}}

  \item{scales}{see \code{\link{tableplot}}}

  \item{pals}{see \code{\link{tableplot}}}

  \item{...}{other arguments of \code{\link{tableplot}} are
  currently ignored}
}
\description{
  There are three options to start the GUI: \enumerate{
  \item Without any arguments. The GUI is initialized
  empty. \item With \code{dat} being a
  \link{tabplot-object}. The GUI is initialized according
  to the settings of \code{dat}. \item With the same set of
  arguments as \code{\link{tableplot}}. The GUI is
  initialized according to these arguments.} General work
  flow: \enumerate{ \item select a loaded dataset \item
  select variables \item configure the tableplot: determine
  the sorted variable, the scales, palettes, number of
  bins, etc. \item create the tableplot, and if needed,
  save it} Actions, such as generating and saving
  tableplots, are printed in the console for
  reproducibility.
}
\examples{
\dontrun{
  tableGUI()
}
}

