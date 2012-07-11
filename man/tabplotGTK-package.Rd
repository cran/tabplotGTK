\docType{package}
\name{tabplotGTK-package}
\alias{tabplotGTK}
\alias{tabplotGTK-package}
\title{A graphical user interface for the tabplot package}
\description{
  \tabular{ll}{ Package: \tab tabplotGTK\cr Type: \tab
  Package\cr Version: \tab 0.6\cr Date: \tab 2012-07-11\cr
  License: \tab GPL-3\cr LazyLoad: \tab yes\cr }
}
\details{
  This package offers a GTK graphical user interface for
  the creation of tableplots with the \code{\link{tabplot}}
  package.

  The function \code{\link{tableGUI}} is used to start the
  graphical user interface. This interface does not support
  all features that are available in \code{\link{tabplot}},
  for instance the saving possibilities. However, for each
  created tableplot, the code to regenerate it is returned
  to the output console. Furthermore, the output can be
  saved into workspace as a \link{tabplot-object}, which
  can be edited and which can be used as input for
  \code{\link{tableSave}}. Note regarding RStudio: after
  pressing the Run button, press enter in the console to
  show the tableplot.
}
\examples{
# load diamonds dataset from ggplot2
require(ggplot2)
data(diamonds)

# start GUI

# Not run:
tableGUI()
# End(Not run)
}
\author{
  Martijn Tennekes \email{mtennekes@gmail.com} and Edwin de
  Jonge
}
\keyword{datasets,}
\keyword{GTK,}
\keyword{GUI}
\keyword{large}
\keyword{visualization,}

