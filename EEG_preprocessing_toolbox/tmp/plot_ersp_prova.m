clc
clear
close all

%% Load dataset from mat
% Settings
progait_settings;
info.subj_group = 'CTRL'; % CTRL, PTRL
info.subj_id = 1;
info.data_mode = {'ekso_modeA', 'ekso_modeM', 'ekso_modeF', 'walking'}; % ekso_modeA, ekso_modeF, ekso_modeM, walking
info.condition_type = {'EcsoWalking', 'EcsoWalking', 'EcsoWalking', 'FreeWalking'}; % EcsoWalking, 'FreeWalking'
info.session_num = [123, 123, 123, 12];

%%
input_type = 'ersp_mean_lap';
mbase = [];
EEG_power = [];
EEG_ersp = [];
for d = 1:length(info.data_mode)
    info2 = info; 
    info2.data_mode = info.data_mode{d}; info2.condition_type = info.condition_type{d}; info2.session_num = info.session_num(d);
    EEG = load_EEG(info2,input_type,settings);
    times = EEG.times;
    freqs = EEG.frequencies;
    mbase = cat(3, mbase, EEG.other.ersp.stepcycle.mbase);
    EEG_power = cat(4, EEG_power, EEG.other.ersp.stepcycle.power);
    EEG_ersp = cat(4, EEG_ersp, EEG.other.ersp.stepcycle.data);
end
mbase = (mean(mbase,3))';
EEG_power = permute(EEG_power, [3 2 1 4]); % [frqs, smps, chans, mods]
EEG_ersp = permute(EEG_ersp, [3 2 1 4]); % [frqs, smps, chans, mods]

%%
EEG_ersp = nan(size(EEG_power));
for d = 1:size(EEG_power,4)
    for c = 1:size(EEG_power,3)
        EEG_ersp(:,:,c,d) = bsxfun(@rdivide, squeeze(EEG_power(:,:,c,d)), mbase(:,c));
    end
end
EEG_ersp = 10*log10(EEG_ersp);

%%
ch = 'CPz';
plot_ch_idx = fidx({ch}, {EEG.chanlocs.labels});
CFG.tlimits = [0 100];
CFG.flimits = [2 40];
CFG.fsteps = 8;
CFG.fdown = 4;
CFG.climits = [-1.2 1.2];

figure
sgtitle(['Channel ', ch], 'FontSize', 14)
for d = 1:size(EEG_ersp,4)
    ERSP = (squeeze(EEG_ersp(:,:,plot_ch_idx,d)))';
    
    subplot(size(EEG_ersp,4)/2,size(EEG_ersp,4)/2,d)
    ERSP_plotMap(ERSP,times,freqs,CFG,[],[],'jet');
    cb = colorbar;
    cb.Label.String = 'ERSP [dB]';
    cb.Label.FontWeight = 'bold';
    cb.Label.FontSize = 14;
    xlabel('Gait cycle [%]', 'FontSize', 14)
    ylabel('Frequency [Hz]', 'FontSize', 14)
    title(info.data_mode{d}, 'FontSize', 14, 'Interpreter', 'none')
    
end


