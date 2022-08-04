function EEG = compute_ersp_stat(EEG,settings)

% ERSP bootstrap parameters
% --------------
timesout = EEG.times;
baseln = EEG.other.ersp.baseln;
settings.eeg.ersp.stat.baseline = settings.eeg.ersp.baseline;
trials_typ = find_trials(EEG.other.imu.triggers.event, [settings.leg.L.label settings.leg.R.label]);

% Both legs
P = EEG.data;
for c = 1:EEG.nbchan
    PA = squeeze(P(c,:,:,:)); % [smps, trls, frqs]
    PA = permute(PA, [3 1 2]); % [frqs, smps, trls]
    maskersp = ersp_bootstrap(PA,timesout,baseln,settings.eeg.ersp.stat);
    PP = (EEG.other.ersp.both_legs.data(c,:,:))';
    PP(~maskersp) = 0;
    EEG.other.ersp.both_legs.data(c,:,:) = PP';
end

% Left leg
P = EEG.data(:,:,trials_typ == settings.leg.L.label,:);
for c = 1:EEG.nbchan
    PA = squeeze(P(c,:,:,:)); % [smps, trls, frqs]
    PA = permute(PA, [3 1 2]); % [frqs, smps, trls]
    maskersp = ersp_bootstrap(PA,timesout,baseln,settings.eeg.ersp.stat);
    PP = (EEG.other.ersp.both_legs.data(c,:,:))';
    PP(~maskersp) = 0;
    EEG.other.ersp.left_leg.data(c,:,:) = PP';
end

% Right leg
P = EEG.data(:,:,trials_typ == settings.leg.R.label,:);
for c = 1:EEG.nbchan
    PA = squeeze(P(c,:,:,:)); % [smps, trls, frqs]
    PA = permute(PA, [3 1 2]); % [frqs, smps, trls]
    maskersp = ersp_bootstrap(PA,timesout,baseln,settings.eeg.ersp.stat);
    PP = (EEG.other.ersp.both_legs.data(c,:,:))';
    PP(~maskersp) = 0;
    EEG.other.ersp.right_leg.data(c,:,:) = PP';
end


end

