function [idxTrain,idxVal,idxTest,onsetNum] = chooseIndices(windowsLabel,settings,nSamples,type)

if strcmpi(type,'sequence')
    nMonWinSize = settings.movWinLength/settings.windowShift;
    nMonWinShift = settings.movWinShift/settings.windowShift;

    idxWindows = nMonWinSize:nMonWinShift:nSamples;
    seq_O = windowsLabel(idxWindows);
    seq_O(isnan(seq_O)) = 0;
    diffSeq_O = diff(seq_O);
    idxChanges = find(diffSeq_O~=0)+1;
    onsetNum = [seq_O(idxChanges) idxChanges];
elseif strcmpi(type,'image')
    onsetNum = num;
end

%disp('creating new windows label')

idxTrain = []; idxVal = []; idxTest = [];

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