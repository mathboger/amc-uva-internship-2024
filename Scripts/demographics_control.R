# Script used to make sure we have proper demographic matches for the HCs
# We expect there not to be significant differences between GD and HC populations over
# the different variables available

# Load data
library(haven)
library(readxl)
library(tidyverse)
tim_demo_data <- read_sav("~/Analysis/Data/Demographics/SAGA_PG_FINAL_SAMPLE_DEMOGRAPHICS.sav")
monja_demo_data <- read_excel("~/Analysis/Data/Demographics/Full Data.xlsx")
monja_audit_data <- read_excel("~/Analysis/Data/Demographics/Full Data.xlsx", sheet="audit")
monja_pgsi_data <- read_excel("~/Analysis/Data/Demographics/Full Data.xlsx", sheet="pgsi")

# Define used participants
participants_tim <- c(2101, 2103, 2104, 2105, 2106, 2107, 2108, 2111, 2113, 2115, 2116, 2118, 2119, 2120, 2121, 2122, 2123, 2124, 2125, 2126, 2127, 2128, 2302, 2303, 2304)
participants_tim_gd <- c(2101, 2103, 2104, 2105, 2106, 2107, 2108, 2111, 2113, 2115, 2116, 2118, 2119, 2120, 2121, 2122, 2123, 2124, 2125, 2126, 2127, 2128)
participants_tim_hc <- c(2302, 2303, 2304)
participants_monja <- c(2101, 2105, 2107, 2111, 2113, 2116, 2117, 2118, 2119, 2120, 2121, 2123, 2125, 2126, 2127, 4102, 4104, 4106, 4107, 4108, 4109, 4110, 4111, 4112, 4113, 4114, 4115, 4120, 4121, 4122, 4123, 4124, 4125, 4126, 4127, 4134, 4135, 4136, 4140, 4141, 4142, 4143, 4145, 4146, 4147, 4148, 4149, 4150, 4151, 4152, 4153, 4154)
participants_monja_gd <- c(2101, 2105, 2107, 2111, 2113, 2116, 2117, 2118, 2119, 2120, 2121, 2123, 2125, 2126, 2127)
participants_monja_hc <- c(4102, 4104, 4106, 4107, 4108, 4109, 4110, 4111, 4112, 4113, 4114, 4115, 4120, 4121, 4122, 4123, 4124, 4125, 4126, 4127, 4134, 4135, 4136, 4140, 4141, 4142, 4143, 4145, 4146, 4147, 4148, 4149, 4150, 4151, 4152, 4153, 4154)
# Define the HCs to drop to get an equal amount of GD/HC
# For now, these have been selected at random, but maybe this can be changed to take gender in consideration
hcs_to_drop <- c(4108, 4136, 2302) # With this drop we get 8 women with GD and 14 as HC (4108 is a woman)

# Clean data (get only relevant values from participants in the experiment, rename and reorder them for comparison)
tim_demo_data <- select(tim_demo_data, subjects, leeftijd, Gender, Opleiding, AUDIT_score, PGSI_nu_total, PGSI_ooit_total, BIS_score, BAS_score, BAS_Drive_score, BAS_Fun_Seeking_score, BAS_Reward_Responsiveness_score)
tim_demo_data <- subset(tim_demo_data, subjects %in% participants_tim)
tim_demo_data <- rename(tim_demo_data, participant=subjects, age=leeftijd, gender=Gender, education=Opleiding, audit=AUDIT_score, pgsi_now=PGSI_nu_total, pgsi_ever=PGSI_ooit_total, bis=BIS_score, bas=BAS_score, bas_drive=BAS_Drive_score, bas_fun=BAS_Fun_Seeking_score, bas_reward=BAS_Reward_Responsiveness_score)
tim_demo_data <- add_column(tim_demo_data, dataset="t")
monja_demo_data <- select(monja_demo_data, Subject, age, gender, education_level, 'BIS score total', 'BAS score total', 'BAS Drive score', 'BAS Fun seeking score', 'BAD Reward responsiveness score')
monja_demo_data <- subset(monja_demo_data, Subject %in% participants_monja)
monja_demo_data <- rename(monja_demo_data, participant=Subject, education=education_level, bis='BIS score total', bas='BAS score total', bas_drive='BAS Drive score', bas_fun='BAS Fun seeking score', bas_reward='BAD Reward responsiveness score')
monja_demo_data$participant <- as.double(monja_demo_data$participant) # So we can bind the data frames
monja_audit_data <- subset(monja_audit_data, subject %in% participants_monja)
monja_audit_data <- rename(monja_audit_data, participant=subject, audit=audit_tot)
monja_demo_data <- inner_join(monja_demo_data, monja_audit_data, by="participant")
monja_pgsi_data <- subset(monja_pgsi_data, subject %in% participants_monja)
monja_pgsi_data <- rename(monja_pgsi_data, participant=subject, pgsi_now=pgsi_nu_tot, pgsi_ever=pgsi_ooit_score)
monja_pgsi_data$participant <- as.double(monja_pgsi_data$participant)
monja_demo_data <- inner_join(monja_demo_data, monja_pgsi_data, by="participant")
monja_demo_data <- add_column(monja_demo_data, dataset="m")
monja_demo_data <- relocate(monja_demo_data, participant, age, gender, education, audit, pgsi_now, pgsi_ever, bis, bas, bas_drive, bas_fun, bas_reward, dataset)
# Tim's data have some NAs for AUDIT/PGSI, which I assume are meant to be 0 (to confirm)
tim_demo_data <- replace_na(tim_demo_data, list(audit=0, pgsi_now=0, pgsi_ever=0))
# Monja's data use 2 for feminine gender, while Tim's use 0, change for congruency
monja_demo_data$gender <- replace(monja_demo_data$gender, monja_demo_data$gender==2, 0)

