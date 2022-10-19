function loss = calcLossMicro(model)

predPerc = permute(model.pred.perc,[2 1 3]);
predPerc = reshape(predPerc,[],size(predPerc,3));

trueClasses = model.trueTestOutput;


loss = calcLossCrossEntropy(trueClasses, predPerc);

