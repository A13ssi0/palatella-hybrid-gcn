%% Plot data scroll
eegplot(EEG1.data, 'srate', EEG1.srate, 'eloc_file', EEG1.chanlocs);

%% Plot single-chan
ch = 'C3';
or_eeg = (EEG_or.data(fidx({ch}, {EEG_or.chanlocs.labels}),:))';  
pr_eeg = (EEG.data(fidx({ch}, {EEG.chanlocs.labels}),:))';

or_eeg = or_eeg-mean(or_eeg);
time = 0:1/settings.eeg.fs:length(pr_eeg)/settings.eeg.fs-1/settings.eeg.fs;

figure
plot(time,or_eeg)
hold on
plot(time,pr_eeg)
legend({'original', 'processed'})
xlabel('time')
ylabel(ch)

%% Plot single-chan spectrum
ch = 'P3';
or_eeg = (EEG_or.data(fidx({ch}, {EEG_or.chanlocs.labels}),:))';  
pr_eeg = (EEG.data(fidx({ch}, {EEG.chanlocs.labels}),:))';

figure
spectrumplot([or_eeg, pr_eeg], settings.eeg.fs, true, {'raw', 'preprocessed'});
title(['Channel ', ch])

%% Plot multi-chan
plot_ch = {'FC3';'FCz';'FC4';...
           'C3';'Cz';'C4';...
      'CP1';'CPz';'CP2';...
           'P3';'Pz';'P4'};

plot_ch_idx = fidx(plot_ch, {EEG.chanlocs.labels});
or_eeg = (EEG_or.data(plot_ch_idx,:))';  
pr_eeg = (EEG.data(plot_ch_idx,:))';

time = 0:1/settings.eeg.fs:length(pr_eeg)/settings.eeg.fs-1/settings.eeg.fs;

tb_eeg = table([or_eeg(:,1)-mean(or_eeg(:,1)), pr_eeg(:,1)], 'VariableNames', plot_ch(1));
for i = 2:length(plot_ch)
    tb_eeg = [tb_eeg table([or_eeg(:,i)-mean(or_eeg(:,i)), pr_eeg(:,i)], 'VariableNames', plot_ch(i))];
end

figure
stackedplot(tb_eeg)

%% Plot multi-chan epochs
plot_ch = {'FC3';'FCz';'FC4';...
           'C3';'Cz';'C4';...
      'CP3';'CPz';'CP4';...
           'P3';'Pz';'P4';...
           'PO3';'POz';'PO4'};
plot_ch_idx = fidx(plot_ch, {EEG.chanlocs.labels});

n_fig = 5;
eps = floor(linspace(1,EEG.trials,n_fig+1));
% eps = floor(linspace(1,60,n_fig+1));

for f = 1:n_fig
    
    or_eeg = (reshape(EEG_or.data(plot_ch_idx,:,eps(f):eps(f+1)),[length(plot_ch_idx)...
        size(EEG_or.data,2)*length(eps(f):eps(f+1))]))';
    pr_eeg = (reshape(EEG.data(plot_ch_idx,:,eps(f):eps(f+1)),[length(plot_ch_idx)...
        size(EEG.data,2)*length(eps(f):eps(f+1))]))';
    
    tb_eeg = table([or_eeg(:,1)-mean(or_eeg(:,1)), pr_eeg(:,1)], 'VariableNames', plot_ch(1));
    for i = 2:length(plot_ch)
        tb_eeg = [tb_eeg table([or_eeg(:,i)-mean(or_eeg(:,i)), pr_eeg(:,i)], 'VariableNames', plot_ch(i))];
    end
    
    
    figure
    s = stackedplot(tb_eeg);
    pos = s.Position;
    xlims = s.xlim;
    line_locations = EEG.pnts:EEG.pnts:size(pr_eeg,1)-EEG.pnts;
    line_locations_norm = interp1(xlims, cumsum(pos([1 3])), line_locations);
    for i=1:numel(line_locations_norm)
        annotation('line', ...
            [line_locations_norm(i) line_locations_norm(i)], ...
            [pos(2) pos(2)+pos(4)], ...
            'Color', 'g', ...
            'LineWidth', 1);
    end
    title(['Epochs from ', num2str(eps(f)), ' to ', num2str(eps(f+1))])
    
    for a = 1:length(s.AxesProperties)
        s.AxesProperties(a).LegendVisible = 'off';
    end
end

%% Plot single-chan ERDS
ch = 'Cz';
plot_ch_idx = fidx({ch}, {EEG.chanlocs.labels});
ERDS = squeeze(permute(EEG.other.es.mean(plot_ch_idx,:,:,:), [2 4 3 1]));

figure
ERDS_plotMap(ERDS(:,:,:),EEG.times(:),EEG.frequencies,...
    EEG.srate,[-0.2 0.2],...
    settings.eeg.erds.bandpower, true);
xlabel('Time [ms]')
ylabel('Frequency [Hz]')
title(['Channel ', ch])

