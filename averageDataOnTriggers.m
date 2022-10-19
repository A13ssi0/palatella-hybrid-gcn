function avgData = averageDataOnTriggers(subj)

disp('importing the data')
filename = ['subj',num2str(subj),'_pruned.mat'];
load(filename)

secPre = 0.5;
secPost = 2;

