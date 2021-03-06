library("bamlss")
data("GAMart", package = "R2BayesX")

## Model formulae.
bamlss.formula(num ~ s(x1) + id)

f <- list(
  num ~ s(x1) + s(x3) + id,
  sigma ~ s(x2),
  id ~ s(x3) + long,
  long ~ te(x1, x2)
)

bamlss.formula(f)
bamlss.formula(f, family = gamma.bamlss())


## Automatic filling with intercept.
bamlss.formula(num ~ x1, family = zinb.bamlss())
bamlss.formula(f, family = zinb.bamlss())


## Terms object from bamlss.formula().
terms(bamlss.formula(f))
terms.bamlss(f)
terms(bamlss.formula(f), model = c(1, 1), sterms = FALSE)
terms(bamlss.formula(f), model = c(1, 1), sterms = FALSE, pterms = FALSE)


## Get the bamlss frame.
bf <- bamlss.frame(f, data = GAMart, family = "gaussian")
names(bf)
print(bf)
head(model.frame(bf))
bf$model.frame <- NULL
head(model.frame(bf))
model.response(model.frame(bf))
response.name(bf)
response.name(model.frame(bf))


## model.matrix() and smooth.construct()
model.matrix(bf)
head(model.matrix(bf, model = c(1, 1)))
smooth.construct(bf)
bf$model.frame <- NULL
head(model.matrix(bf, model = c(1, 1)))
str(smooth.construct(bf))
str(smooth.construct(bf, model = c(1, 1)))

bf <- bamlss.frame(f, data = GAMart, family = "gaussian",
  model.matrix = FALSE, smooth.construct = FALSE)
print(bf)
model.matrix(bf)
head(model.matrix(bf, model = c(1, 1)))
smooth.construct(bf)
names(smooth.construct(bf, model = c(1, 1)))


## Complex multilevel structures.
f <- list(
  cat ~ s(x1) + s(x2) + id,
  id ~ s(x3)
)

bf <- bamlss.frame(f, data = GAMart(), family = "multinomial")
print(bf)
head(model.response(model.frame(bf)))

terms(bf)
terms(formula(bf))
terms(bf, model = c(2, 1))
terms(bf, model = c(2, 1), sterms = FALSE)
terms(bf, model = c(2, 1), pterms = FALSE)

d <- GAMart[1:30, ]

model.matrix(formula(bf), data = d)
head(model.matrix(formula(bf), data = d, model = c(1, 1)))
head(model.matrix(formula(bf, model = c(1, 1)), data = d))
head(model.matrix(terms(bf, model = c(1, 1), drop = FALSE), data = d))

smooth.construct(formula(bf), data = d)
smooth.construct(terms(bf), data = d)
smooth.construct(formula(bf), data = d, model = c(1, 1))
smooth.construct(formula(bf, model = c(1, 1)), data = d)
smooth.construct(terms(bf, model = c(1, 1), drop = FALSE), data = d)


## Extract or initiallize parameters.
bf <- bamlss.frame(num|sigma ~ s(x1) + s(x2)|s(x3), data = GAMart)
p <- parameters(bf)
unlist(p)
unlist(parameters(randomize(bf)))


## Estimate model.
data("GAMart", package = "R2BayesX")
b <- bamlss(num|sigma ~ s(x1) + s(x2) + x3 + id | s(x1) + x2, data = GAMart, cores = 3, chains = 2)
samps <- samples(b)
samps <- samples(b, model = 1, term = 1)
head(samps)
plot(b, model = 1, term = 1, which = "samples")


## Predict.
p <- predict(b, model = "mu", term = "s(x2)")
plot2d(p ~ x2, data = GAMart)
p <- predict(b, model = "mu", term = "s(x2)", FUN = quantile, probs = c(0.025, 0.5, 0.975))
plot2d(p ~ x2, data = GAMart)
p <- predict(b, model = 1, term = "(Intercept)")
p <- predict(b)
names(p)
p <- predict(b, model = "mu", term = "id", intercept = FALSE)
plotblock(p ~ id, data = GAMart)

nd <- data.frame("x2" = seq(0, 1, length = 100))
nd$p <- predict(b, newdata = nd, model = "mu", term = "s(x2)")
plot(nd, type = "l")

nd <- data.frame("x2" = seq(0, 1, length = 100), "x3" = seq(0, 1, length = 100))
p <- predict(b, newdata = nd, model = 1, term = c("x2", "x3"), FUN = quantile)
print(head(p))

str(predict(b, term = 1:2))


## Multinomial example.
data("marital.nz", package = "VGAM")

b <- bamlss(mstatus ~ s(age), data = marital.nz,
  family = "multinomial", reference = "Married/Partnered", cores = 4)

plot(b)
plot(b, which = "samples")
plot(b, model = 1)
plot(b, model = c(1, 3))

a <- results.bamlss.default(b)
plot(a)

