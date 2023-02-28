% load chanlocs60.mat
% 
% teeg = make_EEGLab_struct(EEG',chanlocs60,subj.settings);
% teeg.data = filter_car(teeg.data,1);
% 
% load chanlocs35.mat
% FCz = eeginterp(teeg.data,teeg.chanlocs, chanlocs35(35));
% 
% FCz_eeglab = double(EEG.data(61,:));
% 
% emg_ref = EMG(:,7);
% emg = EMG(:,1:6);
% 
% for i = 1:6
%     emg_reref_eeglab(:,i) = emg(:,i)+FCz_eeglab'-emg_ref;
%     emg_reref_interp(:,i) = emg(:,i)+FCz'-emg_ref;
% end
% 
% save subj15_reref_EMG_eeglab.mat emg_reref_eeglab
% save subj15_reref_EMG_interp.mat emg_reref_interp