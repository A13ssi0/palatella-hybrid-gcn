function [timeAccuracyCorrected,predPercCorrected,trialClasses] = correctTimeAccuracies(model)

tmpPredPerc = model.pred.perc;
outputTestSet = model.trueTestOutput;

if size(tmpPredPerc,2) == 100
    predPercCorrected = nan(size(tmpPredPerc).*[2 0.5 1]);
    
    for i = 1:size(tmpPredPerc,1)
        predPercCorrected(i*2-1,:,:) = tmpPredPerc(i,1:50,:);
        predPercCorrected(i*2,:,:) = tmpPredPerc(i,51:end,:);
    end
elseif size(tmpPredPerc,2) == 500
    predPercCorrected = nan(size(tmpPredPerc).*[10 0.1 1]);
    
    for i = 1:size(tmpPredPerc,1)
        idxVector = 1:50:501;
        for j = 1:length(idxVector)-1
            predPercCorrected(j+(i-1)*10,:,:) = tmpPredPerc(i,idxVector(j):idxVector(j+1)-1,:);
        end
    end
elseif size(tmpPredPerc,2) == 2000
    predPercCorrected = nan(size(tmpPredPerc).*[2 0.5 1]);
    
    for i = 1:size(tmpPredPerc,1)
        predPercCorrected(i*2-1,:,:) = tmpPredPerc(i,1:1000,:);
        predPercCorrected(i*2,:,:) = tmpPredPerc(i,1001:end,:);
    end

end


predCumul = nan(size(predPercCorrected));
for i = 1:size(predPercCorrected,1)
    predCumul(i,:,:) = cumsum(predPercCorrected(i,:,:));
end

nWindowsTrial = size(predCumul,2);
nTrial = length(outputTestSet)/nWindowsTrial;
trialClasses = reshape(outputTestSet,nWindowsTrial,nTrial)';

if  ~isempty(find(trialClasses ~= trialClasses(:,1),1,'first'))
    error('Division in trials not possible. Classes not the same in the trial')
end
trialClasses = double(trialClasses(:,1));

timeAccuracyCorrected = nan(size(predCumul,2),1);
for i = 1:length(timeAccuracyCorrected)
    choosenHorizon = squeeze(predCumul(:,i,:));
    [~,classification] = max(choosenHorizon,[],2);
    timeAccuracyCorrected(i) = sum(classification==trialClasses)/numel(trialClasses);
end

