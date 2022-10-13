function accuracy = accuracyMicroToMacro(confusionMatrix)

truePred = sum(confusionMatrix(1:2,1:2),'all');
truePred = truePred + sum(confusionMatrix(3:8,3:8),'all');
truePred = truePred + sum(confusionMatrix(9:11,9:11),'all');

accuracy = truePred / sum(confusionMatrix,'all');