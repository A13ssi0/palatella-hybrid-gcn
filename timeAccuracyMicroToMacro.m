function macroTimeAccuracy = timeAccuracyMicroToMacro(model)

classes = {1:2,3:8,9:11};

nTrial = size(model.pred.cumul,1);
nWindowsTrial = size(model.pred.cumul,2);


predictionCumul = nan(nTrial,nWindowsTrial,3);
for i = 1:3
    predictionCumul(:,:,i) = sum( model.pred.cumul(:,:,classes{i}),3);
end


trueClasses = predictedClassesMicroToMacro(model.trueTestOutput);
trialClasses = reshape(trueClasses,nWindowsTrial,nTrial)';

if  ~isempty(find(trialClasses ~= trialClasses(:,1),1,'first'))
    error('Division in trials not possible. Classes not the same in the trial')
end
trialClasses = double(trialClasses(:,1));

macroTimeAccuracy = nan(size(predictionCumul,2),1);
for i = 1:length(macroTimeAccuracy)
    choosenHorizon = squeeze(predictionCumul(:,i,:));
    [~,classification] = max(choosenHorizon,[],2);
    macroTimeAccuracy(i) = sum(classification==trialClasses)/numel(trialClasses);
end


