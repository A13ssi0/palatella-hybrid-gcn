close all; clearvars; clc;

subjects = [7 11 19 23]; %13

NumHiddenUnits = 150;
NumOutFeatures = 42;
gcnDropOut = 0.3;
gruDropOut = 0.3;

cutLowFreq = 8;
cutHighFreq = 30;

doMacro = true;

savingPath='/home/palatella/workspace/palatella_net/results_run/';



%%
classes = 1:11;
if doMacro, classes = [];   end

isMacro = doMacro;

for numSubject = subjects
    
    [trainPsd, valPsd, testPsd, trainPsdImage, valPsdImage, testPsdImage, settingsPsd, trainTime, valTime, testTime, trainTimeImage, valTimeImage, testTimeImage, settingsTime, trainFeatures, testFeatures, settingsFeatures] = preparingALLtheInputsAndOutputs(numSubject,classes);

    nn_GCN_dGRU_parallelFreq(trainPsd, valPsd, testPsd, settingsPsd, savingPath, isMacro)
    nn_GCN_dGRU_parallelTime(trainTime, valTime, testTime, settingsTime, savingPath, isMacro)

    nn_GCN_dGRU_sequenceFreq(trainPsd, valPsd, testPsd, settingsPsd, savingPath, isMacro)
    nn_GCN_dGRU_sequenceTime(trainTime, valTime, testTime, settingsTime, savingPath, isMacro)

    nn_GCN_Freq(trainPsdImage, valPsdImage, testPsdImage, settingsPsd, savingPath, isMacro)
    nn_GCN_Time(trainTimeImage, valTimeImage, testTimeImage, settingsTime, savingPath, isMacro)

    LDA_RandomForest(trainFeatures, testFeatures, settingsFeatures, savingPath, isMacro)
    
end