close all; clearvars; clc;

subjects = [11 15 19 23]; %7

savingPath='/home/palatella/workspace/palatella_net/netSmallPaper/';


%%

for numSubject = subjects

  isMacro = false;
  classes = 1:11;
  settings.classes = classes;
  [train, val, test, settings] = preparingALLtheInputsAndOutputs(numSubject,classes,'psd','sequence');
  [train, val, test, settings] = divide_EEG_EMG_half_time(train, val, test, settings);
  
  dataType = 'EEG';
  nn(numSubject, train,val,test,settings,savingPath,isMacro,dataType);
  dataType = 'EMG';
  nn(numSubject, train,val,test,settings,savingPath,isMacro,dataType);



  train.output(train.output>=1 & train.output<=2) = 1;
  train.output(train.output>=3 & train.output<=8) = 2;
  train.output(train.output>=9 & train.output<=11) = 3;
  val.output(val.output>=1 & val.output<=2) = 1;
  val.output(val.output>=3 & val.output<=8) = 2;
  val.output(val.output>=9 & val.output<=11) = 3;
  test.output(test.output>=1 & test.output<=2) = 1;
  test.output(test.output>=3 & test.output<=8) = 2;
  test.output(test.output>=9 & test.output<=11) = 3;
  settings.classes = 1:3;

  isMacro = true;
  classes = [];
%   [train, val, test, settings] = preparingALLtheInputsAndOutputs(numSubject,classes,'psd','sequence');
%   [train, val, test, settings] = divide_EEG_EMG_half_time(train, val, test, settings);
  
  dataType = 'EEG';
  nn(numSubject, train,val,test,settings,savingPath,isMacro,dataType);
  dataType = 'EMG';
  nn(numSubject, train,val,test,settings,savingPath,isMacro,dataType);
    
end