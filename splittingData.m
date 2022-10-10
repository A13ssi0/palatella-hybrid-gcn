function [train, validation, test] = splittingData(data,settings,type)

num = data.triggers.num;
windowsLabel = data.windowsLabel;

if length(size(data.data))==2
    allSxx = permute(data.data,[1,3,4,2]);
    nSamples = size(allSxx,4);
    settings.windowShift = 1/settings.eeg.fs;
else
    Sxx = data.data(:,settings.idxFrequencyChoosen,:);
    nSamples = size(Sxx,1);
    allSxx = permute(Sxx,[3,2,4,1]);
end

if strcmpi(type,'sequence')
    nMonwinSize = settings.movwinLength/settings.windowShift;
    nMonwinShift = settings.movwinShift/settings.windowShift;
    n_sequences = fix((nSamples-(nMonwinSize-nMonwinShift))/nMonwinShift);
    seq_O = nan(n_sequences, 1);
    onsetNum = [];
    for i = 1:n_sequences
        start = (i-1)*nMonwinShift+1; stop = start + nMonwinSize - 1;
        seq_O(i) = windowsLabel(stop);
        if i>1 && seq_O(i)>0 && seq_O(i-1)==0
                onsetNum = [onsetNum; seq_O(i) i];
        elseif i>1 && isnan(seq_O(i)) && seq_O(i-1)>0
                onsetNum = [onsetNum; 0 i];
        end
    end
elseif strcmpi(type,'image')
    onsetNum = num;
end

%disp('creating new windows label')

idxTrain = [];idxVal = [];idxTest = [];

% dividind in train, validation and test set
for i = settings.classes
    idxLabel = find(onsetNum(:,1) == i);
    numTrain = round(length(idxLabel)*settings.fractTrain);
    numVal = round(length(idxLabel)*settings.fractVal);
    numTest = round(length(idxLabel)*settings.fractTest);

    tempidxTrain = datasample(idxLabel,numTrain,'Replace',false);
    tempidxVal = datasample(setdiff(idxLabel, tempidxTrain),numVal,'Replace',false);
    tempidxTest = datasample(setdiff(idxLabel, [tempidxTrain; tempidxVal]),numTest,'Replace',false);

    idxTrain = [idxTrain; tempidxTrain];
    idxVal = [idxVal; tempidxVal];
    idxTest = [idxTest; tempidxTest];
end

%disp('creating the input matrix')

if strcmpi(type,'sequence')
    [train.input, train.output] = createInputOutputMatrices(allSxx, idxTrain, onsetNum, settings);
    [validation.input, validation.output] = createInputOutputMatrices(allSxx, idxVal, onsetNum, settings);
    [test.input, test.output] = createInputOutputMatrices(allSxx, idxTest, onsetNum, settings);
elseif strcmpi(type,'image')
    [train.input, train.output] = createInputOutputVectors(allSxx, idxTrain, num, data.triggers.time, windowsLabel, settings);
    [validation.input, validation.output] = createInputOutputVectors(allSxx, idxVal, num, data.triggers.time, windowsLabel, settings);
    [test.input, test.output] = createInputOutputVectors(allSxx, idxTest, num, data.triggers.time, windowsLabel, settings);
end