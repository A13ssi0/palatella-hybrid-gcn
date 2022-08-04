function [percPredict, cumulPredict] = trial_predict(net, testSet, settings)

nWindowsTrial = (settings.secPostMovement+settings.secPreMovement)/settings.windowShift;
nTrial = size(testSet,4)/nWindowsTrial;
percPredict = cell(nTrial,1);
cumulPredict = cell(nTrial,1);

for i = 1:nTrial
    idx = 1:nWindowsTrial + nWindowsTrial*(i-1);
    percPredict(i) = {predict(net, testSet(:,:,:,idx))};
    cumulPredict(i) = {cumsum(percPredict(i))};
end
