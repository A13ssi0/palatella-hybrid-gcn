function [micro, macro] = extractingTimeAccuracies(freqRes, timeRes, mlRes)

micro = cell(1,14);
macro = cell(1,14);

%% micro
% frequency
micro(1) = { freqRes.parallel.zeros.accuracyThresholds };
micro(2) = { freqRes.parallel.full.accuracyThresholds };
micro(3) = { freqRes.sequence.zeros.accuracyThresholds };
micro(4) = { freqRes.sequence.full.accuracyThresholds };
micro(5) = { freqRes.gcn.zeros.accuracyThresholds };
micro(6) = { freqRes.gcn.full.accuracyThresholds };


% time
micro(7) = { timeRes.parallel.zeros.accuracyThresholds };
micro(8) = { timeRes.parallel.full.accuracyThresholds };
micro(9) = { timeRes.sequence.zeros.accuracyThresholds };
micro(10) = { timeRes.sequence.full.accuracyThresholds };
micro(11) = { timeRes.gcn.zeros.accuracyThresholds };
micro(12) = { timeRes.gcn.full.accuracyThresholds };


% machine learning
micro(13) = { mlRes.lda.accuracyThresholds };
micro(14) = { mlRes.randFor.accuracyThresholds };


%% macro
% frequency
macro(1) = { timeAccuracyMicroToMacro(freqRes.parallel.zeros) };
macro(2) = { timeAccuracyMicroToMacro(freqRes.parallel.full) };
macro(3) = { timeAccuracyMicroToMacro(freqRes.sequence.zeros) };
macro(4) = { timeAccuracyMicroToMacro(freqRes.sequence.full) };
macro(5) = { timeAccuracyMicroToMacro(freqRes.gcn.zeros) };
macro(6) = { timeAccuracyMicroToMacro(freqRes.gcn.full) };


% time
macro(7) = { timeAccuracyMicroToMacro(timeRes.parallel.zeros) };
macro(8) = { timeAccuracyMicroToMacro(timeRes.parallel.full) };
macro(9) = { timeAccuracyMicroToMacro(timeRes.sequence.zeros) };
macro(10) = { timeAccuracyMicroToMacro(timeRes.sequence.full) };
macro(11) = { timeAccuracyMicroToMacro(timeRes.gcn.zeros) };
macro(12) = { timeAccuracyMicroToMacro(timeRes.gcn.full) };


% machine learning
macro(13) = { timeAccuracyMicroToMacro(mlRes.lda) };
macro(14) = { timeAccuracyMicroToMacro(mlRes.randFor) };