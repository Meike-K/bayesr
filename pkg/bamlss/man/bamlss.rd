\name{bamlss}
\alias{bamlss}

\title{
  Generic model fitting function for Bayesian regression models
}

\description{
%%  ~~ A concise (1-5 lines) description of what the function does. ~~
}

\usage{
bamlss(formula, family = gaussian.bamlss,
  data = NULL, knots = NULL, weights = NULL, subset = NULL,
  offset = NULL, na.action = na.fail, contrasts = NULL,
  reference = NULL, parse.input = parse.input.bamlss,
  transform = transformJAGS, setup = setupJAGS,
  sampler = samplerJAGS, results = resultsJAGS,
  cores = NULL, sleep = NULL, combine = TRUE,
  model = TRUE, ...)
}

\arguments{
  \item{formula}{symbolic description of the model (of type \code{y ~ x}), also see 
    \code{\link[mgcv]{formula.gam}} and \code{\link[mgcv]{s}}.}
  \item{family}{family object specifying the distribution and link to use in fitting etc.?}
  \item{data}{a \code{\link{data.frame}} or \code{\link{list}} containing the model response 
    variable and covariates required by the formula. By default the variables are taken from 
    \code{environment(formula)}: typically the environment from which \code{bayesx} is called.}
  \item{knots}{see function \code{\link[mgcv]{gam}}.}
  \item{weights}{prior weights on the data.}
 \item{subset}{an optional vector specifying a subset of observations to be used in the fitting 
    process.}
  \item{offset}{can be used to supply a model offset for use in fitting.}
  \item{na.action}{a function which indicates what should happen when the data contain \code{NA}'s.
    The default is set by the \code{na.action} setting of \code{\link{options}}, and is
    \code{\link{na.omit}} if set to \code{NULL}.}
  \item{contrasts}{an optional list. See the \code{contrasts.arg} of 
    \code{\link[stats]{model.matrix.default}}.}
  \item{reference}{character or integer. The reference category for categorical response models.}
  \item{parse.input}{function, used to parse all input parameters, see function
    \code{parse.bamlss.input}.}
  \item{transform}{function, a transformator function to be applied on smooth term objects.}
  \item{setup}{MCMC setup function or named list controlling arguments of the default setup
    function.}
  \item{sampler}{MCMC sampler function or named list controlling arguments of the default MCMC
    sampler function.}
  \item{results}{function, a function that computes the desired results from MCMC samples and data.}
  \item{cores}{integer. How many cores should be used? The default is one core if
    \code{cores = NULL}. If \code{cores} > 1, the return value is again a list of class
    \code{"bamlss"}, for which all plotting and extractor functions can be applied, see argument
    \code{chains}. Note that this option is not available on Windows systems, see the documentation
    of function \code{\link[parallel]{mclapply}}.}
  \item{sleep}{numeric, when using the multiple core option, sleep determines the waiting time until
    the next process is started.}
  \item{combine}{logical, should samples from different chains/cores already be combined within
    \code{bamlss}?}
  \item{model}{should the model frame be returned?}
  \item{\dots}{arguments passed to \code{setup}, \code{sampler}, \code{results}.}
}

\details{
  ...
}

\value{
  ...
}

\references{
  ...
}

\author{
  Nikolaus Umlauf, Stefan Lang, Achim Zeileis.
}

\examples{
\dontrun{## generate some data
set.seed(111)
n <- 200

## regressor
dat <- data.frame(x = runif(n, -3, 3))

## response
dat$y <- with(dat, 1.5 + sin(x) + rnorm(n, sd = 0.6))

## estimate model
b <- bamlss(y ~ s(x), data = dat)

## plot fitted model term
plot(b)
}}

\keyword{regression}