rm(list=ls())
library(ggplot2)
library(tidyverse)

# problems with complete pooling 

set.seed(1)
n <- 12
n_obs <- 30
Z <- MASS::mvrnorm(n,mu=c(0,0), Sigma=matrix(c(1,-0.75,-0.75,1),ncol=2))
beta_1 <- rnorm(n, mean=0.7, sd=0.2)
sigma_y <- 0.25
sigma_x <- 0.5
simd <- expand.grid(obs=1:n_obs, id=1:n)
simd$x <- NA
simd$y <- NA
for(i in unique(simd$id)){
  simd$x[simd$id==i] <- Z[i,1] + rnorm(n_obs,0,sigma_x)
  simd$y[simd$id==i] <- Z[i,2] + simd$x[simd$id==i]*beta_1[i] - Z[i,1] + rnorm(n_obs,0,sigma_y)
}
simd$id <- paste("sj",simd$id,sep="")

ggplot(simd, aes(x=x, y=y, color=id))+
  geom_point()+
  scale_color_manual(values=rep("black",n))+
  geom_smooth(method="lm",se=F,aes(group=1))


ggplot(simd, aes(x=x, y=y, color=id))+
  geom_point()+
  scale_color_viridis_d()+
  geom_smooth(method="lm",se=F) + 
  geom_smooth(method="lm",se=F,aes(group=1))



# pooling in sleepstudy
library(lme4)

m.0 <- lm(Reaction ~ Days, data=sleepstudy)

d0 <- sleepstudy
d0$prediction <- predict(m.0)
d0$pooling <- "complete"


# estimate individual regressions
m.list <- lmList(Reaction ~ Days | Subject, data=sleepstudy)
d1 <- sleepstudy
d1$prediction <- predict(m.list)
d1$pooling <- "no"

d <- rbind(d0,d1)


ggplot(d, aes(x=Days,y=Reaction))+
  facet_wrap(~Subject,ncol=9)+
  geom_line(aes(y=prediction, color=pooling),size=0.8)+
  geom_point()+
  scale_x_continuous(breaks=seq(0,10,2))+
  labs(x="Days of sleep deprivation",y="Mean reaction times [ms]")


m.lmm <- lmer(Reaction ~ Days + (Days|Subject), data=sleepstudy)
d2 <- sleepstudy
d2$prediction <- predict(m.lmm)
d2$pooling <- "partial (LMM)"

d <- rbind(d0,d1, d2)

ggplot(d, aes(x=Days,y=Reaction))+
  facet_wrap(~Subject,ncol=9)+
  geom_line(aes(y=prediction, color=pooling),size=0.8)+
  geom_point()+
  scale_x_continuous(breaks=seq(0,10,2))+
  labs(x="Days of sleep deprivation",y="Mean reaction times [ms]")


