close all; clearvars; clc;

subjects = [7 11 15 19 23]; 

doHilbert = true;
%%
nTriggers = 0;
for sbj = subjects

    data = divideDataByTriggers(sbj, doHilbert);
    nTriggers = nTriggers + size(data,3);

    if ~exist('timeAverage','var'), timeAverage = zeros(size(data,1,2)); end

    timeAverage = timeAverage + sum(data,3);
    
end

timeAverage = timeAverage/nTriggers;

save timeCourseTriggerAverageHilbert.mat  timeAverage
%%
% secPre = 0.5;
% secPost = 2;
% fc = 500;
% x = -secPre:1/fc:secPost;
% for i = 1:6
%     figure
%     plot(x,timeAverage(i,:))
%     title(num2str(i))
%     xlim([x(1) x(end)])
%     pause()
% end