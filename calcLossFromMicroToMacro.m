function loss = calcLossFromMicroToMacro(model)

predPerc = permute(model.pred.perc,[2 1 3]);
predPerc = reshape(predPerc,[],size(predPerc,3));

tempPredPerc = nan(size(predPerc,1),3);
tempPredPerc(:,1) = sum(predPerc(:,1:2),2);
tempPredPerc(:,2) = sum(predPerc(:,3:8),2);
tempPredPerc(:,3) = sum(predPerc(:,9:11),2);
predPerc = tempPredPerc;

trueClasses = predictedClassesMicroToMacro(model.trueTestOutput);


loss = calcLossCrossEntropy(trueClasses, predPerc);


