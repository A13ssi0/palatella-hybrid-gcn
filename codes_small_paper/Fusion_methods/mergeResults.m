function [cmRes, f1Score, accuracy, loss, precision, sensitivity, kappas] = mergeResults(loadNameComplete, loadName1Perc)

load(loadNameComplete);
p1 = load(loadName1Perc);

accuracy = finalResults;

cmRes(:,:,end) = p1.cmRes;
f1Score(:,:,end) = p1.f1Score;
accuracy(:,:,end) = p1.finalResults;
loss(:,:,end) = p1.loss;
precision(:,:,end) = p1.precision;
sensitivity(:,:,end) = p1.sensitivity;
kappas = extractKappaFromCM(cmRes);