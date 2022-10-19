close all; clearvars; clc;

subjects = [7 11 15 19 23]; 

%%
nTriggers = 0;
for sbj = subjects

    data = divideDataByTriggers(sbj);
    nTriggers = nTriggers + size(data,3);

    if ~exist('timeAverage','var'), timeAverage = zeros(size(data,1,2)); end

    timeAverage = timeAverage + sum(data,3);
    
end

timeAverage = timeAverage/nTriggers;