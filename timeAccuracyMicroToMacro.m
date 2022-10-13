function macroTimeAccuracy = timeAccuracyMicroToMacro(model)

predictionCumul = model.pred.cumul;

trueClasses = predictedClassesMicroToMacro(model.trueTestOutput);
nTrial = size(predictionCumul,1);
nWindowsTrial = size(predictionCumul,2);

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


