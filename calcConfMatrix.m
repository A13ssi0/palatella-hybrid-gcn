function confMatrix = calcConfMatrix(loadingName,idxEval,subjects)

confMatrix = zeros(11,11,length(subjects));

i = 1;
for sbj = subjects
    loadingFinalName = [loadingName, num2str(sbj)];
    model = load(loadingFinalName);

    [~,pred,trialClasses] = correctTimeAccuracies(model);

    predEval = pred(:,1:idxEval,:);
    predEvalCum = squeeze(sum(predEval,2));

    [~,class] = max(predEvalCum,[],2);

    confMatrix(:,:,i) = confusionmat(trialClasses,class);
end
confMatrix = round(mean(confMatrix,3));