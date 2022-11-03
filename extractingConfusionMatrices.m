function [micro, macro] = extractingConfusionMatrices(freqRes, timeRes, mlRes)
micro = cell(1,26);
macro = cell(1,26);

% frequency
micro(1) = {freqRes.parallel.zeros.confMatrix};
macro(1) = {confMatrixMicroToMacro(freqRes.parallel.zeros.confMatrix)};

micro(2) = {freqRes.parallel.full.confMatrix};
macro(2) = {confMatrixMicroToMacro(freqRes.parallel.full.confMatrix)};

micro(3) = {freqRes.parallel.fxd.confMatrix};
macro(3) = {confMatrixMicroToMacro(freqRes.parallel.fxd.confMatrix)};

micro(4) = {freqRes.sequence.zeros.confMatrix};
macro(4) = {confMatrixMicroToMacro(freqRes.sequence.zeros.confMatrix)};

micro(5) = {freqRes.sequence.full.confMatrix};
macro(5) = {confMatrixMicroToMacro(freqRes.sequence.full.confMatrix)};

micro(6) = {freqRes.sequence.fxd.confMatrix};
macro(6) = {confMatrixMicroToMacro(freqRes.sequence.fxd.confMatrix)};

micro(7) = {freqRes.gcn.zeros.confMatrix};
macro(7) = {confMatrixMicroToMacro(freqRes.gcn.zeros.confMatrix)};

micro(8) = {freqRes.gcn.full.confMatrix};
macro(8) = {confMatrixMicroToMacro(freqRes.gcn.full.confMatrix)};

micro(9) = {freqRes.gcn.fxd.confMatrix};
macro(9) = {confMatrixMicroToMacro(freqRes.gcn.fxd.confMatrix)};

% time
micro(10) = {timeRes.parallel.zeros.confMatrix};
macro(10) = {confMatrixMicroToMacro(timeRes.parallel.zeros.confMatrix)};

micro(11) = {timeRes.parallel.full.confMatrix};
macro(11) = {confMatrixMicroToMacro(timeRes.parallel.full.confMatrix)};

micro(12) = {timeRes.parallel.fxd.confMatrix};
macro(12) = {confMatrixMicroToMacro(timeRes.parallel.fxd.confMatrix)};

micro(13) = {timeRes.sequence.zeros.confMatrix};
macro(13) = {confMatrixMicroToMacro(timeRes.sequence.zeros.confMatrix)};

micro(14) = {timeRes.sequence.full.confMatrix};
macro(14) = {confMatrixMicroToMacro(timeRes.sequence.full.confMatrix)};

micro(15) = {timeRes.sequence.fxd.confMatrix};
macro(15) = {confMatrixMicroToMacro(timeRes.sequence.fxd.confMatrix)};

micro(16) = {timeRes.gcn.zeros.confMatrix};
macro(16) = {confMatrixMicroToMacro(timeRes.gcn.zeros.confMatrix)};

micro(17) = {timeRes.gcn.full.confMatrix};
macro(17) = {confMatrixMicroToMacro(timeRes.gcn.full.confMatrix)};

micro(18) = {timeRes.gcn.fxd.confMatrix};
macro(18) = {confMatrixMicroToMacro(timeRes.gcn.fxd.confMatrix)};

% machine learning
micro(19) = {mlRes.lda.LDAconfMatrix};
macro(19) = {confMatrixMicroToMacro(mlRes.lda.LDAconfMatrix)};

micro(20) = {mlRes.randFor.RFconfMatrix};
macro(20) = {confMatrixMicroToMacro(mlRes.randFor.RFconfMatrix)};

% extra
micro(21) = {freqRes.parallel.fullFxd.confMatrix};
macro(21) = {confMatrixMicroToMacro(freqRes.parallel.fullFxd.confMatrix)};

micro(22) = {freqRes.sequence.fullFxd.confMatrix};
macro(22) = {confMatrixMicroToMacro(freqRes.sequence.fullFxd.confMatrix)};

micro(23) = {freqRes.gcn.fullFxd.confMatrix};
macro(23) = {confMatrixMicroToMacro(freqRes.gcn.fullFxd.confMatrix)};

micro(24) = {timeRes.parallel.fullFxd.confMatrix};
macro(24) = {confMatrixMicroToMacro(timeRes.parallel.fullFxd.confMatrix)};

micro(25) = {timeRes.sequence.fullFxd.confMatrix};
macro(25) = {confMatrixMicroToMacro(timeRes.sequence.fullFxd.confMatrix)};

micro(26) = {timeRes.gcn.fullFxd.confMatrix};
macro(26) = {confMatrixMicroToMacro(timeRes.gcn.fullFxd.confMatrix)};
