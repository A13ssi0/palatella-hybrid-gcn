function [train, validation, test, settings] = splittingData(data,settings,type, percRecalibration)

num = data.triggers.num;
windowsLabel = data.windowsLabel;

if length(size(data.data))==2  % Time domain
    allSxx = permute(data.data,[1,3,4,2]);
    nSamples = size(allSxx,4);
    settings.windowShift = 1/settings.eeg.fs;
else                           % Frequency (PSD) domain
    Sxx = data.data(:,settings.idxFrequencyChoosen,:);
    nSamples = size(Sxx,1);
    allSxx = permute(Sxx,[3,2,4,1]);
end

perc = percRecalibration;
%nameFile = ['/home/palatella/workspace/idxTrainValTest25Hz_',num2str(settings.numSubject),'.mat'];
nameFile = ['/home/palatella/workspace/palatella_datasets/imagery dataset/idxTrainValTest25Hz_',num2str(settings.numSubject),'_p',num2str(perc),'.mat'];
if isfile(nameFile)
    load(nameFile)    
else
    [~,~,~,onsetNum] = chooseIndices(windowsLabel,settings,nSamples,type);
    disp('Creating new indeces')
    perc = perc/100;
    [idxTrain, idxVal, idxTest] = recreateIndicesForSessions(onsetNum, perc);
    save(nameFile,'idxTrain',"idxTest","idxVal","onsetNum")  
end

disp('creating the input matrix')

if size(allSxx,1) < 8
    nMonWinSize = settings.movWinLength/settings.windowShift;
    nMonWinShift = settings.movWinShift/settings.windowShift;
    idxWindows = nMonWinSize:nMonWinShift:nSamples;
    seq_O = windowsLabel(idxWindows);
    seq_O(isnan(seq_O)) = 0;
    diffSeq_O = diff(seq_O);
    idxChanges = find(diffSeq_O~=0)+1;
    onsetNum = [seq_O(idxChanges) idxChanges];
end
    


if strcmpi(type,'sequence')
    [train.input, train.output] = createInputOutputMatrices(allSxx, idxTrain, onsetNum, settings);
    [validation.input, validation.output] = createInputOutputMatrices(allSxx, idxVal, onsetNum, settings);
    [test.input, test.output] = createInputOutputMatrices(allSxx, idxTest, onsetNum, settings);
elseif strcmpi(type,'image')
    [train.input, train.output] = createInputOutputVectors(allSxx, idxTrain, num, data.triggers.time, windowsLabel, settings);
    [validation.input, validation.output] = createInputOutputVectors(allSxx, idxVal, num, data.triggers.time, windowsLabel, settings);
    [test.input, test.output] = createInputOutputVectors(allSxx, idxTest, num, data.triggers.time, windowsLabel, settings);
end
