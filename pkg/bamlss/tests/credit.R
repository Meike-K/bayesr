library("bamlss")

credit <- read.table("http://www.stat.uni-muenchen.de/~kneib/regressionsbuch/download/credit.raw",
  header = TRUE)
credit$creditw <- with(credit, factor(y, levels = 0:1, labels = c("no", "yes")))

b0 <- bamlss(creditw ~ acc1 + acc2 + moral + intuse + s(duration) + s(amount), family = binomial, data = credit, method = "backfitting", update = "iwls")

b0 <- bamlss(creditw ~ acc1 + acc2 + moral + intuse +
  s(duration) + s(amount), family = binomial,
  data = credit, engine = "JAGS")

b1 <- bamlss(creditw ~ acc1 + acc2 + moral + intuse +
  sx(duration) + sx(amount), family = binomial,
  data = credit, engine = "BayesX")

