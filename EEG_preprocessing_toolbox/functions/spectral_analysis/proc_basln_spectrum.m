function [Pmean, freqs] = proc_basln_spectrum(Data, g)

g.frames = size(Data, 1);

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

if isempty(g.ntimesout) || isnan(g.ntimesout)
    ntimesout = g.frames - g.winsize;
else
    ntimesout = g.ntimesout;
end
[ g.timesout, g.indexout ] = gettimes(g.frames, [0 g.frames/g.Fs-1/g.Fs].*1000, g.winsize, ntimesout, 'off');

% build large matrix to compute FFT
% ---------------------------------
indices = repmat([-g.winsize/2+1:g.winsize/2]', [1 length(g.indexout)]);
indices = indices + repmat(g.indexout, [size(indices,1) 1]);
tmpX = Data(indices);
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
P  = alltfX.*conj(alltfX); % power
Pmean = squeeze(mean(P,2));

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
