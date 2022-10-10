close all; clearvars; clc;

subjects = [7 11 19 23]; %13, 7 11 19 23


doMacro = false;

savingPath='/home/palatella/workspace/palatella_net/results_run/';



%%
classes = 1:11;
if doMacro, classes = [];   end

isMacro = doMacro;

for numSubject = subjects
  %type of data, type of input  
    [train, val, test, settings] = preparingALLtheInputsAndOutputs(numSubject,classes,'psd','sequence');
    nn_GCN_dGRU_parallelFreq(numSubject, train, val, test, settings, savingPath, isMacro);
    nn_GCN_dGRU_sequenceFreq(numSubject, train, val, test, settings, savingPath, isMacro);


    [train, val, test, settings] = preparingALLtheInputsAndOutputs(numSubject,classes,'time','sequence');
    nn_GCN_dGRU_parallelTime(numSubject, train, val, test, settings, savingPath, isMacro);
    nn_GCN_dGRU_sequenceTime(numSubject, train, val, test, settings, savingPath, isMacro);


    [train, val, test, settings] = preparingALLtheInputsAndOutputs(numSubject,classes,'psd','image');
    nn_GCN_Freq(numSubject, train, val, test, settings, savingPath, isMacro);
    

    [train, val, test, settings] = preparingALLtheInputsAndOutputs(numSubject,classes,'time','image');
    nn_GCN_Time(numSubject, train, val, test, settings, savingPath, isMacro);

    
    [train, val, test, settings] = preparingALLtheInputsAndOutputs(numSubject,classes,'features');
    LDA_RandomForest(numSubject, train, test, settings, savingPath, isMacro);
    
end