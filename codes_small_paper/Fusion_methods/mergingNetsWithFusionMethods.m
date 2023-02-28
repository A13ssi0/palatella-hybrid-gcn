function results = mergingNetsWithFusionMethods(eegNetInformation,emgNetInformation,test)

eegTest = test.eeg.data;
emgTest = test.emg.data;

eegNet = eegNetInformation.net;
emgNet = emgNetInformation.net;

eegConfM = eegNetInformation.confMatrix;
emgConfM = emgNetInformation.confMatrix;


trialsToTest = 1:5;
eegPred = predict(eegNet, eegTest(trialsToTest));
emgPred = predict(emgNet, emgTest(trialsToTest));

eegClass = classify(eegNet, eegTest(trialsToTest));
emgClass = classify(emgNet, emgTest(trialsToTest));

eegOutput = test.eeg.output(trialsToTest);
emgOutput = test.emg.output(trialsToTest);


if length(unique(eegOutput)) >= length(unique(emgOutput))
    output = double(eegOutput);
else
    output = double(emgOutput);
end

nTrial = length(eegClass);
nClasses = size(eegPred,2);



%%
results.naive.class = nan(nTrial,1);
results.naive.score = nan(nTrial,nClasses);

results.bayesian.class = nan(nTrial,1);
results.bayesian.score = nan(nTrial,nClasses);


% EXTRACT FUZZY TEMPLATE AND USE IT

for i = 1:nTrial
    [results.naive.class(i), results.naive.score(i,:)] = naive_fusion_v2(eegPred(i,:), emgPred(i,:));
    [results.bayesian.class(i), results.bayesian.score(i,:)] = bayesian_fusion_v2(eegClass(i), emgClass(i), eegConfM, emgConfM);
end

results.naive.accuracy = sum(results.naive.class==output)/nTrial;
results.bayesian.accuracy = sum(results.bayesian.class==output)/nTrial;







