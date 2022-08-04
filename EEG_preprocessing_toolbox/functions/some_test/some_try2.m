clear all
close all
clc

SVN_SetProjectPaths('TVLDA','Implementation');

filename = 'CTRL001_ekso_modeA';

load('chanlocs41.mat');
load([filename '_eeg.mat']);
load([filename '_triggers.mat']);
load('lapmask41.mat');

% ch_str = {'C1','CZ','C2' ...
%     'CP1','CPZ','CP2', ...
%     'P1','PZ','P2'};
% ch_str = {'FC1','FCZ','FC2' ...
%     'C1','CZ','C2', ...
%     'CP1','CPZ','CP2', ...
%     'P1','PZ','P2'};
% ch_oi = NaN(numel(ch_str),1);
% for i = 1:numel(ch_oi)
%     ch_oi(i) = find(strcmpi({chlocs.labels},ch_str{i}));
% end
eeg_data = eeg_data*mask;
% eeg_data = eeg_data(:,ch_oi);

% combs = nchoosek(1:numel(ch_oi),2);
% eeg_data = eeg_data(:,combs(:,1)) - eeg_data(:,combs(:,2));


CFG.t_range = [1,0.5];
CFG.t_ref = [-0.75,-0.50];
CFG.t_indicator = 0;
CFG.downsample.enable = false;
CFG.f_step_label = 2;
CFG.t_step_label = 0.25;

fs = 250;
time_seg = 0.25;
time_overlap = time_seg*0.75;
seg_len = round((time_seg - time_overlap)*fs);
N_seg = floor(size(eeg_data,1)/seg_len);
group_id_lin = zeros(length(eeg_data),1);

group_id_lin(triggers.pos) = triggers.typ;
group_id_lin = filter(ones(0.5*fs,1),1,group_id_lin);
class_vec = unique(group_id_lin);
CFG.class_vec = num2cell(class_vec(class_vec~=0));
CFG.N_classes = numel(CFG.class_vec);
CFG.class_names = {'Left','Right'};

%% compute logBP
fs_bp = round(1/(time_seg - time_overlap));
% f_bands = {[8,12],[13,25],[26,32]};
f_bands = {[8,12],[13,25]};
cur_bp = NaN(size(eeg_data,1),size(eeg_data,2),numel(f_bands));
for i = 1:numel(f_bands)
    [b,a] = butter(4,f_bands{i}/(fs/2),'bandpass');
    cur_bp(:,:,i) = filtfilt(b,a,eeg_data);
