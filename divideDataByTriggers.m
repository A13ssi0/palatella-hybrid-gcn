function dividedData = divideDataByTriggers(subj)


secPre = 0.5;
secPost = 2;


disp('importing the data')
filename = ['subj',num2str(subj),'_pruned.mat'];
load(filename)

emg = subj.emg.data;
fc = subj.emg.srate;
triggersTime = subj.triggers.time;

nPointPre = secPre*fc;
nPointPost = secPost*fc;
rangeTime = nPointPre:nPointPost;

data = nan(size(emg,1), nPointPost+nPointPre+1, length(triggersTime));

for i = 1:length(triggersTime)
    data(:,:,i) = emg(:, triggersTime(i)+rangeTime);
end

dividedData = mean(data,3);

