library("bamlss")

## pick function
f <- simfun(type = "complicated")

set.seed(111)
n <- 1000
dat <- data.frame("x1" = sort(runif(n, 0, 1)))
dat$y <- with(dat, 1.2 + 0.4 * x1 + rnorm(n, sd = exp(-1 + 0.3 * x1)))

theta <- list("mu" = c(-10, 20), "sigma" = rep(0, 2))
d <- list("mu" = cbind(1, dat$x1), "sigma" = cbind(1, dat$x1))

## b <- bamlss0(y ~ s(x1), ~ s(x1), data = dat)

logLik <- function(mu, sigma, ...) {
  mu <- unlist(mu)
  sigma <- unlist(sigma)
  dnorm(dat$y, mean = d$mu %*% mu, sd = exp(d$sigma %*% sigma), log = TRUE)
}

b0 <- gmcmc(logLik, theta = theta, propose = gmcmc_mvnorm)
b1 <- gmcmc(logLik, theta = theta, propose = gmcmc_slice)
b2 <- gmcmc(logLik, theta = theta, propose = c(gmcmc_slice, gmcmc_mvnorm))

rbind(
  apply(b0, 2, mean),
  apply(b1, 2, mean),
  apply(b2, 2, mean)
)


library("MCMCpack")

logitfun <- function(beta, y, X){
  eta <- X %*% unlist(beta)
  p <- 1.0/(1.0+exp(-eta))
  sum( y * log(p) + (1-y)*log(1-p) )
}
        
x1 <- rnorm(1000)
x2 <- rnorm(1000)
Xdata <- cbind(1,x1,x2)
p <- exp(.5 - x1 + x2)/(1+exp(.5 - x1 + x2))
yvector <- rbinom(1000, 1, p)

post.samp <- MCMCmetrop1R(logitfun, theta.init = c(0,0,0),
  X = Xdata, y = yvector,
  thin = 1, mcmc = 40000, burnin = 500,
  tune = c(1.5, 1.5, 1.5),
  verbose = 500, logfun = TRUE)

b <- gmcmc(logitfun, theta = list(beta = c(0, 0, 0)),
  y = yvector, X = Xdata,
  n.iter = 12000, burnin = 2000, thin = 10,
  propose = gmcmc_slice)


## Negative binomial regression with an improper unform prior
## X and y are passed as args to MCMCmetrop1R.
negbinfun <- function(theta, y, X) {
  theta <- unlist(theta)
  k <- length(theta)
  beta <- theta[1:(k - 1)]
  alpha <- exp(theta[k])
  mu <- exp(X %*% beta)
  log.like <- sum(
    lgamma(y + alpha) - lfactorial(y) - lgamma(alpha) +
    alpha * log(alpha / (alpha + mu)) +
    y * log(mu / (alpha + mu))
  )
}
     
n <- 1000
x1 <- rnorm(n)
x2 <- rnorm(n)
XX <- cbind(1, x1, x2)
mu <- exp(1.5 + x1 + 2*x2) * rgamma(n, 1)
yy <- rpois(n, mu)
     
post.samp <- MCMCmetrop1R(negbinfun, theta.init = c(0, 0, 0, 0), y = yy, X = XX,
  thin = 1, mcmc = 35000, burnin = 1000,
  tune = 1.5, verbose = 500, logfun = TRUE,
  seed = list(NA, 1))

b <- gmcmc(negbinfun, theta = c(0, 0, 0, 0),
  y = yy, X = XX,
  n.iter = 35000, burnin = 6000, thin = 1)

logfun <- function(x) {
  dnorm(unlist(x), mean = 5, sd = 0.1, log = TRUE)
}
b <- gmcmc(logfun, theta = list(x = 5.3), n.iter = 1200, burnin = 200, thin = 1)


## Example taken from
## http://www.dme.ufrj.br/mcmc/Example73-R.txt
loglik = function(theta) {
  theta <- unlist(theta)
  mu <- theta[1] / (1 + exp(theta[2]) * (exp(theta[3]) / (1 + exp(theta[3])))^t)
  sigma <- exp(theta[4])
  sum(dnorm(y, mean = mu, sd = sigma, log = TRUE))
}

n = 15
t = 1:n
y = c(16.08, 33.83, 65.80, 97.20, 191.55, 326.20, 386.87, 520.53, 590.03,
  651.92, 724.93, 699.56, 689.96, 637.56, 717.41)

theta <- c(700, 36, 0.5946)
theta <- c(theta, sd(y - theta[1] / (1 + theta[2] * theta[3]^t)))

b <- gmcmc(loglik, theta = theta, propose = gmcmc_slice)
apply(b, 2, mean)
theta

fit <- apply(b[, 1:4], 1, function(theta) {
  theta[1] / (1 + exp(theta[2]) * (exp(theta[3]) / (1 + exp(theta[3])))^t)
})

matplot(t, fit, type = "l", col = rgb(0.1, 0.1, 0.1, alpha = 0.01))
points(t, y, col = "blue", lwd = 2)
