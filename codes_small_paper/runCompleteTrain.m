function runCompleteTrain(percRecalibration)

subjects = [7 11 15 19 23];

signalToNoiseRatio = [1 0.5 0.1];

disp(num2str(percRecalibration))

%savingPath = '/home/palatella/workspace/palatella_net/netSmallPaper/only grasping/';
savingPath = ['/home/palatella/workspace/palatella_datasets/imagery dataset/',num2str(percRecalibration),' perc/'];


%%

for numSubject = subjects

    trainEEG(numSubject, savingPath, percRecalibration)
    doAttenuation = true;
    trainEMG(numSubject, savingPath, doAttenuation, [], percRecalibration);

    for snr = signalToNoiseRatio

        doAttenuation = false;
        trainEMG(numSubject, savingPath, doAttenuation, snr, percRecalibration);

    end
end
