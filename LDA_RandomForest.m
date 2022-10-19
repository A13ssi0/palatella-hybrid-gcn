function [LDAmodel, LDAconfMatrix, RFmodel, RFconfMatrix] = LDA_RandomForest(subject,train,test,settings,savingPath,isMacro)

      trueTestOutput = test.output;

    % LDA
    disp(['Training LDA for subject ',num2str(subject)]);

    startingNameLDA = 'LDA_';
    if isMacro,     startingNameLDA = [startingNameLDA, 'macro_'];   end

    LDAmodel = fitcdiscr(train.input',categorical(train.output'));

    settings.secPostMovement = 2;
    settings.secPreMovement = 0;
    settings.numClasses = length(unique(test.output));

    [LDAconfMatrix, class, pred] = trial_predict(LDAmodel, test.input', test.output', settings);
    accuracyThresholds = thresholdAccuracy(pred.cumul, test.output, settings, []);

    settings.typeOfMLmodel = startingNameLDA;
    if exist('savingPath','var')
        savingName = [savingPath,startingNameLDA,'subj',num2str(subject),'_noRaw'];
        save(savingName,'LDAmodel','settings','trueTestOutput','LDAconfMatrix',"accuracyThresholds","class",'pred');
    end


    % Random Forest
    disp(['Training Random Forest for subject ',num2str(subject)]);

    startingNameRF = 'RandomForest';
    if isMacro,     startingNameRF = [startingNameRF, 'macro_'];   end

    tmplTree = templateTree('Type','classification');
    RFmodel = fitcecoc(train.input',categorical(train.output'),"Learners",tmplTree,"FitPosterior",1);

    [RFconfMatrix, class, pred] = trial_predict(RFmodel, test.input', test.output', settings,false,true);
    accuracyThresholds = thresholdAccuracy(pred.cumul, test.output, settings, []);

    settings.typeOfMLmodel = startingNameRF;
    if exist('savingPath','var')
        savingName = [savingPath,startingNameRF,'subj',num2str(subject),'_noRaw_Fitposterior'];
        save(savingName,'RFmodel','settings','trueTestOutput','RFconfMatrix',"accuracyThresholds","class",'pred');
    end


end