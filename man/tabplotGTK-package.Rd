\docType{package}
\name{tabplotGTK-package}
\alias{tabplotGTK}
\alias{tabplotGTK-package}
\title{A graphical user interface for the tabplot package}
\description{
  \tabular{ll}{ Package: \tab tabplotGTK\cr Type: \tab
  Package\cr Version: \tab 0.5-2\cr Date: \tab
  2012-05-01\cr License: \tab GPL-3\cr LazyLoad: \tab
  yes\cr }
}
\details{
  This package offers a GTK graphical user interface for
  the creation of tableplots with the tabplot package.

  The function \code{\link{tableGUI}} is used to start the
  graphical user interface.
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

