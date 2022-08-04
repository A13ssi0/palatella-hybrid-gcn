%%
close all; clearvars; clc;

subject = 1;
sessions = [1 2 3];

%% Settings
subj.numSubject = subject;
subj.settings.downsampling = 5;
subj.session.sessions = sessions;
subj.settings.step_epoch = [-4 1.999]; 
subj.settings.eeg.asr.th = 10; % [std]
subj.settings.eeg.asr.block_size = 10;
subj.settings.eeg.asr.window_length = 1; % [sec]
subj.settings.eeg.asr.window_overlap = 0.66; % [%]
subj.settings.eeg.asr.max_bad_channels = 0.05; %0.2
subj.settings.eeg.asr.auto_calib = true;
subj.settings.eeg.asr.iterative = false;
subj.settings.eeg.asr.iter_th = 0.05; % [%]
subj.settings.eeg.asr.max_iter = 20; % [%]
subj.settings.eeg.fs = 2500/subj.settings.downsampling;

subj.settings.eeg.cca.window_length = 2.0; % 5 [sec]
subj.settings.eeg.cca.window_shift = 1; % 2.5 [sec]
subj.settings.eeg.cca.eigratio = 1e6;
subj.settings.eeg.cca.femg = 25; % [Hz] %15
subj.settings.eeg.cca.ratio = 10;
subj.settings.eeg.cca.range = [0 10];

subj.settings.eeg.ica.method = 'amica';
subj.settings.eeg.ica.chanselect = false;


%% Transforming to matrix the EEG datasets
movement = {'reaching','twist','multigrasp'};
prefix = {'R_','T_','G_'};
scaleDownsample = subj.settings.downsampling;
markerTime = [];
markerType = [];
EEG = [];
EMG = [];

disp('concatenating data')
for i = sessions
    for j = 1:length(movement)
        mov = movement{j};
        disp(['session: ',num2str(i),'  ',mov,'  EEG'])
        [data, marker] = load_dataTesi(subject,'EEG',i,mov);

        classOneHot = marker.y;
        className = marker.className;

        [idxClassName,~] = find(classOneHot==1);
        markerType = [markerType; strcat(prefix{j},className(idxClassName))'];
        
        start = marker.misc.pos(1);     stop = marker.misc.pos(2);
        marker.pos = marker.pos-start;
        pos =  round(marker.pos'/scaleDownsample);
        markerTime = [markerTime; pos+size(EEG,1)];

        tEEG = downsample(data(start:stop,:),scaleDownsample);
        EEG = [EEG ; tEEG];

        disp(['session: ',num2str(i),'  ',mov,'  EMG'])
        [data, ~] = load_dataTesi(subject,'EMG',i,mov);
       
        tEMG = downsample(data(start:stop,:),scaleDownsample);
        EMG = [EMG ; tEMG];
    end
end

markerType(contains(markerType,'rest','IgnoreCase',true)) = {'_Rest'};
trigger.type = markerType;
trigger.nameClasses = flip(unique(markerType));
trigger.num = nan(size(trigger.type));

for i = 1:length(trigger.nameClasses)
    nameClass = cell2mat(trigger.nameClasses(i));
    trigger.num(contains(trigger.type,nameClass)) = i-1;
end
