function Trials = extract_trials(data, events, limits, SampleRate, labelset)
% This function extract the data belonging to each trials inside the struct events defined by labelset.
% The data for each trial are extracted in a time window defined by limits (in seconds).
% If no limits are provided, the trials are extracted from the time 0 of each trial and the minimum trial duration
% If no labelset is provided, all the labels included in events.TYP are used to extract the trials.
% The first dimension of the matrix data has to contain the number of samples.

if(nargin < 2)
    error('[extract_trials] Not enough input arguments!\n');
end
if(nargin < 3)
    limits = [];
end
if(nargin < 4)
    SampleRate = 1000; % Hz
end
if(nargin < 5)
    labelset = unique(events.TYP);
end

lower_limit = 0;
upper_limit = 0;
if ~isempty(limits)
    if length(limits)==2
        if limits(1)>limits(2)
            error('[extract_trials] Requested trial begin must be lower than requested trial end!\n');
        else
            lower_limit = floor(limits(1)*SampleRate); % from seconds to samples
        end
        if limits(2)>0
            upper_limit = floor(limits(2)*SampleRate); % from seconds to samples
        else
            error('[extract_trials] Trial end must be greater than zero!\n');
        end
    else
        error('[extract_trials] Unexpected limits size! Limits must be empty or an array with length two\n');
    end
end

nsamples = size(data, 1);
ndim = ndims(data);
ncolons = repmat({':'},1,ndim-1);
[Ck, Tk, TrialStart, TrialDur, CueLb, ntrials] = extract_labels( events, nsamples, labelset );

% Extracting data for each trial
disp('[extract_trials] Extracting data for each trial');
MinTrialDur = min(TrialDur);
if ~isempty(limits) && upper_limit < MinTrialDur
    MinTrialDur = upper_limit;
else
    upper_limit = MinTrialDur;
end

TrialData   = [];
TrialFullLabel = [];
for trId = 1:ntrials
    cstart = TrialStart(trId) + lower_limit;
    cstop  = cstart - lower_limit + MinTrialDur - 1;
    TrialData = cat(ndim+1,TrialData, data(cstart:cstop, ncolons{:}));
    TrialFullLabel = cat(2,TrialFullLabel, Ck(cstart:cstop));
end

Trials.labels = Ck;
Trials.number = Tk;
Trials.start = TrialStart;
Trials.dur = TrialDur;
Trials.sample_limits = [lower_limit upper_limit];
Trials.time_limits = [lower_limit/SampleRate upper_limit/SampleRate];
Trials.trialData = TrialData;
Trials.trialLabel = CueLb;
Trials.trialFullLabel = TrialFullLabel;

end