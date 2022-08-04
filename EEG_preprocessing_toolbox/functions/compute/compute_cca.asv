function EEG = compute_cca(EEG, settings)

% Parameters
windowlen = settings.eeg.cca.window_length; % [sec]
windowshift = settings.eeg.cca.window_shift; % [%]

bss_opt = {'eigratio',settings.eeg.cca.eigratio};
emg_opt = {'femg',settings.eeg.cca.femg,'ratio',settings.eeg.cca.ratio,'fs',settings.eeg.fs,'range',settings.eeg.cca.range};

EEG = pop_autobssemg(EEG,windowlen,windowshift,'bsscca',bss_opt,'emg_psd',emg_opt);

end

