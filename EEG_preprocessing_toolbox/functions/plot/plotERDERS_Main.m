clear all
close all
clc

[filename,path] = uigetfile('*.mat');
load([path '\' filename]);
%% 4 Pangolin
y = DATA.R1.y;
group_id = DATA.R1.trig;
fs = 200;
%% 4 Unicorn
y = DATA.lin.y.raw;
group_id = DATA.lin.group_id;
fs = CFG.fs.lin;
%%
CFG.t_range = [0,8]; % pre and post trigger
CFG.t_ref = [1.0,1.5]; % absolute time
CFG.t_smooth = 0.10;
CFG.t_smooth_plt = 0.10;
CFG.f_width = 2;
CFG.f_step = 1;
CFG.f_range = [8,30];
CFG.class_vec = CFG.class_vec;
CFG.N_classes = CFG.N_classes;
CFG.t_step_label = 1;
CFG.f_step_label = 2;
CFG.t_indicator = 0;
%%
[Y_bp,f_vec] = ERDS_computeBP(y,fs,CFG);
[Y_trig,t_vec] = ERDS_triggerBP(Y_bp,group_id,fs,CFG);
[ERDS] = ERDS_computeERDS(Y_trig,t_vec,CFG);
dummyd = squeeze(mean(mean(trimmean(ERDS(t_vec >= 2 & t_vec <= 3,f_vec >= 8 & f_vec <= 13,:,:,1),10,4),1),2));
locations = load('HD_montage.mat');
h = plot_topography(CFG.montage, dummyd*100, false, locations, ...
    true, false, 1000);

% clear DATA y Y_bp Y_trig
%%
for i = 1:160
    [Y_bp,f_vec] = ERDS_computeBP(y(:,i),fs,CFG);
    [Y_trig,t_vec] = ERDS_triggerBP(Y_bp,group_id',fs,CFG);
    [ERDS] = ERDS_computeERDS(Y_trig,t_vec,CFG);
    figure('position',[50 50 1200 600]);
    for ii = 1:2
        subplot(1,2,ii);
        [c,plt] = ERDS_plotMap(squeeze(ERDS(:,:,1,:,ii)),t_vec,f_vec,fs,CFG);
    end
    sgtitle(num2str(i));
    cb = colorbar('southoutside');
    cb.Position = [0.14 0.03 0.75 0.022];
    close all;
end
%%
dummyd = squeeze(mean(mean(trimmean(ERDS(t_vec >= 2 & t_vec <= 3,f_vec >= 8 & f_vec <= 13,:,:,1),10,4),1),2));

[pos_1,idx_1] = sort(CFG.montage_pos(:,1));
[pos_2,idx_2] = sort(CFG.montage_pos(:,2));
dummyd_M = zeros(numel(dummyd));
for i = 1:numel(dummyd)
    dummyd_M(idx_1(i),idx_2(i)) = dummyd(i);
end
contourf(pos_1,pos_2,dummyd_M,'LineStyle','none');