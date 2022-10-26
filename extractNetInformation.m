function [confMatrix, class, pred, accuracyThresholds] = extractNetInformation(net, inputTest, outputTest, settings, doPlot, isFitPosterior, isTime, th_seconds)

if isTime
     [confMatrix, class, pred] = trial_predict(net, inputTest, outputTest, settings, doPlot, isFitPosterior, settings.movwinLength);
     accuracyThresholds = thresholdAccuracy(pred.cumul, outputTest, settings, th_seconds, doPlot, settings.movwinLength);
else
    [confMatrix, class, pred] = trial_predict(net, inputTest, outputTest, settings);
    accuracyThresholds = thresholdAccuracy(pred.cumul, outputTest, settings);
end

