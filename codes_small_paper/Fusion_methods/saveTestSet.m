function saveTestSet(subject, perc, attenuation, snr)

if nargin<4,    snr=[]; end
if nargin<3,    attenuation=[]; end

if attenuation == -1,   attenuation=[]; end

testSetPath = ['/home/palatella/workspace/palatella_datasets/imagery dataset/testSets/',num2str(perc),' perc/'];

skipEEG = false;

if ~isempty(attenuation) || ~isempty(snr)
	skipEEG = true;
end

numSubject = subject;

testSet = load_testSet_paper_toSave(numSubject,skipEEG, perc, attenuation, snr);
testSet.emg.data = deleteSeventhChannel(testSet.emg.data);

if ~skipEEG,	testEEG = testSet.eeg;	end
testEMG = testSet.emg;

disp('saving')
if isempty(attenuation) && isempty(snr)
	save([testSetPath,'testSet',num2str(numSubject),'_EEG'],"testEEG",'-v7.3')
	save([testSetPath,'testSet',num2str(numSubject),'_EMG'],"testEMG",'-v7.3')
elseif ~isempty(attenuation)
	save([testSetPath,'testSet',num2str(numSubject),'_EMG_att',num2str(fix(attenuation*100))],"testEMG",'-v7.3')
elseif ~isempty(snr)
	save([testSetPath,'testSet',num2str(numSubject),'_EMG_att',num2str(snr),'.mat'],"testEMG",'-v7.3')
end
