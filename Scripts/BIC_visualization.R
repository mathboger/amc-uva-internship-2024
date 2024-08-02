# Script to compile BIC information from DCM models

library(readr)
BIC <- read_csv("~/Analysis/Models/BIC.csv") # Load output from MATLAB

#n_participants <- 74
n_te <- 4
n_models <-5

BIC_over_participants <- matrix(nrow=n_te, ncol=n_models)
rownames(BIC_over_participants) <- c("TE1", "TE2", "TE3", "TE4")
colnames(BIC_over_participants) <- c("A1", "A2", "A3", "A4", "A5")

for (i in 1:n_te) {
  for (j in 1:n_models) {
    BIC_over_participants[i,j] = sum(BIC[BIC$TE==i & BIC$Model==j,]$BIC)
  }
}