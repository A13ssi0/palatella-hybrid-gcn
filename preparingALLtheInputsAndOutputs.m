function [train, val, test, settings] = preparingALLtheInputsAndOutputs(numSubject,classes,typeOfData, typeOfInput)

    NumHiddenUnits = 150;
    NumOutFeatures = 42;
    gcnDropOut = 0.3;
    gruDropOut = 0.3;

    cutLowFreq = 8;
    cutHighFreq = 30;


    % importings PSD -------------------------------------------------------------------------------
    if strcmpi(typeOfData,'psd')
        disp(['Importing the PSD of subject ',num2str(numSubject)])
        filenamePSD = ['subj',num2str(numSubject),'_psd_corrected_LOONG.mat'];
        %filenamePSD = ['subj',num2str(numSubject),'_psd.mat'];
        filenamePSD = ['/home/palatella/workspace/palatella_datasets/0.5 before 1 after onset/',filenamePSD];
        [Psd,settings] = startingTrain(filenamePSD,classes);
    
        disp(['Splitting the PSD of subject ',num2str(numSubject)])
        if strcmpi(typeOfInput,'sequence')
            typeOfDataInput = 'sequence';
            settings.movWinLength = 2*settings.windowLength; % [s]
            settings.movWinShift = 2*settings.windowShift; % [s]
            settings.nWindowsTrial = fix((settings.secPostMovement+settings.secPreMovement)/settings.movWinShift);
            [train, val, test] = splittingData(Psd,settings,typeOfDataInput);
        elseif strcmpi(typeOfInput,'image')
            typeOfDataInput = 'image';
%             fs = settings.eeg.fs;
%             settings.windowShift = 1/fs;
%             %settings.nWindowsTrial = 1;
%             settings.movwinLength = (settings.secPostMovement+settings.secPreMovement);
%             settings.movwinShift = settings.windowShift;
            [train, val, test] = splittingData(Psd,settings,typeOfDataInput);
        end
    end
    
    % importings time -------------------------------------------------------------------------------
    if strcmpi(typeOfData,'time')
        disp(['importing and splitting the time series of subject ',num2str(numSubject)])
        filenameTime = ['subj',num2str(numSubject),'_labeledRaw.mat'];
        [timeSeries,settings] = startingTrain(filenameTime,classes);
        fs = settings.eeg.fs;
    
        [b,a] = butter(4,cutLowFreq/(fs/2),'high');
        [d,c] = butter(4,cutHighFreq/(fs/2),'low');
        for i = 1:settings.NumEEG
            timeSeries.data(i,:) = filtfilt(b,a,double(timeSeries.data(i,:))); 
            timeSeries.data(i,:) = filtfilt(d,c,double(timeSeries.data(i,:)));  
        end
    
        if strcmpi(typeOfInput,'sequence')
            typeOfDataInput = 'sequence';
            settings.windowShift = 1/fs;
            settings.movWinLength = 1;
            settings.movWinShift = 0.04; 
            settings.nWindowsTrial = (settings.secPostMovement+settings.secPreMovement)/settings.movWinShift;
            [train, val, test] = splittingData(timeSeries,settings,typeOfDataInput);
        elseif strcmpi(typeOfInput,'image')
            settings.windowShift = 1/fs;
            %settings.nWindowsTrial = 1;
            typeOfDataInput = 'image';
            [train, val, test] = splittingData(timeSeries,settings,typeOfDataInput);
        end
    end

    % importings features -------------------------------------------------------------------------------
    if strcmpi(typeOfData,'features')
        disp(['importing and splitting the features of subject ',num2str(numSubject)])
        filenameFeat = ['subj',num2str(numSubject),'_featuresEMG.mat'];
        [train,test,settings] = startingSplittingFeatures(filenameFeat,classes);
        val = [];
    end


    settings.NumHiddenUnits = NumHiddenUnits;
    settings.NumOutFeatures = NumOutFeatures;
    settings.gcnDropOut = gcnDropOut;
    settings.gruDropOut = gruDropOut;

end