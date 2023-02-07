close all; clearvars; clc;

subjects = [15 19 23]; %7 11


doMacro = false;

savingPath='/home/palatella/workspace/palatella_net/results_run/second try fixed gcn only/';


%%
classes = 1:11;
if doMacro, classes = [];   end

isMacro = doMacro;

for numSubject = subjects
  %type of data, type of input 
     isTime = false;
     disp('FREQUENCY')
     [train, val, test, settings] = preparingALLtheInputsAndOutputs(numSubject,classes,'psd','sequence');
% %    
%    nn_GCN_dGRU_parallel(numSubject, train, val, test, settings, savingPath, isTime, isMacro);
%     nn_GCN_dGRU_sequence(numSubject, train, val, test, settings, savingPath, isTime, isMacro);
%     nn_GCN_dGRU_parallel_fullAdj(numSubject, train, val, test, settings, savingPath, isTime, isMacro);
%     nn_GCN_dGRU_sequence_fullAdj(numSubject, train, val, test, settings, savingPath, isTime, isMacro);
%     nn_GCN_dGRU_parallel_fxdD(numSubject, train, val, test, settings, savingPath, isTime, isMacro);
    nn_GCN_dGRU_sequence_fxdD(numSubject, train, val, test, settings, savingPath, isTime, isMacro);

%     [train, val, test, settings] = preparingALLtheInputsAndOutputs(numSubject,classes,'psd','image');
%     nn_GCN(numSubject, train, val, test, settings, savingPath, isTime, isMacro);
%     nn_GCN_fullAdj(numSubject, train, val, test, settings, savingPath, isTime, isMacro);
%     nn_GCN_fxdD(numSubject, train, val, test, settings, savingPath, isTime, isMacro);

% % % 
%     isTime = true;
%     disp('TIME')
%     [train, val, test, settings] = preparingALLtheInputsAndOutputs(numSubject,classes,'time','sequence');
% %     %nn_GCN_dGRU_parallel(numSubject, train, val, test, settings, savingPath, isTime, isMacro);
%     %nn_GCN_dGRU_sequence(numSubject, train, val, test, settings, savingPath, isTime, isMacro);
 %     nn_GCN_dGRU_parallel_fullAdj(numSubject, train, val, test, settings, savingPath, isTime, isMacro);
%     %nn_GCN_dGRU_sequence_fullAdj(numSubject, train, val, test, settings, savingPath, isTime, isMacro);
%     nn_GCN_dGRU_parallel_fxdD(numSubject, train, val, test, settings, savingPath, isTime, isMacro);
%     nn_GCN_dGRU_sequence_fxdD(numSubject, train, val, test, settings, savingPath, isTime, isMacro);
% % 
%      [train, val, test, settings] = preparingALLtheInputsAndOutputs(numSubject,classes,'time','image');
% %     %nn_GCN(numSubject, train, val, test, settings, savingPath, isTime, isMacro);
% %     %nn_GCN_fullAdj(numSubject, train, val, test, settings, savingPath, isTime, isMacro);
%      nn_GCN_fxdD(numSubject, train, val, test, settings, savingPath, isTime, isMacro);
% % 
%     
%     [train, val, test, settings] = preparingALLtheInputsAndOutputs(numSubject,classes,'features');
%     LDA_RandomForest(numSubject, train, test, settings, savingPath, isMacro);
    
end