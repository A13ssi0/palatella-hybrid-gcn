close all; clearvars; clc;

subjects = [7 11 15 19 23]; %7

doMacro = false;

savingPath='/home/palatella/workspace/palatella_net/results_run/second try fixed gcn only/';


%%
classes = 1:11;
if doMacro, classes = [];   end

isMacro = doMacro;

for numSubject = subjects
  %type of data, type of input 

  [train, val, test, settings] = preparingALLtheInputsAndOutputs(numSubject,classes,'psd','sequence');
  [net, info, confMatrix, class, pred, accuracyThresholds] = nn(subject, train,val,test,settings,savingPath,isMacro)

    
end