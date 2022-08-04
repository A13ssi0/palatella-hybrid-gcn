function EEG = compute_ersp(EEG,settings)
% Assumes epochs of the same length starting from each foot final contact
% (FC) baseline corrected by pre-step window (e.g., -0.5s before step onset)

if settings.eeg.ersp.do_laplacian
    load(settings.eeg.preprocessing.lapmask)
    data = (EEG.data')*mask;
    EEG.data = data';
end

% Extract epochs
winlen = settings.eeg.ersp.winlen;
epoch = settings.eeg.ersp.step_epoch;
epoch_adj = [epoch(1)-settings.eeg.ersp.ref_size-winlen/2 epoch(2)+winlen/2];
tref = [epoch(1)-settings.eeg.ersp.ref_size epoch(1)-1/EEG.srate].*1000; % [ms]
triggers = EEG.other.imu.triggers.event;
[data_epoch_adj, trials_typ] = extractepochs(EEG.data',triggers,[settings.leg.L.label settings.leg.R.label],epoch_adj,EEG.srate);
% [smps chans trls]

g.Fs = EEG.srate;
g.tlimits = epoch_adj.*1000;
g.winsize = winlen*EEG.srate;
g.freqs = settings.eeg.ersp.freqs;
g.nfreqs = [];
g.padratio = floor(settings.eeg.ersp.padratio*EEG.srate);
g.baseline = tref;
g.ntimesout = 1000;
g.trialbase = 'off';

% Both legs
ersp_type = 'both_legs';
disp(['[compute_ersp] Computing the ERSP for ', strrep(ersp_type, '_', ' ')])
ERSP = [];
% ERSP_epoch = [];
for c = 1:EEG.nbchan
    fprintf('CHANNEL %s (%d/%d)\n', EEG.chanlocs(c).labels, c, EEG.nbchan)
%     figure
%     [c_ersp, ~, ~, times, f_vec] = newtimef(squeeze(data_epoch_adj(:, c, :)), size(data_epoch_adj, 1), ...
%         epoch_adj.*1000, EEG.srate, settings.eeg.ersp.varwin, ...
%         'timesout', 100000,...
%         'winsize',settings.eeg.ersp.winlen*EEG.srate, 'freqs',settings.eeg.ersp.freqs,...
%         'padratio',floor(settings.eeg.ersp.padratio*EEG.srate),...
%         'plotersp','off', 'plotitc','off', 'baseline',tref,'verbose','off','alpha',settings.eeg.ersp.stat_alpha);
    [c_ersp, times, f_vec] = timef_ersp(squeeze(data_epoch_adj(:, c, :)),g);
    ERSP = cat(3, ERSP, c_ersp); % [frqs, smps, chans]
%     ERSP_epoch = cat(4, ERSP_epoch, c_ersp_t); % [frqs, smps, trls, chans]
end
%'timesout',(diff(epoch)+settings.eeg.ersp.ref_size)*EEG.srate
EEG.data = permute(ERSP, [3 2 1]); % [chans, smps, frqs];
% EEG.trials = size(data_epoch_adj, 3);
EEG.xmin = times(1)/1000;
EEG.xmax = times(end)/1000;
EEG.pnts = size(EEG.data,2);
EEG.times = times;
EEG.frequencies = f_vec;
% EEG.other.ersp.baseln = baseln;
EEG.other.ersp.(ersp_type).data = permute(ERSP, [3 2 1]); % [chans, smps, frqs]
fprintf('\n')

% Left leg
ersp_type = 'left_leg';
disp(['[compute_ersp] Computing the ERSP for ', strrep(ersp_type, '_', ' ')])
ERSP = [];
left_trials = trials_typ==settings.leg.L.label;
for c = 1:EEG.nbchan
    fprintf('CHANNEL %s (%d/%d)\n', EEG.chanlocs(c).labels, c, EEG.nbchan)
%     c_ersp = newtimef(squeeze(data_epoch_adj(:, c, left_trials)), size(data_epoch_adj, 1), ...
%         epoch_adj.*1000, EEG.srate, settings.eeg.ersp.varwin, ...
%         'timesout',(diff(epoch)+settings.eeg.ersp.ref_size)*EEG.srate,...
%         'winsize',settings.eeg.ersp.winlen*EEG.srate, 'freqs',settings.eeg.ersp.freqs,...
%         'padratio',floor(settings.eeg.ersp.padratio*EEG.srate),...
%         'plotersp','off', 'plotitc','off', 'baseline',tref,'verbose','off','alpha',settings.eeg.ersp.stat_alpha);
    [c_ersp, ~, ~] = timef_ersp(squeeze(data_epoch_adj(:, c, left_trials)),g);
    ERSP = cat(3, ERSP, c_ersp); % [frqs, smps, chans]
end
EEG.other.ersp.(ersp_type).data = permute(ERSP, [3 2 1]); % [chans, smps, frqs]
fprintf('\n')

% Right leg
ersp_type = 'right_leg';
disp(['[compute_ersp] Computing the ERSP for ', strrep(ersp_type, '_', ' ')])
ERSP = [];
right_trials = trials_typ==settings.leg.R.label;
for c = 1:EEG.nbchan
    fprintf('CHANNEL %s (%d/%d)\n', EEG.chanlocs(c).labels, c, EEG.nbchan)
%     c_ersp = newtimef(squeeze(data_epoch_adj(:, c, right_trials)), size(data_epoch_adj, 1), ...
%         epoch_adj.*1000, EEG.srate, settings.eeg.ersp.varwin, ...
%         'timesout',(diff(epoch)+settings.eeg.ersp.ref_size)*EEG.srate,...
%         'winsize',settings.eeg.ersp.winlen*EEG.srate, 'freqs',settings.eeg.ersp.freqs,...
%         'padratio',floor(settings.eeg.ersp.padratio*EEG.srate),...
%         'plotersp','off', 'plotitc','off', 'baseline',tref,'verbose','off','alpha',settings.eeg.ersp.stat_alpha);
    [c_ersp, ~, ~] = timef_ersp(squeeze(data_epoch_adj(:, c, right_trials)),g);
    ERSP = cat(3, ERSP, c_ersp); % [frqs, smps, chans]
end
EEG.other.ersp.(ersp_type).data = permute(ERSP, [3 2 1]); % [chans, smps, frqs]
fprintf('\n')

end

