% LSTMcomboPar.m
% this script is an attempt at a parallel version
% of LSTMcomboPar

% set numbers of network inputs and outputs
% *** nIn and nOut different for RADC and NACC ***
nIn  = 113; % for RADC
nOut = 25;  % for RACC
% nIn  = 101; % for NACC
% nOut = 57;  % for NACC

% set number of LSTMs 
nLSTM = 80;

% *** look at combo slot!!! ***
% *** THIS IS CRITICAL!!!! ***
% *** LOOK NOW!!!!!!!!!!!!! ***

% set keepers
keepR  = 0;
keepC  = 0;
keepGi = 1;
keepGf = 0;
keepGo = 0;
keepPi = 0;
keepPf = 0;
keepPo = 0;

% set age range and number of ages in rangs
minAge = 50;
maxAge = 110;
numAge = 101;

% set number of drugs in the combinations
numDrugs = 17;
% numDrugs = 16;
% numDrugs = 11;
% numDrugs = 10;

% find number of combinations
numCombos = 2^numDrugs;

% set cmbLim
cmbLim = numCombos; % default
% cmbLim = 2000;
% (note: a bug prevents cmbLim 100 from plotting properly)

% set timer
% *** comment out for Job ***
% tic

% find actual age versus cog data
% ACTage = In(:,1);
% ACTcog = zeros(nPat,1);
% for p = 1:nPat
%     notNaN = ~isnan(desOut(p,:));
%     ACTcog(p) = mean(desOut(p,notNaN));
% end
    
% make a little age series for testing
ageSeries  = linspace(minAge,maxAge,numAge);
ageSerNorm = (ageSeries - minAge) / (maxAge - minAge);

% set up age vs cog array 
ageCogArray = zeros(numCombos,numAge);

% find all the drug combinations
cmbNUMBER  = (1:2^numDrugs)'; % combination number vector
comboArray = rem(floor((cmbNUMBER - 1)*pow2(-(numDrugs-1):0)),2); % combos

% find average of all inputs
avgIn = mean(In);

% resample inputs to capture any change with age
nPat = size(In,1); % grab number of patterns again just in case
ageUni = linspace(0,1,nPat); % make a UNIFORM age vector
[sortAge,sortAgeIndx] = sort(In(:,1)); % sort ages in input
sortIn = In(sortAgeIndx,:); % reorder input according to age
[resIn,ageRes] = resample(sortIn,ageUni,numAge-1); % resample

% now make an input array, using either averaged or resampled inputs
% *** another decision point: averaged or resampled? ***
% inArr = meshgrid(avgIn,1:numAge); % this is for averaged inputs
inArr = resIn; % this is for resampled inputs

% in either case, make the ages smooth for the input array
inArr(:,1) = ageSerNorm;

% set all non-combo drugs to zero for RADC and NACC 
% note: this step is not necessary, its just an option
% *** this is different for RADC versus NACC ***
% inArr(:,28:109) = 0; % for RADC with numDrugs = 17
% inArr(:,38:42) = 0; % for NACC with numDrugs = 17
% inArr(:,27:109) = 0; % for RADC with numDrugs = 16
% inArr(:,37:42) = 0; % for NACC with numDrugs = 16
% inArr(:,22:109) = 0; % for RADC with numDrugs = 11
% inArr(:,32:42) = 0; % for NACC with numDrugs = 11
% inArr(:,21:109) = 0; % for RADC with numDrugs = 10
% inArr(:,31:42) = 0; % for NACC with numDrugs = 10
% inArr(:,11+numDrugs:109) = 0; % for RADC 
% inArr(:,21+numDrugs:42) = 0; % for NACC 

