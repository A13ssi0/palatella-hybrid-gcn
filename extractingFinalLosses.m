function [micro, macro] = extractingFinalLosses(freqRes, timeRes, mlRes)

micro = nan(1,14);
macro = nan(1,14);

% frequency
micro(1) = calcLossMicro(freqRes.parallel.zeros);
macro(1) = calcLossFromMicroToMacro(freqRes.parallel.zeros);

micro(2) = calcLossMicro(freqRes.parallel.full);
macro(2) = calcLossFromMicroToMacro(freqRes.parallel.full);

micro(3) = calcLossMicro(freqRes.sequence.zeros);
macro(3) = calcLossFromMicroToMacro(freqRes.sequence.zeros);

micro(4) = calcLossMicro(freqRes.sequence.full);
macro(4) = calcLossFromMicroToMacro(freqRes.sequence.full);

micro(5) = calcLossMicro(freqRes.gcn.zeros);
macro(5) = calcLossFromMicroToMacro(freqRes.gcn.zeros);

micro(6) = calcLossMicro(freqRes.gcn.full);
macro(6) = calcLossFromMicroToMacro(freqRes.gcn.full);

% time
micro(7) = calcLossMicro(timeRes.parallel.zeros);
macro(7) = calcLossFromMicroToMacro(timeRes.parallel.zeros);

micro(8) = calcLossMicro(timeRes.parallel.full);
macro(8) = calcLossFromMicroToMacro(timeRes.parallel.full);

micro(9) = calcLossMicro(timeRes.sequence.zeros);
macro(9) = calcLossFromMicroToMacro(timeRes.sequence.zeros);

micro(10) = calcLossMicro(timeRes.sequence.full);
macro(10) = calcLossFromMicroToMacro(timeRes.sequence.full);

micro(11) = calcLossMicro(timeRes.gcn.zeros);
macro(11) = calcLossFromMicroToMacro(timeRes.gcn.zeros);

micro(12) = calcLossMicro(timeRes.gcn.full);
macro(12) = calcLossFromMicroToMacro(timeRes.gcn.full);

% features
micro(13) = calcLossMicro(mlRes.lda);
macro(13) = calcLossFromMicroToMacro(mlRes.lda);

micro(14) = calcLossMicro(mlRes.randFor);
macro(14) = calcLossFromMicroToMacro(mlRes.randFor);





