function EEG = compute_ersp_new(EEG,settings)
% Assumes that each epoch corresponds to a full right/left step.
% E.g. for a right step, the epoch contains the events [L_IC, R_FC, R_IC, L_FC]
% The epoch is baseline corrected by the stance phase (e.g., L_IC to R_FC) preceeding
% the step onset (e.g., R_FC).

if settings.eeg.ersp.do_laplacian
    load(settings.eeg.preprocessing.lapmask)
    data = (EEG.data')*mask;
    EEG.data = data';
end

% Extract epochs
winlen = settings.eeg.ersp.winlen;
% epoch = settings.eeg.ersp.step_epoch;
% epoch_adj = [epoch(1)-settings.eeg.ersp.ref_size-winlen/2 epoch(2)+winlen/2];
% tref = [epoch(1)-settings.eeg.ersp.ref_size epoch(1)-1/EEG.srate].*1000; % [ms]
triggers = EEG.other.imu.triggers.event;
[~, trig_epoch, epoch_typ] = extractsteps(EEG.data',triggers,settings);
data_epoch_adj = adjustStepsForErsp(EEG.data', trig_epoch, winlen, EEG.srate);

g.Fs = EEG.srate;
g.winsize = winlen*EEG.srate;
g.freqs = settings.eeg.ersp.freqs;
g.nfreqs = [];
g.padratio = floor(settings.eeg.ersp.padratio*EEG.srate);
g.ntimesout = 1000;
g.basetype = 'baseln';

% Left leg
ersp_type = 'left_leg';
disp(['[compute_ersp] Computing the ERSP for ', strrep(ersp_type, '_', ' ')])
ERSP = [];
left_trials = epoch_typ==settings.leg.L.label;

[avgst, outidx] = avg_stance_perc(trig_epoch(left_trials), 'left', settings);
g.baseline = [0 avgst];

% [bldur, outidx] = baseline_dur(trig_epoch(left_trials), 'left', settings);
% g.baseline = [zeros(sum(left_trials)-sum(outidx),1) bldur(~outidx).*EEG.srate];

dttmp = data_epoch_adj(left_trials); dttmp = dttmp(~outidx);
% dttmp = dttmp(61:end);
for c = 1:EEG.nbchan
    fprintf('CHANNEL %s (%d/%d)\n', EEG.chanlocs(c).labels, c, EEG.nbchan)    
    data_epoch_chan = extractchan(dttmp, c);
    [c_ersp, times, freqs] = timef_ersp_warp(data_epoch_chan, [], g);
    ERSP = cat(3, ERSP, c_ersp); % [frqs, smps, chans]
end
EEG.other.ersp.(ersp_type).data = permute(ERSP, [3 2 1]); % [chans, smps, frqs]
fprintf('\n')

% Right leg
ersp_type = 'right_leg';
disp(['[compute_ersp] Computing the ERSP for ', strrep(ersp_type, '_', ' ')])
ERSP = [];
right_trials = epoch_typ==settings.leg.R.label;

[avgst, outidx] = avg_stance_perc(trig_epoch(right_trials), 'right', settings);
g.baseline = [0 avgst];

% [bldur, outidx] = baseline_dur(trig_epoch(right_trials), 'right', settings);
% g.baseline = [zeros(sum(right_trials)-sum(outidx),1) bldur(~outidx).*EEG.srate];

dttmp = data_epoch_adj(right_trials); dttmp = dttmp(~outidx);
% dttmp = dttmp(61:end);
for c = 1:EEG.nbchan
    fprintf('CHANNEL %s (%d/%d)\n', EEG.chanlocs(c).labels, c, EEG.nbchan)    
    data_epoch_chan = extractchan(dttmp, c);
    [c_ersp, times, freqs] = timef_ersp_warp(data_epoch_chan, [], g);
    ERSP = cat(3, ERSP, c_ersp); % [frqs, smps, chans]
end
EEG.other.ersp.(ersp_type).data = permute(ERSP, [3 2 1]); % [chans, smps, frqs]
fprintf('\n')

EEG.times = times;
EEG.frequencies = freqs;

end

%%
function [ data_epoch_adj ] = adjustStepsForErsp(data, trig_epoch, winlen, srate)
% data must have samples in the first dimension
ndim = ndims(data);
ncolons = repmat({':'},1,ndim-1);
ntrials = length(trig_epoch);

data_epoch_adj = cell(ntrials,1);
for t = 1:ntrials
    tstart = trig_epoch{t}(1,2)-winlen/2*srate;
    tstop = trig_epoch{t}(4,2)+winlen/2*srate;
    data_epoch_adj{t} = data(tstart:tstop, ncolons{:});
end

end

function data_epoch_chan = extractchan(data_epoch, chan)

data_epoch_chan = cell(size(data_epoch));
for t = 1:length(data_epoch)
    data_epoch_chan{t} = data_epoch{t}(:,chan);
end

end

function [avgst, outidx] = avg_stance_perc(trig, leg, settings)

trig_mat = cell2mat(trig);
if strcmp(leg, 'left')
    stprc = (trig_mat(trig_mat(:,1) == settings.leg.L.FC,2) - trig_mat(trig_mat(:,1) == settings.leg.R.IC,2))...
        ./(trig_mat(trig_mat(:,1) == settings.leg.R.FC,2) - trig_mat(trig_mat(:,1) == settings.leg.R.IC,2));
elseif strcmp(leg, 'right')
    stprc = (trig_mat(trig_mat(:,1) == settings.leg.R.FC,2) - trig_mat(trig_mat(:,1) == settings.leg.L.IC,2))...
        ./(trig_mat(trig_mat(:,1) == settings.leg.L.FC,2) - trig_mat(trig_mat(:,1) == settings.leg.L.IC,2));
end

outidx = isoutlier(stprc);

avgst = (trimmean(stprc(~outidx),10))*100;

end

function [bldur, outidx] = baseline_dur(trig, leg, settings)

trig_mat = cell2mat(trig);
if strcmp(leg, 'left')
    bldur = trig_mat(trig_mat(:,1) == settings.leg.L.FC,2) - trig_mat(trig_mat(:,1) == settings.leg.R.IC,2) - 1;
elseif strcmp(leg, 'right')
    bldur = trig_mat(trig_mat(:,1) == settings.leg.R.FC,2) - trig_mat(trig_mat(:,1) == settings.leg.L.IC,2) - 1;
end

outidx = isoutlier(bldur);

end