nd <- data.frame("age" = seq(0, 100, length = 100))
pi <- predict(b, newdata = nd, type = "parameter")
pi <- cbind(as.data.frame(pi), "MarriedPartnered" = 1)
pi <- pi / rowSums(pi)
with(nd, matplot(age, pi, type = "l", lty = 1))
legend("topright", names(pi), lwd = 1, col = 1:ncol(pi))


## Survival example.
set.seed(111)

## Sample covariates first.
n <- 300
X <- matrix(NA, nrow = n, ncol = 3)
X[, 1] <- runif(n, -1, 1)
X[, 2] <- runif(n, -3, 3)
X[, 3] <- runif(n, -1, 1)

## Specify censoring function.
cens_fct <- function(time, mean_cens) {
  ## Censoring times are independent exponentially distributed.
  censor_time <- rexp(n = length(time), rate = 1 / mean_cens)
  event <- (time <= censor_time)
  t_obs <- apply(cbind(time, censor_time), 1, min)
  ## Return matrix of observed survival times and event indicator.
  return(cbind(t_obs, event))
}

## log(time) is the baseline hazard.
lambda <-  function(time, x) {
  exp(log(time) + 0.7 * x[1] + sin(x[2]) + sin(time * 2) * x[3])
}

## Simulate data with lambda() and cens_fct().
d <- rSurvTime2(lambda, X, cens_fct, mean_cens = 5)

f <- list(
  Surv(time, event) ~ s(time, bs = "ps", k = 20) + s(time, by = x3, k = 20),
  gamma ~ s(x1, k = 20) + s(x2, k = 20)
)

## Cox model with continuous time.
b <- bamlss(f, family = "cox", data = d,
  n.iter = 1200, burnin = 200, thin = 1)

## Predict P(T > t).
b$family <- cox.bamlss()
predict(b, type = "probabilties", time = 4)


## JAGS.
data("GAMart", package = "R2BayesX")
b <- bamlss(num|sigma ~ s(x1) + s(x2) + x3 + id | s(x1) + x2, data = GAMart, sampler = JAGS)

data("marital.nz", package = "VGAM")
b <- bamlss(mstatus ~ s(age), data = marital.nz,
  family = "multinomial", reference = "Married/Partnered",
  sampler = JAGS, cores = 4)


## Boosting.
data("GAMart", package = "R2BayesX")

f <- list(
  num ~ x1 + x2 + x3 + s(x1) + s(x2) + s(x3) + s(long, lat) + id,
  sigma ~ x1 + x2 + x3 + s(x1) + s(x2) + s(x3) + s(long, lat) + id
)

b <- bamlss(f, data = GAMart, optimizer = boost99, sampler = FALSE)
plot(b)
plot(b, which = "boost.summary")
x11()

data("india", "india.bnd", package = "gamboostLSS")

india$stunting_rs <- india$stunting / 600
K <- neighbormatrix(india.bnd, id = india$mcdist)

xt <- list("penalty" = K, "center" = FALSE, "force.center" = TRUE)

f <- list(
  stunting_rs ~ s(mage) + s(mbmi) + s(cage) + s(cbmi) + s(mcdist,bs="mrf",xt=xt),
  sigma ~ s(mage) + s(mbmi) + s(cage) + s(cbmi) + s(mcdist,bs="mrf",xt=xt)
)

b <- bamlss(f, data = india, sampler = FALSE, optimizer = boost99)


## Another survival example.
## Paper: http://arxiv.org/pdf/1503.07709.pdf
## Data: http://data.london.gov.uk/dataset/london-fire-brigade-incident-records
data("LondonFire")

f <- list(
  Surv(arrivaltime) ~ ti(arrivaltime) + ti(arrivaltime,lon,lat,d=c(1,2),k=c(5,5)),
  gamma ~ s(fsintens, k = 20) + s(daytime, bs = "cc", k = 20) + te(lon, lat)
)

b <- bamlss(f, data = LondonFire, family = "cox", subdivisions = 25,
  n.iter = 500, burnin = 100, thin = 1, cores = 2)

plot(b, model = 2, term = 2, image = TRUE, grid = 200, swap = TRUE)


## Sparse matrices.
library("spam")
library("Matrix")

sparse.matrix <- function(n = 400, m = 20, k = 5, sparse = TRUE)
{
  require("Matrix")
  x <- smooth.construct(s(x, k = k), list("x" = runif(m)), NULL)
  if(!sparse)
    return(list("X" = x$X, "S" = x$S[[1]]))
  X <- as.matrix(bdiag(rep(list(x$X), length = n)))
  S <- as.matrix(bdiag(rep(list(x$S[[1]]), length = n)))
  return(list("X" = X, "S" = S))
}

M <- sparse.matrix(sparse = TRUE)
xx <- crossprod(M$X) + M$S

xx.spam <- as.spam(xx)
xx.chol <- chol.spam(xx.spam)

xx.Matrix <- Matrix(xx)

b <- runif(ncol(xx.Matrix))
system.time(
  for(i in 1:100) {
    L <- Cholesky(xx.Matrix, super = FALSE)
    a <- solve(L, b, system = "A")
  }
)

spam.options(cholsymmetrycheck = FALSE)

