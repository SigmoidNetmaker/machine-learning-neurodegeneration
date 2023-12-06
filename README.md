# machine-learning-neurodegeneration
This repository contains MATLAB code for optimizing, training, and using artificial neural networks to identify potentially effective drug combinations for the treatment of neurodegenerative disorders. 

The code was used for the project described in:    
Anastasio TJ (2021) Predicting the Potency of Anti-Alzheimer’s Drug Combinations Using Machine Learning. Processes 9(2):264.

The purpose of this study was to (1) process the data in two leading databases on Alzheimer's Disease (AD) into a form suitable for machine learning; (2) find the artificial neural network (ANN) architecture best suited to extract knowledge from the two datasets; (3) train the best suited ANN on either dataset; (4) use the trained ANNs to identify the drug combinations associated with the best cognitive health in both datasets; (5) compare the drug combinations between the two datasets; and (6) identify the jointly determined, best drug combinations.    

Following is the list of MATLAB m-files and a brief description of what they do:

(1) Read Data from the NACC and the RADC Databases and Create Input/Desired-output Lists   

NACCreadDataset.m -- reads data from the National Alzheimer's Coordinating Center (NACC) database    
RADCreadLongBasic.m -- reads data from the Rush Alzheimer's Disease Center (RADC) database

NACCmakeTruthTable.m -- constructs a supervised-learning truth table from the NACC dataset    
RADCmakeTruthTable.m -- constructs a supervised-learning truth table from the RADC dataset

NACCmakeSeqCellArray.m -- organizes the NACC truth table into temporal sequences for each participant    
RADCmadeSeqCellArray.m -- organizes the RADC truch table into temporal sequences for each participant

(2) Set Up the ANN/ML Environment and Find the Best ANN Architecture for the NACC and RACD Datasets     
    Note that the ANNs are based on the Long Short-Term Memory (LSTM) formalism  
    
LSTMsetUp.m -- sets basic ML and ANN parameters and constructs ANN weight matrices   
LSTMrandomize.m -- randomizes ANN weight matrices before training 
 
LSTMdecomTrain.m -- decomposes LSTM networks to remove specific LSTM features  
LSTMdecomTest.m -- tests LSTM networks with specific LSTM features removed   
LSTMeval.m  -- evaluates fitness of LSTM networks with features removed
LSTMga.m -- uses genetic algorithm to find optimal LSTM feature sets and ML parameters    
LSTMgaJob.m -- runs the genetic algorithm in batch mode  

