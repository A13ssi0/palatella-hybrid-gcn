function testSet = load_testSet_paper(testSetPath,numSubject,settings)

disp(['Loading test set for subject ',num2str(numSubject)])


loadName = ['testSet_subj',num2str(numSubject)];
loadNameTest = [testSetPath,loadName,'_psd'];

testSet.eeg = load(loadNameTest,'test.eeg');
testSet.output = load(loadNameTest,'test.output');


if settings.emg.timeDomain
    loadNameTest = [testSetPath,loadName,'_time_EMGRaw'];
    testSet.emg = load(loadNameTest,'test.emg');
else
    testSet.emg = load(loadNameTest,'test.emg');
end