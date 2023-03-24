function testSet = load_testSet_paper(testSetPath,numSubject,settings,typeEMGData,skipEEG)

disp(['Loading test set for subject ',num2str(numSubject)])


if ~skipEEG
    loadNameEEG = ['testSet',num2str(numSubject),'_EEG'];
    loadNameTest = [testSetPath,loadNameEEG];
    
    test = load(loadNameTest,'-mat');
    testSet.eeg.data = test.testEEG.data;
    testSet.eeg.output = test.testEEG.output;
end


if settings.emg.timeDomain
    loadNameTest = [testSetPath,loadName,'_time_EMGRaw'];
    test = load(loadNameTest,'-mat');
    testSet.emg.data = test.emg;
else
    if strcmpi(typeEMGData, 'healthy')
        loadNameEMG = ['testSet',num2str(numSubject),'_EMG'];
    elseif strcmpi(typeEMGData, 'fatigue')
        loadNameEMG = ['testSet',num2str(numSubject),'_EMG_att',num2str(fix(settings.emg.attenuation*100))];
    elseif strcmpi(typeEMGData, 'paraplegic')
        loadNameEMG = ['testSet',num2str(numSubject),'_EMG_att',num2str(settings.emg.snr),'.mat'];      
    end
    loadNameTest = [testSetPath,loadNameEMG];
    test = load(loadNameTest,'-mat');    
    testSet.emg.data = test.testEMG.data;
    testSet.emg.output = test.testEMG.output;
end