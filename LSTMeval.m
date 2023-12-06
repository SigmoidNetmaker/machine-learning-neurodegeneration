% function LSTMeval

function LSTMerror = LSTMeval(LSTMhyper,SeqCell)

% find number of sequnces in SeqCell
numSeq = size(SeqCell,1);

% make error hold cell array
ErrCell = cell(numSeq,1);

% set default selected sequences
seqSel = 1:numSeq; % default seqSel

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
mFix   = LSTMhyper(12);

LSTMrandomize

LSTMdecomTrain

LSTMdecomTest

LSTMerror = RMSerr;

end % end function definition

