function [confMatrix,accuracy,f1score,precision,sensitivity] = extract_net_performances(prediction,trueValues)
%   prediction = N x classes  or  prediction = N x 1 (==classes)

trueValues = double(trueValues);
if size(prediction,2) > 1
    [~,class] = max(prediction,[],2);
else
    class = prediction;
end

confMatrix = confusionmat(trueValues,class);

accuracy = sum(class==trueValues)/length(trueValues);

sensitivity = diag(confMatrix)./sum(confMatrix,2);
precision = diag(confMatrix)./sum(confMatrix,1)';
f1score = 2*precision.*sensitivity./(precision+sensitivity);

sensitivity = mean(sensitivity);
precision = mean(precision);
f1score = mean(f1score);