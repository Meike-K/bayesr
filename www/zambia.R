library("R2BayesX")

## load zambia data and map
data("ZambiaNutrition")
data("ZambiaBnd")

## estimate model
zm1 <- bayesx(stunting ~ memployment + education + urban + gender + 
  sx(bmi) + sx(agechild) + sx(district, bs = "mrf", map = ZambiaBnd) + r(district),
  iter = 12000, burnin = 2000, step = 10, data = ZambiaNutrition)

## summary statistics
summary(zm1)

## visualising estimation results
plot(zm1, term = "sx(bmi)")
plot(zm1, term = "sx(agechild)")

plot(zm1, term = "sx(district)")
plot(zm1, term = "r(district)")

plot(zm1, term = c("sx(district)", "r(district)"), 
  map = ZambiaBnd, pos = "topleft")

## customizing graphics
plot(zm1, term = "sx(bmi)", resid = TRUE, cex = 0.1)
plot(zm1, term = "sx(agechild)", resid = TRUE, cex = 0.1)

plot(zm1, term = "sx(bmi)", main = "Mother body mass index", 
  xlab = "",ylab = "")
plot(zm1, term = "sx(bmi)", main = "Mother body mass index", 
  xlab = "",ylab = "", ylim = c(-0.8, 0.6))
plot(zm1, term = "sx(bmi)", main = "Mother body mass index", 
  xlab = "",ylab = "", ylim = c(-0.8, 0.6), rug = FALSE)
plot(zm1, term = "sx(bmi)", main = "Mother body mass index", 
  xlab = "",ylab = "", ylim = c(-0.8, 0.6), rug = FALSE, 
  col.poly = NA, lwd = 1, lty = 1)
plot(zm1, term = "sx(bmi)", main = "Mother body mass index", 
  xlab = "", ylab = "", ylim = c(-0.8, 0.6), rug = FALSE, 
  col.poly = NA, lwd = 1, lty = c(3, 1, 2, 2, 1))

plot(zm1, term = "sx(district)", map = ZambiaBnd, pos = "topleft")
plot(zm1, term = "r(district)", map = ZambiaBnd, pos = "topleft")
plot(zm1, term = "r(district)", map = ZambiaBnd, pos = "topleft", 
  density = 30, swap = TRUE)
plot(zm1, term = "sx(district)", map = ZambiaBnd, pos = "topleft", 
  names = TRUE)
plot(zm1, term = "sx(district)", map = ZambiaBnd, pos = "topleft", 
  names = TRUE, cex.names = 0.8, cex.legend = 0.8)
plot(zm1, term = "sx(district)", map = ZambiaBnd, pos = "topleft", 
  range = c(-0.2, 0.2))
plot(zm1, term = "sx(district)", map = ZambiaBnd, pos = "topleft", 
  c.select = "pcat95", at = c(-1, 0, 1), ncol = 3)
plot(zm1, term = "sx(district)", map = ZambiaBnd, pos = "topleft", 
  c.select = "pcat80", at = c(-1, 0, 1), ncol = 3)

op <- par(no.readonly = TRUE)
par(mfrow = c(1, 2))
plot(zm1, term = "sx(district)", map = ZambiaBnd, pos = "topleft", 
  main = "Structured spatial effect", names = TRUE)
plot(zm1, term = "r(district)", map = ZambiaBnd, pos = "topleft", 
  density = 40, main = "Unstructured spatial effect", names = TRUE)
par(op)

## diagnostic plots
plot(zm1, which = 5:8, cex = 0.1)
plot(zm1, which = "intcpt-samples")

plot(zm1, term = c("memployment", "education"), 
  which = "coef-samples", ask = TRUE)

plot(zm1, term = "sx(bmi)", which = "coef-samples")
plot(zm1, term = "sx(bmi)", which = "coef-samples", acf = TRUE)

plot(zm1, term = "sx(bmi)", which = "var-samples")
plot(zm1, term = "sx(bmi)", which = "var-samples", acf = TRUE)
plot(zm1, term = "sx(bmi)", which = "var-samples", acf = TRUE, lag.max = 400)

plot(zm1, term = "sx(agechild)", which = "var-samples")
plot(zm1, term = "sx(district)", which = "var-samples")
plot(zm1, term = "r(district)", which = "var-samples")

## sensitivity analysis 
zm2 <- bayesx(stunting ~ memployment + education + urban + gender + 
  sx(bmi, a = 0.00001, b = 0.00001) +
  sx(agechild, a = 0.00001, b = 0.00001) +
  sx(district, bs = "mrf", map = ZambiaBnd, a = 0.00001, b = 0.00001) +
  r(district, xt = list(a = 0.00001, b = 0.00001)),
  iter = 12000, burnin = 2000, step = 10, data = ZambiaNutrition)

zm3 <- bayesx(stunting ~ memployment + education + urban + gender +
  sx(bmi, a = 0.005, b = 0.005) +
  sx(agechild, a = 0.005, b = 0.005) +
  sx(district, bs = "mrf", map = ZambiaBnd, a = 0.005, b = 0.005) +
  r(district, xt = list(a = 0.005, b = 0.005)),
  iter = 12000, burnin = 2000, step = 10, data = ZambiaNutrition)

zm4 <- bayesx(stunting ~ memployment + education + urban + gender +
  sx(bmi, a = 0.00005, b = 0.00005) +
  sx(agechild, a = 0.00005, b = 0.00005) +
  sx(district, bs = "mrf", map = ZambiaBnd, a = 0.00005, b = 0.00005) +
  r(district, xt = list(a = 0.00005, b = 0.00005)),
  iter = 12000, burnin = 2000, step = 10, data = ZambiaNutrition)

plot(c(zm1, zm2, zm3, zm4), term = "sx(bmi)")
plot(c(zm1, zm2, zm3, zm4), term = "sx(agechild)")


## same model with REML
zm5 <- bayesx(stunting ~ memployment + education + urban + gender + 
  sx(bmi) + sx(agechild) + sx(district, bs = "mrf", map = ZambiaBnd) + r(district),
  method = "REML", data = ZambiaNutrition)
summary(zm5)
plot(zm5, map = ZambiaBnd)


## now use the stepwise algorithm
zm6 <- bayesx(stunting ~ memployment + education + urban + gender + 
  sx(bmi) + sx(agechild) + sx(district, bs = "mrf", map = ZambiaBnd) + r(district),
  method = "STEP", data = ZambiaNutrition)
summary(zm6)
