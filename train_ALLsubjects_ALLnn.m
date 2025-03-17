close all; clearvars; clc;

spath=  '/home/palatella/workspace/palatella_datasets/';
dpath = '/home/palatella/workspace/palatella_net/';
subjects = [2]; % from 1 to 23
train_type = 'psd'; % either 'time','psd' or 'features'
doMacro = false;
classes = 1:11;



%%

if doMacro, classes = [];   end

isMacro = doMacro;

for numSubject = subjects
    settings.numSubject = numSubject;

    % TRAIN MODEL USING TEMPORAL DATA
    if strcmp(train_type,'time')
        isTime = true;
        disp(['TIME: Subject no.' ,num2str(numSubject)]);

        filenameTime = [spath,'window_time/subj',num2str(numSubject),'_labeled_time.mat'];
        
        % SEQUENCE
        [timeSeries, settings] = preparingALLtheInputsAndOutputs(filenameTime,classes,'time','sequence');
        settings.numSubject = numSubject;
        [train, val, test,settings] = splittingData(timeSeries,settings,'sequence');
        % nn_GCN_dGRU_parallel(numSubject, train, val, test, settings, dpath, isTime, isMacro);
        % nn_GCN_dGRU_sequence(numSubject, train, val, test, settings, dpath, isTime, isMacro);
        % nn_GCN_dGRU_parallel_fullAdj(numSubject, train, val, test, settings, dpath, isTime, isMacro);
        % nn_GCN_dGRU_sequence_fullAdj(numSubject, train, val, test, settings, dpath, isTime, isMacro);
        % nn_GCN_dGRU_parallel_fxdD(numSubject, train, val, test, settings, dpath, isTime, isMacro);
        nn_GCN_dGRU_sequence_fxdD(numSubject, train, val, test, settings, dpath, isTime, isMacro);
        
        % IMAGE
        % [data, settings] = preparingALLtheInputsAndOutputs(numSubject,classes,'time','image');
        % settings.numSubject = numSubject;
        % [train, val, test,settings] = splittingData(timeSeries,settings,'image', percRecalibration);

        % nn_GCN(numSubject, train, val, test, settings, dpath, isTime, isMacro);
        % nn_GCN_fullAdj(numSubject, train, val, test, settings, dpath, isTime, isMacro);
        % nn_GCN_fxdD(numSubject, train, val, test, settings, dpath, isTime, isMacro);
        
        
    % TRAIN MODEL USING FREQUENCY DATA
    elseif strcmp(train_type,'psd')
        isTime = false;
        
        disp(['FREQUENCY: Subject no.' ,num2str(numSubject)]);
        filenamePSD = [spath,'window_psd/subj',num2str(numSubject),'_labeled_psd.mat'];

%         if strcmpi(typeOfSignal,'EEG')
%             filenamePSD = ['subj',num2str(numSubject),'_psd_corrected.mat'];
%             %filenamePSD = [base_path,'imagery dataset/s7_imagery'];
%         else
%             if exist('attenuation','var') && ~isempty(attenuation)
%                 filenamePSD = [spath,'only emg/fatigue/',...
%                     's',num2str(numSubject),'_wind25Hz_raw_attenuation',num2str(fix(attenuation*100))];
%             elseif exist('snr','var') && ~isempty(snr)
%                 filenamePSD = [spath,'only emg/paraplegic/',...
%                     's',num2str(numSubject),'_wind25Hz_raw_snr',num2str(snr),'.mat'];
%             else
%                 filenamePSD = [spath,'only emg/healthy/',...
%                     's',num2str(numSubject),'_wind25Hz_raw'];
%             end
%         end
        
        % SEQUENCE
        [Psd, settings] = preparingALLtheInputsAndOutputs(filenamePSD,classes,'psd','sequence'); 
        settings.numSubject = numSubject;
        [train, val, test, settings] = splittingData(Psd,settings,'sequence');
        

        % nn_GCN_dGRU_parallel(numSubject, train, val, test, settings, dpath, isTime, isMacro);
        % nn_GCN_dGRU_sequence(numSubject, train, val, test, settings, dpath, isTime, isMacro);
        % nn_GCN_dGRU_parallel_fullAdj(numSubject, train, val, test, settings, dpath, isTime, isMacro);
        % nn_GCN_dGRU_sequence_fullAdj(numSubject, train, val, test, settings, dpath, isTime, isMacro);
        % nn_GCN_dGRU_parallel_fxdD(numSubject, train, val, test, settings, dpath, isTime, isMacro);
        nn_GCN_dGRU_sequence_fxdD(numSubject, train, val, test, settings, dpath, isTime, isMacro);
        
        % IMAGE
        % [Psd, settings] = preparingALLtheInputsAndOutputs(numSubject,classes,'psd','image');
        % settings.numSubject = numSubject;
        % [train, val, test,settings] = splittingData(Psd,settings,'image', percRecalibration);
        

        % nn_GCN(numSubject, train, val, test, settings, dpath, isTime, isMacro);
        % nn_GCN_fullAdj(numSubject, train, val, test, settings, dpath, isTime, isMacro);
        % nn_GCN_fxdD(numSubject, train, val, test, settings, dpath, isTime, isMacro);
        
    % TRAIN MODEL USING EXTRACTED FEATURES (LDA, RandomForest)
    elseif  strcmp(train_type,'features')
        isTime = false;
        disp(['FEATURES: Subject no.' ,num2str(numSubject)]);

        filenameFeat = [base_path,'subj',num2str(numSubject),'_featuresEMG.mat'];
        [train, val, test, settings] = preparingALLtheInputsAndOutputs(filenameFeat,classes,'features');
        LDA_RandomForest(numSubject, train, test, settings, dpath, isMacro);
    else
        fprintf(2,'Variable ''train type'' must be either ''psd'',''time'' or ''features'', but is ''%s''',train_type);
    end
    
    
end