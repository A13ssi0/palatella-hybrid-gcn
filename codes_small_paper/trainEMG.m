function net = trainEMG(numSubject, savingPath, doAttenuation, snr, percRecalibration)

classes = 1:11;
dataType = 'EMG';
[train, val, test, settings] = preparingALLtheInputsAndOutputs(numSubject,classes,'psd','sequence',dataType, snr, [], percRecalibration);

settings.NumEMG = 6;
settings.NumEEG = 0;
choosenClasses = 1:11;
[train, val, test, settings] = divide_EEG_EMG_half_time(train, val, test, settings,[],choosenClasses);
[train, val, test, settings] = microToMacroClasses(train,val,test,settings);  

isMacro = true;  
isTime = false;
net = nn_2LSTM(numSubject, train,val,test,settings,savingPath,isMacro,dataType,isTime,doAttenuation,snr, percRecalibration);