function testSet = load_testSet_paper_toSave(numSubject,skipEEG,percRecalibration, attenuation, snr)

disp(['Loading test set for subject ',num2str(numSubject)])


if ~skipEEG
    classes = 1:11;
    dataType = 'EEG';
    [train, val, test, stt] = preparingALLtheInputsAndOutputs(numSubject,classes,'psd','sequence',dataType,[], [], percRecalibration);

    idxFinal = [];
    
    stt.NumEMG = 0;
    stt.NumEEG = 35;
    choosenClasses = 1:11;
    [train, val, test, stt] = divide_EEG_EMG_half_time(train, val, test, stt,idxFinal,choosenClasses);
    [~, ~, test, ~] = microToMacroClasses(train,val,test,stt);  
    
    testSet.eeg.data = test.eeg;
    testSet.eeg.output = test.output;
end


classes = 1:11;
dataType = 'EMG';
[train, val, test, settings] = preparingALLtheInputsAndOutputs(numSubject,classes,'psd','sequence',dataType, snr, attenuation, percRecalibration);

settings.NumEMG = 6;
settings.NumEEG = 0;
choosenClasses = 1:11;
[train, val, test, settings] = divide_EEG_EMG_half_time(train, val, test, settings,[],choosenClasses);
[~, ~, test, ~] = microToMacroClasses(train,val,test,settings); 
 
testSet.emg.data = test.emg;
testSet.emg.output = test.output;






