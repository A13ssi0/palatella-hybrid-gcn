function EEG = compute_extractsteps(EEG,settings)

% Parameters
triggers = EEG.other.imu.triggers.event;

[data_epoch, trig_epoch, epoch_typ] = extractsteps(EEG.data',triggers,settings);

EEG.data = data_epoch;
EEG.trials = length(data_epoch);
EEG.other.imu.triggers.steps.steps_typ = epoch_typ;
EEG.other.imu.triggers.steps.trig_steps = trig_epoch;

end

