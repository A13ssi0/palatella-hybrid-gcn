function EEG = reduce_dataset(EEG, settings)

% Parameters
fs = settings.eeg.fs;
del = settings.begin_delay*fs;

EEG.data = EEG.data(:, del:end);
EEG.pnts = size(EEG.data, 2);
EEG.xmin = settings.begin_delay;
EEG.times = EEG.time(del:end);


end

