function [trainNew, valNew, testNew, settings] = divide_EEG_EMG_half_time(train, val, test, settings)

disp('Dividing the loaded dataset')

timeLength = size(train.input{1},4);

channelEEG = 1:settings.NumEEG;
channelEMG = settings.NumEEG+(1:settings.NumEMG);


for i = 1:length(train.input)
    trainNew.eeg{i,1} = train.input{i}(channelEEG,:,:,1:timeLength/2);
    trainNew.emg{i,1} = train.input{i}(channelEMG,:,:,1:timeLength/2);
end
trainNew.output = train.output;

for i = 1:length(val.input)
    valNew.eeg{i,1} = val.input{i}(channelEEG,:,:,1:timeLength/2);
    valNew.emg{i,1} = val.input{i}(channelEMG,:,:,1:timeLength/2);
end
valNew.output = val.output;

for i = 1:length(test.input)
    testNew.eeg{i,1} = test.input{i}(channelEEG,:,:,1:timeLength/2);
    testNew.emg{i,1} = test.input{i}(channelEMG,:,:,1:timeLength/2);
end
testNew.output = test.output;
