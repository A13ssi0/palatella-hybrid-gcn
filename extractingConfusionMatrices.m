function [micro, macro] = extractingConfusionMatrices(freqRes, timeRes, mlRes)

micro = cell(1,14);
macro = cell(1,14);

% frequency
micro(1) = { freqRes.parallel.zeros.confMatrix  } ;
macro(1) = { confMatrixMicroToMacro(freqRes.parallel.zeros.confMatrix)  } ;

micro(2) = { freqRes.parallel.full.confMatrix  } ;
macro(2) = { confMatrixMicroToMacro(freqRes.parallel.full.confMatrix)  } ;


micro(3) = { freqRes.sequence.zeros.confMatrix  } ;
macro(3) = { confMatrixMicroToMacro(freqRes.sequence.zeros.confMatrix)  } ;

micro(4) = { freqRes.sequence.full.confMatrix  } ;
macro(4) = { confMatrixMicroToMacro(freqRes.sequence.full.confMatrix)  } ;


micro(5) = { freqRes.gcn.zeros.confMatrix } ;
macro(5) = { confMatrixMicroToMacro(freqRes.gcn.zeros.confMatrix) } ;

micro(6) = { freqRes.gcn.full.confMatrix } ;
macro(6) = { confMatrixMicroToMacro(freqRes.gcn.full.confMatrix) } ;



% time
micro(7) = { timeRes.parallel.zeros.confMatrix } ;
macro(7) = { confMatrixMicroToMacro(timeRes.parallel.zeros.confMatrix) } ;

micro(8) = { timeRes.parallel.full.confMatrix } ;
macro(8) = { confMatrixMicroToMacro(timeRes.parallel.full.confMatrix) } ;


micro(9) = { timeRes.sequence.zeros.confMatrix } ;
macro(9) = { confMatrixMicroToMacro(timeRes.sequence.zeros.confMatrix) } ;

micro(10) = { timeRes.sequence.full.confMatrix } ;
macro(10) = { confMatrixMicroToMacro(timeRes.sequence.full.confMatrix) } ;


micro(11) = { timeRes.gcn.zeros.confMatrix } ;
macro(11) = { confMatrixMicroToMacro(timeRes.gcn.zeros.confMatrix) } ;

micro(12) = { timeRes.gcn.full.confMatrix } ;
macro(12) = { confMatrixMicroToMacro(timeRes.gcn.full.confMatrix) } ;



% machine learning
micro(13) = { mlRes.lda.confMatrixLDA } ;
macro(13) = { confMatrixMicroToMacro(mlRes.lda.confMatrixLDA) } ;

micro(14) = { mlRes.randFor.confMatrixRF } ;
macro(14) = { confMatrixMicroToMacro(mlRes.randFor.confMatrixRF) } ;
