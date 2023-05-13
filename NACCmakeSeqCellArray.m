% NACCmakeSeqCellArray.m 
% this script makes a cell array of sequences from NACC datset;
% numerical martix NACCdataset must be available in the workspace;
% both NACCreadDataset and NACCmakeTruthTable must be run first

% set minimum sequence length
minSeq = 10;

% use N to hold NACCdataset
N = NACCdataset;

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
cellRowVec = splitapply(@numel,N(:,1),IDgroups)';

% set number of columns for cell array
cellColVec = [101 57];

% trim the IDnums off of N
N = N(:,2:end);

% make the NACC sequence cell array
% (in SeqCell, all inputs are in cell col 1, cog scores in cell col 2)
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





