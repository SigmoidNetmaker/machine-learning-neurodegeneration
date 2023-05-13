% LSTMsetUp.m
% this script sets up the LSTM learning environment;
% In and desOut must be available in the workspace

% set network parameters
nIn   = 113;
nOut  = 25;
nLSTM = 10;

% set hyperparameters
aStart = 0.01; % starting learning rate
aEnd   = 0.0001; % ending learning rate
nits = 20; % number of training iterations
% compute learning rate rescale factor
aScale = exp((log(aEnd) - log(aStart)) / nits);
a = aStart; % set initial learning rate
m = 1 - a; % set initial momentum
aFix = 0.0001; % set a fixed learnig rate
mFix = 0.9000; % set a fixed momentum
minSeq = 3; % defalut for minimum LSTM sequence length
% minSeq = 10; % set minimum sequence length
maxSeq = 25; % default for maximum sequence from RADC

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

% return

% much of this code is probably redundant
% zero weigth change and previous change matrices
% forward weight change matrices
dWz = zeros(nLSTM,nIn); % x-z weights
dWi = zeros(nLSTM,nIn); % x-i weights
dWf = zeros(nLSTM,nIn); % x-f weights
dWo = zeros(nLSTM,nIn); % x-o weights
dWu = zeros(nOut,nLSTM); % y-u weights
% recurrent weight change matrices
dRz = zeros(nLSTM,nLSTM); % y-z weights
dRi = zeros(nLSTM,nLSTM); % y-i weights
dRf = zeros(nLSTM,nLSTM); % y-f weights
dRo = zeros(nLSTM,nLSTM); % y-o weights
% peephole change vectors
dPi = zeros(nLSTM,1); % input gate peepholes
dPf = zeros(nLSTM,1); % forget gate peepholes
dPo = zeros(nLSTM,1); % output gate peepholes
% bias change vectors
dbz = zeros(nLSTM,1); % block input bias
dbi = zeros(nLSTM,1); % input gate bias
dbf = zeros(nLSTM,1); % forget gate bias
dbo = zeros(nLSTM,1); % output gate bias
dbu = zeros(nOut,1); % network output bias
% previous forward weight change matrices
pWz = zeros(nLSTM,nIn); % x-z weights
pWi = zeros(nLSTM,nIn); % x-i weights
pWf = zeros(nLSTM,nIn); % x-f weights
pWo = zeros(nLSTM,nIn); % x-o weights
pWu = zeros(nOut,nLSTM); % y-u weights
% previous recurrent weight change matrices
pRz = zeros(nLSTM,nLSTM); % y-z weights
pRi = zeros(nLSTM,nLSTM); % y-i weights
pRf = zeros(nLSTM,nLSTM); % y-f weights
pRo = zeros(nLSTM,nLSTM); % y-o weights
% previous peephole change vectors
pPi = zeros(nLSTM,1); % input gate peepholes
pPf = zeros(nLSTM,1); % forget gate peepholes
pPo = zeros(nLSTM,1); % output gate peepholes
% previous bias change vectors
pbz = zeros(nLSTM,1); % block input bias
pbi = zeros(nLSTM,1); % input gate bias
pbf = zeros(nLSTM,1); % forget gate bias
pbo = zeros(nLSTM,1); % output gate bias
pbu = zeros(nOut,1); % network output bias

% set start values for LSTM units
% state vectors
z = zeros(nLSTM,maxSeq); % define z
i = zeros(nLSTM,maxSeq); % define i
f = zeros(nLSTM,maxSeq); % define f
c = zeros(nLSTM,maxSeq); % define c
o = zeros(nLSTM,maxSeq); % define o
y = zeros(nLSTM,maxSeq); % define y
u = zeros(nOut,maxSeq); % define u
% net input vectors
nz = zeros(nLSTM,maxSeq); % define nz
ni = zeros(nLSTM,maxSeq); % define ni
nf = zeros(nLSTM,maxSeq); % define nf
no = zeros(nLSTM,maxSeq); % define no
nu = zeros(nOut,maxSeq); % define nu
% delta vectors
dz = zeros(nLSTM,maxSeq); % define dz
di = zeros(nLSTM,maxSeq); % define di
df = zeros(nLSTM,maxSeq); % define df
dc = zeros(nLSTM,maxSeq); % define dc
do = zeros(nLSTM,maxSeq); % define do
dy = zeros(nLSTM,maxSeq); % define dy
du = zeros(nOut,maxSeq); % define du

% make a little age series for testing
minAge = 50;
maxAge = 110;
ageSeries  = linspace(minAge,maxAge,1000);
ageSerNorm = (ageSeries - minAge) / (maxAge - minAge);
numAge = length(ageSeries);

% make some input/desired-output patterns as a debug
% (note: these are normally COMMENTED OUT)
% In = round(randn(10) * 20); 
% desOut = round(randn(10) * 20); 
% desOut(abs(desOut) < 10) = NaN;
% In = eye(10) * 20;
% desOut = eye(10) * 20;
% desOut = diag((rand(1,10)- 0.5)*100);

% make a standard In/Out sequence
% age = 55:105; % set an age input vector
% numAge = length(age); % find number of ages
% scale = -1e-10; % set scale for power function
% power = 5; % set power of power function
% const = 0.7; % set constant of power function
% cog = scale * age.^power + const; % make a cog score vecor
% % make a sigmoidal cog vector as a debug
% % cog = 1 ./ (1+exp(-(age-mean(age))/5));
% In = age'/100; % let In be age (but scaled) for sequence learning
% desOut = cog'; % let desOut just be cog for sequence learning

% compute the vector of averaged inputs
% InAvgVec = mean(In);







