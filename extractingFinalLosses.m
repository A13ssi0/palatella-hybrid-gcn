function [micro, macro] = extractingFinalLosses(freqRes, timeRes, mlRes)

micro = nan(1,20);
macro = nan(1,20);

% frequency
micro(1) = calcLossMicro(freqRes.parallel.zeros);
macro(1) = calcLossFromMicroToMacro(freqRes.parallel.zeros);

micro(2) = calcLossMicro(freqRes.parallel.full);
macro(2) = calcLossFromMicroToMacro(freqRes.parallel.full);

%micro(3) = calcLossMicro(freqRes.parallel.fxd);
%macro(3) = calcLossFromMicroToMacro(freqRes.parallel.fxd);

micro(4) = calcLossMicro(freqRes.sequence.zeros);
macro(4) = calcLossFromMicroToMacro(freqRes.sequence.zeros);

micro(5) = calcLossMicro(freqRes.sequence.full);
macro(5) = calcLossFromMicroToMacro(freqRes.sequence.full);

%micro(6) = calcLossMicro(freqRes.sequence.fxd);
%macro(6) = calcLossFromMicroToMacro(freqRes.sequence.fxd);

micro(7) = calcLossMicro(freqRes.gcn.zeros);
macro(7) = calcLossFromMicroToMacro(freqRes.gcn.zeros);

micro(8) = calcLossMicro(freqRes.gcn.full);
macro(8) = calcLossFromMicroToMacro(freqRes.gcn.full);

%micro(9) = calcLossMicro(freqRes.gcn.fxd);
%macro(9) = calcLossFromMicroToMacro(freqRes.gcn.fxd);

% time
micro(10) = calcLossMicro(timeRes.parallel.zeros);
macro(10) = calcLossFromMicroToMacro(timeRes.parallel.zeros);

micro(11) = calcLossMicro(timeRes.parallel.full);
macro(11) = calcLossFromMicroToMacro(timeRes.parallel.full);

%micro(12) = calcLossMicro(timeRes.parallel.fxd);
%macro(12) = calcLossFromMicroToMacro(timeRes.parallel.fxd);

micro(13) = calcLossMicro(timeRes.sequence.zeros);
macro(13) = calcLossFromMicroToMacro(timeRes.sequence.zeros);

micro(14) = calcLossMicro(timeRes.sequence.full);
macro(14) = calcLossFromMicroToMacro(timeRes.sequence.full);

%micro(15) = calcLossMicro(timeRes.sequence.fxd);
%macro(15) = calcLossFromMicroToMacro(timeRes.sequence.fxd);

micro(16) = calcLossMicro(timeRes.gcn.zeros);
macro(16) = calcLossFromMicroToMacro(timeRes.gcn.zeros);

micro(17) = calcLossMicro(timeRes.gcn.full);
macro(17) = calcLossFromMicroToMacro(timeRes.gcn.full);

%micro(18) = calcLossMicro(timeRes.gcn.fxd);
%macro(18) = calcLossFromMicroToMacro(timeRes.gcn.fxd);

% machine learning
micro(19) = calcLossMicro(mlRes.lda);
macro(19) = calcLossFromMicroToMacro(mlRes.lda);

micro(20) = calcLossMicro(mlRes.randFor);
macro(20) = calcLossFromMicroToMacro(mlRes.randFor);
