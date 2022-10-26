function dividedData = divideDataByTriggers(subj, doHilbert)


secPre = 0.5;
secPost = 2;


disp(['importing the data subject ',num2str(subj)])
filename = ['subj',num2str(subj),'_pruned.mat'];
load(filename)

if doHilbert
    emg = hilbert(subj.emg.data');
    emg = abs(emg');
else 
    emg = subj.emg.data;
end


fc = subj.emg.srate;
triggersTime = subj.triggers.time;

nPointPre = secPre*fc;
nPointPost = secPost*fc;
rangeTime = -nPointPre:nPointPost;

dividedData = nan(size(emg,1), length(rangeTime), length(triggersTime));

for i = 1:length(triggersTime)
    dividedData(:,:,i) = emg(:, triggersTime(i)+rangeTime);
end

