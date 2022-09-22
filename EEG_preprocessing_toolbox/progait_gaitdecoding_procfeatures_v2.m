clc
clear
% close all

%% Load dataset from mat
% Settings
progait_settings;
info.subj_group = 'CTRL'; % CTRL, PTRL
info.subj_id = 1;
info.data_mode = 'ekso_modeM'; % ekso_modeA, ekso_modeF, ekso_modeM, walking
info.condition_type = 'EcsoWalking'; % EcsoWalking, 'FreeWalking'
info.session_num = 123;

%% Load data
disp('Loading data...')
input_type = 'cca_triggers_v2';

EEG = load_EEG(info,input_type,settings);

eeg_nchans = EEG.nbchan;
emg_nchans = length(EEG.other.emg.label);
nsamples = EEG.pnts;

%% Process the EMG signal
disp('Processing EMG...')
order = 4;
fcutoff = 5;
[b,a] = butter(order, fcutoff*2/settings.emg.fs, 'high');
EEG.other.emg.data = filtfilt(b,a,EEG.other.emg.data);
h_emg = hilbert(EEG.other.emg.data);
EEG.other.emg.data = abs(h_emg);

%% Compute features
disp('Computing features...')
% win_len = 1.2; % [sec] 0.8
fft_win_len = 0.4; % [sec]
% win_shift = 0.032; % [sec] 0.04 0.032
fft_win_shift = 0.032; % [sec] 0.008
padratio = 1;
Fs = 250; % [Hz]
freq_sel = [2 40];

% win_size = win_len*Fs;
fft_win_size = fft_win_len*Fs;
% win_step = win_shift*Fs;
fft_win_step = fft_win_shift*Fs;

freqs = linspace(0, Fs/2, fft_win_size*padratio/2+1);
freqs = freqs(2:end);
freq_idx = freqs >= freq_sel(1) & freqs <= freq_sel(2);
freqs = freqs(freq_idx);
nfreqs = length(freqs);

window = hanning(fft_win_size);

n_fft_wins = fix((nsamples-(fft_win_size-fft_win_step))/fft_win_step);
Sxx = nan(n_fft_wins,nfreqs,eeg_nchans);
Syy = nan(n_fft_wins,nfreqs,emg_nchans);
Sxy = nan(n_fft_wins,nfreqs,eeg_nchans,emg_nchans);
for w = 1:n_fft_wins
    start = (w-1)*fft_win_step+1; stop = start + fft_win_size - 1;
    
    tmpX = (EEG.data(:,start:stop))';
    tmpX = bsxfun(@minus, tmpX, mean(tmpX,1));
    tmpX = bsxfun(@times, tmpX, window);
    fftX = fft(tmpX,padratio*fft_win_size);
    fftX = fftX(2:padratio*fft_win_size/2+1,:);
    fftX = 2/0.375*fftX/fft_win_size;
    fftX = fftX(freq_idx,:);
    
    tmpY = EEG.other.emg.data(start:stop,:);
    tmpY = bsxfun(@minus, tmpY, mean(tmpY,1));
    tmpY = bsxfun(@times, tmpY, window);
    fftY = fft(tmpY,padratio*fft_win_size);
    fftY = fftY(2:padratio*fft_win_size/2+1,:);
    fftY = 2/0.375*fftY/fft_win_size;
    fftY = fftY(freq_idx,:);
    
    Sxx(w,:,:) = fftX.*conj(fftX);
    Syy(w,:,:) = fftY.*conj(fftY);
    
    repX = repmat(fftX,[1 1 size(fftY,2)]);
    repY = repmat(fftY,[1 1 size(fftX,2)]);
    Sxy(w,:,:,:) = repX.*conj(permute(repY,[1 3 2]));   
end

% mavg_step = win_step/fft_win_step;
% Sxx = movmean(Sxx,[win_size 0]);
% Syy = movmean(Syy,[win_size 0]);
% Sxy = movmean(Sxy,[win_size 0]);
% 
% if mavg_step > 1
%     Sxx = Sxx(1:mavg_step:end,:,:);
%     Syy = Syy(1:mavg_step:end,:,:);
%     Sxy = Sxy(1:mavg_step:end,:,:,:);
% end

% repX = repmat(Sxx, [1 1 1 size(Syy,3)]);
% repY = repmat(Syy, [1 1 1 size(Sxx,3)]);
% COH = abs(Sxy)./sqrt(repX.*permute(repY,[1 2 4 3]));

%% Create gait labels
disp('Creating labels...')
triggers = EEG.other.imu.triggers.event;
triggers.pos = proc_pos2win(triggers.pos, fft_win_step, 'backward', fft_win_size);

gait_labels = nan(n_fft_wins,1);
bouts_labels = zeros(n_fft_wins,1);

