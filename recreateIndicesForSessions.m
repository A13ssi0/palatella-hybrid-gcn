function [idxTrain, idxVal, idxTest] = recreateIndicesForSessions(onsetNum, percToTransfer)

idx = find(onsetNum(:,1)==11 | onsetNum(:,1)==10);
dIdx = diff(idx);
num = unique(dIdx);

if sum(dIdx==num(end))==2
    Idx = find(dIdx==num(end));
else
    Idx = find(dIdx==num(end) | dIdx==num(end-1));
end


idxTrain = 1:2:idx(Idx(1));
idxVal = idx(Idx(1))+2:2:idx(Idx(2));
idxTest = idx(Idx(2))+2:2:idx(end);

vl = [];        tst = [];
if nargin==2 && percToTransfer > 0

    valNum = onsetNum(idxVal,1);
    countVal = ceil(histcounts(valNum)*percToTransfer);
    testNum = onsetNum(idxTest,1);
    countTest = ceil(histcounts(testNum)*percToTransfer);

    for c = 1:length(countTest)
        vl = [vl; find(valNum==c,countVal(c),'first')];
        tst = [tst; find(testNum==c,countTest(c),'first')];
    end
end

idxTrain = [idxTrain idxVal(vl)];
idxVal(vl) = [];
idxTrain = [idxTrain idxTest(tst)];
idxTest(tst) = []; 
