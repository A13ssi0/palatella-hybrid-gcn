function [PSD,settings] = startingTrain(filename,classes,takeRest)

if ~exist('takeRest','var')
    takeRest = false;
end
if ~exist('classes','var') || isempty(classes)
    doMacroDividing = true;
else
    doMacroDividing = false;
end

load(filename)

settings = PSD.settings;

PSD.data = log(PSD.data);

%% Settings
settings.trainChoosenFreq = 4:30;
settings.NumOutFeatures = 32; 
settings.fractTrain = 0.60;
settings.fractVal = 0.20;
settings.fractTest = 1 - settings.fractTrain - settings.fractVal;

%%
[settings.trainChoosenFreq,~,settings.idxFrequencyChoosen] = intersect(settings.trainChoosenFreq, PSD.frequency);
windowsLabel = PSD.windowsLabel;

settings.NumFeatures = length(settings.trainChoosenFreq);
settings.NumChannels = size(PSD.data,3);
settings.inputSize = [settings.NumChannels, settings.NumFeatures, 1];
windowsNum = PSD.triggers.num;

if doMacroDividing
    windowsLabel(windowsLabel>=1 & windowsLabel<=2) = 1;
    windowsLabel(windowsLabel>=3 & windowsLabel<=8) = 2;
    windowsLabel(windowsLabel>=9 & windowsLabel<=11) = 3;
    windowsNum(windowsNum>=1 & windowsNum<=2) = 1;
    windowsNum(windowsNum>=3 & windowsNum<=8) = 2;
    windowsNum(windowsNum>=9 & windowsNum<=11) = 3;
    settings.classes = 1:3;
else
    settings.classes = classes;
end

if takeRest, settings.classes = [0 settings.classes]; end


% idxZeros = find(windowsLabel==0);
% idxStartZeroTrial = [idxZeros(1); idxZeros(find(diff(idxZeros)>1)+1)];
% 
% secNothing = 0.5;
% secZeros = 2;
% idxEndNewZero = idxStartZeroTrial-secNothing/settings.windowShift;
% 
% windowsLabel(idxZeros) = nan;
% windowsLabel([-secZeros/settings.windowShift:0]+idxEndNewZero) = 0;


settings.numClasses = length(settings.classes);
PSD.triggers.num = windowsNum;
PSD.windowsLabel = windowsLabel;
