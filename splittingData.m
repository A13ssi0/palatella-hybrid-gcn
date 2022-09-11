function [train, validation, test] = splittingData(Psd,settings,type)

num = Psd.triggers.num;
Sxx = Psd.data(:,settings.idxFrequencyChoosen,:);
windowsLabel = Psd.windowsLabel;

if strcmpi(type,'sequence')
    nSamples = size(Sxx,1);
    allSxx = single(permute(Sxx,[3,2,4,1]));

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

disp('creating new windows label')

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

disp('creating the input matrix')

if strcmpi(type,'sequence')
    [train.input, train.output] = createInputOutputMatrices(allSxx, idxTrain, onsetNum, settings);
    [validation.input, validation.output] = createInputOutputMatrices(allSxx, idxVal, onsetNum, settings);
    [test.input, test.output] = createInputOutputMatrices(allSxx, idxTest, onsetNum, settings);
elseif strcmpi(type,'image')
    [train.input, train.output] = createInputOutputVectors(Sxx, idxTrain, num, Psd.triggers.time, windowsLabel, settings);
    [validation.input, validation.output] = createInputOutputVectors(Sxx, idxVal, num, Psd.triggers.time, windowsLabel, settings);
    [test.input, test.output] = createInputOutputVectors(Sxx, idxTest, num, Psd.triggers.time, windowsLabel, settings);
end