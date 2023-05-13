% LSTMrandomize.m
% this script randomizes LSTM networks

% set number of LSTMs
% *** comment OUT for GA ***
nLSTM = 80;

% set numbers of input and output units
% (note: getting them automatically doesn't work for GA, so ...)
% *** comment OUT next two for GA ***
% nIn  = size(In,2);
% nOut = size(desOut,2);
% *** comment IN one pair or the other for GA ***
nIn  = 113; % for RADC
nOut = 25;  % for RACC
% nIn  = 101; % for NACC
% nOut = 57;  % for NACC

% set start values for weights
% forward weight matrices
Wz = randn(nLSTM,nIn)*0.1; % x-z weights
Wi = randn(nLSTM,nIn)*0.1; % x-i weights
Wf = randn(nLSTM,nIn)*0.1; % x-f weights
Wo = randn(nLSTM,nIn)*0.1; % x-o weights
Wu = randn(nOut,nLSTM)*0.1; % y-u weights
% recurrent weight matrices
Rz = randn(nLSTM,nLSTM)*0.1; % y-z weights
Ri = randn(nLSTM,nLSTM)*0.1; % y-i weights
Rf = randn(nLSTM,nLSTM)*0.1; % y-f weights
Ro = randn(nLSTM,nLSTM)*0.1; % y-o weights
% peephole weights
Pi = randn(nLSTM,1)*0.1; % input gate peepholes
Pf = randn(nLSTM,1)*0.1; % forget gate peepholes
Po = randn(nLSTM,1)*0.1; % output gate peepholes
% biases
bz = randn(nLSTM,1)*0.1; % block input bias
bi = randn(nLSTM,1)*0.1; % input gate bias
bf = randn(nLSTM,1)*0.1; % forget gate bias
bo = randn(nLSTM,1)*0.1; % output gate bias
bu = randn(nOut,1)*0.1; % network output bias