end
cur_bp = permute(cur_bp,[1,3,2]);
group_id = group_id_lin(seg_len:seg_len:end);
y = reshape(cur_bp(1:N_seg*seg_len,:,:),seg_len,N_seg,size(cur_bp,2),size(cur_bp,3));
y = y.^2;
logBP = squeeze(mean(y,1));
logBP = movmean(logBP,[time_seg*fs_bp-1,0],1);
logBP = log(logBP);    
%% PSC
% time_PSC = 25;
% PSC = movmean(logBP,[time_PSC*fs_bp,0],1);
% logBP = logBP - PSC;
%% Trigger logBP
[Y_trig,t_vec] = ERDS_triggerBP(logBP,group_id,fs_bp,CFG);
[ERDS,ES,ES2] = ERDS_computeERDS(exp(Y_trig),t_vec,CFG);
% cfg.statsDiff.method = 'perm';
% cfg.statsDiff.log = false;
% cfg.statsDiff.B = 1000;%1000;
% cfg.statsDiff.alpha = 0.05;
% [Y_diff] = ERDS_statsDiff(ERDS,cfg);
%% Machine Learning
% N_CV = 10;
% N_runs = 10;
% feat = reshape(Y_trig,size(Y_trig,1),size(Y_trig,3)*size(Y_trig,2),size(Y_trig,4),size(Y_trig,5));
% Z = [];
% for i_run = 1:N_runs
%     rng(i_run);
%     CV = cvpartition(size(feat,3),'KFold',N_CV);
%     z_CV = [];
%     for i_CV = 1:N_CV
%         idx_train = training(CV,i_CV);
%         feat_train = feat(:,:,idx_train,:);
%         w2 = LDA_Train_MEX(TVLDA_GetTypeIdentifier('tvlda',1,0,'ml'),feat(~isnan(feat_train(:,1)),:,randperm(size(feat_train,3)),:));
%         [~,~,T3] = svd(w2,'econ');
%         T3 = T3(:,1:5);
%         CFG.feat.proj_mat = T3;
%         cf = TVLDA_GetTypeIdentifier('atvlda',0,0,'stat');
%         [w,d,c,b] = LDA_Train_MEX(cf,feat_train,CFG.feat.proj_mat);
%         z = NaN(2,2,2,size(Y_trig,1),sum(~idx_train));
%         xd_train = find(~idx_train);
%             for i = 1:sum(~idx_train)
%             z(:,:,:,:,i) = LDA_Test_MEX(cf,permute(feat(:,:,xd_train(i),:),[1,2,4,3]),w,d,c,CFG.feat.proj_mat);
%             end
%         z_CV = cat(5,z_CV,z);
%     end
%     Z = cat(6,Z,z_CV);
% end
% c = Z < 0; c1 = squeeze(mean(c(1,2,1,:,:,:),5)); c2 = squeeze(mean(c(2,1,2,:,:,:),5));
% figure(); lineError({c1,c2},t_vec,'SD');
% c1 = squeeze(mean(Z(1,2,1,:,:,:),5)); c2 = squeeze(mean(-Z(2,1,2,:,:,:),5));
% figure(); lineError({c1,c2},t_vec,'SD');
%% Plot Topography
y = Y_trig;
[N_samples,N_bands,N_ch,N_trials,N_classes] = size(y);
montage.x = -[chlocs.Y]';
montage.y = [chlocs.X]';
montage.ch_names = {chlocs.labels};
CFG.montage_pos = cat(2,montage.x,montage.y);
CFG.ch_names = montage.ch_names;
cfg.plot_contour = false;
cfg.plot_channels = true;
cfg.plot_ch_names = false;
cfg.interp_points = 200;
cfg.pos_factor = 0.6;
cfg.colormap = my_colormap(2);
for i_band = 1:N_bands
    cfg.climits = [-0.5,0.5];
    for i_class = 1:N_classes
        figure('position',[50 50 1600 800]);
        ha = tight_subplot(2,9,[0.001 0.001],[0.01 0.1],[0.05 0.05]);
        i_plt = 0;
        for i_t = 8:25
            i_plt = i_plt + 1;
            axes(ha(i_plt));
            y_plt = squeeze(median(ES2(i_t,i_band,:,:,i_class),4));
            plot_topography(montage.ch_names,y_plt,'default',cfg);
            title(sprintf('%.2f s',t_vec(i_t)),'FontSize',14);
        end
        cb = colorbar('location','southoutside');
        cb.Position = [0.16,0.03,0.7,0.03];
        cb.FontSize = 12;
        sgtitle(sprintf('%s: %s (%.1f - %.1f Hz)',strrep(filename,'_','-'),CFG.class_names{i_class},f_bands{i_band}),'FontSize',14);
    end
end
%%
combs = nchoosek(1:N_classes,2);
for i_band = 1:N_bands
    cfg.climits = [-0.5,0.5];
    for i_comb = 1:size(combs,1)
        figure('position',[50 50 1600 800]);
        ha = tight_subplot(2,9,[0.001 0.001],[0.01 0.1],[0.05 0.05]);
        i_plt = 0;
        for i_t = 8:25
            i_plt = i_plt + 1;
            axes(ha(i_plt));
            y_plt = squeeze(Y_diff(i_t,i_band,:,i_comb));
            plot_topography(montage.ch_names,y_plt,'default',cfg);
            title(sprintf('%.2f s',t_vec(i_t)),'FontSize',14);
        end
        cb = colorbar('location','southoutside');
        cb.Position = [0.16,0.03,0.7,0.03];
        cb.FontSize = 12;
        sgtitle(sprintf('%s: Difference %s-%s (%.1f - %.1f Hz)',strrep(filename,'_','-'),CFG.class_names{combs(i_comb,1)},CFG.class_names{combs(i_comb,2)},f_bands{i_band}),'FontSize',14);
    end
end