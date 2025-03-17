%%
function [] = preprocessing_func(subject)
%     close all; clearvars; clc;

%     dataPath = '/media/palatella/Elements/DatasetGraz/';
    dataPath = '/home/palatella/workspace/palatella_datasets/';
    savingPath = [dataPath,'preprocessed/'];
    
    ICA_outfile = [savingPath,'subj',num2str(subject),'_fullDataset.mat'];
    dataType = 'realMove'; % either 'realMove' or 'MI' TODO: check safety
    
    secStartStop = 10;    % Set an offset for the trial extraction. The marker would be zero when the trial start
                      % Doing so other 10 second before it is taken
    sessions = [1 2 3];
    movement = {'reaching','twist','multigrasp'};

    %% Settings
    
    subj.numSubject = subject;
    subj.settings.downsampling = 5;
    subj.settings.sessions = sessions;
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
    
    prefix = {'R_','T_','G_'};
    scaleDownsample = subj.settings.downsampling;
    markerTime = [];
    markerType = [];
    EEG = [];
    EMG = [];
    
    disp(['Concatenating data (dataset type: ',dataType,')'])
    for i = sessions
        for j = 1:length(movement)
            mov = movement{j};
    
            EEG_filename = [dataPath,'EEG_ConvertedData/EEG_session',...
               num2str(i),'_sub',int2str(subject),'_',mov,'_',dataType,'.mat'];
            EMG_filename = [dataPath,'EMG_ConvertedData/EMG_session',...
               num2str(i),'_sub',int2str(subject),'_',mov,'_',dataType,'.mat'];
    
            disp(['session: ',num2str(i),'  ',mov,'  EEG'])
            [data, marker] = load_dataTesi(EEG_filename);
    
            classOneHot = marker.y;
            className = marker.className;
    
            [idxClassName,~] = find(classOneHot==1);
            markerType = [markerType; strcat(prefix{j},className(idxClassName))'];
            
            
            nStartStop = secStartStop*subj.settings.eeg.fs*scaleDownsample ;            
            start = marker.pos(1)-nStartStop;     stop = marker.pos(end)+nStartStop/2;
            pos = round((marker.pos-start)'/scaleDownsample);
            markerTime = [markerTime; pos+size(EEG,1)];
    
            tEEG = downsample(data(start:stop,:),scaleDownsample);
            EEG = [EEG ; tEEG];
    
            disp(['session: ',num2str(i),'  ',mov,'  EMG'])
            [data, ~] = load_dataTesi(EMG_filename);
           
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
    
    %% Filtering
    disp('Filtering EEG')
    fs = subj.settings.eeg.fs;
    
    fc_l = 1;   fc_h = 40;
    order = 4;
    
    subj.settings.eeg.preprocessing.HP_cutoff = fc_l;
    subj.settings.eeg.preprocessing.LP_cutoff = fc_h;
    subj.settings.eeg.preprocessing.order = order;
    
    for i = 1:size(EEG,2)
        % High pass filtering @1 Hz
        [b,a] = butter(order,fc_l/(fs/2),'high');
        EEG(:,i) = filtfilt(b,a,EEG(:,i)); 
    
        % Low pass filtering @40 Hz
        [b,a] = butter(order,fc_h/(fs/2),'low');
        EEG(:,i) = filtfilt(b,a,EEG(:,i)); 
    end
    
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
    
    clearvars -except EEG EMG subj ICA_outfile ICA_pruned_outfile
    
    %% Find Electrodes to Keep and Deleting the others
    disp('Deleting Electrodes')
    load chanlocs60.mat
    chanlocs7 = readlocs('chanlocs7.locs');
    subj.eeg = make_EEGLab_struct(EEG',chanlocs60,subj.settings);
    subj.emg = make_EEGLab_struct(EMG',chanlocs7,subj.settings);
    clearvars EEG EMG
    
    labels = struct2cell(chanlocs60);
    labels = squeeze(labels(1,1,:));
    delete= {'7','8','AF','O','FP','IZ'};
    idx = zeros(length(labels),1);
    for i=1:length(delete)
        idx = idx + contains(upper(labels),delete(i));
    end
    idx_good = idx==0;
    subj.settings.eeg.preprocessing.channelSubset = labels(idx_good);
    subj.eeg = pop_select(subj.eeg, 'channel', subj.settings.eeg.preprocessing.channelSubset);
    subj.eeg.data = double(subj.eeg.data);
    
    labels = struct2cell(chanlocs7);
    labels = squeeze(labels(3,1,:));
    delete= {'7'};
    idx = zeros(length(labels),1);
    for i=1:length(delete)
        idx = idx + contains(upper(labels),delete(i));
    end
    idx_good = idx==0;
    subj.settings.emg.preprocessing.channelSubset = labels(idx_good);
    subj.emg = pop_select(subj.emg, 'channel', subj.settings.emg.preprocessing.channelSubset);
    subj.emg.data = double(subj.emg.data);
    subj.settings.NumEMG = 6;
    
    clearvars -except subj ICA_outfile ICA_pruned_outfile
    
    %% Re-referencing And Interpolating
    disp('Re-referencing And Interpolating FCz')
    subj.eeg.data = filter_car(subj.eeg.data,1);
    
    load chanlocs35.mat
    FCz = eeginterp(subj.eeg.data,subj.eeg.chanlocs, chanlocs35(35));
    subj.eeg.data = [subj.eeg.data
                        FCz];
    subj.eeg.chanlocs = chanlocs35;
    subj.eeg.nbchan = 35;
    subj.settings.NumEEG = subj.eeg.nbchan;
    
    %% ASR
    disp('ASR step')
    subj.eeg = compute_asr(subj.eeg, subj.settings);
    subj.settings.doneASR = 'yes';
    % save(savingName, 'subj','-v7.3');
    
    
    %% CCA
    disp('CCA step')
    subj.eeg = compute_cca(subj.eeg, subj.settings);
    subj.settings.doneCCA = 'yes';
    % save(savingName, 'subj','-v7.3');
    
    %% ICA
    disp('ICA step')
    subj.eeg = compute_ica(subj.eeg, subj.settings);
    subj.settings.doneICA = 'yes';
    save(ICA_outfile, 'subj','-v7.3');
    disp(['Saved at ',ICA_outfile])
end


