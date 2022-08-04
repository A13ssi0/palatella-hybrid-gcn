function EEG = load_EEG(info,input_type,settings)

datapath = strcat(settings.dirpath, settings.savedir, info.subj_group, '/', ...
    info.subj_group, num2str(info.subj_id, '%03d'), '/', info.condition_type, '/', input_type, 'EEG/', ...
    'S', num2str(info.subj_id), '_', info.data_mode, ...
    '_', num2str(info.session_num), '_', input_type, '.mat');
tmp = load(datapath);
EEG = tmp.EEG;

end

