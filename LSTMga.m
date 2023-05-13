% LSTMga.m
% this script evolves LSTM networks for database data
% *** enter "parpool" to use parallel processing

tic

% options = optimoptions('ga','MaxGenerations',100);
% options = optimoptions('ga','MaxGenerations',100,'UseParallel',true);
options = optimoptions('ga','MaxGenerations',100,'UseParallel',true, ...
   'UseVectorized',false);
% options = optimoptions('ga','MaxGenerations',100,'UseParallel',false, ...
%    'UseVectorized',true);
% options = optimoptions('ga','MaxGenerations',100,'UseParallel',true, ...
%    'UseVectorized',true);

lb = [0 0 0 0 0 0 0 0 1   0.0001 0.0000001 0.0000001];
ub = [1 1 1 1 1 1 1 1 100 0.1    0.01      1.0];
ic = [1 2 3 4 5 6 7 8 9];

% this command optimizes learning accuracy
% bestLSTMhyper = ga({@LSTMeval,SeqCell},12,[],[],[],[],lb,ub,[],ic,options)
% this command optimizes generalization ability
bestLSTMhyper = ga({@LSTMgenTest,SeqCell},12,[],[],[],[],lb,ub,[],ic,options)

toc

