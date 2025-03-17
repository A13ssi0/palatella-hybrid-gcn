function results = mergingNetsWithFusionMethods(eegNetInformation,emgNetInformation,test)

eegTest = test.eeg.data;
emgTest = test.emg.data;

eegNet = eegNetInformation.net;
emgNet = emgNetInformation.net;

eegConfM = eegNetInformation.CMval;
emgConfM = emgNetInformation.CMval;

eegPred = predict(eegNet, eegTest);
emgPred = predict(emgNet, emgTest);

[~,eegClass] = max(eegPred,[],2);
[~,emgClass] = max(emgPred,[],2);

eegOutput = test.eeg.output;
emgOutput = test.emg.output;

if sum(eegOutput~=emgOutput)>0, error('Output diversi'); end


if length(unique(eegOutput)) >= length(unique(emgOutput))
    output = double(eegOutput);
else
    output = double(emgOutput);
end

nTrial = length(eegClass);
nClasses = size(eegPred,2);


FT = extract_fuzzy_template(eegNetInformation.probPredValidation, emgNetInformation.probPredValidation, eegNetInformation.trueValOutput, emgNetInformation.trueValOutput);

%%
results.naive.class = nan(nTrial,1);
results.naive.score = nan(nTrial,nClasses);

results.bayesian.class = nan(nTrial,1);
results.bayesian.score = nan(nTrial,nClasses);

results.fuzzy.class = nan(nTrial,1);
results.fuzzy.score = nan(nTrial,nClasses);

for i = 1:nTrial
    [results.naive.class(i), results.naive.score(i,:)] = naive_fusion_v2(eegPred(i,:), emgPred(i,:));
    [results.bayesian.class(i), results.bayesian.score(i,:)] = bayesian_fusion_v2(eegClass(i), emgClass(i), eegConfM, emgConfM);
    [results.fuzzy.class(i), results.fuzzy.score(i,:)] = fuzzy_template(eegPred(i,:), emgPred(i,:), FT);
end


[results.eeg.cm, results.eeg.accuracy, results.eeg.f1, results.eeg.precision, results.eeg.sensitivity, results.eeg.loss] = extract_net_performances(eegClass, output);
[results.emg.cm, results.emg.accuracy, results.emg.f1, results.emg.precision, results.emg.sensitivity, results.emg.loss] = extract_net_performances(emgClass, output);

[results.naive.cm, results.naive.accuracy, results.naive.f1, results.naive.precision, results.naive.sensitivity, results.naive.loss] = extract_net_performances(results.naive.class, output);
[results.bayesian.cm, results.bayesian.accuracy, results.bayesian.f1, results.bayesian.precision, results.bayesian.sensitivity, results.bayesian.loss] = extract_net_performances(results.bayesian.class, output);
[results.fuzzy.cm, results.fuzzy.accuracy, results.fuzzy.f1, results.fuzzy.precision, results.fuzzy.sensitivity, results.fuzzy.loss] = extract_net_performances(results.fuzzy.class, output);









