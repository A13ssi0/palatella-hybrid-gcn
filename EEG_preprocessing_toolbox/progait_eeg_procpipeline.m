clc
clear
close all

%% Load dataset from mat
% Settings
progait_settings;
info.subj_group = 'CTRL'; % CTRL, PTRL
info.subj_id = 6;
info.data_mode = 'walking'; % ekso_modeA, ekso_modeF, ekso_modeM, walking
info.condition_type = 'FreeWalking'; % EcsoWalking, 'FreeWalking'
info.session_num = 3;

%% Compute triggers
input_type = 'eeglab'; %can be any
input_load = true;
if input_load
    EEG = load_EEG(info,input_type,settings);
end

output_type = 'triggers'; % cca_triggers_v2 (cca with FC neg peak), cca_triggers_v3 (cca with FC pos peak)
output_save = true;

settings.imu.trigger.method = 'step_cycle'; %velocity_threshold, swing, step_cycle, toe_off
EEG = compute_triggers(EEG, settings);

if output_save
    save_EEG(EEG,info.condition_type,output_type,settings);
end

%% Compute preprocessing
input_type = 'triggers'; % or eeglab
input_load = true;
output_type = 'preproc_ref';
output_save = true;
info.session_num = [1 2 3];

for s = 1:length(info.session_num)
    info2 = info; info2.session_num = info.session_num(s);
    if input_load
        EEG = load_EEG(info2,input_type,settings);
    end   
    
    EEG_or = EEG;
    EEG = compute_preprocessing(EEG, settings);
    if isfield(EEG.other, 'resting')
        EEG.other.resting = compute_preprocessing(EEG.other.resting, settings);
    end
    
    if output_save
        save_EEG(EEG,info2.condition_type,output_type,settings);
    end
end

%% Compute ASR
input_type = 'preproc_ref';
input_load = true;
output_type = 'asr';
output_save = true;
info.session_num = [2 3];

for s = 1:length(info.session_num)
    info2 = info; info2.session_num = info.session_num(s);
    if input_load
        EEG = load_EEG(info2,input_type,settings);
    end
    
    EEG_or = EEG;
    EEG = compute_asr(EEG, settings);
    
    if output_save
        save_EEG(EEG,info.condition_type,output_type,settings);
    end
end

%% Merge sessions
clear EEG
input_type = 'asr';
info.session_nums = [1 2 3];
EEG = merge_EEG(info,input_type,settings);

output_type = 'merge';
output_save = true;
if output_save
    save_EEG(EEG,info.condition_type,output_type,settings);
end

%% Compute ICA
info.session_num = 123; %123
input_type = 'merge';
input_load = true;
if input_load
    EEG = load_EEG(info,input_type,settings);
end

output_type = settings.eeg.ica.method;
output_save = true;

EEG_or = EEG;
EEG = compute_ica(EEG, settings);

if output_save
    save_EEG(EEG,info.condition_type,output_type,settings);
end

%% IC selection - part I
info.session_num = 123; %123
input_type = 'amica';
input_load = true;
if input_load
    EEG = load_EEG(info,input_type,settings);
end

EEG1 = compute_extractepochs(EEG,settings);
EEG1.icaact = geticaact(EEG1);
EEG1 = iclabel(EEG1);
[art_comps]=ADJUST(EEG1,'report.txt');
pop_viewprops(EEG1, 0);

%% IC selection - part II
prompt = 'Enter the components to remove:\n';
rm_comps = (str2num(input(prompt, "s")))';

EEG_or = EEG;
EEG = compute_subcomp(EEG,rm_comps,settings);

output_type = 'clean';
output_save = true;
if output_save
    save_EEG(EEG,info.condition_type,output_type,settings);
end

%% Compute CCA
input_type = 'clean';
input_load = true;
output_type = 'cca';
output_save = true;
info.session_num = 123;

if input_load
    EEG = load_EEG(info,input_type,settings);
end

EEG_or = EEG;
EEG = compute_cca(EEG, settings);

if output_save
    save_EEG(EEG,info.condition_type,output_type,settings);
end

%% Compute ERDS
info.session_num = 123; %123
input_type = 'cca';
input_load = true;
if input_load
    EEG = load_EEG(info,input_type,settings);
end

EEG = compute_erds(EEG, settings);
% EEG = compute_erds_v2(EEG, settings);

output_type = settings.eeg.erds.method;
output_save = true;
if output_save
    save_EEG(EEG,info.condition_type,output_type,settings);
end

%% Compute Event-Related Spectral Perturbation (ERSP)
info.session_num = 123; %123
input_type = 'cca';
input_load = true;
if input_load
    EEG = load_EEG(info,input_type,settings);
end

% EEG = compute_ersp(EEG,settings);
% EEG = compute_ersp_new(EEG,settings);
EEG = compute_ersp_new2(EEG,settings);

output_type = 'ersp_mean_lap';
output_save = true;
if output_save
    save_EEG(EEG,info.condition_type,output_type,settings);
end

%% Compute Cortico-Muscular Coherence (CMC)
info.session_num = 12; %123
input_type = 'cca';
input_load = true;
if input_load
    EEG = load_EEG(info,input_type,settings);
end

EEG = compute_cmc(EEG,settings);

output_type = 'cmc_hil_lap';
output_save = true;
if output_save
    save_EEG(EEG,info.condition_type,output_type,settings);
end

%% Load data
info.session_num = 12; %123
input_type = 'cmc_hil';
EEG = load_EEG(info,input_type,settings);


