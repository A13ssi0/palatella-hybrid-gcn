function loss = calcLossCrossEntropy(trueClasses, predPostProb)

trueClasses = double(trueClasses);
if size(trueClasses,1)~=1
    trueClasses = trueClasses';
end
selectedProbabilities = predPostProb((1:numel(trueClasses))+(trueClasses-1)*size(predPostProb,1));

loss = -sum(log10(selectedProbabilities),'all')/length(selectedProbabilities);




