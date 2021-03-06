% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/opti.R
\name{fit.gpd}
\alias{fit.gpd}
\title{Robust maximum-likelihood fit of the GPD distribution}
\usage{
fit.gpd(x, initial = NULL, threshold = NULL,
  likelihood.function = likelihood, gradient.function = likelihood.gradient,
  error.estimation = c("MLE", "MC", "bootstrap", "none"),
  monte.carlo.sample.size = 100, bootstrap.sample.size = 100,
  return.period = 100, total.length = NULL, silent = TRUE, ...)
}
\arguments{
\item{x}{Threshold exceedances with the threshold already subtracted.}

\item{initial}{Initial values for the GPD parameters. Has to be
provided as 2x1 vector. If NULL the parameters are estimated
with the function \code{\link{likelihood.initials}}. If the
shape parameter is set to 0 the exponential distribution instead
of the GP one is fitted. But this its strongly discouraged to do
so! Default = NULL}

\item{threshold}{Optional threshold used to extract the exceedances
from the provided series \emph{x}. If present it will be added to the
return level to produce a value which fits to underlying time series.
Default = NULL.}

\item{likelihood.function}{Function which is going to be optimized.
Default: \code{\link{likelihood}}}

\item{gradient.function}{If NULL a finite difference method is
invoked. To use the derived formula from the GPD likelihood gradient
provide \code{\link{likelihood.gradient}}.
Default = \code{\link{likelihood.gradient}}.}

\item{error.estimation}{Method for calculating the standard errors of
the fitted results. The errors of the GPD parameters will be
calculated as the square roots of the diagonal elements of the
inverse of the hessian matrix. The latter will be evaluated at the
maximum likelihood estimates (MLE) of the GPD parameters.

\strong{MLE}: The standard error of the return level is
calculated using the Delta method and the maximum likelihood
estimates of the GPD parameters. Note: For positive shape
  parameters bigger than 0.3 this approach tends to highly
  overestimates the errors of the return levels.

\strong{MC}: Alternative one can use a Monte Carlo method for which
\emph{monte.carlo.sample.size} samples of the same size as \emph{x} will be drawn
from a GPD distribution constituted by the obtained MLE of the GPD
parameters of \emph{x}. The standard error is then calculated via the square
of the variance of all fitted GPD parameters and calculated return
levels. Note: In its essence this approach is not an estimation of
  the error involved in fitting the time series to a GPD
  distribution. It is rather the mean error of fitting a
  GPD-distribution with the same length and parameters as
  estimated ones.

\strong{bootstrap}: Using this option the provided time series
  \emph{x} will be sampled with replacement
  \emph{bootstrap.sample.size} times and with the same length as
  the original time series. The standard errors of the GPD
  parameters and return levels of all those sampled series is
  calculated and returned as an estimate of the fitting error.
  Note: Since the data is (hopefully) GPD-distributed, such a
  sampling has to be treated with a lot of care.

Sometimes the inversion of the hessian fails (since the are some NaN
in the hessian) when calculating the error estimates using the
  maximum likelihood approach (MLE) (which is also the reason why
  the ismev package occasionally does not work). In such cases the
  Monte Carlo (MC) method is used as a fallback. Option

\strong{none} skips the calculation of the error. 
Default = "MLE".}

\item{monte.carlo.sample.size}{Number of samples used to obtain the
Monte Carlo estimate of the standard error of the fitting.
Default = 100.}

\item{bootstrap.sample.size}{Number of samples with replacements
to drawn from the original series \emph{x} in order to determine
the standard errors for the GPD parameters and return
levels. Default = 100.}

\item{return.period}{Quantiles at which the return level is going to
be evaluated. Class "numeric". Default = 100.}

\item{total.length}{Uses the maximum likelihood estimator to
calculate the probability of a measurement to be an
exceedance. Else an estimate based on the mean number of
exceedances in the available years (time stamps of the class
"xts" time series) will be used. Default = NULL.}

\item{silent}{Determines whether or not warning messages shall be
displayed and results shall be reported. Default = TRUE.}

\item{...}{Additional arguments for the optim() function.}
}
\value{
Output of the optim function with class ==
c( "list", "climex.fit.gpd" )
\itemize{
 \item{ par = MLE of the GPD parameters }
 \item{ value = Value of the negative log-likelihood
evaluated at the MLE }
 \item{ counts = Number of evaluations of the likelihood
function and its gradient during optimization (inner routine) }
 \item{ outer.iteration = Number of updates of the penalty and
the Lagrangian parameter to fine-tune the impact of the
constraints on the optimization (outer routine) }
 \item{ return.level = Estimate of the return levels at the provided
return periods }
 \item{ se = Standard error of the GPD parameters and the return
levels }
 \item{ x = Threshold exceedances }
 \item{ threshold = Value which had to be exceeded }
 \item{ control = Parameter and options used during optimization }
}
}
\description{
This function fits the Generalized Pareto distribution
(GPD) to the supplied data, which have to be threshold exceedances
with the corresponding threshold already subtracted. The
determination of the starting point for the optimization and the
calculation of the return level and the all the corresponding
estimates of the fitting errors will be done internally.
}
\details{
The optimization is performed by the augmented Lagrangian
method using the \code{\link{auglag}} function of the
  \pkg{alabama} package. Within this framework the log-likelihood
  function of the GPD 
gets augmented with N+2 constraints, where N is the
number of points in the time series. N+1 of those constraints ensure
the log-likelihood (containing two logarithms) to be always defined.
The remaining constraints ensures for the shape parameter to be
always bigger than -1 for the maximum likelihood to be defined in the
first place. The penalty in the log-likelihood function is the sum of
all squared constrain violations plus an additional term linear in
the constraint violation to ensure well-conditioning. Using this
penalty term the problem becomes unconstrained again and can be
solved using \code{\link[stats]{optim}}. After each of those inner
routines the weighting parameter of the penalty is being increased
until some convergence conditions are fulfilled.

Since it usually takes just four to five outer iterations this
functions needs only double the time a pure call to the
  \code{\link[stats]{optim}} function would need.

  The \emph{total.length} argument refers to the length of the
  original time series before the thresholding was applied. If
  present it will be used to calculate the maximum likelihood
  estimate of the probability of an observation to be a threshold
  exceedance (necessary to determine the estimation errors for the
  calculated return levels). Else an estimator based on mean
  number of exceedances per year will be used.

If the user instead wants to fit just the exponential distribution
and not the entire GP distribution, the shape parameter of the
\emph{initial} has to be set to 0. But in practice this is strongly
discouraged since it will yield inferior results.

I found the Nelder-Mead method to be more robust to starting
points more far away from the global optimum. This also holds
for the inner routine of the augmented Lagrangian method. Since
other routines, like CG and BFGS only cause problems in the
extreme value analysis, there won't be an option to choose them
in this package.
}
\examples{
potsdam.anomalies <- anomalies( temp.potsdam )
potsdam.extremes <- threshold( potsdam.anomalies, threshold = 10,
                               decluster = TRUE )
fit.gpd( potsdam.extremes )
}
\seealso{
Other optimization: \code{\link{fit.gev}},
  \code{\link{likelihood.augmented}},
  \code{\link{likelihood.gradient.augmented}},
  \code{\link{likelihood.gradient}},
  \code{\link{likelihood.initials}},
  \code{\link{likelihood}}
}
\author{
Philipp Mueller
}
