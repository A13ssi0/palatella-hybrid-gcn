function EEG = compute_cmc(EEG,settings)
% Assumes that each epoch corresponds to a full gait cycle.
% The epoch starts and ends with a right final contact (R_FC).

if settings.eeg.ersp.do_laplacian
    load(settings.eeg.preprocessing.lapmask)
    data = (EEG.data')*mask;
    EEG.data = data';
end

% EMG BP filter
% order = settings.emg.preprocessing.filter.LP.order;
% fcutoff = settings.emg.preprocessing.filter.LP.fcutoff;
% [b_l,a_l] = butter(order, fcutoff*2/settings.emg.fs, 'low');
% EEG.other.emg.data = (filtfilt(b_l,a_l,EEG.other.emg.data));

order = settings.emg.preprocessing.filter.HP.order;
fcutoff = settings.emg.preprocessing.filter.HP.fcutoff;
% fcutoff = 10;
[b_h,a_h] = butter(order, fcutoff*2/settings.emg.fs, 'high');
EEG.other.emg.data = (filtfilt(b_h,a_h,EEG.other.emg.data));
EEG.other.emg.nbemg = size(EEG.other.emg.data, 2);

h_emg = hilbert(EEG.other.emg.data);
% theta = atan(imag(h_emg)./real(h_emg));
% dem_emg = cos(theta);
EEG.other.emg.data = abs(h_emg);
% EEG.other.emg.data = dem_emg;

% Extract epochs
winlen = settings.eegemg.cmc.winlen;
triggers = EEG.other.imu.triggers.event;
[data_epoch, trig_epoch] = extractstepcycles(EEG.data',triggers,settings);
eeg_epoch_adj = adjustStepEpochs(EEG.data', trig_epoch, winlen, EEG.srate);
emg_epoch_adj = adjustStepEpochs(EEG.other.emg.data, trig_epoch, winlen, EEG.other.emg.srate);

g.Fs = EEG.srate;
g.winsize = winlen*EEG.srate;
g.freqs = settings.eegemg.cmc.freqs;
g.nfreqs = 2*(g.freqs(2)-g.freqs(1)+1);
g.padratio = floor(settings.eeg.ersp.padratio*EEG.srate);
g.ntimesout = 1000;

% Compute walking-related spectral perturbation
dispstat(sprintf('Computing walking ERSP...'),'keepthis');
CMC = nan(g.nfreqs,g.ntimesout,EEG.nbchan,EEG.other.emg.nbemg);
IMC = nan(g.nfreqs,g.ntimesout,EEG.nbchan,EEG.other.emg.nbemg);
wPLI = nan(g.nfreqs,g.ntimesout,EEG.nbchan,EEG.other.emg.nbemg);
EEG_pow = nan(g.nfreqs,g.ntimesout,EEG.nbchan);
EMG_pow = nan(g.nfreqs,g.ntimesout,EEG.other.emg.nbemg);
crosspow = nan(g.nfreqs,g.ntimesout,EEG.nbchan,EEG.other.emg.nbemg);
for c = 1:EEG.nbchan
    eeg_epoch_chan = extractchan(eeg_epoch_adj, c);
    for m = 1:EEG.other.emg.nbemg
        dispstat(sprintf('    - Processing EEG %s (%d/%d) - EMG %s (%d/%d)', ...
            EEG.chanlocs(c).labels, c, EEG.nbchan, EEG.other.emg.label{m}, m, EEG.other.emg.nbemg));
        emg_epoch_chan = extractchan(emg_epoch_adj, m);
        [cm_cmc, times, freqs, cm_imc, cm_pli, c_pow, m_pow, cm_pow] = timef_cmc_warp(eeg_epoch_chan, emg_epoch_chan, g);
        
        % to debug
%         sgtitle(sprintf('EEG %s - EMG %s', EEG.chanlocs(c).labels, EEG.other.emg.label{m}))
        % ----
        
        CMC(:,:,c,m) = cm_cmc; % [frqs, smps, chans, mscls]
        IMC(:,:,c,m) = cm_imc; % [frqs, smps, chans, mscls]
        wPLI(:,:,c,m) = cm_pli; % [frqs, smps, chans, mscls]
        crosspow(:,:,c,m) = cm_pow; % [frqs, smps, chans, mscls]
        EMG_pow(:,:,m) = m_pow; % [frqs, smps, mscls]
    end
    EEG_pow(:,:,c) = c_pow; % [frqs, smps, chans]
end
EEG.other.cmc.stepcycle.data = CMC; % [frqs, smps, chans, mscls]
EEG.other.cmc.stepcycle.IMC = IMC; % [frqs, smps, chans, mscls]
EEG.other.cmc.stepcycle.wPLI = wPLI; % [frqs, smps, chans, mscls]
EEG.other.cmc.stepcycle.eeg_pow = EEG_pow; % [frqs, smps, chans]
EEG.other.cmc.stepcycle.emg_pow = EMG_pow; % [frqs, smps, mscls]
EEG.other.cmc.stepcycle.crosspow = crosspow; % [frqs, smps, chans, mscls]
dispstat('Done.','keepprev');

EEG.data = data_epoch;
EEG.trials = length(data_epoch);
EEG.other.imu.triggers.trig_epoch = trig_epoch;
EEG.times = times;
EEG.frequencies = freqs;

end

%%
function [ data_epoch_adj ] = adjustStepEpochs(data, trig_epoch, winlen, srate)
% data must have samples in the first dimension
ndim = ndims(data);
ncolons = repmat({':'},1,ndim-1);
ntrials = length(trig_epoch);

data_epoch_adj = cell(ntrials,1);
for t = 1:ntrials
    tstart = trig_epoch{t}(1,2)-winlen/2*srate;
    tstop = trig_epoch{t}(end,2)+winlen/2*srate;
    data_epoch_adj{t} = data(tstart:tstop, ncolons{:});
end

end

function data_epoch_chan = extractchan(data_epoch, chan)

data_epoch_chan = cell(size(data_epoch));
for t = 1:length(data_epoch)
    data_epoch_chan{t} = data_epoch{t}(:,chan);
end

end
