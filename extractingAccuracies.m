function [micro, macro] = extractingAccuracies(freqRes, timeRes, mlRes)

micro = nan(1,14);
macro = nan(1,14);

% frequency
micro(1) = freqRes.parallel.zeros.class.accuracy;
macro(1) = accuracyMicroToMacro(freqRes.parallel.zeros.confMatrix);

micro(2) = freqRes.parallel.full.class.accuracy;
macro(2) = accuracyMicroToMacro(freqRes.parallel.full.confMatrix);


micro(3) = freqRes.sequence.zeros.class.accuracy;
macro(3) = accuracyMicroToMacro(freqRes.sequence.zeros.confMatrix);

micro(4) = freqRes.sequence.full.class.accuracy;
macro(4) = accuracyMicroToMacro(freqRes.sequence.full.confMatrix);


micro(5) = freqRes.gcn.zeros.class.accuracy;
macro(5) = accuracyMicroToMacro(freqRes.gcn.zeros.confMatrix);

micro(6) = freqRes.gcn.full.class.accuracy;
macro(6) = accuracyMicroToMacro(freqRes.gcn.full.confMatrix);



% time
micro(7) = timeRes.parallel.zeros.class.accuracy;
macro(7) = accuracyMicroToMacro(timeRes.parallel.zeros.confMatrix);

micro(8) = timeRes.parallel.full.class.accuracy;
macro(8) = accuracyMicroToMacro(timeRes.parallel.full.confMatrix);


micro(9) = timeRes.sequence.zeros.class.accuracy;
macro(9) = accuracyMicroToMacro(timeRes.sequence.zeros.confMatrix);

micro(10) = timeRes.sequence.full.class.accuracy;
macro(10) = accuracyMicroToMacro(timeRes.sequence.full.confMatrix);


micro(11) = timeRes.gcn.zeros.class.accuracy;
macro(11) = accuracyMicroToMacro(timeRes.gcn.zeros.confMatrix);

micro(12) = timeRes.gcn.full.class.accuracy;
macro(12) = accuracyMicroToMacro(timeRes.gcn.full.confMatrix);



% machine learning
micro(13) = mlRes.lda.class.accuracy;
macro(13) = accuracyMicroToMacro(mlRes.lda.LDAconfMatrix);

micro(14) = mlRes.randFor.class.accuracy;
macro(14) = accuracyMicroToMacro(mlRes.randFor.RFconfMatrix);
