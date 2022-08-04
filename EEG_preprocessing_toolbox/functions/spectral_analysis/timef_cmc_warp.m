function [COH, times, freqs, IMC, wPLI, Sxx, Syy, Sxy] = timef_cmc_warp(DataX, DataY, g)

if ~iscell(DataX)
    % Assumes Data in the form [samples x trials]
    DataX = mat2cell(DataX', ones(1, size(DataX,2)));
end
if ~iscell(DataY)
    % Assumes Data in the form [samples x trials]
    DataY = mat2cell(DataY', ones(1, size(DataY,2)));
end
if length(DataX) ~= length(DataY)
    error('[timef_cmc_warp] Wrong number of trials between Data1 and Data2!')
end
g.trials = length(DataX);

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

Pxx = cell(g.trials,1); Pyy = cell(g.trials,1); Pxy = cell(g.trials,1);
for t = 1:g.trials
    data1 = (DataX{t})'; data2 = (DataY{t})';
    if length(data1) ~= length(data2), error('[timef_cmc_warp] Trials of Data1 and Data2 have different number of frames!'), end
    frames = length(data1);
    ntimesout = frames - g.winsize;
    [ timesout, indexout ] = gettimes(frames, [0 frames/g.Fs-1/g.Fs].*1000, g.winsize, ntimesout, 'off');
    indices = repmat([-g.winsize/2+1:g.winsize/2]', [1 length(indexout)]);
    indices = indices + repmat(indexout, [size(indices,1) 1]);
    
    tmpX = data1(indices);
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
    
    tmpY = data2(indices);
    tmpY = bsxfun(@minus, tmpY, mean( tmpY, 1)); % avoids repmat - faster than tmpX = tmpX - repmat(mean(tmpX), [size(tmpX,1) 1]);
    tmpY = bsxfun(@times, tmpY, g.win);
    tmpY = fft(tmpY,g.padratio*g.winsize);
    alltfY = tmpY(2:g.padratio*g.winsize/2+1,:);
    zerovals = alltfY == 0;
    if any(reshape(zerovals, 1, prod(size(zerovals))))
        alltfY(zerovals) = Inf;
        minval = min(alltfY(:)); % remove bug
        alltfY(zerovals) = minval;
    end    
    alltfY = alltfY(freqidx,:);
    alltfY = 2/0.375*alltfY/g.winsize; % normalization, divide by g.winsize
    
    Pxx{t}  = alltfX.*conj(alltfX); % power
    Pyy{t}  = alltfY.*conj(alltfY); % power
    Pxy{t} = alltfX.*conj(alltfY); % power
    
end

% Time-warping each trial
% -------------------------
Sxx = nan(length(freqs),g.ntimesout,g.trials);
Syy = nan(length(freqs),g.ntimesout,g.trials);
Sxy = nan(length(freqs),g.ntimesout,g.trials);
if ~isfield(g, 'warptrigs')
    for t = 1:g.trials        
        % ODD-MIRRORING (avoid edge distortion)
        mirror_len = 100; % mirror length in samples
        Sxx(:,:,t) = resample_withmirror(Pxx{t},g.ntimesout,size(Pxx{t},2),2,mirror_len);
        Syy(:,:,t) = resample_withmirror(Pyy{t},g.ntimesout,size(Pyy{t},2),2,mirror_len);
        Sxy(:,:,t) = resample_withmirror(Pxy{t},g.ntimesout,size(Pxy{t},2),2,mirror_len);
    end
else
%     ntrigs = size(g.warptrigs,2);
%     if ~isfield(g, 'warpperc')
%         g.warpperc = linspace(0, 100, ntrigs);
%     end
%     warpout = normalize(g.warpperc,'range',[0 g.ntimesout]);
%     for t = 1:g.trials
%         trigtmp = g.warptrigs(t,:)-g.warptrigs(t,1); 
%         for i = 1:ntrigs-1
%             Ptmp = P{t}(:,trigtmp(i)+1:trigtmp(i+1));
%             Pr(:,warpout(i)+1:warpout(i+1),t) = resample(Ptmp,length(warpout(i)+1:warpout(i+1)),size(Ptmp,2),'Dimension',2);   
%         end
%     end
    error('NOT WORKING YET!')
end
g.timesout = 100/g.ntimesout:100/g.ntimesout:100;
times = g.timesout;

% compute phase lag index (PLI)
wPLI = abs(sum(imag(Sxy),3)./sum(abs(imag(Sxy)),3));

% compute CMC
% -----------------
Sxx = mean(Sxx, 3);
Syy = mean(Syy, 3);
Sxy = mean(Sxy, 3);

COH = abs(Sxy)./sqrt(Sxx.*Syy);
C = Sxy./sqrt(Sxx.*Syy);
IMC = abs(imag(C));

% for debug
% figure
% subplot(3,1,1)
% % imagesc([0 100],[g.freqs(1) g.freqs(2)],COH,[0 0.5])
% imagesc(COH,[0 0.3])
% title('CMC'), xlabel('Gait cycle [%]'), ylabel('Frequencies [Hz]')
% subplot(3,1,2)
% % imagesc([0 100],[g.freqs(1) g.freqs(2)],IMC,[0 0.5])
% imagesc(IMC,[0 0.3])
% title('IMC'), xlabel('Gait cycle [%]'), ylabel('Frequencies [Hz]')
% subplot(3,1,3)
% % imagesc([0 100],[g.freqs(1) g.freqs(2)],wPLI,[0 0.5])
% imagesc(wPLI,[0 0.3])
% title('wPLI'), xlabel('Gait cycle [%]'), ylabel('Frequencies [Hz]')

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
