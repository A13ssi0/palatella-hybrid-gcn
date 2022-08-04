function EEG = compute_asr(EEG, settings)

% Parameters
fs = settings.eeg.fs;
th = settings.eeg.asr.th; % [std]
blocksize = settings.eeg.asr.block_size;
windowlen = settings.eeg.asr.window_length; % [sec]
windowlap = settings.eeg.asr.window_overlap; % [%]
stepsize = floor(settings.eeg.fs*windowlen/2);
maxbadchans = settings.eeg.asr.max_bad_channels;


% Clean calibration data
if settings.eeg.asr.auto_calib
    disp('[compute_asr] ASR is auto-calibrated on the processed data')
    EEG1 = EEG;
else
    disp('[compute_asr] Reference data for ASR calibration are provided')
    EEG1 = EEG.other.resting;
%     EEG1 = clean_asr(EEG1,th,windowlen,blocksize,[],...
%         maxbadchans,[],windowlen); % NOT SURE IT IS CORRECT!
end
disp('[compute_asr] Extracting clean reference widows')
ref_section = clean_windows(EEG1, maxbadchans);

% calibrate on the reference data
state = asr_calibrate(ref_section.data, fs, ...
    th, blocksize, [], [], windowlen, windowlap);  % calibrate the parameters of the method (sampling rate 100Hz)

data = EEG.data;
if settings.eeg.asr.iterative
    disp(['[compute_asr] Applying iterative ASR (th = ', ...
        num2str(settings.eeg.asr.iter_th), ', max iter = ', ...
        num2str(settings.eeg.asr.max_iter),')'])
    diff = 1;
    for it = 1:settings.eeg.asr.max_iter
        fprintf('  - iteration %d: ', it)
        cleandata = asr_apply(data, fs, state, windowlen, windowlen/2, stepsize);
        diff = abs(norm(cleandata,1)-norm(data,1))/norm(data,1);
        fprintf('       difference %f \n', diff)
        if diff < settings.eeg.asr.iter_th
            break;
        else
            data = cleandata;
        end
    end
    
else
    disp('[compute_asr] Applying single-shot ASR')
    cleandata = asr_apply(data, fs, state, windowlen, windowlen/2, stepsize);
    
end
EEG.data = cleandata;

end

% th = settings.eeg.asr.th;
% winLen = settings.eeg.asr.window_length;
% fs = settings.eeg.fs;
% del = settings.begin_delay*settings.eeg.fs;
% 
% data = ASR(EEG.data(:,del:end)',th,winLen,fs);
% EEG.data(:,del:end) = data';