% find the age vs cog for all combos
parfor cmb = 1:cmbLim % for combo limit combinations
    
    % set x to the input array insice parfor loop
    x = inArr';
        
    % *** combo slot different for RADC and NACC ***
    % *** this is CRUCIALLY important!!! ***
    % x(11:27,:) = meshgrid(comboArray(cmb,:),1:numAge)'; % for RADC 17
    % x(21:37,:) = meshgrid(comboArray(cmb,:),1:numAge)'; % for NACC 17
    % x(11:26,:) = meshgrid(comboArray(cmb,:),1:numAge)'; % for RADC 16
    % x(21:36,:) = meshgrid(comboArray(cmb,:),1:numAge)'; % for NACC 16
    % x(11:21,:) = meshgrid(comboArray(cmb,:),1:numAge)'; % for RADC 11
    % x(21:31,:) = meshgrid(comboArray(cmb,:),1:numAge)'; % for NACC 11
    % x(11:20,:) = meshgrid(comboArray(cmb,:),1:numAge)'; % for RADC 10
    % x(21:30,:) = meshgrid(comboArray(cmb,:),1:numAge)'; % for NACC 10
    x(11:11+numDrugs-1,:) = meshgrid(comboArray(cmb,:),1:numAge)'; % RADC
    % x(21:21+numDrugs-1,:) = meshgrid(comboArray(cmb,:),1:numAge)'; % NACC
    
    % define LSTM unit state and net vectors inside parfor loop
    % state vectors
    z = zeros(nLSTM,numAge); % define z
    i = zeros(nLSTM,numAge); % define i
    f = zeros(nLSTM,numAge); % define f
    c = zeros(nLSTM,numAge); % define c
    o = zeros(nLSTM,numAge); % define o
    y = zeros(nLSTM,numAge); % define y
    u = zeros(nOut,numAge); % define u
    % net input vectors
    nz = zeros(nLSTM,numAge); % define nz
    ni = zeros(nLSTM,numAge); % define ni
    nf = zeros(nLSTM,numAge); % define nf
    no = zeros(nLSTM,numAge); % define no
    nu = zeros(nOut,numAge); % define nu
    
    for t = 2:numAge % for all ages in age series (as times)
        % compute net z input, decomposed
        nz(:,t) = Wz * x(:,t) + ...
            (keepR * Rz) * y(:,t-1) + ...
            bz; % end decomposed NET z
        z(:,t)  = tanh(nz(:,t)); % squash z net input
        % compute net i gate, decomposed
        ni(:,t) = Wi * x(:,t) + ...
            (keepR  * Ri) * y(:,t-1) + ...
            (keepPi * Pi) .* c(:,t-1) + ...
            bi; % end decompose net i
        i(:,t)  = 1 ./ (1 + exp(-ni(:,t))); % squash i net input
        % compute net f gate, decomposed
        nf(:,t) = Wf * x(:,t) + ...
            (keepR  * Rf) * y(:,t-1) + ...
            (keepPf * Pf) .* c(:,t-1) + ...
            bf; % end decompose net f
        f(:,t)  = 1 ./ (1 + exp(-nf(:,t))); % squash f net input
        % compute c, decomposed
        c(:,t)  = z(:,t) .* ...
            (keepGi * i(:,t)) + ...
            z(:,t) * ...
            (1 - keepGi) + ...
            (keepC  * c(:,t-1)) .* ...
            (keepGf * f(:,t)) + ...
            (keepC  * c(:,t-1)) * ...
            (1 - keepGf); % compute c
        % compute net o gate, decomposed
        no(:,t) = Wo * x(:,t) + ...
            (keepR  * Ro) * y(:,t-1) + ...
            (keepPo * Po) .* c(:,t) + ...
            bo; % end decompose net o
        o(:,t)  = 1 ./ (1 + exp(-no(:,t))); % squash o net input
        % compute y, decomposed
        y(:,t)  = tanh(c(:,t)) .* ...
            (keepGo * o(:,t)) + ...
            tanh(c(:,t)) * ...
            (1 - keepGo); % end decompose y
        % compute net u, no need to decompose
        nu(:,t) = Wu * y(:,t) + bu; % net u input
        u(:,t)  = 1 ./ (1 + exp(-nu(:,t))); % squash u net input
        
    end % end age loop
    
    ageCogArray(cmb,:) = mean(u);
    
end % end combination loop

% report elapsed time
% *** probably should comment out for Jobs ***
% toc

% check input array against field names as a debug
% [CnameRADCin num2cell(x(:,101))]
% [CnameNACCin num2cell(x(:,101))]

% *** commment in for jobs ***
return

% strip initial transient from responses
ageCogArray = ageCogArray(:,2:end);
ageSeries   = ageSeries(:,2:end);
ageSerNorm  = ageSerNorm(:,2:end);
numAge = numAge - 1;

% find combination potental potencies
% allNoDrugArray = meshgrid(ageCogArray(1,:),cmbNUMBER);
% cmbPot = mean(ageCogArray - allNoDrugArray,2);
% *** save cmbPot for RADC or NACC ***
% cmbPotRADC = cmbPot;
% cmbPotNACC = cmbPot;

% comment in so as not to see figure
% return

% plot responses to combinations
figure(6)
clf
% plot(ageSeries,ageCogArray)
% plot(ageSerNorm',ageCogArray(1:cmbLim,:))
plot(ageSeries',ageCogArray(1:1000:cmbLim,:))
hold
plot(ageSeries',ageCogArray(1,:),'r','linewidth',2.5)
% plot(ACTage,ACTcog,'.')
hold
% axis([0,1,0.5,0.7])
xlabel('age (years)')
ylabel('predicted composite cognitive score')
% title('Simulated Age versus Cogscore for All Drug Combos')
set(gca,'fontsize',11,'fontweight','bold')
set(gca,'linewidth',1)

