function save_EEG(EEG,condition_type,output_type,settings)

savedir = strcat(settings.dirpath,settings.savedir, EEG.group, '/', ...
    EEG.group, num2str(str2num(EEG.subject), '%03d'), '/', condition_type, '/', output_type, 'EEG/');
if ~exist(savedir, 'dir')
    mkdir(savedir)
end

filename = strcat('S', EEG.subject, '_', EEG.condition, '_', ...
    num2str(EEG.session), '_', output_type, '.mat');

if whos('EEG').bytes < 2e+9
    save([savedir, filename], 'EEG')
else
    save([savedir, filename], 'EEG', '-v7.3')
end

end

