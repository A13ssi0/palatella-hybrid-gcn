function [LDAModel, confMatrixLDA, forestModel, confMatrixRF] = LDA_RandomForest(subject,train,test,settings,savingPath,isMacro)

    % LDA
    disp(['Training LDA for subject ',num2str(subject)]);

    startingNameLDA = 'LDA_';
    if isMacro,     startingNameLDA = [startingNameLDA, 'macro_'];   end

    LDAModel = fitcdiscr(train.input',categorical(train.output'));

    pred = predict(LDAModel,test.input');
    accuracy = sum(pred==categorical(test.output'))/length(test.output);
    confMatrixLDA = confusionmat(categorical(test.output)',pred);
    disp(['The accuracy is:  ',num2str(accuracy)])

    settings.typeOfMLmodel = startingNameLDA;
    if exist('savingPath','var')
        savingName = [savingPath,startingNameLDA,'subj',num2str(subject)];
        save(savingName,'LDAModel','settings','confMatrixLDA');
    end


    % Random Forest
    disp(['Training Random Forest for subject ',num2str(subject)]);

    startingNameRF = 'RandomForest';
    if isMacro,     startingNameRF = [startingNameRF, 'macro_'];   end

    tmplTree = templateTree('Type','classification');
    forestModel = fitcecoc(train.input,categorical(train.output),"ObservationsIn","columns","Learners",tmplTree);

    pred = predict(forestModel,test.input');
    accuracy = sum(pred==categorical(test.output)')/length(test.output);
    confMatrixRF = confusionmat(categorical(test.output),pred);
    disp(['The accuracy is:  ',num2str(accuracy)])

    settings.typeOfMLmodel = startingNameRF;
    if exist('savingPath','var')
        savingName = [savingPath,startingNameRF,'subj',num2str(subject)];
        save(savingName,'forestModel','settings','confMatrixRF');
    end


end