function [data, settings] = preparingALLtheInputsAndOutputs(filename,classes,typeOfData, typeOfInput,  percRecalibration)

    NumHiddenUnits = 150;
    NumOutFeatures = 42;
    gcnDropOut = 0.3;
    gruDropOut = 0.3;

    cutLowFreq = 8;
    cutHighFreq = 30;

    % importing PSD -------------------------------------------------------------------------------
    if strcmpi(typeOfData,'psd')
        disp('Loading');
        [data,settings] = startingTrain(filename,classes);

        disp('Splitting');
        if strcmpi(typeOfInput,'sequence')
            settings.movWinLength = 2*settings.windowLength; % [s]
            settings.movWinShift = 2*settings.windowShift; % [s]
            settings.nWindowsTrial = fix((settings.secPostMovement+settings.secPreMovement)/settings.movWinShift);
        elseif strcmpi(typeOfInput,'image')
%             fs = settings.eeg.fs;
%             settings.windowShift = 1/fs;
%             %settings.nWindowsTrial = 1;
%             settings.movwinLength = (settings.secPostMovement+settings.secPreMovement);
%             settings.movwinShift = settings.windowShift;
        end
    end
    
    % importings time -------------------------------------------------------------------------------
    if strcmpi(typeOfData,'time')
        disp('Loading');
        [data,settings] = startingTrain(filename,classes);
        fs = settings.eeg.fs;
    
        [b,a] = butter(4,cutLowFreq/(fs/2),'high');
        [d,c] = butter(4,cutHighFreq/(fs/2),'low');
        for i = 1:settings.NumEEG
            data.data(i,:) = filtfilt(b,a,double(data.data(i,:))); 
            data.data(i,:) = filtfilt(d,c,double(data.data(i,:)));  
        end
        
        disp('Splitting');
        if strcmpi(typeOfInput,'sequence')
            settings.windowShift = 1/fs;
            settings.movWinLength = 1;
            settings.movWinShift = 0.04; 
            settings.nWindowsTrial = (settings.secPostMovement+settings.secPreMovement)/settings.movWinShift;
            
        elseif strcmpi(typeOfInput,'image')
            settings.windowShift = 1/fs;
            settings.nWindowsTrial = 1;
        end
    end

    % importings features -------------------------------------------------------------------------------
    if strcmpi(typeOfData,'features')
        disp('Loading and splitting');
        [train,test,settings] = startingSplittingFeatures(filename,classes);
        val = [];
        data = [train,val,test];
    end


    settings.NumHiddenUnits = NumHiddenUnits;
    settings.NumOutFeatures = NumOutFeatures;
    settings.gcnDropOut = gcnDropOut;
    settings.gruDropOut = gruDropOut;

end