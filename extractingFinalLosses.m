function micro = extractingFinalLosses(freqRes, timeRes)

micro = nan(1,12);

% frequency
micro(1) = freqRes.parallel.zeros.info.TrainingLoss(end);
micro(2) = freqRes.parallel.full.info.TrainingLoss(end);
micro(3) = freqRes.sequence.zeros.info.TrainingLoss(end);
micro(4) = freqRes.sequence.full.info.TrainingLoss(end);
micro(5) = freqRes.gcn.zeros.info.TrainingLoss(end);
micro(6) = freqRes.gcn.full.info.TrainingLoss(end);


% time
micro(7) = timeRes.parallel.zeros.info.TrainingLoss(end);
micro(8) = timeRes.parallel.full.info.TrainingLoss(end);
micro(9) = timeRes.sequence.zeros.info.TrainingLoss(end);
micro(10) = timeRes.sequence.full.info.TrainingLoss(end);
micro(11) = timeRes.gcn.zeros.info.TrainingLoss(end);
micro(12) = timeRes.gcn.full.info.TrainingLoss(end);