%% Plot multi-chan ERDS
plot_ch = {'FC3';'FC1';'FCz';'FC2';'FC4';...
           'C3';'C1';'Cz';'C2';'C4';...
      'CP3';'CP1';'CPz';'CP2';'CP4';...
           'P3';'P1';'Pz';'P2';'P4'};
plot_ch_idx = fidx(plot_ch, {EEG.chanlocs.labels});
ERDS = permute(EEG.data(plot_ch_idx,:,:,:), [2 4 3 1]);

figure
for c = 1:length(plot_ch)
    subplot(4,5,c)
    ERDS_plotMap(ERDS(:,:,:,c),EEG.times(:),EEG.frequencies,...
    EEG.srate,[-0.4 0.4],...
    settings.eeg.erds.bandpower, false);
    title(plot_ch{c})
    xlabel('Time [ms]')
    ylabel('Frequency [Hz]')
end

%% Plot multi-chan ES
plot_ch = {'FC3';'FC1';'FCz';'FC2';'FC4';...
           'C3';'C1';'Cz';'C2';'C4';...
      'CP3';'CP1';'CPz';'CP2';'CP4';...
           'P3';'P1';'Pz';'P2';'P4'};
plot_ch_idx = fidx(plot_ch, {EEG.chanlocs.labels});
ERDS = permute(EEG.other.es.mean(plot_ch_idx,:,:,:), [2 4 3 1]);

figure
for c = 1:length(plot_ch)
    subplot(4,5,c)
    ERDS_plotMap(ERDS(:,:,:,c),EEG.times(:),EEG.frequencies,...
    EEG.srate,[-0.3 0.3],...
    settings.eeg.erds.bandpower, true);
    title(plot_ch{c})
    xlabel('time [s]')
    ylabel('Fequency [Hz]')
end

%% Plot single-chan ERSP
ch = 'Cz';
ersp_type = 'right_leg'; % 'right_leg', 'left_leg'
plot_ch_idx = fidx({ch}, {EEG.chanlocs.labels});
ERSP = squeeze(EEG.other.ersp.(ersp_type).data(plot_ch_idx,:,:));

CFG.tlimits = [0 100];
CFG.flimits = [6 35];
CFG.fsteps = 8;
CFG.fdown = 1;
CFG.climits = [-1.2 1.2];

figure
% ERSP_plotMap(ERSP,EEG.times,EEG.frequencies,CFG,[],[],'jet');
ERSP_plotMap(ERSP,times,freqs,CFG,[],[],'jet');
cb = colorbar('southoutside');
cb.Label.String = 'ERSP [dB]';
cb.Label.FontWeight = 'bold';
cb.Label.FontSize = 14;
% xlabel('Time [ms]', 'FontSize', 14)
xlabel('Gait cycle [%]', 'FontSize', 14)
ylabel('Frequency [Hz]', 'FontSize', 14)
title(['Channel ', ch], 'FontSize', 14)

%% Plot multi-chan ERSP
plot_ch = {'FC3';'FC1';'FCz';'FC2';'FC4';...
           'C3';'C1';'Cz';'C2';'C4';...
      'CP3';'CP1';'CPz';'CP2';'CP4';...
           'P3';'P1';'Pz';'P2';'P4'};
ersp_type = 'stepcycle'; % 'right_leg', 'left_leg'
plot_ch_idx = fidx(plot_ch, {EEG.chanlocs.labels});
ERSP = squeeze(EEG.other.ersp.(ersp_type).data(plot_ch_idx,:,:));

CFG.tlimits = [0 100];
CFG.flimits = [6 30];
CFG.fsteps = 8;
CFG.fdown = 4;
CFG.climits = [-1.2 1.2];

figure
for c = 1:length(plot_ch)
    subplot(4,5,c)
    ERSP_plotMap(squeeze(ERSP(c,:,:)),EEG.times./1000,EEG.frequencies,CFG,[],[],'jet');
    xlabel('Time [ms]')
    ylabel('Frequency [Hz]')
    title(plot_ch{c})
end

%% Plot ERSP Topography
load chanlocs64.mat
plot_ch_idx = fidx({EEG.chanlocs.labels}, {chanlocs.labels});
ersp_type = 'stepcycle';
CFG.tlimits = [0 100]; % [-0.2 1.0]
CFG.tsteps = 10; %0.2
CFG.fbands = [4 8; 8 13; 14 24; 25 35]; % alpha, beta, low-gamma
CFG.climits = [-1.5 1.5];

t_vec = EEG.times;%./1000;
f_vec = EEG.frequencies;

tbands = CFG.tlimits(1):CFG.tsteps:CFG.tlimits(2);
ntopos = length(tbands)-1;
N_bands = size(CFG.fbands,1);
N_rows = 1;

