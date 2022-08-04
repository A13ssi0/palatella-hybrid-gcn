function EEG = compute_erds(EEG,settings)

EEG.other.eeg = rmfield(EEG, 'other');

if settings.eeg.erds.do_laplacian
    load(settings.eeg.preprocessing.lapmask)
    data = (EEG.data')*mask;
    EEG.data = data';
end

switch settings.eeg.erds.method
    case 'bandpower'
        % Compute BP
        [p_data, f_vec] = ERDS_computeBP(double(EEG.data'),settings.eeg.fs,settings.eeg.erds.bandpower);
        % [smps, frqs, chans]
    case 'psd'
        mlength = settings.eeg.erds.psd.mlength;
        wlength = settings.eeg.erds.psd.wlength;
        pshift = settings.eeg.erds.psd.pshift;
        wshift = settings.eeg.erds.psd.wshift;
        [p_data, f_vec] = proc_spectrogram(double(EEG.data'), wlength, wshift, pshift, settings.eeg.fs, mlength);
        idfreqs = f_vec >= settings.eeg.erds.psd.f_range(1) & ...
            f_vec <= settings.eeg.erds.psd.f_range(2);
        f_vec = f_vec(idfreqs);
        p_data = p_data(:, idfreqs, :);
        EEG.other.imu.triggers.event.pos = proc_pos2win(EEG.other.imu.triggers.event.pos, wshift*settings.eeg.fs, 'backward', mlength*settings.eeg.fs);
        EEG.srate = 1/wshift;
end

% Extract epochs
% epoch = settings.step_epoch;
epoch = settings.eeg.erds.step_epoch;
triggers = EEG.other.imu.triggers.event;
data_epoch = extractepochs(p_data,triggers,[settings.leg.L.label settings.leg.R.label],epoch,EEG.srate);
% [smps, frqs, chans, trials]

EEG.data = permute(data_epoch, [3 1 4 2]); % [chans, smps, trls, frqs]
EEG.trials = size(EEG.data,3);
EEG.xmin = epoch(1);
EEG.xmax = epoch(2)-1/EEG.srate;
EEG.pnts = size(EEG.data,2);
EEG.times = (EEG.xmin:1/EEG.srate:EEG.xmax).*1000;
EEG.frequencies = f_vec;

% Compute ERDS
data_trig = permute(EEG.data, [2 4 1 3]); % [smps, frqs, chans, trls] 
[ERDS,ES,ES2] = ERDS_computeERDS(data_trig,EEG.times./1000,settings.eeg.erds.t_ref,settings.eeg.erds.exclude_baseline);
EEG.data = permute(ERDS, [3 1 4 2]); % [chans, smps, trls, frqs]
EEG.other.es.median = permute(ES, [3 1 4 2]);
EEG.other.es.mean = permute(ES2, [3 1 4 2]);

if settings.eeg.erds.exclude_baseline
    EEG.xmin = settings.eeg.erds.t_ref(2)+1/EEG.srate;
    EEG.xmax = epoch(2)-1/EEG.srate;
    EEG.pnts = size(EEG.data,2);
    EEG.times = (EEG.xmin:1/EEG.srate:EEG.xmax).*1000;
end

end

