function [micro, macro] = extractingAccuracies(freqRes, timeRes, mlRes)

micro = nan(1,20);
macro = nan(1,20);

% frequency
micro(1) = freqRes.parallel.zeros.class.accuracy;
macro(1) = accuracyMicroToMacro(freqRes.parallel.zeros.confMatrix);

micro(2) = freqRes.parallel.full.class.accuracy;
macro(2) = accuracyMicroToMacro(freqRes.parallel.full.confMatrix);

micro(3) = freqRes.parallel.fxd.class.accuracy;
macro(3) = accuracyMicroToMacro(freqRes.parallel.fxd.confMatrix);

micro(4) = freqRes.sequence.zeros.class.accuracy;
macro(4) = accuracyMicroToMacro(freqRes.sequence.zeros.confMatrix);

micro(5) = freqRes.sequence.full.class.accuracy;
macro(5) = accuracyMicroToMacro(freqRes.sequence.full.confMatrix);

micro(6) = freqRes.sequence.fxd.class.accuracy;
macro(6) = accuracyMicroToMacro(freqRes.sequence.fxd.confMatrix);

micro(7) = freqRes.gcn.zeros.class.accuracy;
macro(7) = accuracyMicroToMacro(freqRes.gcn.zeros.confMatrix);

micro(8) = freqRes.gcn.full.class.accuracy;
macro(8) = accuracyMicroToMacro(freqRes.gcn.full.confMatrix);

micro(9) = freqRes.gcn.fxd.class.accuracy;
macro(9) = accuracyMicroToMacro(freqRes.gcn.fxd.confMatrix);

% time
micro(10) = timeRes.parallel.zeros.class.accuracy;
macro(10) = accuracyMicroToMacro(timeRes.parallel.zeros.confMatrix);

micro(11) = timeRes.parallel.full.class.accuracy;
macro(11) = accuracyMicroToMacro(timeRes.parallel.full.confMatrix);

micro(12) = timeRes.parallel.fxd.class.accuracy;
macro(12) = accuracyMicroToMacro(timeRes.parallel.fxd.confMatrix);

micro(13) = timeRes.sequence.zeros.class.accuracy;
macro(13) = accuracyMicroToMacro(timeRes.sequence.zeros.confMatrix);

micro(14) = timeRes.sequence.full.class.accuracy;
macro(14) = accuracyMicroToMacro(timeRes.sequence.full.confMatrix);

micro(15) = timeRes.sequence.fxd.class.accuracy;
macro(15) = accuracyMicroToMacro(timeRes.sequence.fxd.confMatrix);

micro(16) = timeRes.gcn.zeros.class.accuracy;
macro(16) = accuracyMicroToMacro(timeRes.gcn.zeros.confMatrix);

micro(17) = timeRes.gcn.full.class.accuracy;
macro(17) = accuracyMicroToMacro(timeRes.gcn.full.confMatrix);

micro(18) = timeRes.gcn.fxd.class.accuracy;
macro(18) = accuracyMicroToMacro(timeRes.gcn.fxd.confMatrix);

% machine learning
micro(19) = mlRes.lda.class.accuracy;
macro(19) = accuracyMicroToMacro(mlRes.lda.LDAconfMatrix);

micro(20) = mlRes.randFor.class.accuracy;
macro(20) = accuracyMicroToMacro(mlRes.randFor.RFconfMatrix);
