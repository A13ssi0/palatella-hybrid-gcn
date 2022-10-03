
j = classify(net,test.input);

confMatrix = confusionmat(test.output,j);