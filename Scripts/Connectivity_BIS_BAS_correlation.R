# Script to run the correlation analysis between the connectivity of
# the models and BIS/BAS values for each participant

# The convention used when ordering participatnts in the model is
# first all GD patients from Monja's dataset, then all GD patients
# from Tim's dataset, then all HC from Monja's dataset and finally
# all HC from Tim's dataset, all in ascending order

# Load and clean BIS/BAS values
# This section of the script is an adaptation from the demographics control script
library(haven)
library(readxl)
library(tidyverse)
tim_demo_data <- read_sav("~/Analysis/Data/Demographics/SAGA_PG_FINAL_SAMPLE_DEMOGRAPHICS.sav")
monja_demo_data <- read_excel("~/Analysis/Data/Demographics/Full Data.xlsx")

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
tim_demo_data <- select(tim_demo_data, subjects, BIS_score, BAS_score, BAS_Drive_score, BAS_Fun_Seeking_score, BAS_Reward_Responsiveness_score)
tim_demo_data <- subset(tim_demo_data, subjects %in% participants_tim)
tim_demo_data <- rename(tim_demo_data, participant=subjects, bis=BIS_score, bas=BAS_score, bas_drive=BAS_Drive_score, bas_fun=BAS_Fun_Seeking_score, bas_reward=BAS_Reward_Responsiveness_score)
tim_demo_data <- add_column(tim_demo_data, dataset="t")
monja_demo_data <- select(monja_demo_data, Subject, 'BIS score total', 'BAS score total', 'BAS Drive score', 'BAS Fun seeking score', 'BAD Reward responsiveness score')
monja_demo_data <- subset(monja_demo_data, Subject %in% participants_monja)
monja_demo_data <- rename(monja_demo_data, participant=Subject, bis='BIS score total', bas='BAS score total', bas_drive='BAS Drive score', bas_fun='BAS Fun seeking score', bas_reward='BAD Reward responsiveness score')
monja_demo_data$participant <- as.double(monja_demo_data$participant) # So we can bind the data frames
monja_demo_data <- add_column(monja_demo_data, dataset="m")

participants_gd <- subset(monja_demo_data, participant %in% participants_monja_gd)
participants_gd <- rbind(participants_gd, subset(tim_demo_data, participant %in% participants_tim_gd))
participants_hc <- subset(monja_demo_data, participant %in% participants_monja_hc)
participants_hc <- rbind(participants_hc, subset(tim_demo_data, participant %in% participants_tim_hc))
participants_hc <- participants_hc[!(participants_hc$participant %in% hcs_to_drop),]
bis_bas <- rbind(participants_gd, participants_hc)

# Load connectivity values
connectivities <- read_csv("~/Analysis/Models/connectivities_chosen_model.csv")
connectivities <- rename(connectivities, index=participant)

# Run analysis

# The main analysis based in Piray et al. is to check the correlation of the connectivity
# of the nucleus accumbens to the caudate and the BIS score. We do this for 3 different groups:
# only GD, only HC and everyone. Post hoc analyses may follow

cor.test(bis_bas$bis, connectivities$nuc_acc_to_caudate)
cor.test(bis_bas$bis, connectivities$caudate_to_nuc_acc)
cor.test(bis_bas$bas, connectivities$nuc_acc_to_caudate)
cor.test(bis_bas$bas, connectivities$caudate_to_nuc_acc)
plot(bis_bas$bis, connectivities$nuc_acc_to_caudate)