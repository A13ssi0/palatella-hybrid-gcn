function [P, times, freqs, mbase, PA] = timef_ersp_warp(Data, powbase, g)

if ~iscell(Data)
    % Assumes Data in the form [samples x trials]
    Data = mat2cell(Data', ones(1, size(Data,2)));
end
g.trials = length(Data);

% test argument consistency
% --------------------------
if ~isempty(g.padratio)
    if (pow2(nextpow2(g.padratio)) ~= g.padratio)
        error('Value of padratio must be an integer power of two [1,2,4,8,16,...]');
    end
else
    g.padratio = 2;
end

if (g.freqs(2) > g.Fs/2)
    warning(['Warning: value of maxfreq reduced to Nyquist rate' ...
        ' (%3.2f)\n\n'], g.Fs/2);
    g.freqs(2) = g.Fs/2;
end

if ~isfield(g, 'basetype')
    error('[timef_ersp_warp] The type of baseline correction is not defined!')
end
if strcmp(g.basetype, 'powbase') && isempty(powbase)
    error('[timef_ersp_warp] No powbase is provided for the required baseline correction!')
end
if strcmp(g.basetype, 'baseln') && isempty(g.baseline)
    error('[timef_ersp_warp] No baseline period is provided for the required baseline correction!')
end

% default number of freqs using padratio
% --------------------------------------
if isempty(g.nfreqs)
    g.nfreqs = g.winsize/2*g.padratio+1;
    % adjust nfreqs depending on frequency range
    tmpfreqs = linspace(0, g.Fs/2, g.nfreqs);
    tmpfreqs = tmpfreqs(2:end);  % remove DC (match the output of PSD)
    
    % adjust limits for FFT (only linear scale)
    if ~any(tmpfreqs == g.freqs(1))
        [tmp minind] = min(abs(tmpfreqs-g.freqs(1)));
        g.freqs(1)   = tmpfreqs(minind);
        %fprintf('Adjust min freq. to %3.2f Hz to match FFT output frequencies\n', g.freqs(1));
    end
    if ~any(tmpfreqs == g.freqs(2))
        [tmp minind] = min(abs(tmpfreqs-g.freqs(2)));
        g.freqs(2)   = tmpfreqs(minind);
        %fprintf('Adjust max freq. to %3.2f Hz to match FFT output frequencies\n', g.freqs(2));
    end
    
    % find number of frequencies
    % --------------------------
    g.nfreqs = length(tmpfreqs( intersect( find(tmpfreqs >= g.freqs(1)), find(tmpfreqs <= g.freqs(2)))));
    if g.freqs(1)==g.freqs(2), g.nfreqs = 1; end
end

% find closest freqs for FFT
% --------------------------
g.freqs = linspace(g.freqs(1), g.freqs(2), g.nfreqs); % this should be OK for FFT
% because of the limit adjustment
g.nfreqs = length(g.freqs);

freqs = linspace(0, g.Fs/2, g.winsize*g.padratio/2+1);
freqs = freqs(2:end); % remove DC (match the output of PSD)
g.win = hanning(g.winsize);

% find closest output frequencies
% -------------------------------
if length(g.freqs) ~= length(freqs) || any(g.freqs ~= freqs)
    freqidx = zeros(1,length(g.freqs));
    for index = 1:length(g.freqs)
        [dum ind] = min(abs(freqs-g.freqs(index)));
        freqidx(index) = ind;
    end
    freqs = freqs(freqidx);
end

P = cell(g.trials,1);
trbase = [];
for t = 1:g.trials
    data = (Data{t})';
    frames = length(data);
    ntimesout = frames - g.winsize;
    [ timesout, indexout ] = gettimes(frames, [0 frames/g.Fs-1/g.Fs].*1000, g.winsize, ntimesout, 'off');
    indices = repmat([-g.winsize/2+1:g.winsize/2]', [1 length(indexout)]);
    indices = indices + repmat(indexout, [size(indices,1) 1]);
    tmpX = data(indices);
    tmpX = bsxfun(@minus, tmpX, mean( tmpX, 1)); % avoids repmat - faster than tmpX = tmpX - repmat(mean(tmpX), [size(tmpX,1) 1]);
    tmpX = bsxfun(@times, tmpX, g.win);
    tmpX = fft(tmpX,g.padratio*g.winsize);
    alltfX = tmpX(2:g.padratio*g.winsize/2+1,:);
    
    zerovals = alltfX == 0;
    if any(reshape(zerovals, 1, prod(size(zerovals))))
        alltfX(zerovals) = Inf;
        minval = min(alltfX(:)); % remove bug
        alltfX(zerovals) = minval;
    end
    
    alltfX = alltfX(freqidx,:);
    alltfX = 2/0.375*alltfX/g.winsize; % normalization, divide by g.winsize
    P{t}  = alltfX.*conj(alltfX); % power
    
    % Compute trial-based baseline
    if strcmp(g.basetype, 'baseln') && size(g.baseline,1) > 1
        timesout = [0:1/g.Fs:ntimesout/g.Fs-1/g.Fs].*1000;
        baseln   = find(timesout >= g.baseline(t,1) & timesout <= g.baseline(t,2));
        if length(baseln)==0
            error( [ 'There are no sample points found in the default baseline.' 10 ...
                'This may happen even though data time limits overlap with' 10 ...
                'the baseline period (because of the time-freq. window width).' 10 ...
                'Either disable the baseline, change the baseline limits.' ] );
        end
        trbase = [trbase squeeze(mean(P{t}(:,baseln),2))];
    end
    
end

% Time-warping each trial
% -------------------------
Pr = nan(length(freqs),g.ntimesout,g.trials);
% Pr2 = nan(length(freqs),g.ntimesout,g.trials);
if ~isfield(g, 'warptrigs')
    for t = 1:g.trials
        
        % ODD-MIRRORING (avoid edge distortion)
        % -----------------------------------
        mirror_len = 100; % mirror length in samples
        Pr(:,:,t) = resample_withmirror(P{t},g.ntimesout,size(P{t},2),2,mirror_len);
        % -----------------------------------
        
        %         Pr2(:,:,t) = 10.^resample(log10(P{t}),g.ntimesout,size(P{t},2),'Dimension',2);
%         Pr(:,:,t) = resample(P{t},g.ntimesout,size(P{t},2),'Dimension',2);   
    end
else
    ntrigs = size(g.warptrigs,2);
    if ~isfield(g, 'warpperc')
        g.warpperc = linspace(0, 100, ntrigs);
    end
    warpout = normalize(g.warpperc,'range',[0 g.ntimesout]);
    for t = 1:g.trials
        trigtmp = g.warptrigs(t,:)-g.warptrigs(t,1); 
        for i = 1:ntrigs-1
            Ptmp = P{t}(:,trigtmp(i)+1:trigtmp(i+1));
            Pr(:,warpout(i)+1:warpout(i+1),t) = resample(Ptmp,length(warpout(i)+1:warpout(i+1)),size(Ptmp,2),'Dimension',2);   
        end
    end
end
P = Pr;
P(P<0) = 1e-11;
% clear Pr
g.timesout = 100/g.ntimesout:100/g.ntimesout:100;

% baseline normalization after warping
% -------------------------------------------
if strcmp(g.basetype, 'baseln') && size(g.baseline,1) == 1
    baseln   = find(g.timesout >= g.baseline(1) & g.timesout <= g.baseline(2));
    if length(baseln)==0
        error( [ 'There are no sample points found in the default baseline.' 10 ...
            'This may happen even though data time limits overlap with' 10 ...
            'the baseline period (because of the time-freq. window width).' 10 ...
            'Either disable the baseline, change the baseline limits.' ] );
    end
    Pmean  = trimmean(P, 10, 3);
    mbase = mean(Pmean(:,baseln),2);
elseif strcmp(g.basetype, 'baseln') && size(g.baseline,1) > 1
    mbase = mean(trbase,2);
elseif strcmp(g.basetype, 'mean')
    Pmean = trimmean(P, 10, 3);
    mbase = mean(Pmean,2);
elseif strcmp(g.basetype, 'powbase')
    mbase = powbase;
else
    mbase = [];
end

PA = P;
if ~strcmp(g.basetype, 'none')
    P = bsxfun(@rdivide, P, mbase);
end

% average the power
% -----------------
P = trimmean(P, 10, 3);
PA = trimmean(PA, 10, 3);
% if ~isnan( g.baseline(1) ) && ~isnan( mbase(1) ) && strcmpi(g.trialbase, 'off'), mbase = log10(mbase)*10; end
P = 10 * log10(P);
times = g.timesout;

end

%%
function w = hanning(n)
if ~rem(n,2)
    w = .5*(1 - cos(2*pi*(1:n/2)'/(n+1)));
    w = [w; w(end:-1:1)];
else
    w = .5*(1 - cos(2*pi*(1:(n+1)/2)'/(n+1)));
    w = [w; w(end-1:-1:1)];
end
end

% get time points
% ---------------
function [ timevals, timeindices ] = gettimes(frames, tlimits, winsize, ntimevar, causal)
timevect = linspace(tlimits(1), tlimits(2), frames);
srate    = 1000*(frames-1)/(tlimits(2)-tlimits(1));

if ntimevar(1) > 0
    % generate linearly space vector
    % ------------------------------
    if (ntimevar > frames-winsize)
        ntimevar = frames-winsize;
        if ntimevar < 0
            error('Not enough data points, reduce the window size or lowest frequency');
        end
    end
    npoints = ntimevar(1);
    wintime = 500*winsize/srate;
    if strcmpi(causal, 'on')
        timevals = linspace(tlimits(1)+2*wintime, tlimits(2), npoints);
    else
        timevals = linspace(tlimits(1)+wintime, tlimits(2)-wintime, npoints);
    end
else
    % subsample data
    % --------------
    nsub     = -ntimevar(1);
    if strcmpi(causal, 'on')
        timeindices = [ceil(winsize+nsub):nsub:length(timevect)];
    else
        timeindices = [ceil(winsize/2+nsub/2):nsub:length(timevect)-ceil(winsize/2)-1];
    end
    timevals    = timevect( timeindices );
end

% find closet points in data
% --------------------------
timeindices = round(eeg_lat2point(timevals, 1, srate, tlimits, 1E-3));
if length(timeindices) < length(unique(timeindices))
    timeindices = unique_bc(timeindices);
    warning('Warning: duplicate times, reduce the number of output times\n');
end
timevals    = timevect(timeindices);
end
