function [data,settings] = startingTrain(filename,classes,takeRest)

if ~exist('takeRest','var')
    takeRest = false;
end
if ~exist('classes','var') || isempty(classes)
    doMacroDividing = true;
else
    doMacroDividing = false;
end

load(filename)

if contains(filename,'labeled')
    data = subjLabeled;
    settings = data.settings;
    settings.NumChannels = size(data.data,1);
    settings.NumFeatures = 1;
else
    data = PSD;
    data.data = log(PSD.data);
    settings = PSD.settings;

    settings.NumChannels = size(PSD.data,3);
    settings.trainChoosenFreq = 4:30; 
    [settings.trainChoosenFreq,~,settings.idxFrequencyChoosen] = intersect(settings.trainChoosenFreq, PSD.frequency);
    settings.NumFeatures = length(settings.trainChoosenFreq);
end

windowsNum = data.triggers.num;
windowsLabel = data.windowsLabel;


%% Settings
settings.fractTrain = 0.6;
%settings.fractVal = 0.20;
settings.fractVal = 0;
settings.fractTest = 1 - settings.fractTrain - settings.fractVal;


%%
settings.inputSize = [settings.NumChannels, settings.NumFeatures, 1];

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


settings.numClasses = length(settings.classes);
data.triggers.num = windowsNum;
data.windowsLabel = windowsLabel;
