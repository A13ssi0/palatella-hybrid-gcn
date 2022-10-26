function [micro, macro] = extractingTimeAccuracies(freqRes, timeRes, mlRes)

micro = cell(1,20);
macro = cell(1,20);

% frequency
micro(1) = {freqRes.parallel.zeros.accuracyThresholds};
macro(1) = {timeAccuracyMicroToMacro(freqRes.parallel.zeros)};

micro(2) = {freqRes.parallel.full.accuracyThresholds};
macro(2) = {timeAccuracyMicroToMacro(freqRes.parallel.full)};

micro(3) = {freqRes.parallel.fxd.accuracyThresholds};
%macro(3) = {timeAccuracyMicroToMacro(freqRes.parallel.fxd)};

micro(4) = {freqRes.sequence.zeros.accuracyThresholds};
macro(4) = {timeAccuracyMicroToMacro(freqRes.sequence.zeros)};

micro(5) = {freqRes.sequence.full.accuracyThresholds};
macro(5) = {timeAccuracyMicroToMacro(freqRes.sequence.full)};

micro(6) = {freqRes.sequence.fxd.accuracyThresholds};
%macro(6) = {timeAccuracyMicroToMacro(freqRes.sequence.fxd)};

micro(7) = {freqRes.gcn.zeros.accuracyThresholds};
macro(7) = {timeAccuracyMicroToMacro(freqRes.gcn.zeros)};

micro(8) = {freqRes.gcn.full.accuracyThresholds};
macro(8) = {timeAccuracyMicroToMacro(freqRes.gcn.full)};

micro(9) = {freqRes.gcn.fxd.accuracyThresholds};
%macro(9) = {timeAccuracyMicroToMacro(freqRes.gcn.fxd)};

% time
micro(10) = {timeRes.parallel.zeros.accuracyThresholds};
macro(10) = {timeAccuracyMicroToMacro(timeRes.parallel.zeros)};

micro(11) = {timeRes.parallel.full.accuracyThresholds};
macro(11) = {timeAccuracyMicroToMacro(timeRes.parallel.full)};

micro(12) = {timeRes.parallel.fxd.accuracyThresholds};
%macro(12) = {timeAccuracyMicroToMacro(timeRes.parallel.fxd)};

micro(13) = {timeRes.sequence.zeros.accuracyThresholds};
macro(13) = {timeAccuracyMicroToMacro(timeRes.sequence.zeros)};

micro(14) = {timeRes.sequence.full.accuracyThresholds};
macro(14) = {timeAccuracyMicroToMacro(timeRes.sequence.full)};

micro(15) = {timeRes.sequence.fxd.accuracyThresholds};
%macro(15) = {timeAccuracyMicroToMacro(timeRes.sequence.fxd)};

micro(16) = {timeRes.gcn.zeros.accuracyThresholds};
macro(16) = {timeAccuracyMicroToMacro(timeRes.gcn.zeros)};

micro(17) = {timeRes.gcn.full.accuracyThresholds};
macro(17) = {timeAccuracyMicroToMacro(timeRes.gcn.full)};

micro(18) = {timeRes.gcn.fxd.accuracyThresholds};
%macro(18) = {timeAccuracyMicroToMacro(timeRes.gcn.fxd)};

% machine learning
micro(19) = {mlRes.lda.accuracyThresholds};
macro(19) = {timeAccuracyMicroToMacro(mlRes.lda)};

micro(20) = {mlRes.randFor.accuracyThresholds};
macro(20) = {timeAccuracyMicroToMacro(mlRes.randFor)};