system.time(
  for(i in 1:100) {
    U <- update.spam.chol.NgPeyton(xx.chol, xx.spam)
    P <- chol2inv.spam(U)
  }
)

system.time(
  for(i in 1:100) {
    U1 <- chol(xx.Matrix)
    P2 <- chol2inv(U1)
  }
)

system.time(
  for(i in 1:100) {
    U <- chol(xx)
    P <- chol2inv(U)
  }
)


b <- seq(0, 1, length = nrow(xx))
sp <- sparse.setup(M$X)
L <- sparse.chol(xx, index = list("matrix" = sp$crossprod, "ordering" = sp$ordering))
y <- sparse.forwardsolve(L, b, index = list("matrix" = sp$forward, "ordering" = sp$ordering))
z1 <- sparse.backsolve(L, y, list("matrix" = sp$backward, "ordering" = sp$ordering))
z2 <- solve(xx) %*% b
all.equal(z1, z2)
all.equal(sparse.solve(xx, b, sp), solve(xx,b))

sparse.solve(xx, diag(nrow(xx)), sp)


add2spam <- function(x, y)
{
  pointers <- attributes(x)
  x@entries <- x@entries + y[x@rowpointers, x@colindices]
  return(x)
}


## MVN.
if(FALSE) {
  a <- c(1,2,3,4,5,6)
  b <- c(2,3,5,6,1,9)
  c <- c(3,5,5,5,10,8)
  d <- c(10,20,30,40,50,55)
  e <- c(7,8,9,4,6,10)
 
  #create matrix from vectors
  S <- cov(cbind(a,b,c,d,e))
  mu <- rnorm(nrow(S))
  y <- rnorm(nrow(S))

  dmvnorm(x = y, mean = mu, sigma = S, log = TRUE)

  mu <- as.list(mu)
  names(mu) <- paste("mu", 1:length(mu), sep = "")
  sigma <- as.list(diag(S))
  names(sigma) <- paste("sigma", 1:length(sigma), sep = "")

  rho <- list()
  for(i in 1:length(sigma)) {
    for(j in 1:length(sigma)) {
      if(i < j) {
        rho[[paste("rho", i, j, sep = "")]] <- S[i, j] / (sigma[[i]] * sigma[[j]])
      }
    }
  }

  par <- c(mu, sigma, rho)
  y <- matrix(y, nrow = 1)

  compile(); sbayesr()
  log_dmvnorm(y, par)
}

## Model.
f0 <- function(x) 2 * sin(pi * x)
f1 <- function(x) exp(2 * x)
f2 <- function(x) 0.2 * x^11 * (10 * (1 - x))^6 + 10 * (10 * x)^3 * (1 - x)^10
f3 <- function(x) sin(x * 3) - 3
f4 <- function(x) cos(x * 6) - 2
f5 <- function(x) {
  eta <- sin(scale2(x, -3, 3)) - 3
  eta / sqrt(1 + eta^2)
}
f6 <- function(x) {
  eta <- cos(scale2(x, -3, 3)) - 2
  eta / sqrt(1 + eta^2)
}

n <- 1000
x0 <- runif(n); x1 <- runif(n);
x2 <- runif(n); x3 <- runif(n)

s1 <- exp(f3(x1))
s2 <- exp(f4(x2))
s3 <- exp(rep(-1, n))
rho12 <- f5(x3)
rho13 <- rep(0.1, n)
rho23 <- f6(x3)

y <- matrix(0, n, 3)

for(i in 1:n) {
  V <- diag(c(s1[i], s2[i], s3[i])^2)
  V[1, 2] <- rho12[i] * s1[i] * s2[i]
  V[1, 3] <- rho13[i] * s1[i] * s3[i]
  V[2, 3] <- rho23[i] * s2[i] * s3[i]
  V[2, 1] <- V[1, 2]
  V[3, 1] <- V[1, 3]
  V[3, 2] <- V[2, 3]
  mu <- c(f0(x0[i]) + f1(x1[i]), f2(x2[i]), f3(x3[i]))
  mu <- rep(0, 3)
  y[i,] <- rmvn(1, mu, V)
  #print(dmvnorm(y[i,], mu, V))
  par <- list(mu1 = mu[1], mu2 = mu[2], mu3 = mu[3], sigma1 = s1[i], sigma2 = s2[i], rho12 = rho12[i], rho13 = rho13[i], rho23 = rho23[i])
  log_dmvnorm(matrix(y[i,], nrow = 1), par)
}

dat <- data.frame(y0=y[,1],y1=y[,2],y2=y[,3],x0=x0,x1=x1,x2=x2,x3=x3)

f <- list(
  y0 ~ 1,
  y1 ~ 1,
  y2 ~ 1,
  sigma1 ~ s(x1),
  sigma2 ~ s(x2),
  sigma3 ~ 1,
  rho12 ~ s(x3),
  rho13 ~ 1,
  rho23 ~ s(x3)
)

b <- bamlss(f, family = gF("mvnorm", k = 3), data = dat, optimizer = boost, sampler = FALSE, maxit = 1000, nu = 0.1)

