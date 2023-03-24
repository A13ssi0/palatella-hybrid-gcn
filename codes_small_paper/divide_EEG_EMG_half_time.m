function [trainNew, valNew, testNew, settings] = divide_EEG_EMG_half_time(train, val, test, settings, idxEEG, choosenClasses)

disp('Dividing the loaded dataset')

if nargin>=5 && ~isempty(idxEEG)   
    channelEEG = find(idxEEG');
else
    channelEEG = 1:settings.NumEEG;
end

if nargin<6
    choosenClasses = unique(train.output);
end

timeLength = size(train.input{1},4)*2;
channelEMG = settings.NumEEG+(1:settings.NumEMG);

choosenClasses = categorical(choosenClasses)';

idx = find(ismember(train.output,choosenClasses))';
for i = 1:length(idx)
    trainNew.eeg{i,1} = train.input{idx(i)}(channelEEG,:,:,1:timeLength/2);
    trainNew.emg{i,1} = train.input{idx(i)}(channelEMG,:,:,1:timeLength/2);
end
trainNew.output = train.output(idx');

idx = find(ismember(val.output,choosenClasses))';
for i = 1:length(idx)
    valNew.eeg{i,1} = val.input{idx(i)}(channelEEG,:,:,1:timeLength/2);
    valNew.emg{i,1} = val.input{idx(i)}(channelEMG,:,:,1:timeLength/2);
end
valNew.output = val.output(idx');

idx = find(ismember(test.output,choosenClasses))';
for i = 1:length(idx)
    testNew.eeg{i,1} = test.input{idx(i)}(channelEEG,:,:,1:timeLength/2);
    testNew.emg{i,1} = test.input{idx(i)}(channelEMG,:,:,1:timeLength/2);
end
testNew.output = test.output(idx');
