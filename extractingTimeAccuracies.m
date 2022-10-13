function timeAccuracies = extractingTimeAccuracies(freqRes, timeRes, mlRes)

timeAccuracies = cell(1,14);


% frequency
timeAccuracies(1) = { freqRes.parallel.zeros.accuracyThresholds };
timeAccuracies(2) = { freqRes.parallel.full.accuracyThresholds };
timeAccuracies(3) = { freqRes.sequence.zeros.accuracyThresholds };
timeAccuracies(4) = { freqRes.sequence.full.accuracyThresholds };
timeAccuracies(5) = { freqRes.gcn.zeros.accuracyThresholds };
timeAccuracies(6) = { freqRes.gcn.full.accuracyThresholds };


% time
timeAccuracies(7) = { timeRes.parallel.zeros.accuracyThresholds };
timeAccuracies(8) = { timeRes.parallel.full.accuracyThresholds };
timeAccuracies(9) = { timeRes.sequence.zeros.accuracyThresholds };
timeAccuracies(10) = { timeRes.sequence.full.accuracyThresholds };
timeAccuracies(11) = { timeRes.gcn.zeros.accuracyThresholds };
timeAccuracies(12) = { timeRes.gcn.full.accuracyThresholds };


% machine learning
timeAccuracies(13) = { mlRes.lda.accuracyThresholds };
timeAccuracies(14) = { mlRes.randFor.accuracyThresholds };

% timeAccuracies = cell(14,1);
% 
% % frequency
% timeAccuracies(1) =  freqRes.parallel.zeros.accuracyThresholds };
% timeAccuracies(2) =  freqRes.parallel.full.accuracyThresholds };
% timeAccuracies(3) =  freqRes.sequence.zeros.accuracyThresholds };
% timeAccuracies(4) =  freqRes.sequence.full.accuracyThresholds };
% timeAccuracies(5) =  freqRes.gcn.zeros.accuracyThresholds };
% timeAccuracies(6) =  freqRes.gcn.full.accuracyThresholds };
% 
% 
% % time
% timeAccuracies(7) =  timeRes.parallel.zeros.accuracyThresholds };
% timeAccuracies(8) =  timeRes.parallel.full.accuracyThresholds };
% timeAccuracies(9) =  timeRes.sequence.zeros.accuracyThresholds };
% timeAccuracies(10) =  timeRes.sequence.full.accuracyThresholds };
% timeAccuracies(11) =  timeRes.gcn.zeros.accuracyThresholds };
% timeAccuracies(12) =  timeRes.gcn.full.accuracyThresholds };
% 
% 
% % machine learning
% timeAccuracies(13) =  mlRes.lda.accuracyThresholds };
% timeAccuracies(14) =  mlRes.randFor.accuracyThresholds };