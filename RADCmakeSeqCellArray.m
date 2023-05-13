% ADmlMakeSeqCellArray.m (same as RADCmakeSeqCellArray.m) 
% this script makes a cell array of sequences from RADC datset;
% numerical martix RADCdataset must be available in the workspace;
% both RADCreadLongBasic and RADCmakeTruthTable must be run first

% set minimun sequence length (LSTMsetUp does this too)
minSeq = 10; % defalut for minimum LSTM sequence length

% restore N if necessary
% (note: the following two statements are equivalent)
N = RADCdataset;
% N = Nhold;

% edit N to remove all rows without drug info
% (not sure I want this in)
% N = N(~isnan(N(:,28)),:);

% find ID groups in N
% (note: the first column of N are ID numbers;
%        each yearly entry starts with the patient's ID number)
IDgroups = findgroups(N(:,1));

% find number of IDgroups
numIDgroups = length(unique(IDgroups));

% find number of rows in each group for cell array
% (this is also the number of entries for each ID)
% (this is also the sequence length for each ID)
cellRowVec = splitapply(@numel,N(:,1),IDgroups)';

% trim the IDnums and visit numbers off of N
N = N(:,3:end);

% rearrange N so that inputs come before desired outputs
N = [N(:,26:end) N(:,1:25)]; 

% set number of columns for cell array
% (note: there are 113 inputs and 25 outputs)
cellColVec = [113 25]; 

% make the SeqCell array
% (note: in SeqCell, cog scores are in cell col 1, all else in cell col 2)
SeqCell = mat2cell(N, cellRowVec, cellColVec);

% as a *debug* set input to be age only
% NcogAge = N(:,1:26);
% cellColVec = [25 1];
% SeqCell = mat2cell(NcogAge, cellRowVec, cellColVec);

% as another *debug* set input to age and desOut to avg cog score
% NcogAge = [mean(N(:,1:25)')' N(:,26)];
% cellColVec = [1 1];
% SeqCell = mat2cell(NcogAge, cellRowVec, cellColVec);

% limit SeqCell by the minimum allowed sequence length
% (note: these can be commented out, but minSeq = 1
%        just takes all the data anyway)
goodSeqIndx = find(cellRowVec >= minSeq);
cellRowVec = cellRowVec(goodSeqIndx);
SeqCell = SeqCell(goodSeqIndx,:);

% find number of sequnces in SeqCell
numSeq = size(SeqCell,1);

% make output and error hold cell arrays
OutCell = cell(numSeq,1);
ErrCell = cell(numSeq,1);

% make new In and desOut arrays, limited my minimum sequence
In     = cell2mat(SeqCell(:,1));
desOut = cell2mat(SeqCell(:,2));

% find new nIn, nOut, and nPat
[nPat,nIn]  = size(In); 
[nPat,nOut] = size(desOut);

% % *****  this is only a test of correlation  *****
% % *****   do ***NOT*** use for drug screens  *****
% % now that In and desOut are carefully made -- scramble them!
% In     = reshape(In(randperm(nPat*nIn)),nPat,nIn); 
% desOut = reshape(desOut(randperm(nPat*nOut)),nPat,nOut); 
% % reassumble a scrambled N from scrambled In and desOut
% scramN = [In,desOut];
% % now remake SeqCell from the scrambled N
% % (note: In and desOut were scrambled separately!)
% SeqCell = mat2cell(scramN, cellRowVec, cellColVec);
% % *****  make sure this is usually commented out  *****

% set defaults for patterns or sequences
pSel = 1:nPat;  % new default pSel
seqSel = 1:numSeq; % default seqSel

% convert NaNs in desOut to 0 for plotting
desOutPlot = desOut;
desOutPlot(isnan(desOutPlot)) = 0;

% *** comment IN for GA ***
% return

% show In and desOut as images
figure(3)
clf
subplot(1,2,1)
imagesc(In)
xlabel('input number')
ylabel('pattern number')
title('Input')
subplot(1,2,2)
imagesc(desOutPlot)
xlabel('output number')
title('Desired Output')




