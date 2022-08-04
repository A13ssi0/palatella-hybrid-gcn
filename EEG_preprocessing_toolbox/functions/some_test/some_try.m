clear all
close all
clc

SVN_SetProjectPaths('TVLDA','Implementation');

load('chanlocs41.mat');
load('CTRL001_ekso_modeA_eeg.mat');
load('CTRL001_ekso_modeA_triggers.mat');
load('lapmask41.mat');

eeg_data = eeg_data*mask;

f_vec = [6:1:32]; % Hz
CFG.t_range = [0.75,0.1];
CFG.t_ref = [-1,-0.5];
CFG.t_indicator = 0;
CFG.downsample.enable = false;
CFG.f_step_label = 2;
CFG.t_step_label = 0.25;
fs = 250; % Hz

time_seg = 0.5;
time_overlap = time_seg*0.95;
group_id = zeros(length(eeg_data),1);
N_LA = round(time_seg*fs/2);
N_S = round((time_seg-time_overlap)*fs);

group_id(triggers.pos) = triggers.typ;
group_id = filter(ones(0.5*fs,1),1,group_id);
group_id = group_id(N_LA+1:N_S:end-N_LA);
class_vec = unique(group_id);
CFG.class_vec = num2cell(class_vec(class_vec~=0));
CFG.N_classes = numel(CFG.class_vec);
CFG.class_names = {'Left','Right'};
[y_PSD,time,~] = pow_est_core(eeg_data,fs,min(f_vec),max(f_vec),N_LA,N_S,'ar',false,10);
y_PSD = log(y_PSD);

%% trigger data
y_PSD = permute(y_PSD,[1,3,2]);
fs_psd = round(1/(time_seg - time_overlap));
[Y_trig,t_vec] = ERDS_triggerBP(y_PSD,group_id,fs_psd,CFG);
% ERD/S
% [ERDS,ES,ES2] = ERDS_computeERDS(exp(Y_trig),t_vec,CFG);
cfg.statsDiff.method = 'ES';
cfg.statsDiff.log = true;
cfg.statsDiff.B = 200;%1000;
cfg.statsDiff.alpha = 0.1;
% [Y_diff] = ERDS_statsDiff(exp(ERDS),cfg);
%% Plot Channels of interest
% ch_str = {'FC3','FC1','FCZ','FC2','FC4', ...
%     'C3','C1','CZ','C2','C4', ...
%     'CP3','CP1','CPZ','CP2','CP4'};
ch_str = {'C3','C1','CZ','C2','C4', ...
    'CP3','CP1','CPZ','CP2','CP4', ...
    'P3','P1','PZ','P2','P4'};
ch_oi = NaN(numel(ch_str),1);
for i = 1:numel(ch_oi)
    ch_oi(i) = find(strcmpi({chlocs.labels},ch_str{i}));
end
N_figures = 3;
ch_oi = reshape(ch_oi,[],N_figures)';
ch_str = reshape(ch_str,[],N_figures)';
for i = 1:N_figures
    figure('position',[50 50 1700 800]);
    [ha] = tight_subplot(CFG.N_classes,size(ch_oi,2),[0.02 0.02],[0.15 0.15],[0.07 0.01]);
    i_plt = 0;
    for i_class = 1:CFG.N_classes
        for i_col = 1:size(ch_oi,2)
            i_plt = i_plt + 1;
            axes(ha(i_plt));
            ERDS_plotMap(squeeze(ERDS(:,:,ch_oi(i,i_col),:,i_class)),t_vec,f_vec,fs_psd,[-0.6,0.6],CFG); grid on;
            if i_col == 1
                ylabel('f (Hz)');
            else
                set(gca,'YTickLabels',[]);
            end
            if i_class == CFG.N_classes
%                 xlabel('time (s)');
                xtickangle(30);
            else
                set(gca,'XTickLabels',[]);
                title(ch_str{i,i_col},'FontSize',12);
            end
        end
    end
    cb = colorbar('southoutside');
    cb.Position = [0.14 0.05 0.75 0.022];
