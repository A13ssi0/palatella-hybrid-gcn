function runCompleteTrain(percRecalibration,subjects)

%subjects = [7 11 15 19 23];

signalToNoiseRatio = [1 0.5 0.1];

disp(num2str(percRecalibration))

%savingPath = '/home/palatella/workspace/palatella_net/netSmallPaper/only grasping/';
savingPath = ['/home/palatella/workspace/palatella_datasets/imagery dataset/weighted train/',num2str(percRecalibration),' perc/'];


%%

disp(['percRecalibration = ',num2str(percRecalibration)])
for numSubject = subjects

    trainEEG(numSubject, savingPath, percRecalibration)
    doAttenuation = true;
    trainEMG(numSubject, savingPath, doAttenuation, [], percRecalibration);

    for snr = signalToNoiseRatio

        doAttenuation = false;
        trainEMG(numSubject, savingPath, doAttenuation, snr, percRecalibration);

    end
end
