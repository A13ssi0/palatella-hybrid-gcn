function [P, times, freqs] = timef_ersp(Data,g)

g.frames = size(Data, 1);
g.trials = size(Data, 2);

% test argument consistency
% --------------------------
if g.tlimits(2)-g.tlimits(1) < 30
    warning('WARNING: Specified time range is very small (< 30 ms)???');
    warning('                     Epoch time limits should be in msec, not seconds!');
end

if (g.winsize > g.frames)
    error('Value of winsize must be smaller than epoch frames.');
end

if length(g.ntimesout) == 1 && g.ntimesout > 0
    if g.ntimesout > g.frames-g.winsize
        g.ntimesout = g.frames-g.winsize;
        disp(['Value of timesout must be <= frames-winsize, timeout adjusted to ' int2str(g.ntimesout) ]);
    end
else
    g.ntimesout = g.frames-g.winsize;
end

if (pow2(nextpow2(g.padratio)) ~= g.padratio)
    error('Value of padratio must be an integer power of two [1,2,4,8,16,...]');
end

if (g.freqs(2) > g.Fs/2)
    warning(['Warning: value of maxfreq reduced to Nyquist rate' ...
        ' (%3.2f)\n\n'], g.Fs/2);
    g.freqs(2) = g.Fs/2;
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

[ g.timesout, g.indexout ] = gettimes(g.frames, g.tlimits, g.winsize, g.ntimesout, 'off');

% build large matrix to compute FFT
% ---------------------------------
indices = repmat([-g.winsize/2+1:g.winsize/2]', [1 length(g.indexout) g.trials]);
indices = indices + repmat(g.indexout, [size(indices,1) 1 g.trials]);
indices = indices + repmat(reshape(([1:g.trials]-1)*g.frames,1,1,g.trials), [size(indices,1) length(g.indexout) 1]);
alltfX = repmat(nan,[length(freqs) length(g.timesout) g.trials]);
tmpX    = Data(indices);
tmpX = bsxfun(@minus, tmpX, mean( tmpX, 1)); % avoids repmat - faster than tmpX = tmpX - repmat(mean(tmpX), [size(tmpX,1) 1 1]);
tmpX = bsxfun(@times, tmpX, g.win);
tmpX = fft(tmpX,g.padratio*g.winsize);
alltfX = tmpX(2:g.padratio*g.winsize/2+1,:,:);

zerovals = alltfX == 0;
if any(reshape(zerovals, 1, prod(size(zerovals))))
    alltfX(zerovals) = Inf;
    minval = min(alltfX(:)); % remove bug
    alltfX(zerovals) = minval;
end

% find closest output frequencies
% -------------------------------
if length(g.freqs) ~= length(freqs) || any(g.freqs ~= freqs)
    allindices = zeros(1,length(g.freqs));
    for index = 1:length(g.freqs)
        [dum ind] = min(abs(freqs-g.freqs(index)));
        allindices(index) = ind;
    end
    freqs = freqs(allindices);
    alltfX = alltfX(allindices,:,:);
end

alltfX = 2/0.375*alltfX/g.winsize; % normalization, divide by g.winsize
P  = alltfX.*conj(alltfX); % power

% baseline normalization
% -------------------------
baseln = [];
for index = 1:size(g.baseline,1)
    tmptime   = find(g.timesout >= g.baseline(index,1) & g.timesout <= g.baseline(index,2));
    baseln = union_bc(baseln, tmptime);
end
if length(baseln)==0
    error( [ 'There are no sample points found in the default baseline.' 10 ...
        'This may happen even though data time limits overlap with' 10 ...
        'the baseline period (because of the time-freq. window width).' 10 ...
        'Either disable the baseline, change the baseline limits.' ] );
end
baselength    = length(baseln);
Pmean  = mean(P, 3);
mbase = mean(Pmean(:,baseln),2);
mstd  = std(Pmean(:,baseln),[],2);
P = bsxfun(@rdivide, P, mbase);

% average the power
% -----------------
PA = P;
P = mean(P, 3);
if ~isnan( g.baseline(1) ) && ~isnan( mbase(1) ) && strcmpi(g.trialbase, 'off'), mbase = log10(mbase)*10; end
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