for i_band = 1:N_bands
    f_idx = f_vec >= CFG.fbands(i_band,1) & f_vec <= CFG.fbands(i_band,2);
    ERSP = mean(EEG.other.ersp.(ersp_type).data(:,:,f_idx),3);
    
    figure('position',[50 50 1600 800]);
    ha = tight_subplot(N_rows,ceil(ntopos/N_rows),[0.001 0.001],[0.01 0.1],[0.05 0.05]);
    for i_t = 1:ntopos
        axes(ha(i_t));
        t_idx = t_vec >= tbands(i_t) & t_vec <= tbands(i_t+1);
        y_t = squeeze(mean(ERSP(:,t_idx),2));
        y_plt = zeros(length(chanlocs),1);
        y_plt(plot_ch_idx) = y_t;
        topoplot(y_plt, chanlocs, 'maplimits', CFG.climits, 'electrodes', 'off');
%         title(sprintf('%.2f s',mean([tbands(i_t) tbands(i_t+1)])),'FontSize',14);
    end
    cb = colorbar('location','southoutside');
    cb.Position = [0.16,0.03,0.7,0.03];
    cb.FontSize = 12;
    sgtitle(sprintf('%s (%.1f - %.1f Hz)',strrep(ersp_type,'_',' '),CFG.fbands(i_band,1),CFG.fbands(i_band,2)),'FontSize',14);
end

%% Plot CMC Topography
load chanlocs64.mat
plot_ch_idx = fidx({EEG.chanlocs.labels}, {chanlocs.labels});
cmc_type = 'stepcycle';
CFG.tlimits = [0 100]; % [-0.2 1.0]
CFG.tsteps = 10; %0.2
CFG.fbands = [4 8; 8 13; 14 24]; % delta, alpha, beta, low-gamma
CFG.climits = [0 0.5];

t_vec = EEG.times;%./1000;
f_vec = EEG.frequencies;

tbands = CFG.tlimits(1):CFG.tsteps:CFG.tlimits(2);
ntopos = length(tbands)-1;
N_bands = size(CFG.fbands,1);

for m = 1:4%:EEG.other.emg.nbemg
    figure('position',[50 50 1600 800]);
    sgtitle(sprintf('CMC %s',EEG.other.emg.label{m}),'FontSize',14);
    ha = tight_subplot(N_bands,ntopos,[0.001 0.001],[0.01 0.1],[0.05 0.05]);
    for i_band = 1:N_bands
        f_idx = f_vec >= CFG.fbands(i_band,1) & f_vec <= CFG.fbands(i_band,2);
        CMC = squeeze(mean(EEG.other.cmc.(cmc_type).data(f_idx,:,:,m),1));      
        for i_t = 1:ntopos
            axes(ha(i_t+(i_band-1)*ntopos));
            t_idx = t_vec >= tbands(i_t) & t_vec <= tbands(i_t+1);
            y_t = (squeeze(mean(CMC(t_idx,:),1)))';
            y_plt = zeros(length(chanlocs),1);
            y_plt(plot_ch_idx) = y_t;
            topoplot(y_plt, chanlocs, 'maplimits', CFG.climits, 'electrodes', 'off');
            %         title(sprintf('%.2f s',mean([tbands(i_t) tbands(i_t+1)])),'FontSize',14);
        end
        cb = colorbar('location','southoutside');
        cb.Position = [0.16,0.03,0.7,0.03];
        cb.FontSize = 12;
    end
end

%% Plot single-chan ERSP over gait cycle
ch = 'Pz';
plot_ch_idx = fidx({ch}, {EEG.chanlocs.labels});
ERSP = squeeze(EEG.other.ersp.stepcycle.data(plot_ch_idx,:,:));
trig_avgprc = cumsum(round(avg_trig_perc(EEG.other.imu.triggers.trig_epoch).*100));
t_indicator = [0  trig_avgprc(1:end-1)' 100];
t_indicator_lbl = ["RTO" "RHS" "LTO" "LHS" "RTO"];
% t_indicator = [0  50 100];
% t_indicator_lbl = ["RTO" "LTO" "RTO"];

CFG.tlimits = [0 100];
CFG.flimits = [2 40];
CFG.fsteps = 8;
CFG.fdown = 4;
CFG.climits = [-2.0 2.0];

figure
ERSP_plotMap(ERSP,EEG.times,EEG.frequencies,CFG,t_indicator,t_indicator_lbl,'jet');
cb = colorbar;
cb.Label.String = 'ERSP [dB]';
cb.Label.FontWeight = 'bold';
cb.Label.FontSize = 14;
xlabel('Gait cycle [%]', 'FontSize', 14)
ylabel('Frequency [Hz]', 'FontSize', 14)
title(['Channel ', ch], 'FontSize', 14)

function trig_avgprc = avg_trig_perc(trig)

ntrigs = size(trig{1},1);
trig_mat = cell2mat(trig);
trig_rep = reshape(trig_mat(:,2), [ntrigs size(trig_mat,1)/ntrigs]);
trig_diff = diff(trig_rep);
trig_all_dur = trig_rep(end,:)-trig_rep(1,:);

trig_prc = trig_diff ./ repmat(trig_all_dur, [size(trig_diff,1) 1]);
trig_avgprc = trimmean(trig_prc,10,2);

end
