function adjacencyMatrices = extractingAdjacencyMatrices(freqRes, timeRes)

adjacencyMatrices = cell(1,12);

% frequency
adjacencyMatrices(1) = { freqRes.parallel.zeros.net.A };
adjacencyMatrices(2) = { freqRes.parallel.full.net.A };
adjacencyMatrices(3) = { freqRes.sequence.zeros.net.A };
adjacencyMatrices(4) = { freqRes.sequence.full.net.A };
adjacencyMatrices(5) = { freqRes.gcn.zeros.net.A };
adjacencyMatrices(6) = { freqRes.gcn.full.net.A };


% time
adjacencyMatrices(7) = { timeRes.parallel.zeros.net.A };
adjacencyMatrices(8) = { timeRes.parallel.full.net.A };
adjacencyMatrices(9) = { timeRes.sequence.zeros.net.A };
adjacencyMatrices(10) = { timeRes.sequence.full.net.A };
adjacencyMatrices(11) = { timeRes.gcn.zeros.net.A };
adjacencyMatrices(12) = { timeRes.gcn.full.net.A };