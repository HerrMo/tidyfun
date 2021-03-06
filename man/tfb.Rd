% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/convert.R, R/tfb-class.R
\name{as.tfb}
\alias{as.tfb}
\alias{as.data.frame.tfb}
\alias{as.matrix.tfb}
\alias{tfb}
\alias{tfb.data.frame}
\alias{tfb.matrix}
\alias{tfb.numeric}
\alias{tfb.list}
\alias{tfb.tfd}
\alias{tfb.tfb}
\title{Constructors & convertors for functional data in (spline) basis representation}
\usage{
as.tfb(data, basis = c("mgcv", "fpc"), ...)

\method{as.data.frame}{tfb}(x, row.names = NULL, optional = FALSE,
  arg = NULL, ...)

\method{as.matrix}{tfb}(x, arg = NULL, ...)

tfb(data, ...)

\method{tfb}{data.frame}(data, id = 1, arg = 2, value = 3,
  domain = NULL, penalized = TRUE, resolution = NULL, ...)

\method{tfb}{matrix}(data, arg = NULL, domain = NULL,
  penalized = TRUE, resolution = NULL, ...)

\method{tfb}{numeric}(data, arg = NULL, domain = NULL,
  penalized = TRUE, resolution = NULL, ...)

\method{tfb}{list}(data, arg = NULL, domain = NULL, penalized = TRUE,
  resolution = NULL, ...)

\method{tfb}{tfd}(data, arg = NULL, domain = NULL, penalized = TRUE,
  resolution = NULL, ...)

\method{tfb}{tfb}(data, arg = NULL, domain = NULL, penalized = TRUE,
  resolution = NULL, ...)
}
\arguments{
\item{data}{a \code{matrix}, \code{data.frame} or \code{list} of suitable shape, or another
\code{tf}-object.}

\item{basis}{either "mgcv" to call \code{\link[=tfb]{tfb()}} which uses \code{mgcv}-type spline basis functions
or "fpc" to call \code{\link[=tfb_fpc]{tfb_fpc()}} which uses a (smoothed) functional principal component basis.}

\item{...}{\strong{for \code{tfb}}: arguments to the calls to \code{\link[mgcv:s]{mgcv::s()}} setting up the basis and
\code{\link[mgcv:magic]{mgcv::magic()}} (if \code{penalized} is TRUE). If not user-specified here,
\code{tidyfun} uses \code{k=15} cubic regression spline basis functions (i.e., \code{bs = "cr"}) by default, but at least how many basis functions \code{k} the spline
basis should have probably needs to be set manually.\cr
\strong{for \code{as.tfb}:} use this to give arguments to \code{\link[=tfb]{tfb()}} or \code{\link[=tfb_fpc]{tfb_fpc()}}.}

\item{x}{an \code{tfb} object}

\item{row.names}{not used}

\item{optional}{not used}

\item{arg}{\code{numeric}, or list of \code{numeric}s. The evaluation grid. See Details.
For the \code{data.frame}-method: the name/number of the column defining the evaluation grid.}

\item{id}{The name/number of the column defining which data belong to which function.}

\item{value}{The name/number of the column containing the function evaluations.}

\item{domain}{range of the \code{arg}.}

\item{penalized}{should the coefficients of the basis representation be estimated
via \code{\link[mgcv:magic]{mgcv::magic()}} (default) or ordinary least squares.}

\item{resolution}{resolution of the evaluation grid. See details for \code{\link[=tfd]{tfd()}}.}
}
\value{
an \code{tfb}-object (or a \code{data.frame}/\code{matrix} for the conversion
functions, obviously.)
}
\description{
Various constructor and conversion methods.
}
\details{
\code{tfb} tries to represent the input data as linear
combinations of a set of common spline basis functions identical for all
observations and coefficient vectors estimated for each observation. The
basis used is set up via a call to \code{\link[mgcv:s]{mgcv::s()}} and all the spline bases
discussed in \link[mgcv:smooth.terms]{mgcv::smooth.terms} are available, in principle. Depending on
the value of the \code{penalized}-flag, the coefficient vectors for each
observation are then estimated via fitting a (small) GAM for each observation
via \code{\link[mgcv:magic]{mgcv::magic()}} or via simple ordinary least squares.

After the "smoothed" representation is computed, the amount of smoothing that
was performed is reported in terms of the "percentage of variance preserved",
which is the variance of the smoothed function values divided by the variance
of the original values. The \code{...} arguments supplies arguments to both the
spline basis set up (via \code{\link[mgcv:s]{mgcv::s()}}) and the estimation (via
\code{\link[mgcv:magic]{mgcv::magic()}}), most important: how many basis functions \code{k} the spline
basis should have, the default is 25.

See \code{\link[=tfb_fpc]{tfb_fpc()}} for using an FPC representation with an orthogonal basis estimated from the
data instead.
}
\seealso{
\code{\link[=tfb_fpc]{tfb_fpc()}}
}
