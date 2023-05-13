% LSTMtest.m
% this script tests LSTM networks on database data;
% note: SeqCell must be in the workspace along with 
% OutCell and ErrCell

% set number of LSTMs
% (note: this is set in LSTM randomize)
% nLSTM = 10; % number of LSTMs
% (note: nIn and nOut should be in workspace)

% make output and error hold cell arrays
OutCell = cell(numSeq,1);
ErrCell = cell(numSeq,1);

% test network on all sequences in seqSel
for s = seqSel % for each sequence
    
    x  = SeqCell{s,1}'; % set input for current sequence
    d  = SeqCell{s,2}'; % set desired output for current sequence
    sL = size(x,2); % find length of current sequence
    
    % set start values for LSTM units
    % state vectors
    z = zeros(nLSTM,sL); % define z
    i = zeros(nLSTM,sL); % define i
    f = zeros(nLSTM,sL); % define f
    c = zeros(nLSTM,sL); % define c
    o = zeros(nLSTM,sL); % define o
    y = zeros(nLSTM,sL); % define y
    u = zeros(nOut,sL); % define u
    % net input vectors
    nz = zeros(nLSTM,sL); % define nz
    ni = zeros(nLSTM,sL); % define ni
    nf = zeros(nLSTM,sL); % define nf
    no = zeros(nLSTM,sL); % define no
    nu = zeros(nOut,sL); % define nu
    
    for t = 2:sL % for each sequence time point
        nz(:,t) = Wz*x(:,t) + Rz*y(:,t-1) + bz; % compute net z
        z(:,t)  = tanh(nz(:,t)); % squash z net input
        ni(:,t) = Wi*x(:,t) + Ri*y(:,t-1) + Pi .* c(:,t-1) + bi; % net i
        i(:,t)  = 1 ./ (1 + exp(-ni(:,t))); % squash i net input
        nf(:,t) = Wf*x(:,t) + Rf*y(:,t-1) + Pf .* c(:,t-1) + bf; % net f
        f(:,t)  = 1 ./ (1 + exp(-nf(:,t))); % squash f net input
        c(:,t)  = z(:,t) .* i(:,t) + c(:,t-1) .* f(:,t); % compute c
        no(:,t) = Wo*x(:,t) + Ro*y(:,t-1) + Po .* c(:,t) + bo; % net o
        o(:,t)  = 1 ./ (1 + exp(-no(:,t))); % squash o net input
        y(:,t)  = tanh(c(:,t)) .* o(:,t); % compute y
        nu(:,t) = Wu*y(:,t) + bu; % net u input
        u(:,t)  = 1 ./ (1 + exp(-nu(:,t))); % squash u net input
    end % end time loop

    OutCell{s} = u';       % save output for current sequence
    ErrCell{s} = (d - u)'; % save error for current sequence
    
end % end sequence loop

% make desOut from SeqCell, just to be sure
desOut = cell2mat(SeqCell(:,2)); 

% grab actual output and error
actOut = cell2mat(OutCell);
Err    = cell2mat(ErrCell); 

% find RMS error
RMSerr = rms(Err(~isnan(Err)))

% for plotting, set any NaNs to zeros
actOutPlot = actOut;
desOutPlot = desOut; 
ErrPlot = Err;
actOutPlot(isnan(desOutPlot)) = 0;
desOutPlot(isnan(desOutPlot)) = 0;
ErrPlot(isnan(ErrPlot)) = 0;

% plot results
% show the desire and actual outputs and the error
figure(4)
clf
subplot(1,4,1)
imagesc(In)
xlabel('in num')
ylabel('pattern number')
title('Input')
subplot(1,4,2)
imagesc(desOutPlot)
xlabel('out num')
title('Des Out')
subplot(1,4,3)
imagesc(actOutPlot)
xlabel('out num')
title('Act Out')
subplot(1,4,4)
imagesc(ErrPlot)
% colorbar
xlabel('out num')
title('Error')
