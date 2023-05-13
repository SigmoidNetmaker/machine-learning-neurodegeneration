# machine-learning-neurodegeneration
This repository contains MATLAB code for optimizing, training, and using artificial neural networks to identify potentially effective drug combinations for the treatment of neurodegenerative disorders. 

The code was used for the project described in:    
Anastasio TJ (2021) Predicting the Potency of Anti-Alzheimer’s Drug Combinations Using Machine Learning. Processes 9(2):264.

The purpose of this study was to (1) process the data in two leading databases on Alzheimer's Disease (AD) into a form suitable for machine learning; (2) find the artificial neural network (ANN) architecture best suited to extract knowledge from the two datasets; (3) train the best suited ANN on either dataset; (4) use the trained ANNs to identify the drug combinations associated with the best cognitive health in both datasets; (5) compare the drug combinations between the two datasets; and (6) identify the jointly determined, best drug combinations.    

Following is the list of MATLAB m-files and a brief description of what they do:

NACCreadDataset.m -- reads data from the National Alzheimer's Coordinating Center (NACC) database    
RADCreadLongBasic.m -- reads data from the Rush Alzheimer's Disease Center (RADC) database

NACCmakeTruthTable.m -- constructs a supervised-learning truth table from the NACC dataset    
RADCmakeTruthTable.m -- constructs a supervised-learning truth table from the RADC dataset

NACCmakeSeqCellArray.m -- organizes the NACC truth table into temporal sequences for each participant    
RADCmadeSeqCellArray.m -- organizes the RADC truch table into temporal sequences for each participant


