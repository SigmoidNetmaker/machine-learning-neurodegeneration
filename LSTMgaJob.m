% LSTMgaJob.m
% this script just does a batch of GAs

% *** don't forget to start parpool! ***
% but no worries if you forget because ...
% MATLAB will start it automatically if GA is parallelized

% set number of separate GAs in batch
batchNum = 5;

% set number of parameters to be optimized
pramNum = 12;

% define chromosome holder array
chromArray = zeros(batchNum,pramNum); 

% now do the optimizations
for era = 1:batchNum
    LSTMga
    chromArray(era,:) = bestLSTMhyper;
    era
end

% save the chromosome array
% don't forget to rename it!
save('LSTMchromHOLD','chromArray')


