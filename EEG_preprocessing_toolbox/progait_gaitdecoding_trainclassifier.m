clc
clear
% close all

%% Load dataset from mat
% Settings
progait_settings;
info.subj_group = 'CTRL'; % CTRL, PTRL
info.subj_id = 1;
info.data_mode = {'ekso_modeA', 'ekso_modeM'}; % ekso_modeA, ekso_modeF, ekso_modeM, walking
info.condition_type = {'EcsoWalking', 'EcsoWalking'}; % EcsoWalking, 'FreeWalking'
info.session_num = [123, 123];

%% Load data
disp('Loading data...')
input_type = 'forGaitDecoding_v2';

all_gait_labels = [];
all_bouts_labels = [];
all_Sxx = [];
all_Syy = [];
% all_coh = [];
for d = 1:length(info.data_mode)
    info2 = info;
    info2.data_mode = info.data_mode{d}; info2.condition_type = info.condition_type{d}; info2.session_num = info.session_num(d);
    
    loaddir = strcat(settings.dirpath, settings.savedir, info2.subj_group, '/', ...
        info2.subj_group, num2str(info2.subj_id, '%03d'), '/', info2.condition_type, '/', input_type, '/');
    filename = strcat('S', num2str(info2.subj_id), '_', info2.data_mode, ...
        '_', num2str(info2.session_num), '_', input_type, '.mat');   
    load([loaddir filename]);
    
    all_gait_labels = cat(1,all_gait_labels,gait_labels);
    if isempty(all_bouts_labels)
        all_bouts_labels = cat(1,all_bouts_labels,bouts_labels);
    else
        bouts_labels(bouts_labels>0) = bouts_labels(bouts_labels>0)+max(all_bouts_labels);
        all_bouts_labels = cat(1,all_bouts_labels,bouts_labels);
    end
    
    all_Sxx = cat(1,all_Sxx,Sxx);
    all_Syy = cat(1,all_Syy,Syy);
%     all_coh = cat(1,all_coh,COH);

end
NumEEG = size(all_Sxx,3);
NumEMG = size(all_Syy,3);

%%
% all_Sxx_mean = mean(all_Sxx,1);
% all_Sxx_mean = repmat(all_Sxx_mean,[size(all_Sxx,1) 1 1]);
% all_Sxx = all_Sxx./all_Sxx_mean;

all_S = cat(3,all_Sxx,all_Syy);
all_S = log(all_S);
% all_S = normalize(all_S, 1);
% all_S_mean = mean(all_S,1);
% all_S_mean = repmat(all_S_mean,[size(all_S,1) 1 1]);
% all_S = all_S./all_S_mean;

all_S = permute(all_S,[3 2 4 1]);

%% Partition
disp('Data partition...')
n_bouts = max(all_bouts_labels);
val_bouts = [1 12];
train_bouts = 1:n_bouts; train_bouts(val_bouts) = [];

% bouts_S = cell(n_bouts,1);
% bouts_gait_labels = cell(n_bouts,1);
% for b = 1:n_bouts
%     bouts_S{b} = all_S(:,:,:,all_bouts_labels==b);
%     bouts_gait_labels{b} = (categorical(all_gait_labels(all_bouts_labels==b)))';
% end
% train_S = bouts_S(train_bouts);
% train_labels = bouts_gait_labels(train_bouts);
% val_S = bouts_S(val_bouts);
% val_labels = bouts_gait_labels(val_bouts);

train_S = all_S(:,:,:,any(all_bouts_labels==train_bouts,2));
train_labels = all_gait_labels(any(all_bouts_labels==train_bouts,2));
val_S = all_S(:,:,:,any(all_bouts_labels==val_bouts,2));
val_labels = all_gait_labels(any(all_bouts_labels==val_bouts,2));
train_labels_cat = categorical(train_labels);
val_labels_cat = categorical(val_labels);

%% Model architecture
disp('Model creation...')
NumChannels = size(all_S,1);
NumFeatures = size(all_S,2);
NumOutFeatures = 32;
NumHiddenUnits = 50;

inputSize = [NumChannels NumFeatures 1];
numClasses = 3;

% layers = [
%     sequenceInputLayer(inputSize,'Name','input')
%     sequenceFoldingLayer('Name','fold')
%     graphConvWithLearnStruct2Layer(NumFeatures,NumOutFeatures,NumEMG,NumEEG,'Name','GConv')
%     reluLayer('Name','relu')
%     sequenceUnfoldingLayer('Name','unfold')
%     flattenLayer('Name','flatten')
%     lstmLayer(NumHiddenUnits,'OutputMode','sequence','Name','lstm')
%     dropoutLayer(0.5,'Name','drop')
%     fullyConnectedLayer(numClasses,'Name','fc')
%     softmaxLayer('Name','soft')
%     classificationLayer('Name','classification')];
% lgraph = layerGraph(layers);
% lgraph = connectLayers(lgraph,'fold/miniBatchSize','unfold/miniBatchSize');

layers = [
    imageInputLayer(inputSize,'Normalization','zscore')
    graphConvWithLearnStruct3Layer(NumFeatures,NumOutFeatures,NumEMG,NumEEG)
    reluLayer
    fullyConnectedLayer(numClasses)
    softmaxLayer
    classificationLayer];

miniBatchSize  = 1024; %512
validationFrequency = floor(numel(train_labels)/miniBatchSize);
options = trainingOptions('adam', ...
    'MiniBatchSize',miniBatchSize, ...
    'MaxEpochs',60, ...
    'InitialLearnRate',1e-2, ...
    'LearnRateSchedule','piecewise', ...
    'LearnRateDropFactor',0.1, ...
    'LearnRateDropPeriod',20, ...
    'ValidationData',{val_S,val_labels_cat}, ...
    'Shuffle', 'once', ...
    'ValidationFrequency',validationFrequency, ...
    'Plots','training-progress', ...
    'Verbose',false);

