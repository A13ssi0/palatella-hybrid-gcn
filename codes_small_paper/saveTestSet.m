function lol = saveTestSet(subject,typ,attenuation,snr)

testSetPath = '/home/palatella/workspace/palatella_datasets/imagery dataset/';

netSettings.eeg.macro = true;
typers = {'healthy','fatigue','paraplegic'};

netSettings.emg.timeDomain = false;
netSettings.emg.macro = true;
netSettings.emg.attenuation = attenuation;
netSettings.emg.snr = snr;
netSettings.emg.type = typers{typ};

skipEEG = false;

if typ==2 || typ==3
	skipEEG = true;
end

numSubject = subject;

testSet = load_testSet_paper(testSetPath,numSubject,netSettings,netSettings.emg.type,skipEEG);
testSet.emg.data = deleteSeventhChannel(testSet.emg.data);

if ~skipEEG,	testEEG = testSet.eeg;	end
testEMG = testSet.emg;

disp('saving')
if typ == 1
	save(['/home/palatella/workspace/palatella_datasets/imagery dataset/testSet',num2str(numSubject),'_EEG'],"testEEG",'-v7.3')
	save(['/home/palatella/workspace/palatella_datasets/imagery dataset/testSet',num2str(numSubject),'_EMG'],"testEMG",'-v7.3')
elseif typ == 2
	save(['/home/palatella/workspace/palatella_datasets/imagery dataset/testSet',num2str(numSubject),'_EMG_att',num2str(fix(attenuation*100))],"testEMG",'-v7.3')
elseif typ == 3 
	save(['/home/palatella/workspace/palatella_datasets/imagery dataset/testSet',num2str(numSubject),'_EMG_att',num2str(snr),'.mat'],"testEMG",'-v7.3')
end
