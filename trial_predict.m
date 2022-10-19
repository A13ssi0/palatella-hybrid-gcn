function [confMatrix, classification, prediction] = trial_predict(net, inputTestSet, outputTestSet, settings, doPlots, isFitPosterior, windowSeconds)

disp('Trial predicting')
if ~exist('isFitPosterior','var')
    isFitPosterior = false;
end

if ~exist('doPlots','var')  || isempty(doPlots)
    doPlots = false;
end

if exist('windowSeconds','var')
    nWindowsTrial = windowSeconds/settings.windowShift;
else
    nWindowsTrial = (settings.secPostMovement+settings.secPreMovement)/settings.windowShift;
end


nTrial = length(outputTestSet)/nWindowsTrial;
trialClasses = reshape(outputTestSet,nWindowsTrial,nTrial)';

if  ~isempty(find(trialClasses ~= trialClasses(:,1),1,'first'))
    error('Division in trials not possible. Classes not the same in the trial')
end
trialClasses = trialClasses(:,1);

prediction.perc = nan(nTrial,nWindowsTrial,settings.numClasses);
prediction.cumul = nan(nTrial,nWindowsTrial,settings.numClasses);

classification.classes = categorical(nan(nTrial,nWindowsTrial));
isCorrectClass = nan(nTrial,nWindowsTrial);

for i = 1:nTrial
    idx = (1:nWindowsTrial) + nWindowsTrial*(i-1);
    if ~isa(inputTestSet,'cell')
        if length(size(inputTestSet))==2
            if isFitPosterior
                [classification.classes(i,:),~,~,prediction.perc(i,:,:)] = predict(net, inputTestSet(idx,:)); 
            else
                [classification.classes(i,:),prediction.perc(i,:,:),~] = predict(net, inputTestSet(idx,:));       
            end
            isCorrectClass(i,:) = classification.classes(i,:)==categorical(trialClasses(i));
            prediction.cumul(i,:,:) = cumsum(prediction.perc(i,:,:));
        else
            classification.classes(i,:) = classify(net, inputTestSet(:,:,:,idx));
            isCorrectClass(i,:) = classification.classes(i,:)==trialClasses(i);
        
            prediction.perc(i,:,:) = predict(net, inputTestSet(:,:,:,idx));
            prediction.cumul(i,:,:) = cumsum(prediction.perc(i,:,:));
        end
    else
        classification.classes(i,:) = classify(net, inputTestSet(idx));
        isCorrectClass(i,:) = classification.classes(i,:)==trialClasses(i);
    
        prediction.perc(i,:,:) = predict(net, inputTestSet(idx));
        prediction.cumul(i,:,:) = cumsum(prediction.perc(i,:,:));

    end
end

classification.accuracy = sum(isCorrectClass,'all')/numel(outputTestSet);
disp(['Classification accuracy of: ', num2str(classification.accuracy)])

if iscategorical(classification.classes), outputTestSet = categorical(outputTestSet); end

confMatrix = confusionmat(outputTestSet,reshape(classification.classes', size(outputTestSet)));

%% Plots
if doPlots
t = (0:nWindowsTrial-1)*settings.windowShift;
figure()
bar(t, sum(isCorrectClass)/nTrial)
title('Percentage of accuracy in every window (not cumulative)')

alreadyDoneWarning = false;
for i = settings.classes
    idx = find(trialClasses==i);
    averageCumulOnClasses = squeeze(mean(prediction.cumul(idx,:,:)));

    if length(idx)>15   
        idx = idx(1:15); 
        if ~alreadyDoneWarning
            warning('Keeping the first 15 trials to plot')
            alreadyDoneWarning = true;
        end
    end

    m = ceil(sqrt(length(idx)+1));
    n = ceil((length(idx)+1)/m);

    figure()
    sgtitle(['Cumulative predictions of class ',num2str(i)])
    for j = 1:length(idx)
        subplot(m,n,j)
        plot(t+settings.windowShift,squeeze(prediction.cumul(idx(j),:,:)))
        title(['#',num2str(idx(j)),' trial'])
    end
    subplot(m,n,j+1)
    plot(t+settings.windowShift,averageCumulOnClasses)
    title('Average')
    legend(num2str(settings.classes'), 'Position', [0.9 0.9 0.1 0.1]);
end

figure()
confusionchart(confMatrix,'ColumnSummary','absolute','RowSummary','absolute','Normalization','row-normalized');
end
