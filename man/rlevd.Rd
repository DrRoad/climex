% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/extremes.R
\name{rlevd}
\alias{rlevd}
\title{Return level calculation}
\usage{
rlevd(period, location = NULL, scale = NULL, shape = NULL,
  threshold = NULL, model = c("gev", "gpd"), silent = FALSE)
}
\arguments{
\item{period}{Return period in years.}

\item{location}{Of the GEV distribution. Default = NULL.}

\item{scale}{Of the GEV/GP distribution. Default = NULL.}

\item{shape}{Of the GEV/GP distribution. Default = NULL.}

\item{threshold}{Used in the GP distribution. This parameter is
optional but should be provided in order to create a representation
of the fitted data exceedance. Default = NULL.}

\item{model}{Determines if to use the GEV or GP distribution.
Default = "gev".}

\item{silent}{Whether to display warnings or not. Default = FALSE.}
}
\value{
Numerical vector of the same length as 'period'.
}
\description{
Internal function to calculate the return level of
  GEV or GP distribution.
}
\details{
Port from the extRemes package to ensure compatibility and
to make the threshold argument obligatory. This is just for internal
usage. Please use the \code{\link{return.level}} function instead!
}
\seealso{
Other extremes: \code{\link{block}},
  \code{\link{decluster}}, \code{\link{extremal.index}},
  \code{\link{gev.density}}, \code{\link{gpd.density}},
  \code{\link{qevd}}, \code{\link{return.level}},
  \code{\link{revd}}, \code{\link{threshold}}
}
\author{
Philipp Mueller
}