%% Model training
disp('Model training...')
% net = trainNetwork(train_S,train_labels,lgraph,options);
net = trainNetwork(train_S,train_labels_cat,layers,options);

%% Model prediction
YPred = predict(net,val_S(:,:,:,1199:end));
YLabs = classify(net,val_S(:,:,:,1199:end));
accuracy = sum(YLabs == val_labels_cat(1199:end))/numel(val_labels_cat(1199:end));

% alpha = 0.95;
% YPred_smooth = nan(size(YPred));
% pp = (1/numClasses)*ones(1,numClasses);
% for i = 1:numel(val_labels_cat)
%     YPred_smooth(i,:) = alpha*pp + (1-alpha)*YPred(i,:);
%     pp = YPred_smooth(i,:);
% end
% [~,YLabs_smooth] = max(YPred_smooth,[],2);
% YLabs_smooth = categorical(YLabs_smooth-1);
% accuracy_smooth = sum(YLabs_smooth == val_labels_cat)/numel(val_labels_cat);

figure,
plot(val_labels_cat(1199:end))
hold on
plot(YLabs,'--')
% plot(YLabs_smooth,'--g')

%%
tmp = squeeze(train_S);
MdL_Train_S = nan([NumChannels*NumFeatures size(tmp,3)]);
for i = 1:size(MdL_Train_S,2)
    MdL_Train_S(:,i) = reshape(tmp(:,:,i),[NumChannels*NumFeatures 1]);
end
% MdlQuadratic = fitcdiscr(MdL_Train_S',train_labels_cat,'DiscrimType','quadratic');
MdlLinear = fitcdiscr(MdL_Train_S',train_labels_cat);

tmp = squeeze(val_S);
MdL_Val_S = nan([NumChannels*NumFeatures size(tmp,3)]);
for i = 1:size(MdL_Val_S,2)
    MdL_Val_S(:,i) = reshape(tmp(:,:,i),[NumChannels*NumFeatures 1]);
end
MdLYLabs = predict(MdlLinear,MdL_Val_S');
MdLaccuracy = sum(MdLYLabs == val_labels_cat)/numel(val_labels_cat);

%%
tmp = squeeze(train_S);
MdL_Train_S = nan([NumChannels*NumFeatures size(tmp,3)]);
for i = 1:size(MdL_Train_S,2)
    MdL_Train_S(:,i) = reshape(tmp(:,:,i),[NumChannels*NumFeatures 1]);
end
nTrees=500;
B = TreeBagger(nTrees,MdL_Train_S',train_labels_cat, 'Method', 'classification'); 

tmp = squeeze(val_S);
MdL_Val_S = nan([NumChannels*NumFeatures size(tmp,3)]);
for i = 1:size(MdL_Val_S,2)
    MdL_Val_S(:,i) = reshape(tmp(:,:,i),[NumChannels*NumFeatures 1]);
end
predChar1 = B.predict(MdL_Val_S');  % Predictions is a char though. We want it to be a number.
TreeYLabs = str2double(predChar1);
Treeaccuracy = sum(TreeYLabs(1199:end) == val_labels(1199:end))/numel(val_labels(1199:end));

%%
A = extractdata(net.Layers(2).A);
Wa = double(net.Layers(2).Wa);
Wi = double(net.Layers(2).Wi);
Atmp = A;
Atmp(end-size(Wa,1)+1:end,1:size(Wa,2)) = A(end-size(Wa,1)+1:end,1:size(Wa,2)).*Wa;
Atmp(1:size(Wa,2),end-size(Wa,1)+1:end) = A(1:size(Wa,2),end-size(Wa,1)+1:end).*(Wa)';
Atmp(1:size(Atmp,1)+1:end) = Atmp(1:size(Atmp,1)+1:end) .* Wi;

ch38 =load('chanlocs38.mat');
ch64 =load('chanlocs64.mat');
plot_ch_idx = fidx({ch38.chanlocs.labels}, {ch64.chanlocs.labels});
load emg_labels.mat
eeg_labels = {ch38.chanlocs.labels};
figure
imagesc(Atmp,[0 1])
xticks(1:46)
xticklabels(cat(2,eeg_labels,emg_labels))
yticks(1:46)
yticklabels(cat(2,eeg_labels,emg_labels))
grid on

figure
ha = tight_subplot(2,length(emg_labels)/2,[0.001 0.001],[0.01 0.1],[0.05 0.05]);
count = 0;
for m = 1:2:length(emg_labels)
    count = count + 1;
    axes(ha(count));
    y_plt = zeros(length(ch64.chanlocs),1);
    y_plt(plot_ch_idx) = Atmp(length(ch38.chanlocs)+m,1:length(ch38.chanlocs));
    topoplot(y_plt, ch64.chanlocs, 'maplimits', [0 1], 'electrodes', 'off');
    title(emg_labels{m},'FontSize',14);
    
    y_plt = zeros(length(ch64.chanlocs),1);
    y_plt(plot_ch_idx) = Atmp(length(ch38.chanlocs)+m+1,1:length(ch38.chanlocs));
    axes(ha(count+length(emg_labels)/2));
    topoplot(y_plt, ch64.chanlocs, 'maplimits', [0 1], 'electrodes', 'off');
    title(emg_labels{m+1},'FontSize',14);
end



