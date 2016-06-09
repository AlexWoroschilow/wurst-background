assert <- function (shouldbe, ...) {
  if (!shouldbe) {
    .Internal(stop(
      as.logical(TRUE),
      .makeMessage(..., domain = NULL)
    ))
  }
}
