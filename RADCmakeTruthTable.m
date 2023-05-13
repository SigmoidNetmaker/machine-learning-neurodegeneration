% RADCmakeTruthTable
% this script makes a truth table from RADC data;
% it combines data in the Long and Basic spreadsheets;
% the truth table is a pair of huge 2-D matrices;
% RADCreadLongBasic must be run first

% restore Nlong and Nbasic if necessary
Nlong  = N621longHold;
Nbasic = N621basicHold;

% find ID groups in N
IDgroups = findgroups(Nlong(:,1));

% find number of IDgroups
numIDgroups = length(unique(IDgroups));

% find the number of entries for each ID
% (note: each entry is for a differet age)
numAgeEachID = splitapply(@numel,Nlong(:,1),IDgroups);

% find unique IDs themselves
uniqueIDs = unique(Nlong(:,1));

% remove extra IDs from Nbasic
Nbasic = Nbasic(ismember(Nbasic(:,1),uniqueIDs),:);
% isequal(Nbasic(:,1),uniqueIDs) % check, not usually needed

% just take from Nbasic what is not in Nlong
% (this is cols 4 thru 7 of Nbasic)
Nbasic = Nbasic(:,3:6);
Cname621basic = Cname621basic(3:6);

% make a vector of combined column names
CnameRADC = [Cname621long; Cname621basic];

% expand Nbasic for all ages for each ID and complete N matrix
NbasExpan = [];
for i = 1:numIDgroups
    NbasExpan = [NbasExpan; 
                 meshgrid(Nbasic(i,:),ones(numAgeEachID(i),1))];
end
N = [Nlong NbasExpan];

% process N to remove rows with no cognitive scores
[numNent,numNvar] = size(N); % find num entries and variables for N
rawOut = N(:,3:27); % extract the raw output
rawOut = rawOut + 1; % add one to make ligit zeros nonzero
rawOut(find(isnan(rawOut))) = 0; % convert NaNs to zeros
noCogs = find(sum(rawOut') == 0); % find rows with no cog score
indxCog = 1:numNent; % make a vector of indices for N
indxCog(noCogs) = []; % remove indices for no cog score
N = N(indxCog,:); % remove rows with no cog score

% compute percent NaNs in input rows of N
InNaNpercent = ...
    sum(sum(isnan(N(:,28:numNvar)))) / numel(N(:,28:numNvar)) * 100;

% process the input cols of N to replace NaNs and normalize
% for each input col (col 28 to end) of N replace NaNs with mean of col
for i = 28:numNvar
    N(isnan(N(:,i)),i) = mean(N(~isnan(N(:,i)),i));
end
% normalize each input col of N (NaNs automatically avoided)
for i = 28:numNvar
    N(:,i) = (N(:,i) - min(N(:,i))) / max(N(:,i) - min(N(:,i)));
end

% normalize output cols of N as specific to RADC
N(:,3) = min(N(:,3),4); % dcfdx
N(:,3) = (4 - N(:,3)) / 3;
N((N(:,4) == 98),4) = 0; % cts_animals
N((N(:,4) == 99),4) = 0; 
N(:,4) = N(:,4)/75;
N(:,5) = N(:,5)/15; % cts_bname
N(:,6) = N(:,6)/150; % cts_catflu
N(:,7) = N(:,7)/12; % cts_db
N(:,8) = N(:,8)/25; % cts_delay
N(:,9) = N(:,9)/12; % cts_df
N(:,10) = N(:,10)/14; % cts_doperf
N(:,11) = N(:,11)/12; % cts_ebdr
N(:,12) = N(:,12)/12; % cts_ebmt
N(:,13) = N(:,13)/75; % cts_fruits
N(:,14) = N(:,14)/8; % cts_idea
N(:,15) = N(:,15)/15; % cts_lopair
N(:,16) = N(:,16)/30; % cts_mmse30
N(:,17) = N(:,17)/48; % cts_nccrtd
N(:,18) = N(:,18)/16; % cts_pmat
N(:,19) = N(:,19)/9; % cts_pmsub
N(:,20) = N(:,20)/10; % cts_read_nart
N(:,21) = N(:,21)/110; % cts_sdmt
N((N(:,22) == 77),22) = 0; % cts_story
N((N(:,22) == 98),22) = 0; 
N((N(:,22) == 99),22) = 0; 
N(:,22) = N(:,22)/25; 
N(:,23) = N(:,23)/100; % cts_stroop_cna
N(:,24) = N(:,24)/80; % cts_stroop_wread
N(:,25) = N(:,25)/30; % cts_wli
N(:,26) = N(:,26)/10; % cts_wlii
N(:,27) = N(:,27)/10; % cts_wliii

% save the current matrix N as RADCdataset
RADCdataset = N; % this is the conditioned RADCdataset
Nhold = N; % save N in a hold array (this is old)

% grab In and desOut as submatrices of N
In     = N(:,28:end);
desOut = N(:,3:27);

% grab the column names
CnameRADCin  = CnameRADC(28:end);
CnameRADCout = CnameRADC(3:27);

% as a *debug* set In to age only
% In = N(:,28);

% as another *debug* set desOut to be composite cog score
% desOut = mean(N(:,3:27)')';

% find numbers of inputs and outputs
nIn  = size(In,2);
nOut = size(desOut,2);
nPat = size(N,1);

% convert desired outputs to Zscores
% for i = 1:nOut
%     indxOK = find(~isnan(desOut(:,i)));
%     desOut(indxOK,i) = zscore(desOut(indxOK,i));
% end

% convert NaNs in desOut to 0 for plotting
desOutPlot = desOut;
desOutPlot(isnan(desOutPlot)) = 0;

% spy In and desOut
% figure(4)
% subplot(1,2,1)
% spy(In)
% axis square
% title('Input')
% xlabel('input number')
% ylabel('pattern number')
% subplot(1,2,2)
% spy(desOutPlot)
% axis square
% title('Desired Output')
% xlabel('output number')
% ylabel('pattern number')

% return

% show In and desOut as images
figure(2)
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