# Make final variables
participants_gd <- subset(tim_demo_data, participant %in% participants_tim_gd)
participants_gd <- rbind(participants_gd, subset(monja_demo_data, participant %in% participants_monja_gd))
participants_hc <- subset(tim_demo_data, participant %in% participants_tim_hc)
participants_hc <- rbind(participants_hc, subset(monja_demo_data, participant %in% participants_monja_hc))
participants_hc <- participants_hc[!(participants_hc$participant %in% hcs_to_drop),]
bis_bas <- rbind(participants_gd, participants_hc)
bis_bas <- add_column(bis_bas, c(1:74))
bis_bas <- rename(bis_bas, index='c(1:74)')

# Run the tests (Wilcoxon for numeric, Chi-squared for categorical)
# P-value (with the dropped participants on top) in the comments
age_test <- wilcox.test(participants_gd$age, participants_hc$age) # p=0.35
gender_test <- chisq.test(participants_gd$gender, participants_hc$gender) # p=1
education_test <- chisq.test(participants_gd$education, participants_hc$education) # p=0.52
audit_test <- wilcox.test(participants_gd$audit, participants_hc$audit) # p=0.57
pgsi_now_test <- wilcox.test(participants_gd$pgsi_now, participants_hc$pgsi_now) # p=2.47e-15
pgsi_ever_test <- wilcox.test(participants_gd$pgsi_ever, participants_hc$pgsi_ever) # p=2.55e-15
bis_test <- wilcox.test(participants_gd$bis, participants_hc$bis) # p=0.006
bas_test <- wilcox.test(participants_gd$bas, participants_hc$bas) # p=0.0003
bas_drive_test <- wilcox.test(participants_gd$bas_drive, participants_hc$bas_drive) # p=0.71
bas_fun_test <- wilcox.test(participants_gd$bas_fun, participants_hc$bas_fun) # p=0.12
bas_reward_test <- wilcox.test(participants_gd$bas_reward, participants_hc$bas_reward) # p=2.5e-11


# -------- DOWNWARDS IS UNUSED SCRIPT, SAVED FOR REFERENCE IN CASE A SIMILAR THING NEEDS TO BE PROGRAMMED LATER

# Go through each column, if there's not a single NA value, conduct a t.test
# Conducting a t-test for each different type of variable might not be the
# best solution
t_results <- list()
ps <- rep(1, length=dim(participants_gd)[2])

for (i in 2:dim(participants_gd)[2]) {
  if (!any(is.na(participants_gd[,i])) && !any(is.na(participants_hc[,i]))) {
    # Wrap t.test with try because if all values are the same in a field it throws
    # an error and stops execution (this can happen in Gender, for example)
    t_results[[i]] <- try(t.test(participants_gd[,i], participants_hc[,i], paired=FALSE), silent=TRUE)
    if(!is(t_results[[i]], "try-error")) { ps[i] <- t_results[[i]]$p.value }
  }
}

# Check if there were significant differences
if(any(ps <= 0.05)) {
  look_at <- which(ps <= 0.05) # see which variables are the problem
} else {
  print("No problems.")
}

# Inspect which variables signficantly differed if any through look_at
# and decide whether the population is balanced enough

# We know the t-test is not ideal for all data, so we check here the most
# important variables separately too

# Age wilcox
# Gender controlled by maybe deleting female participants
# Education (opleiding variable) Chi-square
# AUDIT score
# BIS score
# BAS score