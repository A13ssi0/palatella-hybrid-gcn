function accuracy = thresholdAccuracy(predictionCumul, outputTestSet, settings, th_seconds, doPlot)

if ~exist('doPlot','var') 
    doPlot = false;
end

if ~isempty(th_seconds) && th_seconds<settings.windowShift
    error(['Threshold is before the first window end. It must be more or equal to ',num2str(settings.windowShift),' seconds']);
end

if ~isempty(th_seconds) && mod(th_seconds,settings.windowShift) >0 
    warning('Threshold is not an integer number of windows. Rounded towards zero')
end

nWindowsTrial = (settings.secPostMovement+settings.secPreMovement)/settings.windowShift;
nTrial = length(outputTestSet)/nWindowsTrial;
trialClasses = reshape(outputTestSet,nWindowsTrial,nTrial)';

if  ~isempty(find(trialClasses ~= trialClasses(:,1),1,'first'))
    error('Division in trials not possible. Classes not the same in the trial')
end
trialClasses = double(trialClasses(:,1));

if ~isempty(th_seconds)
    nWindowsThreshold = fix(th_seconds/settings.windowShift);
    choosenHorizon = squeeze(predictionCumul(:,nWindowsThreshold,:));
    [~,classification] = max(choosenHorizon,[],2);
    accuracy = sum(classification==trialClasses)/numel(trialClasses);
    disp(['Accuracy of: ',num2str(accuracy)])
    return
end

accuracy = nan(size(predictionCumul,2),1);
for i = 1:length(accuracy)
    choosenHorizon = squeeze(predictionCumul(:,i,:));
    [~,classification] = max(choosenHorizon,[],2);
    accuracy(i) = sum(classification==trialClasses)/numel(trialClasses);
end

if doPlot
    t = (0:nWindowsTrial-1)*settings.windowShift;
    figure()
    plot(t,accuracy);
end

