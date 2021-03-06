% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ts.R
\name{remove.seasonality}
\alias{remove.seasonality}
\title{Remove seasonality}
\usage{
remove.seasonality(x)
}
\arguments{
\item{x}{Time series of class "xts"}
}
\value{
Deseasonalized time series of class "xts".
}
\description{
Calculates the seasonal component of a time series
  and subtracts it from the original.
}
\details{
Only time series of class "xts" are accepted (on purpose
  because I want to get rid of handling both objects of class "ts"
  and "xts"). For now \code{\link[stats]{stl}} with s.window = 12
  and a 
  conversion of the input into a ts object of daily data is used
  to calculate the seasonal component. This should be replaced by
  a more sophisticated solution as soon I digged deeper into the
  field of
  deseasonalization. \code{\link{remove.incomplete.years}} is used
  to remove incomplete years from the data set. This ensures a
  better calculation of the seasonal component but also requires
  to forecast it to the length of the original data set and align
  it at the right place for subtraction.
}
\seealso{
Other ts: \code{\link{aic}}, \code{\link{anomalies}},
  \code{\link{bic}}, \code{\link{remove.incomplete.years}}
}
\author{
Philipp Mueller
}
