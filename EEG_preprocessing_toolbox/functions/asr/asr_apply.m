function cleandata = asr_apply(data,fs, state, windowlen, lookahead, stepsize)

% extrapolate last few samples of the signal
sig = [data bsxfun(@minus,2*data(:,end),data(:,(end-1):-1:end-round(windowlen/2*fs)))];

% process signal using ASR
[cleandata, state] = asr_process(sig, fs, state, windowlen, lookahead, stepsize);

% shift signal content back (to compensate for processing delay)
cleandata(:,1:size(state.carry,2)) = [];

end

