function EEG = compute_preprocessing(EEG,settings)

%% Take channels subset
if ~isempty(settings.eeg.preprocessing.channelSubset)
    EEG = pop_select(EEG, 'channel', settings.eeg.preprocessing.channelSubset);
elseif ~isempty(settings.eeg.preprocessing.channelRemove)
    i_rm = fidx(settings.eeg.preprocessing.channelRemove,{EEG.chanlocs.labels});
    channelSubset = {EEG.chanlocs.labels}; channelSubset(i_rm) = [];
    EEG = pop_select(EEG, 'channel', channelSubset);
end

%% Remove trend
[EEG, detrendOut] = removeTrend(EEG);

%% Remove line noise
% lineNoiseIn = struct('lineNoiseChannels', [1:62],...
%     'Fs', settings.eeg.fs, ...
%     'lineFrequencies', [50], ...
%     'p', 0.01,...
%     'fScanBandWidth', 2,...
%     'taperWindowSize', 4,...
%     'taperBandWidth', 2,...
%     'taperWindowStep', 1,...
%     'tau', 100,...
%     'pad', 0,...
%     'fPassBand', [0 settings.eeg.fs/2],...
%     'maximumIterations', 5);
% [EEG, lineNoiseOut] = cleanLineNoise(EEG, lineNoiseIn);
wo = settings.eeg.preprocessing.notch.fcutoff/(settings.eeg.fs/2);  
bw = wo/settings.eeg.preprocessing.notch.bw;
[b_n,a_n] = iirnotch(wo,bw);
EEG1 = EEG.data';
EEG.data = (filtfilt(b_n,a_n,EEG1))';
    
%% Robust re-referencing
if strcmp(settings.eeg.preprocessing.reference, 'robust')
    [EEG, referenceOut] = performReference(EEG);
elseif strcmp(settings.eeg.preprocessing.reference, 'car')
    EEG.data = filter_car(EEG.data,1);
elseif strcmp(settings.eeg.preprocessing.reference, 'laplacian')
    load(settings.eeg.preprocessing.lapmask)
    data = (EEG.data')*mask;
    EEG.data = data';
elseif strcmp(settings.eeg.preprocessing.reference, 'no')
else
    error('[compute_preprocessing] Unknown referencing method!')
end

%% BP filter
order = settings.eeg.preprocessing.filter.LP.order;
fcutoff = settings.eeg.preprocessing.filter.LP.fcutoff;
[b_l,a_l] = butter(order, fcutoff*2/settings.eeg.fs, 'low');
EEG1 = EEG.data';
EEG.data = (filtfilt(b_l,a_l,EEG1))';

order = settings.eeg.preprocessing.filter.HP.order;
fcutoff = settings.eeg.preprocessing.filter.HP.fcutoff;
[b_h,a_h] = butter(order, fcutoff*2/settings.eeg.fs, 'high');
EEG1 = EEG.data';
EEG.data = (filtfilt(b_h,a_h,EEG1))';


end

