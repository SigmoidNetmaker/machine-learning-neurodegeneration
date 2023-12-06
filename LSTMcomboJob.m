% LSTMcomboJob.m
% this script finds the drug combination responses of 
% ten separately trained networks and averages them
% to get the best estimate, it then computes the
% potential potency based on all ten networks
% (note: watch for RADC or NACC specific code lines)

% enter number of networks in average
numNets = 100;

% *** make sure to set save for RADC or NACC!!! ***

% set some dimensions
% *** these must be the same as in LSTMcombo ***
numAge = 101; % number of values in age series
numDrugs = 17; % number of drugs in combinations
numCombos = 2^numDrugs; % find number of combinations

% now define array to hold averaged age-cog values
avgAgeCogArray = zeros(numCombos,numAge);

% set timer
tic

% generate all the responses and sum them
for net = 1:numNets
    
    % *****  this is only a test of correlation  *****
    % *****   do ***NOT*** use for drug screens  *****
    % now that In and desOut are carefully made -- scramble them!
    In     = reshape(In(randperm(nPat*nIn)),nPat,nIn);
    desOut = reshape(desOut(randperm(nPat*nOut)),nPat,nOut);
    % reassumble a scrambled N from scrambled In and desOut
    scramN = [In,desOut];
    % now remake SeqCell from the scrambled N
    % (note: In and desOut were scrambled separately!)
    SeqCell = mat2cell(scramN, cellRowVec, cellColVec);
    % *****  make sure this is usually commented out  *****

    LSTMrandomize
    
    LSTMdecomTrain
    
    % choose serial or parallel
    % if parallel run parpool first
    % LSTMcombo
    LSTMcomboPar
    
    avgAgeCogArray = ageCogArray + avgAgeCogArray;
    
    percentDone = net/numNets * 100
    
end

% now find the average response
avgAgeCogArray = avgAgeCogArray ./ numNets;

% strip initial transient from responses
avgAgeCogArray = avgAgeCogArray(:,2:end);

% find combination potental potencies
avgNoDrugArray = meshgrid(avgAgeCogArray(1,:),cmbNUMBER);
cmbPot = mean(avgAgeCogArray - avgNoDrugArray,2);

% *** save values for RADC or NACC ***
% for RADC
avgNoDrugRADC = avgNoDrugArray;
avgAgeCogRADC = avgAgeCogArray;
cmbPotRADC    = cmbPot;
save('RADCestimate','avgNoDrugRADC','avgAgeCogRADC','cmbPotRADC')
% for NACC
% avgNoDrugNACC = avgNoDrugArray;
% avgAgeCogNACC = avgAgeCogArray;
% cmbPotNACC    = cmbPot;
% save('NACCestimate','avgNoDrugNACC','avgAgeCogNACC','cmbPotNACC')

% report elapsed time
toc






