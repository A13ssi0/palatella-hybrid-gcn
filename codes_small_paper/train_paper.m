close all; clearvars; clc;

subjects = [7 11 15 19 23]; %7

savingPath='/home/palatella/workspace/palatella_net/netSmallPaper/';


%%

for numSubject = subjects

  isTime = true;

  isMacro = false;
  classes = 1:11;
  settings.classes = classes;
  [train, val, test, settings] = preparingALLtheInputsAndOutputs(numSubject,classes,'time','sequence');
  [train, val, test, settings] = divide_EEG_EMG_half_time(train, val, test, settings);
  
  %dataType = 'EEG';
  %nn(numSubject, train,val,test,settings,savingPath,isMacro,dataType);
  dataType = 'EMG';
  nn_2LSTM(numSubject, train,val,test,settings,savingPath,isMacro,dataType,isTime);

  [train, val, test, settings] = microToMacroClasses(train,val,test,settings);  
  
  isMacro = true;     
  %dataType = 'EEG';
  %nn(numSubject, train,val,test,settings,savingPath,isMacro,dataType);
  dataType = 'EMG';
  nn_2LSTM(numSubject, train,val,test,settings,savingPath,isMacro,dataType,isTime);
    
end