[gait_typ,gait_pos] = find_events(triggers,[settings.leg.R.FC; settings.leg.R.IC; settings.leg.L.FC; settings.leg.L.IC]);
[bouts_typ,bouts_pos] = find_events(triggers,[settings.imu.trigger.BOUTS_START settings.imu.trigger.BOUTS_STOP]);
bcount = 0;
for b = 1:2:length(bouts_typ)-1
    % bouts boundaries
    bcount = bcount + 1;
    bstr = bouts_pos(b);
    bstp = bouts_pos(b+1);  
    gait_labels(bstr:bstp) = zeros(length(bstr:bstp),1);
    bouts_labels(bstr:bstp) = bcount*ones(length(bstr:bstp),1);
    
    typ_b = gait_typ(gait_pos >= bstr & gait_pos <= bstp);
    pos_b = gait_pos(gait_pos >= bstr & gait_pos <= bstp);
    
    fc = find(typ_b == settings.leg.L.FC | typ_b == settings.leg.R.FC);
    for i = 1:length(fc)
        gait_labels(pos_b(fc(i)):pos_b(fc(i)+1)-1) = typ_b(fc(i))*ones(length(pos_b(fc(i)):pos_b(fc(i)+1)-1),1);
    end  
end

% if mavg_step > 1
%     gait_labels = gait_labels(1:mavg_step:end);
%     bouts_labels = bouts_labels(1:mavg_step:end);
% end

%% Save
disp('Saving data...')
output_type = 'forGaitDecoding_v2';
savedir = strcat(settings.dirpath, settings.savedir, info.subj_group, '/', ...
    info.subj_group, num2str(info.subj_id, '%03d'), '/', info.condition_type, '/', output_type, '/');
if ~exist(savedir, 'dir')
    mkdir(savedir)
end
filename = strcat('S', num2str(info.subj_id), '_', info.data_mode, ...
    '_', num2str(info.session_num), '_', output_type, '.mat');
save([savedir, filename], 'Sxx', 'Syy', 'Sxy', 'gait_labels', 'bouts_labels', 'triggers', '-v7.3')

%% Test the features
% [coh_epoch, trig_epoch] = extractstepcycles(COH,triggers,settings);
% 
% trials = length(coh_epoch);
% ntimesout = 500;
% coh_cycle = nan([ntimesout, size(coh_epoch{1},[2:4]), trials]);
% for t = 1:trials
%     % ODD-MIRRORING (avoid edge distortion)
%     mirror_len = 50; % mirror length in samples
%     coh_cycle(:,:,:,:,t) = resample_withmirror(coh_epoch{t},ntimesout,size(coh_epoch{t},1),1,mirror_len);
% end
% coh_cycle(coh_cycle<0) = 0;
% coh_cycle = mean(coh_cycle,5);
% 
% figure
% imagesc((squeeze(coh_cycle(:,:,18,7)))',[0 0.35])
% title('CMC'), xlabel('Gait cycle [%]'), ylabel('Frequencies [Hz]')

%%
[sxx_epoch, trig_epoch] = extractstepcycles(Sxx,triggers,settings);
[syy_epoch, trig_epoch] = extractstepcycles(Syy,triggers,settings);
[sxy_epoch, trig_epoch] = extractstepcycles(Sxy,triggers,settings);

trials = length(sxx_epoch);
ntimesout = 500;
sxx_cycle = nan([ntimesout, size(Sxx,[2:ndims(Sxx)]), trials]);
syy_cycle = nan([ntimesout, size(Syy,[2:ndims(Syy)]), trials]);
sxy_cycle = nan([ntimesout, size(Sxy,[2:ndims(Sxy)]), trials]);
for t = 1:trials
    % ODD-MIRRORING (avoid edge distortion)
    mirror_len = 50; % mirror length in samples
    sxx_cycle(:,:,:,t) = resample_withmirror(sxx_epoch{t},ntimesout,size(sxx_epoch{t},1),1,mirror_len);
    syy_cycle(:,:,:,t) = resample_withmirror(syy_epoch{t},ntimesout,size(syy_epoch{t},1),1,mirror_len);
    sxy_cycle(:,:,:,:,t) = resample_withmirror(sxy_epoch{t},ntimesout,size(sxy_epoch{t},1),1,mirror_len);
end
sxx_cycle(sxx_cycle<0) = 0; syy_cycle(syy_cycle<0) = 0; sxy_cycle(sxy_cycle<0) = 0;

mean_sxx = mean(sxx_cycle,ndims(sxx_cycle));
mean_syy = mean(syy_cycle,ndims(syy_cycle));
mean_sxy = mean(sxy_cycle,ndims(sxy_cycle));

repX = repmat(mean_sxx, [1 1 1 size(mean_syy,3)]);
repY = repmat(mean_syy, [1 1 1 size(mean_sxx,3)]);
mean_coh = abs(mean_sxy)./sqrt(repX.*permute(repY,[1 2 4 3]));

%%
c = 24; m = 1;
figure
subplot(2,1,1)
imagesc((squeeze(mean_coh(:,:,c,m)))',[0 0.4])
title('CMC'), xlabel('Gait cycle [%]'), ylabel('Frequencies [Hz]')

subplot(2,1,2)
% plot(squeeze(max(mean_coh(:,:,c,m),[],2))-squeeze(min(mean_coh(:,:,c,m),[],2)))
plot(squeeze(mean(mean_coh(:,:,c,m),2)))
ylim([0 0.5])
xlabel('Gait cycle [%]'), ylabel('Average CMC')

%%
function w = hanning(n)
if ~rem(n,2)
    w = .5*(1 - cos(2*pi*(1:n/2)'/(n+1)));
    w = [w; w(end:-1:1)];
else
    w = .5*(1 - cos(2*pi*(1:(n+1)/2)'/(n+1)));
    w = [w; w(end-1:-1:1)];
end
end








