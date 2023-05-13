% LSTMdecomTrain.m
% this script trains LSTM networks on database data;
% it decomposes the LSTMs to block certain features;
% note: SeqCell must be available in workspace

% set number of LSTMs
% (note: this is set in LSTM randomize)
% *** comment OUT for GA ***
% nLSTM = 80; % number of LSTMs
% (note: nIn and nOut should be in workspace)

% set some hyperparameters
% (note: these are optimized by the GA)
% *** comment OUT for GA ***
aStart = 0.06; % starting learning rate
aEnd   = 0.0006; % ending learning rate
mFix = 0.0002; % set a fixed momentum

% set other hyperparameters
nits = 2 * numSeq; % number of training iterations
% (note: nits should be 2x number of sequences (numSeq))
% compute learning rate rescale factor
aScale = exp((log(aEnd) - log(aStart)) / nits);
a = aStart; % set initial learning rate
% m = 1 - a; % set initial momentum
% aFix = 0.0001; % set a fixed learnig rate
m = mFix; % set m to fixed momentum

% set the timer
% *** comment OUT for GA or Job ***
% tic

% set masks
% *** comment OUT for GA, not for Job ***
keepR  = 0;
keepC  = 0;
keepGi = 1;
keepGf = 0;
keepGo = 0;
keepPi = 0;
keepPf = 0;
keepPo = 0;

% define the previous weight change matrices
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
    
% for each training iteration
for it = 1:nits
    
    s  = datasample(seqSel,1); % grab a sequence at random
    x  = SeqCell{s,1}'; % grab the input sequence
    d  = SeqCell{s,2}'; % grab the output sequence
    sL = size(x,2); % find sequence length

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
    end % end forward propagation through time
    
    % compute network output delta
    du = d - u; % diff between desired and actual output
    du(isnan(du)) = 0; % change all NaNs to zeros
   
    % zero all other delta vectors
    dz = zeros(nLSTM,sL); % define dz
    di = zeros(nLSTM,sL); % define di
    df = zeros(nLSTM,sL); % define df
    dc = zeros(nLSTM,sL); % define dc
    do = zeros(nLSTM,sL); % define do
    dy = zeros(nLSTM,sL); % define dy
    
    % compute new unit deltas
    for t = sL-1:-1:2
        % compute delta y, decomposed
        dy(:,t) = Wu' * du(:,t) + ...
                  (keepR * Rz') * dz(:,t+1) + ...
                  (keepR * Ri') * (keepGi * di(:,t+1)) + ...
                  (keepR * Rf') * (keepGf * df(:,t+1)) + ...
                  (keepR * Ro') * (keepGo * do(:,t+1)); % end decom dy
        % compute delta o, decomposed
        do(:,t) = dy(:,t) .* tanh(c(:,t)) .* ...
                  (keepGo * (o(:,t) .* (1 - o(:,t)))); % end decom do
        % compute delta c, decomposed
        dc(:,t) = dy(:,t) .* sech(c(:,t)).^2 .* ...
                  (keepGo * (o(:,t))) + ...
                  dy(:,t) .* sech(c(:,t)).^2 * ...
                  (1 - keepGo) + ...
                  (keepPo * Po) .* (keepGo * do(:,t)) + ...
                  (keepPi * Pi) .* (keepGi * di(:,t+1)) + ...
                  (keepPf * Pf) .* (keepGf * df(:,t+1)) + ...
                  (keepC  * dc(:,t+1)) .* ...
                  (keepGf * f(:,t+1)) + ...
                  (keepC  * dc(:,t+1)) * ...
                  (1 - keepGf); % end decom delta c
        % compute delta f, decomposed
        df(:,t) = dc(:,t) .* ...
                  (keepC  * c(:,t-1)) .* ...
                  (keepGf * (f(:,t) .* (1 - f(:,t)))) + ...
                  dc(:,t) .* ...
                  (keepC  * c(:,t-1)) .* ...
                  (1 - keepGf); % end decom delta f
        % compute delta i, decomposed
        di(:,t) = dc(:,t) .* z(:,t) .* ...
                  (keepGi * (i(:,t) .* (1 - i(:,t)))); % end decom di
        % compute delta z, decomposed
        dz(:,t) = dc(:,t) .* sech(nz(:,t)).^2 .* ...
                  (keepGi * i(:,t)) + ...
                  dc(:,t) .* sech(nz(:,t)).^2 .* ...
                  (1 - keepGi); % end dcom delta z
        
    end % end backward propagation through time
    
    % zero all change matices and vectors
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
    
    % compute weight updates
    for t = 1:sL-1
        % for forward weights
        dWz = dWz + dz(:,t) * x(:,t)';
        dWi = dWi + di(:,t) * x(:,t)';
        dWf = dWf + df(:,t) * x(:,t)';
        dWo = dWo + do(:,t) * x(:,t)';
        dWu = dWu + du(:,t) * y(:,t)';
        % for recurrent weights
        dRz = dRz + dz(:,t+1) * y(:,t)';
        dRi = dRi + di(:,t+1) * y(:,t)';
        dRf = dRf + df(:,t+1) * y(:,t)';
        dRo = dRo + do(:,t+1) * y(:,t)';
        % for peepholes
        dPi = dPi + c(:,t) .* di(:,t+1);
        dPf = dPf + c(:,t) .* df(:,t+1);
        dPo = dPo + c(:,t) .* do(:,t);
        % for biases
        dbz = dbz + dz(:,t);
        dbi = dbi + di(:,t);
        dbf = dbf + df(:,t);
        dbo = dbo + do(:,t);
        dbu = dbu + du(:,t);
    end
    
    % apply updates
    % for forward weights
    Wz = Wz + a*dWz + m*pWz;
    Wi = Wi + a*dWi + m*pWi;
    Wf = Wf + a*dWf + m*pWf;
    Wo = Wo + a*dWo + m*pWo;
    Wu = Wu + a*dWu + m*pWu;
    % for recurrent weights
    Rz = Rz + a*dRz + m*pRz;
    Ri = Ri + a*dRi + m*pRi;
    Rf = Rf + a*dRf + m*pRf;
    Ro = Ro + a*dRo + m*pRo;
    % for peepholes
    Pi = Pi + a*dPi + m*pPi;
    Pf = Pf + a*dPf + m*pPf;
    Po = Po + a*dPo + m*pPo;
    % for biases
    bz = bz + a*dbz + m*pbz;
    bi = bi + a*dbi + m*pbi;
    bf = bf + a*dbf + m*pbf;
    bo = bo + a*dbo + m*pbo;
    bu = bu + a*dbu + m*pbu;
    
    % save weigth changes
    % for forward weights
    pWz = dWz;
    pWi = dWi;
    pWf = dWf;
    pWo = dWo;
    pWu = dWu;
    % for recurrent weights
    pRz = dRz;
    pRi = dRi;
    pRf = dRf;
    pRo = dRo;
    % for peepholes
    pPi = dPi;
    pPf = dPf;
    pPo = dPo;
    % for biases
    pbz = dbz;
    pbi = dbi;
    pbf = dbf;
    pbo = dbo;
    pbu = dbu;
    
    % rescale learning rate
    a = a * aScale;
    % m = 1 - a;
    % a = aFix;
    % m = mFix;
        
end % end training iteration

% report elapsed time
% *** comment OUT for GA or Job ***
% toc

