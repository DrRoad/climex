% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/extremes.R
\name{decluster}
\alias{decluster}
\title{Decluster data}
\usage{
decluster(x, threshold, cluster.distance = NULL, silent = FALSE)
}
\arguments{
\item{x}{Time series. The full one, not just the
exceedances.position! Can be of class 'xts' or 'numeric'}

\item{threshold}{Has to be set sufficient high to fulfill the
asymptotic condition for the GP distribution.}

\item{cluster.distance}{Specifies how many points have to be below
the threshold for the next point to be considered the starting point
of a new cluster. Only supply a value when you really know what you
are doing! Default = NULL}

\item{silent}{Whether or not to display warnings.}
}
\value{
Returns the original time series x with all the elements
within one cluster having smaller values than the clusters maximum
being replaced by NA.
}
\description{
Decluster point over threshold data used for GP
  fitting.
}
\details{
This function determines clusters in a time series and
extract just their maximal value in order to remove short-range
correlations. All exceedances.position will be considered belonging
to a cluster until at least cluster.distance consecutive points fall
below the threshold. The parameter cluster.distance will be
determined using the extremal index as suggested in Ferro & Segers
(2003) when set to NULL. It thus provides a non-parametric way of
declustering.
It also features a special treatment of missing values. All of them
will be kept and the returned time series will have the same length
as the input. Separate missing values and small sequences will be
omitted in the cluster determination. But if more than 15 missing
values appear in a row, they will be replaced with the minimal value
of the time series for the cluster detection. This way exceedances
separated over a big temporal distance will not be considered to
belong to the same cluster.
}
\seealso{
Other extremes: \code{\link{block}},
  \code{\link{extremal.index}}, \code{\link{gev.density}},
  \code{\link{gpd.density}}, \code{\link{qevd}},
  \code{\link{return.level}}, \code{\link{revd}},
  \code{\link{rlevd}}, \code{\link{threshold}}
}
\author{
Philipp Mueller
}
