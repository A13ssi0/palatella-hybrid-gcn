function [micro, macro] = extractingTimeAccuracies(freqRes, timeRes, mlRes)

micro = cell(1,26);
macro = cell(1,26);

% frequency
micro(1) = {correctTimeAccuracies(freqRes.parallel.zeros)};
%macro(1) = {timeAccuracyMicroTo%macro(freqRes.parallel.zeros)};

micro(2) = {correctTimeAccuracies(freqRes.parallel.full)};
%macro(2) = {timeAccuracyMicroTo%macro(freqRes.parallel.full)};

micro(3) = {correctTimeAccuracies(freqRes.parallel.fxd)};
%%macro(3) = {timeAccuracyMicroTo%macro(freqRes.parallel.fxd)};

micro(4) = {correctTimeAccuracies(freqRes.sequence.zeros)};
%macro(4) = {timeAccuracyMicroTo%macro(freqRes.sequence.zeros)};

micro(5) = {correctTimeAccuracies(freqRes.sequence.full)};
%macro(5) = {timeAccuracyMicroTo%macro(freqRes.sequence.full)};

micro(6) = {correctTimeAccuracies(freqRes.sequence.fxd)};
%%macro(6) = {timeAccuracyMicroTo%macro(freqRes.sequence.fxd)};

micro(7) = {(freqRes.gcn.zeros.accuracyThresholds)};
%macro(7) = {timeAccuracyMicroTo%macro(freqRes.gcn.zeros)};

micro(8) = {(freqRes.gcn.full.accuracyThresholds)};
%macro(8) = {timeAccuracyMicroTo%macro(freqRes.gcn.full)};

micro(9) = {(freqRes.gcn.fxd.accuracyThresholds)};
%%macro(9) = {timeAccuracyMicroTo%macro(freqRes.gcn.fxd)};

% time
micro(10) = {correctTimeAccuracies(timeRes.parallel.zeros)};
%macro(10) = {timeAccuracyMicroTo%macro(timeRes.parallel.zeros)};

micro(11) = {correctTimeAccuracies(timeRes.parallel.full)};
%macro(11) = {timeAccuracyMicroTo%macro(timeRes.parallel.full)};

micro(12) = {correctTimeAccuracies(timeRes.parallel.fxd)};
%%macro(12) = {timeAccuracyMicroTo%macro(timeRes.parallel.fxd)};

micro(13) = {correctTimeAccuracies(timeRes.sequence.zeros)};
%macro(13) = {timeAccuracyMicroTo%macro(timeRes.sequence.zeros)};

micro(14) = {correctTimeAccuracies(timeRes.sequence.full)};
%macro(14) = {timeAccuracyMicroTo%macro(timeRes.sequence.full)};

micro(15) = {correctTimeAccuracies(timeRes.sequence.fxd)};
%%macro(15) = {timeAccuracyMicroTo%macro(timeRes.sequence.fxd)};

micro(16) = {timeRes.gcn.zeros.accuracyThresholds};
%macro(16) = {timeAccuracyMicroTo%macro(timeRes.gcn.zeros)};

micro(17) = {timeRes.gcn.full.accuracyThresholds};
%macro(17) = {timeAccuracyMicroTo%macro(timeRes.gcn.full)};

micro(18) = {correctTimeAccuracies(timeRes.gcn.fxd)};
%%macro(18) = {timeAccuracyMicroTo%macro(timeRes.gcn.fxd)};

% machine learning
micro(19) = {correctTimeAccuracies(mlRes.lda)};
%macro(19) = {timeAccuracyMicroTo%macro(mlRes.lda)};

micro(20) = {correctTimeAccuracies(mlRes.randFor)};
%macro(20) = {timeAccuracyMicroTo%macro(mlRes.randFor)};

% extra
micro(21) = {freqRes.parallel.fullFxd.accuracyThresholds};
%macro(21) = {timeAccuracyMicroTo%macro(freqRes.parallel.fullFxd)};

micro(22) = {freqRes.sequence.fullFxd.accuracyThresholds};
%macro(22) = {timeAccuracyMicroTo%macro(freqRes.sequence.fullFxd)};

micro(23) = {freqRes.gcn.fullFxd.accuracyThresholds};
%macro(23) = {timeAccuracyMicroTo%macro(freqRes.gcn.fullFxd)};

micro(24) = {correctTimeAccuracies(timeRes.parallel.fullFxd)};
%macro(24) = {timeAccuracyMicroTo%macro(timeRes.parallel.fullFxd)};

micro(25) = {correctTimeAccuracies(timeRes.sequence.fullFxd)};
%macro(25) = {timeAccuracyMicroTo%macro(timeRes.sequence.fullFxd)};

micro(26) = {timeRes.gcn.fullFxd.accuracyThresholds};
%macro(26) = {timeAccuracyMicroTo%macro(timeRes.gcn.fullFxd)};
