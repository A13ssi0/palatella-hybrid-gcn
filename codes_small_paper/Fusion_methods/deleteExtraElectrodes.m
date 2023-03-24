function eeg = deleteExtraElectrodes(eeg,pathIdx)

load(pathIdx)

for i = 1:length(eeg)
    teeg = eeg{i};
    eeg{i} = teeg(idxFinal,:,:,:);
end