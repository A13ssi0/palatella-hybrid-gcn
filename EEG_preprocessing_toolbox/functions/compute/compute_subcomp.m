function EEG = compute_subcomp(EEG,rm_comps,settings)

EEG = pop_subcomp(EEG, rm_comps);
EEG.etc.removed_comps = rm_comps;

% Take channels subset if required
if ~isempty(settings.eeg.ica.channelSubset)
    EEG = pop_select(EEG, 'channel', settings.eeg.ica.channelSubset);
elseif ~isempty(settings.eeg.ica.channelRemove)
    i_rm = fidx(settings.eeg.ica.channelRemove,{EEG.chanlocs.labels});
    channelSubset = {EEG.chanlocs.labels}; channelSubset(i_rm) = [];
    EEG = pop_select(EEG, 'channel', channelSubset);
end


end

