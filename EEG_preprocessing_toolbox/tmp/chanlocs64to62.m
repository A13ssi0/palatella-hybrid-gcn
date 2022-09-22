clc
clear
close all

%%
load('/home/stetor/workspace/ProGait_gtec/extra/Channel_Info.mat')
eegch = ChannelInfo(45:108);
exclude = [61 62]; % [F9 F10]
eegch(exclude) = [];

load('/home/stetor/workspace/ProGait_gtec/extra/chanlocs64.mat')
allch = {chanlocs.labels}';

%%
tmp = [];
for i = 1:length(eegch)
    idx = find(strcmpi(eegch{i},allch));
    if isempty(idx)
        tmp = [tmp; nan];
    else
        tmp = [tmp; idx];
    end
    
end
chlocs = chanlocs(tmp);

%%
save('./extra/chanlocs62.mat', 'chlocs');

