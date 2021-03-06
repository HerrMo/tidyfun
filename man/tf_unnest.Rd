% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/tidyr.R
\name{tf_unnest}
\alias{tf_unnest}
\title{Turn data frames with \code{tf}-objects / list columns into "long" tables.}
\usage{
tf_unnest(data, ..., .arg, .drop = NA, .id = "id", .sep = "_",
  .preserve = NULL, try_dropping = TRUE)
}
\arguments{
\item{data}{a data frame}

\item{...}{optional:  A selection of columns. If empty, all \code{tfd}-variables
are selected. You can supply bare variable names,
select all variables between \code{x} and \code{z} with \code{x:z}, exclude \code{y} with \code{-y}.
For more options, see the \code{\link[dplyr:select]{dplyr::select()}} documentation.}

\item{.arg}{optional values for the \code{arg} argument of \code{\link[=tf_evaluate.data.frame]{tf_evaluate.data.frame()}}}

\item{.drop}{Should additional list columns be dropped? By default,
\code{unnest} will drop them if unnesting the specified columns requires
the rows to be duplicated.}

\item{.id}{Data frame identifier - if supplied, will create a new column
with name \code{.id}, giving a unique identifier. This is most useful if
the list column is named.}

\item{.sep}{If non-\code{NULL}, the names of unnested data frame columns
will combine the name of the original list-col with the names from
nested data frame, separated by \code{.sep}.}

\item{.preserve}{Optionally, list-columns to preserve in the output. These
will be duplicated in the same way as atomic vectors. This has
\link[dplyr:select]{dplyr::select} semantics so you can preserve multiple variables with
\code{.preserve = c(x, y)} or \code{.preserve = starts_with("list")}.}

\item{try_dropping}{should \code{tf_unnest} try to avoid duplicating \code{id} or
\code{arg} columns? Defaults to TRUE.}
}
\value{
a "long" data frame with
}
\description{
Similar in spirit to \code{\link[tidyr:unnest]{tidyr::unnest()}}, the reverse of \code{tf_nest}.
}
\seealso{
tf_gather(), tf_unnest(), tf_evaluate.data.frame()
}
