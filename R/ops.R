# *, / for tfs; and +, -, ^ for tfds
fun_op <- function(x, y, op, numeric = NA) {
  if (!is.na(numeric)) {
    num <- list(x, y)[[numeric]]
    f <- list(x, y)[[3 - numeric]]
    assert_numeric(num)
    # no "recycling" of args -- breaking a crappy R convention, proudly so.
    stopifnot(
      (length(num) > 0 & length(f) == 1) |
        length(num) %in% c(1, length(f))
    )
    attr_ret <- attributes(f)
    arg_ret <- tf_arg(f)
  } else {
    stopifnot(
      # no "recycling" of args
      (length(x) %in% c(1, length(y))) | (length(y) %in% c(1, length(x))),
      all.equal(tf_domain(x), tf_domain(y)),
      all.equal(tf_arg(x), tf_arg(y))
    )
    attr_ret <- attributes(y)
    arg_ret <- tf_arg(y)
  }
  if (is_tfb(x)) x_ <- coef(x)
  if (is_tfd(x)) x_ <- tf_evaluations(x)
  if (isTRUE(numeric == 1)) x_ <- x
  if (is_tfb(y)) y_ <- coef(y)
  if (is_tfd(y)) y_ <- tf_evaluations(y)
  if (isTRUE(numeric == 2)) y_ <- y
  ret <- map2(x_, y_, ~do.call(op, list(e1 = .x, e2 = .y)))
  if ("tfd" %in% attr_ret$class) {
    if (is.na(numeric) &&
      (attr(x, "evaluator_name") != attr(y, "evaluator_name"))) {
      warning(
        "inputs have different evaluators, result has ",
        attr_ret$evaluator_name
      )
    }
    forget(attr_ret$evaluator)
    if ("tfd_irreg" %in% attr_ret$class) {
      ret <- map2(arg_ret, ret, ~list(arg = .x, value = .y))
    }
  }
  attributes(ret) <- attr_ret
  ret
}

#' @rdname tfgroupgenerics
#' @export
Ops.tf <- function(e1, e2) {
  not_defined <- switch(.Generic,
    `%%` = , 
    `%/%` = ,
    `&` = , 
    `|` = , 
    `!` = ,
    `<` = , 
    `<=` = , 
    `>=` = , 
    `>` = TRUE, 
    FALSE
  )
  if (not_defined) {
    stop(sprintf("%s not defined for \"tf\" objects", .Generic))
  }
  if (nargs() == 1) {
    return(fun_op(0, e1, .Generic, numeric = 1))
  }
}

#' @rdname tfgroupgenerics
#' @export
`==.tfd` <- function(e1, e2) {
  # no "recycling" of args
  stopifnot((length(e1) %in% c(1, length(e2))) |
    (length(e2) %in% c(1, length(e1))))
  # not comparing names, as per convention...
  same <- all(compare_tf_attribs(e1, e2))
  if (!same) return(rep(FALSE, max(length(e1), length(e2))))
  unlist(map2(e1, e2, ~isTRUE(all.equal(.x, .y))))
}
#' @rdname tfgroupgenerics
#' @export
`!=.tfd` <- function(e1, e2) !(e1 == e2)
# need to copy instead of defining tf-method s.t. dispatch in Ops works
#' @rdname tfgroupgenerics
#' @export
`==.tfb` <- eval(`==.tfd`)
#' @rdname tfgroupgenerics
#' @export
`!=.tfb` <- eval(`!=.tfd`)

#' @rdname tfgroupgenerics
#' @export
Ops.tfd <- function(e1, e2) {
  ret <- NextMethod()
  if (nargs() != 1) {
    if (is_tfd(e1) && is_tfd(e2)) {
      if (.Generic == "^") {
        stop("^ not defined for \"tfd\" objects")
      } else {
        return(fun_op(e1, e2, .Generic))
      }
    }
    if (is.logical(e1)) e1 <- as.numeric(e1)
    if (is.logical(e2)) e2 <- as.numeric(e2)
    if (is_tfd(e1) && is.numeric(e2)) {
      return(fun_op(e1, e2, .Generic, numeric = 2))
    }
    if (is_tfd(e2) && is.numeric(e1)) {
      return(fun_op(e1, e2, .Generic, numeric = 1))
    }
    stop(sprintf(
      "binary %s not defined for classes %s and %s",
      .Generic, class(e1)[1], class(e2)[1]
    ))
  }
  ret
}
#' @rdname tfgroupgenerics
#' @export
Ops.tfb <- function(e1, e2) {
  ret <- NextMethod()
  if (nargs() != 1) {
    both_funs <- is_tfb(e1) & is_tfb(e2)
    if (both_funs) {
      if (.Generic == "^") {
        stop("^ not defined for \"tfb\" objects")
      }
      stopifnot(all(compare_tf_attribs(e1, e2)))
    }
    if (both_funs & .Generic %in% c("+", "-")) {
      # just add/subtract coefs for identical bases
      return(fun_op(e1, e2, .Generic))
    } else {
      # ... else convert to tfd, compute, refit basis
      if (both_funs) {
        basis_args <- attr(e1, "basis_args")
        eval <- fun_op(tfd(e1), tfd(e2), .Generic)
      }
      if (is.logical(e1)) e1 <- as.numeric(e1)
      if (is.logical(e2)) e2 <- as.numeric(e2)
      if (is_tfb(e1) && is.numeric(e2)) {
        basis_args <- attr(e1, "basis_args")
        eval <- fun_op(tfd(e1), e2, .Generic, numeric = 2)
      }
      if (is_tfb(e2) && is.numeric(e1)) {
        basis_args <- attr(e2, "basis_args")
        eval <- fun_op(e1, tfd(e2), .Generic, numeric = 1)
      }
      return(do.call(
        "tfb",
        c(list(eval), basis_args, penalized = FALSE, verbose = FALSE)
      ))
    }
  }
  ret
}
