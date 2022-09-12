close all; clearvars; clc;
rng(12)

subject = 7;

NumHiddenUnits = 150;
NumOutFeatures = 7;
gcnDropOut = 0.3;
gruDropOut = 0.3;

endingName = '_macro';

onlyGru = false;

typeOfDataInput = 'sequence'; %'image'



%%
savingPath='/home/palatella/workspace/palatella_net/';
disp('importing the data')
filename = ['subj',num2str(subject),'_psd.mat'];
[Psd,settings] = startingTrain(filename);

%%
disp('creating new windows label')
settings.movwinLength = 2*settings.windowLength; % [s]
settings.movwinShift = 2*settings.windowShift; % [s]

[~, ~, test] = splittingData(Psd,settings,typeOfDataInput);

%%
q = ''; x = ''; y=''; z ='';

drop = '_drop';

hidUnits = '_hidF';
if onlyGru, hidUnits = '_hUnits'; end 

if exist('NumHiddenUnits','var'), q = [hidUnits,num2str(NumHiddenUnits)]; end
if exist('NumOutFeatures','var'), x = ['_outF',num2str(NumOutFeatures)]; end
if exist('gcnDropOut','var'), y = [drop,num2str(gcnDropOut)]; drop='_'; end
if exist('gruDropOut','var'), z = [drop,num2str(gruDropOut)]; end

loadingName = [savingPath,'subj',num2str(subject),'_net',q,x,y,z,endingName];
load(loadingName,'-mat');

%%
[confMatrix, class, prediction] = trial_predict(net, test.input, test.output, settings);

nWindowsTrial = (settings.secPostMovement+settings.secPreMovement)/settings.windowShift;
t = (0:nWindowsTrial-1)*settings.windowShift;

nTrial = length(test.output)/nWindowsTrial;
trialClasses = reshape(test.output,nWindowsTrial,nTrial)';
trialClasses = trialClasses(:,1);

for i = settings.classes
    idx = find(trialClasses==categorical(i));
    averageCumulOnClasses = squeeze(mean(prediction.cumul(idx,:,:)));

    figure()
    plot(t+settings.windowShift,averageCumulOnClasses)
    title(['Average cumulative predictions of class ',num2str(i)])
    legend(num2str(settings.classes'), 'Position', [0.9 0.9 0.1 0.1]);
end







