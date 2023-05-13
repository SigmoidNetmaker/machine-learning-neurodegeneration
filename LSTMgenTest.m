% function LSTMgenTest

function LSTMerror = LSTMgenTest(LSTMhyper,SeqCell)

% set number of retrainings
numReTrain = 10;

% find number of sequnces in SeqCell
numSeq = size(SeqCell,1);

% make error hold cell array
ErrCell = cell(numSeq,1);

% set default selected sequences
seqSel = 1:numSeq; % default seqSel

% set gene-encoded hyperparameters
% set keepers
keepR  = LSTMhyper(1);
keepC  = LSTMhyper(2);
keepGi = LSTMhyper(3);
keepGf = LSTMhyper(4);
keepGo = LSTMhyper(5);
keepPi = LSTMhyper(6);
keepPf = LSTMhyper(7);
keepPo = LSTMhyper(8);
% set LSTM number
nLSTM  = LSTMhyper(9);
% set learning rate start and end
aStart = LSTMhyper(10);
aEnd   = LSTMhyper(11);
% set fixed momentum
mFix   = LSTMhyper(12);

% set number of sequences in test set to
% about 75% of the total sequences
% (note: the rest are in the training set)
nTrainSeq = round(0.75 * numSeq);
nTestSeq  = numSeq - nTrainSeq;

% define generalization error hold vector
GenErr = zeros(1,numReTrain);

% retrain and retest gene-encoded network
for r = 1:numReTrain
    
    permSeq = randperm(numSeq); % randomly permute sequence numbers
    sTrain  = permSeq(1:nTrainSeq-1); % grab train sequence numbers
    sTest   = permSeq(nTrainSeq:end); % grab test sequence numbers
   
    LSTMrandomize % randomize weights
    
    seqSel = sTrain; % set sequences to be trained
    
    LSTMdecomTrain % train network
    
    seqSel = sTest; % set sequences to be tested
    
    LSTMdecomTest % test network
    
    GenErr(r) = RMSerr; % save RMS error over test set
    
end % end function definition

 LSTMerror = mean(GenErr); % find mean generalization error
 
 
 
 
