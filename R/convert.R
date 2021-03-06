#' @rdname tfd
#' @export
as.tfd <- function(data, ...) UseMethod("as.tfd")
as.tfd.default <- function(data, ...) {
  tfd(data, ...)
}

# TODO: this ignores arg, domain for now, only needed internally in c.tfd
#' @rdname tfd
as.tfd_irreg <- function(data, ...) UseMethod("as.tfd_irreg")

as.tfd_irreg.tfd_reg <- function(data, ...) {
  arg <- ensure_list(tf_arg(data))
  ret <- map2(tf_evaluations(data), arg, ~list(arg = .y, value = .x))
  attributes(ret) <- attributes(data)
  attr(ret, "arg") <- numeric(0)
  class(ret)[1] <- "tfd_irreg"
  ret
}

as.tfd_irreg.tfd_irreg <- function(data, ...) {
  data
}

#' @rdname tfd
#' @param row.names not used
#' @param optional not used
#' @param x an `tfd` object
#' @inheritParams [.tf
#' @export
as.data.frame.tfd <- function(x, row.names = NULL, optional = FALSE,
                              arg = NULL, interpolate = FALSE, ...) {
  if (is.null(arg)) {
    arg <- ensure_list(tf_arg(x))
  }
  tmp <- x[, arg, interpolate = interpolate, matrix = FALSE]
  id <- unique_id(names(x)) %||% seq_along(x)
  id <- ordered(id, levels = id) # don't reshuffle
  tidyr::unnest(bind_rows(list(id = id, data = tmp)))
}

#' @rdname tfd
#' @export
as.matrix.tfd <- function(x, arg = NULL, interpolate = FALSE, ...) {
  if (is.null(arg)) {
    arg <- sort(unique(unlist(tf_arg(x))))
  }
  ret <- x[, arg, interpolate = interpolate, matrix = TRUE]
  structure(ret, arg = as.numeric(colnames(ret)))
}

#-------------------------------------------------------------------------------

#' @rdname tfb
#' @param basis either "mgcv" to call [tfb()] which uses `mgcv`-type spline basis functions
#'   or "fpc" to call [tfb_fpc()] which uses a (smoothed) functional principal component basis.
#' @export
as.tfb <- function(data, basis = c("mgcv", "fpc"), ...) UseMethod("as.tfb")
as.tfb.default <- function(data, basis = c("mgcv", "fpc"), ...) {
  basis <- match.arg(basis)
  tfb_maker <- switch(basis, "mgcv" = tfb, "fpc" = tfb_fpc)
  tfb_maker(data, ...)
}

#' @rdname tfb
#' @param row.names not used
#' @param optional not used
#' @param x an `tfb` object
#' @export
as.data.frame.tfb <- function(x, row.names = NULL, optional = FALSE,
                              arg = NULL, ...) {
  if (is.null(arg)) {
    arg <- ensure_list(tf_arg(x))
  }
  tmp <- x[, arg, matrix = FALSE]
  id <- unique_id(names(x)) %||% seq_along(x)
  id <- ordered(id, levels = id) # don't reshuffle
  tidyr::unnest(bind_rows(list(id = id, data = tmp)))
}

#' @rdname tfb
as.matrix.tfb <- function(x, arg = NULL, ...) {
  ret <- as.data.frame(x, arg = arg) %>%
    arrange(arg) %>%
    tidyr::spread(key = arg, value = value) %>%
    select(-id) %>%
    as.matrix()
  rownames(ret) <- names(x)
  structure(ret, arg = as.numeric(colnames(ret)))
}

#-------------------------------------------------------------------------------
#' @export
as.function.tf <- function(x, ...) {
  function(arg) unlist(tf_evaluate(object = x, arg = arg))
}
