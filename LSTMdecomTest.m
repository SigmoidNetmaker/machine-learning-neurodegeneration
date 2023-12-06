% LSTMdecomTest.m
% this script tests LSTM networks on database data;
% note: SeqCell must be in the workspace along with 
% OutCell and ErrCell

% set masks
% *** comment OUT for GA ***
% keepR  = 1;
% keepC  = 1;
% keepGi = 1;
% keepGf = 1;
% keepGo = 1;
% keepPi = 1;
% keepPf = 1;
% keepPo = 1;

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
       
    for t = 2:sL
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
    end % end time loop

    OutCell{s} = u';       % save output for current sequence
    ErrCell{s} = (d - u)'; % save error for current sequence
    
end % end sequence loop

% grab error
Err = cell2mat(ErrCell); 

% find RMS error
RMSerr = rms(Err(~isnan(Err)));

% *** comment IN for GA ***
return

% report RMS error
RMSerr

% make desOut from SeqCell, just to be sure
desOut = cell2mat(SeqCell(:,2)); 

% grab actual output 
actOut = cell2mat(OutCell);

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