end
%% Plot Channels of interest
% ch_str = {'FC3','FC1','FCZ','FC2','FC4', ...
%     'C3','C1','CZ','C2','C4', ...
%     'CP3','CP1','CPZ','CP2','CP4'};
ch_str = {'C3','C1','CZ','C2','C4', ...
    'CP3','CP1','CPZ','CP2','CP4', ...
    'P3','P1','PZ','P2','P4'};
ch_oi = NaN(numel(ch_str),1);
for i = 1:numel(ch_oi)
    ch_oi(i) = find(strcmpi({chlocs.labels},ch_str{i}));
end
N_figures = 3;
ch_oi = reshape(ch_oi,[],N_figures)';
ch_str = reshape(ch_str,[],N_figures)';
for i = 1:N_figures
    figure('position',[50 50 1700 500]);
    [ha] = tight_subplot(1,size(ch_oi,2),[0.02 0.02],[0.15 0.15],[0.07 0.01]);
    i_plt = 0;
    for i_col = 1:size(ch_oi,2)
        i_plt = i_plt + 1;
        axes(ha(i_plt));
        ERDS_plotMap(squeeze(Y_diff(:,:,ch_oi(i,i_col))),t_vec,f_vec,fs_psd,[-0.5,0.5],CFG); grid on;
        if i_col == 1
            ylabel('f (Hz)');
        else
            set(gca,'YTickLabels',[]);
        end
        if i_class == CFG.N_classes
%                 xlabel('time (s)');
            xtickangle(30);
        else
            set(gca,'XTickLabels',[]);
            title(ch_str{i,i_col},'FontSize',12);
        end
    end
    cb = colorbar('southoutside');
    cb.Position = [0.14 0.05 0.75 0.022];
end
%%
CV = cvpartition(90,'KFold',10);
ch_str = {'C1','CZ','C2' ...
    'CP1','CPZ','CP2', ...
    'P1','PZ','P2'};
ch_oi = NaN(numel(ch_str),1);
for i = 1:numel(ch_oi)
    ch_oi(i) = find(strcmpi({chlocs.labels},ch_str{i}));
end
% Y_trig2 = cat(2,mean(Y_trig(:,3:7,:,:,:),2),mean(Y_trig(:,9:13,:,:,:),2),mean(Y_trig(:,17:21,:,:,:),2));
Y_trig2 = Y_trig(:,:,:,:,:);
feat = reshape(Y_trig2(:,:,ch_oi,:,:),size(Y_trig2,1),3*numel(ch_oi),90,2);
z_CV = [];
for i_CV = 1:10
	idx_train = training(CV,i_CV);
	feat_train = feat(:,:,idx_train,:);
	w2 = LDA_Train_MEX(TVLDA_GetTypeIdentifier('tvlda',1,0,'ml'),feat(~isnan(feat_train(:,1)),:,randperm(size(feat_train,3)),:));
	[~,~,T3] = svd(w2,'econ');
	T3 = T3(:,1:5);
	CFG.feat.proj_mat = T3;
	cf = TVLDA_GetTypeIdentifier('atvlda',0,0,'stat');
	[w,d,c,b] = LDA_Train_MEX(cf,feat_train,CFG.feat.proj_mat);
	z = NaN(2,2,2,size(Y_trig,1),sum(~idx_train));
	xd_train = find(~idx_train);
		for i = 1:sum(~idx_train)
		z(:,:,:,:,i) = LDA_Test_MEX(cf,permute(feat(:,:,xd_train(i),:),[1,2,4,3]),w,d,c,CFG.feat.proj_mat);
		end
	z_CV = cat(6,z_CV,z);
end
%%
c = z_CV < 0; c1 = squeeze(mean(c(1,2,1,:,:,:),5)); c2 = squeeze(mean(c(2,1,2,:,:,:),5));
figure(); lineError({c1,c2},t_vec,'SD');
c1 = squeeze(mean(z_CV(1,2,1,:,:,:),5)); c2 = squeeze(mean(-z_CV(2,1,2,:,:,:),5));
figure(); lineError({c1,c2},t_vec,'SD');