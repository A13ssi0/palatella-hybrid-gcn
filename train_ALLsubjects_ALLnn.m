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
    isTime = false;
    [train, val, test, settings] = preparingALLtheInputsAndOutputs(numSubject,classes,'psd','sequence');
    nn_GCN_dGRU_parallel(numSubject, train, val, test, settings, savingPath, isTime, isMacro);
    nn_GCN_dGRU_sequence(numSubject, train, val, test, settings, savingPath, isTIme, isMacro);


    isTime = true;
    [train, val, test, settings] = preparingALLtheInputsAndOutputs(numSubject,classes,'time','sequence');
    nn_GCN_dGRU_parallel(numSubject, train, val, test, settings, savingPath, isTime, isMacro);
    nn_GCN_dGRU_sequence(numSubject, train, val, test, settings, savingPath, isTime, isMacro);


    isTime = false;
    [train, val, test, settings] = preparingALLtheInputsAndOutputs(numSubject,classes,'psd','image');
    nn_GCN(numSubject, train, val, test, settings, savingPath, isTime, isMacro);
    

    isTime = true;
    [train, val, test, settings] = preparingALLtheInputsAndOutputs(numSubject,classes,'time','image');
    nn_GCN(numSubject, train, val, test, settings, savingPath, isTime, isMacro);

    
    [train, val, test, settings] = preparingALLtheInputsAndOutputs(numSubject,classes,'features');
    LDA_RandomForest(numSubject, train, test, settings, savingPath, isMacro);
    
end