function EEG = compute_ersp_new2(EEG,settings)
% Assumes that each epoch corresponds to a full gait cycle.
% The epoch starts and ends with a right final contact (R_FC). 
% The epoch is baseline corrected by the mean power of the EEG resting
% state or the mean power over all the gait cycles

if settings.eeg.ersp.do_laplacian
    load(settings.eeg.preprocessing.lapmask)
    data = (EEG.data')*mask;
    EEG.data = data';
end

% Extract epochs
winlen = settings.eeg.ersp.winlen;
triggers = EEG.other.imu.triggers.event;
[data_epoch, trig_epoch] = extractstepcycles(EEG.data',triggers,settings);
data_epoch_adj = adjustStepEpochs(EEG.data', trig_epoch, winlen, EEG.srate);

g.Fs = EEG.srate;
g.winsize = winlen*EEG.srate;
g.freqs = settings.eeg.ersp.freqs;
g.nfreqs = [];
g.padratio = floor(settings.eeg.ersp.padratio*EEG.srate);
g.baseline = [];

% Compute baseline spectrum from resting state EEG
% ref_EEG = pop_select(EEG.other.resting, 'channel', {EEG.chanlocs.labels});
% ref_EEG = clean_windows(ref_EEG, 0.05);
% ref_EEG = compute_cca(ref_EEG, settings);
% if settings.eeg.ersp.do_laplacian
%     load(settings.eeg.preprocessing.lapmask)
%     data = (ref_EEG.data')*mask;
%     ref_EEG.data = data';
% end
% g.ntimesout = [];
% Pref = [];
% dispstat('','init'); % One time only initialization
% dispstat(sprintf('Computing baseline spectrum...'),'keepthis');
% for c = 1:18%ref_EEG.nbchan
%     dispstat(sprintf('    - Processing %d/%d - CHANNEL %s', c, ref_EEG.nbchan, ref_EEG.chanlocs(c).labels));
%     [Ptmp, freqs] = proc_basln_spectrum((ref_EEG.data(c,:))', g); % [frqs, 1]
%     Pref = [Pref, Ptmp]; % [frqs, chans]
% end
% dispstat('\n','keepprev');

% Assumes the left final contact (L_FC) to be at 50% of the gait cycle.
% ntrigs = size(trig_epoch{1},1);
% trig_mat = cell2mat(trig_epoch);
% trig_rep = reshape(trig_mat(:,2), [ntrigs size(trig_mat,1)/ntrigs]);
% g.warptrigs = trig_rep([1 3 5],:)';

% Compute walking-related spectral perturbation
dispstat(sprintf('Computing walking ERSP...'),'keepthis');
ERSP = [];
POWER = [];
mbase = [];
g.ntimesout = 1000;
g.basetype = 'mean'; % 'mean', 'powbase', 'baseln', 'none'
for c = 1:EEG.nbchan
    dispstat(sprintf('    - Processing %d/%d - CHANNEL %s', c, EEG.nbchan, EEG.chanlocs(c).labels));
    data_epoch_chan = extractchan(data_epoch_adj, c);
%     [c_ersp, times, freqs] = timef_ersp_warp(data_epoch_chan, Pref(:,c), g);
[c_ersp, times, freqs, c_mbase, c_power] = timef_ersp_warp(data_epoch_chan, [], g);
    ERSP = cat(3, ERSP, c_ersp); % [frqs, smps, chans]
    POWER = cat(3, POWER, c_power); % [frqs, smps, chans]
    mbase = cat(2, mbase, c_mbase); % [frqs, chans]
end
EEG.other.ersp.stepcycle.data = permute(ERSP, [3 2 1]); % [chans, smps, frqs]
EEG.other.ersp.stepcycle.mbase = mbase'; % [chans, frqs]
EEG.other.ersp.stepcycle.power = permute(POWER, [3 2 1]); % [chans, smps, frqs]
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
