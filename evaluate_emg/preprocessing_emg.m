%%
close all; clearvars; clc; 

sessions = [1 2 3];

secOffsetTrials = 10; % set an offset for the trial extraction. Min 10 sec

%% Settings

subj.settings.downsampling = 5;
subj.settings.eeg.fs = 2500/subj.settings.downsampling;


%% Transforming to matrix the EEG datasets
for numSubj = 23%[7 11 15 19 23]
    subject = numSubj;
    clearvars triggers
    movement = {'reaching','twist','multigrasp'};
    prefix = {'R_','T_','G_'};
    scaleDownsample = subj.settings.downsampling;
    markerTime = [];
    markerType = [];
    EMG = [];
    
    
    disp('concatenating data')
    for i = sessions
        for j = 1:length(movement)
            mov = movement{j};    
            disp(['session: ',num2str(i),'  ',mov,'  EMG'])
            [data, marker, ~] = load_dataTesi(subject,'EMG',i,mov);

            classOneHot = marker.y;
            className = marker.className;
    
            [idxClassName,~] = find(classOneHot==1);
            markerType = [markerType; strcat(prefix{j},className(idxClassName))'];
            
            
            nOffsetStart = secOffsetTrials*subj.settings.eeg.fs*scaleDownsample;
            start = marker.pos(1)-nOffsetStart;     stop = marker.pos(end)+round(nOffsetStart/2);
            if start<1,     start = 1;  warning('First trigger are less than 10 seconds from the start');   end
            pos = round((marker.pos-start)'/scaleDownsample)+1;
            markerTime = [markerTime; pos+size(EMG,1)];
           
            tEMG = downsample(data(start:stop,:),scaleDownsample);
            EMG = [EMG ; tEMG];
        end
    end
    
    markerType(contains(markerType,'rest','IgnoreCase',true)) = {'_Rest'};
    trigger.type = markerType;
    trigger.time = markerTime;
    trigger.nameClasses = flip(unique(markerType));
    trigger.num = nan(size(trigger.type));
    
    for i = 1:length(trigger.nameClasses)
        nameClass = cell2mat(trigger.nameClasses(i));
        trigger.num(contains(trigger.type,nameClass)) = i-1;
    end
    
    subj.triggers = trigger;
    
    save(['/home/palatella/workspace/palatella_datasets/only emg/','s',num2str(numSubj),'_raw'],"EMG","trigger")
end
clearvars;


%% Re-referencing EMG data
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


%% Filtering
disp('Filtering EEG')
fs = subj.settings.eeg.fs;

disp('Filtering EMG')
fc_l = 5;
order = 4;

subj.settings.emg.preprocessing.HP_cutoff = fc_l;
subj.settings.emg.preprocessing.order = order;

for i = 1:size(EMG,2)
    % High pass filtering @1 Hz
    [b,a] = butter(order,fc_l/(fs/2),'high');
    EMG(:,i) = filtfilt(b,a,EMG(:,i)); 
end 


