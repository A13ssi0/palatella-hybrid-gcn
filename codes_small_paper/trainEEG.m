function net = trainEEG(numSubject, savingPath, percRecalibration)

classes = 1:11;
dataType = 'EEG';
[train, val, test, settings] = preparingALLtheInputsAndOutputs(numSubject,classes,'psd','sequence',dataType,[],[], percRecalibration);


%   % channel selection
%   channels = settings.eeg.preprocessing.channelSubset;
% 
%   pat = {'C'};
%   idxP = contains(channels,pat);
% %   pat = {'F'};
% %   idxF = contains(channels,pat);
%   pat = {'1','3','5','z'};
%   idxNum = contains(channels,pat);
% 
%   idxFinal = idxP & idxNum;
%   idxFinal = [idxFinal; true];
idxFinal = [];

%
settings.NumEMG = 0;
settings.NumEEG = 35;
choosenClasses = 1:11;
[train, val, test, settings] = divide_EEG_EMG_half_time(train, val, test, settings,idxFinal,choosenClasses);
[train, val, test, settings] = microToMacroClasses(train,val,test,settings);  

isMacro = true;     
net = nn_CNN_2LSTM(numSubject, train,val,test,settings,savingPath,isMacro,dataType);