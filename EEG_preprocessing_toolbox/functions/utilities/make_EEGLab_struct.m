function EEG = make_EEGLab_struct(eeg,chlocs,settings)

load EEGlab_struct.mat

% EEG.setname = [info.subj_group, num2str(info.subj_id, '%03d'), '_', info.data_mode, '_', num2str(info.session_num)];
% EEG.subject = num2str(info.subj_id);
% EEG.group = info.subj_group;
% EEG.condition = info.data_mode;
% EEG.session = info.session_num;
EEG.nbchan = size(eeg, 1);
EEG.trials = 1;
EEG.pnts = size(eeg, 2);
EEG.srate = settings.eeg.fs;
EEG.xmin = 0;
EEG.xmax = size(eeg, 2)/settings.eeg.fs-1/settings.eeg.fs;
EEG.times = EEG.xmin*1000:1/settings.eeg.fs*1000:EEG.xmax*1000;
EEG.data = eeg;
EEG.chanlocs = chlocs;
EEG.ref = 'none';
EEG.etc.eeglabvers = '2021.1';
EEG.datfile = '';

end

