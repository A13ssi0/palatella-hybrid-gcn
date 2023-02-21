function testSet = load_testSet_paper(testSetPath,numSubject,settings)

disp(['Loading test set for subject ',num2str(numSubject)])


loadName = ['testSet_subj',num2str(numSubject)];
loadNameTest = [testSetPath,loadName,'_psd'];

test = load(loadNameTest,'-mat');
testSet.eeg = test.test.eeg;
testSet.output = test.test.output;


if settings.emg.timeDomain
    loadNameTest = [testSetPath,loadName,'_time_EMGRaw'];
    test = load(loadNameTest,'-mat');
    testSet.emg = test.test.emg;
else
    testSet.emg = test.test.emg;
end