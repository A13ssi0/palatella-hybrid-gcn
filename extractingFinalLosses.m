function [micro, macro] = extractingFinalLosses(freqRes, timeRes, mlRes)

micro = nan(1,14);
macro = nan(1,14);

% frequency
micro(1) = freqRes.parallel.zeros.info.TrainingLoss(end);
macro(1) = lossesMicroToMacro(freqRes.parallel.zeros);

micro(2) = freqRes.parallel.full.info.TrainingLoss(end);
macro(2) = lossesMicroToMacro(freqRes.parallel.full);

micro(3) = freqRes.sequence.zeros.info.TrainingLoss(end);
macro(3) = lossesMicroToMacro(freqRes.sequence.zeros);

micro(4) = freqRes.sequence.full.info.TrainingLoss(end);
macro(4) = lossesMicroToMacro(freqRes.sequence.full);

micro(5) = freqRes.gcn.zeros.info.TrainingLoss(end);
macro(5) = lossesMicroToMacro(freqRes.gcn.zeros);

micro(6) = freqRes.gcn.full.info.TrainingLoss(end);
macro(6) = lossesMicroToMacro(freqRes.gcn.full);

% time
micro(7) = timeRes.parallel.zeros.info.TrainingLoss(end);
macro(7) = lossesMicroToMacro(timeRes.parallel.zeros);

micro(8) = timeRes.parallel.full.info.TrainingLoss(end);
macro(8) = lossesMicroToMacro(timeRes.parallel.full);

micro(9) = timeRes.sequence.zeros.info.TrainingLoss(end);
macro(9) = lossesMicroToMacro(timeRes.sequence.zeros);

micro(10) = timeRes.sequence.full.info.TrainingLoss(end);
macro(10) = lossesMicroToMacro(timeRes.sequence.full);

micro(11) = timeRes.gcn.zeros.info.TrainingLoss(end);
macro(11) = lossesMicroToMacro(timeRes.gcn.zeros);

micro(12) = timeRes.gcn.full.info.TrainingLoss(end);
macro(12) = lossesMicroToMacro(timeRes.gcn.full);

% features
micro(13) = computeLossFromModel(mlRes.lda);
macro(13) = lossesMicroToMacro(mlRes.lda);

micro(14) = computeLossFromModel(mlRes.randFor);
macro(14) = lossesMicroToMacro(mlRes.randFor);





