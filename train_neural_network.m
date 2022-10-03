close all; clearvars; clc;


subject = 7;

%%
disp('importing the data')
%filename = ['subj',num2str(subject),'_psd.mat'];
filename = 'subj1_1trial_psd.mat';
[Psd,settings] = startingTrain(filename,1:11);


%% Creating and extracting windows
num = Psd.triggers.num;
Sxx = Psd.data;
windows = Psd.windowsLabel;

disp('creating new windows label')

idxTrain = [];
idxVal = [];
idxTest = [];

% dividind in train, validation and test set
for i = settings.classes
    idxLabel = find(num == i);
    numTrials = length(idxLabel);
    numTrain = round(numTrials*settings.fractTrain);
    numVal = round(numTrials*settings.fractVal);
    numTest = round(numTrials*settings.fractTest);
    tempidxTrain = datasample(idxLabel,numTrain,'Replace',false);
    tempidxVal = datasample(setdiff(idxLabel, tempidxTrain),numVal,'Replace',false);
    tempidxTest = datasample(setdiff(idxLabel, [tempidxTrain; tempidxVal]),numTest,'Replace',false);
    idxTrain = [idxTrain; tempidxTrain];
    idxVal = [idxVal; tempidxVal];
    idxTest = [idxTest; tempidxTest];
end

nWindowsTrial = (settings.secPostMovement+settings.secPreMovement)/settings.windowShift;  
trainSeries = zeros(nWindowsTrial*length(idxTrain),1);
for i = 1:length(idxTrain)
    if num(idxTrain) ~= 0
        trainSeries( (1:nWindowsTrial)+nWindowsTrial*(i-1) ) = Psd.triggers.time(idxTrain(i)):Psd.triggers.time(idxTrain(i)+1)-1;
    else        
        trainSeries( (1:nWindowsTrial)+nWindowsTrial*(i-1) ) = (-nWindowsTrial:-1) + Psd.triggers.time(idxTrain(i)-1);
    end
end
valSeries = zeros(nWindowsTrial*length(idxVal),1);
for i = 1:length(idxVal)
    if num(idxVal) ~= 0
        valSeries( (1:nWindowsTrial)+nWindowsTrial*(i-1) ) = Psd.triggers.time(idxVal(i)):Psd.triggers.time(idxVal(i)+1)-1;
    else        
        valSeries( (1:nWindowsTrial)+nWindowsTrial*(i-1) ) = (-nWindowsTrial:-1) + Psd.triggers.time(idxVal(i)-1);
    end
end
testSeries = zeros(nWindowsTrial*length(idxTest),1);
for i = 1:length(idxTest)
    if num(idxTest) ~= 0
        testSeries( (1:nWindowsTrial)+nWindowsTrial*(i-1) ) = Psd.triggers.time(idxTest(i)):Psd.triggers.time(idxTest(i)+1)-1;
    else        
        testSeries( (1:nWindowsTrial)+nWindowsTrial*(i-1) ) = (-nWindowsTrial:-1) + Psd.triggers.time(idxTest(i)-1);
    end
end

disp('creating the input matrix')
inputTrain = zeros([settings.inputSize length(trainSeries)]);
for i = 1:length(trainSeries)
    inputTrain(:,:,1,i) = squeeze(Sxx(trainSeries(i),settings.idxFrequencyChoosen,:))';
end
outputTrain = categorical(windows(trainSeries));

inputVal = zeros([settings.inputSize length(valSeries)]);
for i = 1:length(valSeries)
    inputVal(:,:,1,i) = squeeze(Sxx(valSeries(i),settings.idxFrequencyChoosen,:))';
end
outputVal = categorical(windows(valSeries));

inputTest = zeros([settings.inputSize length(testSeries)]);
for i = 1:length(testSeries)
    inputTest(:,:,1,i) = squeeze(Sxx(testSeries(i),settings.idxFrequencyChoosen,:))';
end
outputTest = categorical(windows(testSeries));

%% Creating GCN
% layers = graphConvWithLearnStruct3Layer(NumFeatures,NumOutFeatures,NumEMG,NumEEG);
% checkLayer(layers,inputSize,ObservationDimension=4)
layers = [
    imageInputLayer(settings.inputSize,'Normalization','zscore','NormalizationDimension','element')
    graphConvWithLearnStruct3Layer(settings.NumFeatures,settings.NumOutFeatures,settings.NumEMG,settings.NumEEG)
    reluLayer
    batchNormalizationLayer
    dropoutLayer(0.1,'Name','drop')
    fullyConnectedLayer(settings.numClasses)
    softmaxLayer
    classificationLayer];

miniBatchSize  = 512; %1024
validationFrequency = floor(numel(outputTrain)/miniBatchSize);
options = trainingOptions('adam', ...
    'MiniBatchSize',miniBatchSize, ...
    'MaxEpochs',40, ...
    'InitialLearnRate',1e-3, ...
    'LearnRateSchedule','piecewise', ...
    'LearnRateDropFactor',1e-1, ...
    'LearnRateDropPeriod',30, ...
    'ValidationData',{inputVal,outputVal}, ...
    'Shuffle', 'once', ...
    'ValidationFrequency',validationFrequency, ...
    'Plots','training-progress', ...
    'Verbose',false, ...
    'ExecutionEnvironment','gpu');

%% Training
disp('model training')
net = trainNetwork(inputTrain, outputTrain, layers, options);

%% Prediction and confusion matrix
[confMatrix, class, pred] = trial_predict(net, inputTest, outputTest, settings);

accuracy = thresholdAccuracy(pred.cumul, outputTest, settings, [], true);


%% Plot of the features
Wa = double(net.Layers(3).Wa);
Aui = triu(ones(settings.NumChannels));
Al = tril(ones(settings.NumChannels),-1);
A = Aui;
A(A>0) = Wa;
A = A + Al.*A';
Atmp = A;
% Atmp(end-size(Wa,1)+1:end,1:size(Wa,2)) = A(end-size(Wa,1)+1:end,1:size(Wa,2)).*Wa;
% Atmp(1:size(Wa,2),end-size(Wa,1)+1:end) = A(1:size(Wa,2),end-size(Wa,1)+1:end).*(Wa)';

load('chanlocs35.mat');
ch35 = chanlocs35;
ch7 = readlocs('chanlocs7.locs');
eeg_labels = {ch35.labels};
emg_labels = {ch7(1:6).labels};

figure
imagesc(Wa,[0 1])
% xticks(1:size(A,1))
% xticklabels(cat(2,eeg_labels,emg_labels))
% yticks(1:size(A,1))
% yticklabels(cat(2,eeg_labels,emg_labels))
colorbar

figure
ha = tight_subplot(2,length(emg_labels)/2,[0.001 0.001],[0.01 0.1],[0.05 0.05]);
count = 0;
for m = 1:2:length(emg_labels)
    count = count + 1;
    axes(ha(count));
    y_plt = zeros(length(ch35),1);
    y_plt = Atmp(length(ch35)+m,1:length(ch35));
    topoplot(y_plt, ch35, 'maplimits', [0 0.3], 'electrodes', 'off');
    title(emg_labels{m},'FontSize',14);
    
    y_plt = zeros(length(ch35),1);
    y_plt = Atmp(length(ch35)+m+1,1:length(ch35));
    axes(ha(count+length(emg_labels)/2));
    topoplot(y_plt, ch35, 'maplimits', [0 0.3], 'electrodes', 'off');
    title(emg_labels{m+1},'FontSize',14);
end






