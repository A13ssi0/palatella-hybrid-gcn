function EEG = compute_extractepochs(subj)

% Parameters
epoch = subj.settings.step_epoch;
triggers = subj.triggers;
EEG = subj.eeg;
labels = unique(subj.triggers.type);
labels(contains(labels,'rest','IgnoreCase',true)) = [];

data_epoch = extractepochs(EEG.data',triggers,labels,epoch,EEG.srate);

EEG.other.eeg = EEG;
EEG.data = permute(data_epoch, [2 1 3]);
EEG.trials = size(data_epoch,3);
EEG.xmin = epoch(1);
EEG.xmax = epoch(2)-1/EEG.srate;
EEG.pnts = size(EEG.data,2);
% EEG.times = epoch(1):1/EEG.srate:epoch(2)-1/EEG.srate;

end

