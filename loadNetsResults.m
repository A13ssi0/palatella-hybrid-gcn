function [netsFreqResults, netsTimeResults, machineLearningResults] = loadNetsResults(subject)

loadingPath='/home/palatella/workspace/palatella_net/results_run/';

%% Loading Parallel nets
loadingName = 'nn_GCN_dGRU_parallelTime';
loadingName = [loadingPath,loadingName,'subj',num2str(subject),'_noRaw'];
netsTimeResults.parallel.zeros = load(loadingName);
loadingName = 'nn_GCN_dGRU_parallel_fullAdjTime';
loadingName = [loadingPath,loadingName,'subj',num2str(subject),'_noRaw'];
netsTimeResults.parallel.full = load(loadingName);

loadingName = 'nn_GCN_dGRU_parallelFreq';
loadingName = [loadingPath,loadingName,'subj',num2str(subject),'_noRaw'];
netsFreqResults.parallel.zeros = load(loadingName);
loadingName = 'nn_GCN_dGRU_parallel_fullAdjFreq';
loadingName = [loadingPath,loadingName,'subj',num2str(subject),'_noRaw'];
netsFreqResults.parallel.full = load(loadingName);

% loadingName = 'nn_GCN_dGRU_parallel_fxdDTime';
% loadingName = [loadingPath,loadingName,'subj',num2str(subject)];
% netsTimeResults.parallel.fxd = load(loadingName);
% loadingName = 'nn_GCN_dGRU_parallel_fxdDFreq';
% loadingName = [loadingPath,loadingName,'subj',num2str(subject)];
% netsFreqResults.parallel.fxd = load(loadingName);

%% Loading Sequence nets
loadingName = 'nn_GCN_dGRU_sequenceTime_';
loadingName = [loadingPath,loadingName,'subj',num2str(subject),'_noRaw'];
netsTimeResults.sequence.zeros = load(loadingName);
loadingName = 'nn_GCN_dGRU_sequence_fullAdjTime_';
loadingName = [loadingPath,loadingName,'subj',num2str(subject),'_noRaw'];
netsTimeResults.sequence.full = load(loadingName);

loadingName = 'nn_GCN_dGRU_sequenceFreq_';
loadingName = [loadingPath,loadingName,'subj',num2str(subject),'_noRaw'];
netsFreqResults.sequence.zeros = load(loadingName);
loadingName = 'nn_GCN_dGRU_sequence_fullAdjFreq_';
loadingName = [loadingPath,loadingName,'subj',num2str(subject),'_noRaw'];
netsFreqResults.sequence.full = load(loadingName);

% loadingName = 'nn_GCN_dGRU_sequence_fxdDTime_';
% loadingName = [loadingPath,loadingName,'subj',num2str(subject)];
% netsTimeResults.sequence.fxd = load(loadingName);
% loadingName = 'nn_GCN_dGRU_sequence_fxdDFreq_';
% loadingName = [loadingPath,loadingName,'subj',num2str(subject)];
% netsFreqResults.sequence.fxd = load(loadingName);

%% Load only GCN nets
loadingName = 'nn_GCN_Time';
loadingName = [loadingPath,loadingName,'subj',num2str(subject),'_noRaw'];
netsTimeResults.gcn.zeros = load(loadingName);
loadingName = 'nn_GCN__fullAdjTime';
loadingName = [loadingPath,loadingName,'subj',num2str(subject),'_noRaw'];
netsTimeResults.gcn.full = load(loadingName);

loadingName = 'nn_GCN_Freq';
loadingName = [loadingPath,loadingName,'subj',num2str(subject),'_noRaw'];
netsFreqResults.gcn.zeros = load(loadingName);
loadingName = 'nn_GCN__fullAdjFreq';
loadingName = [loadingPath,loadingName,'subj',num2str(subject),'_noRaw'];
netsFreqResults.gcn.full = load(loadingName);

% loadingName = 'nn_GCN_fxdD_Time';
% loadingName = [loadingPath,loadingName,'subj',num2str(subject)];
% netsTimeResults.gcn.fxd = load(loadingName);
% loadingName =  'nn_GCN_fxdD_Freq';
% loadingName = [loadingPath,loadingName,'subj',num2str(subject)];
% netsFreqResults.gcn.fxd = load(loadingName);

%% Load machine learning 
loadingName = 'LDA_';
loadingName = [loadingPath,loadingName,'subj',num2str(subject),'_noRaw'];
machineLearningResults.lda = load(loadingName);

loadingName = 'RandomForest';
loadingName = [loadingPath,loadingName,'subj',num2str(subject),'_noRaw'];
machineLearningResults.randFor = load(loadingName);





