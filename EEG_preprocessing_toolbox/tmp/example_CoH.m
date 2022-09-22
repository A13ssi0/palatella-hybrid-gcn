clear all
% close all
clc

rng(17);

N = 1;
fs = 250;
t = [0:1/fs:30]';
X = NaN(numel(t),N);
Y = NaN(numel(t),N);
fc_band = [0,35];
for i = 1:N
    f_delay = pearsrnd(20,0.2,0,3,1,1);
    f_zero = pearsrnd(12,0.2,0,3,1,1);
    phi_delay = pearsrnd(45,5,0,3,1,1);
    X(:,i) = sin(2*pi*f_delay*t+deg2rad(phi_delay)) + sin(2*pi*f_zero*t) + pearsrnd(0,0.3,0,3,numel(t),1);
    Y(:,i) = sin(2*pi*f_delay*t) + sin(2*pi*f_zero*t) + pearsrnd(0,0.5,0,3,numel(t),1);
end

% X (CORTICAL) CAUSES Y (MUSCLE)

time_seg = 3;
time_overlap = time_seg*(0.99);
window_width = round(time_seg*fs);
overlap_width = round(time_overlap*fs);
step_size = round((time_seg - time_overlap)*fs);
t_vec_plt = t(window_width+1:step_size:end);

f = fs*(0:(window_width/2))/window_width;
f = f(f>=min(fc_band) & f<=max(fc_band));
fft_x = NaN(numel(f),numel(t_vec_plt));
fft_y = NaN(numel(f),numel(t_vec_plt));
X_t = NaN(window_width,numel(t_vec_plt));
Y_t = NaN(window_width,numel(t_vec_plt));

for i = 1:numel(t_vec_plt)
    start = (i-1)*step_size+1; stop = start + window_width - 1;
    [fft_x(:,i),f] = fft_fc_band(X(start:stop,1),fc_band,fs);
    [fft_y(:,i),f] = fft_fc_band(Y(start:stop,1),fc_band,fs);
    
    X_t(:,i) = X(start:stop,1);
    Y_t(:,i) = Y(start:stop,1);
end

g.Fs = fs;
g.winsize = 1.0*fs;
g.freqs = fc_band;
g.nfreqs = 2*(g.freqs(2)-g.freqs(1)+1);
g.padratio = 16;
g.ntimesout = 750-g-winsize;
[cm_cmc, times, freqs, cm_imc, cm_pli, c_pow, m_pow, cm_pow] = timef_cmc_warp(X_t, Y_t, g);

% [fft_x,f] = fft_fc_band(X,fc_band,fs);
% [fft_y,f] = fft_fc_band(Y,fc_band,fs);

% wPLI ONLY BASED ON IMAGINARY PART OF CROSS-SPECTRUM
Sxy = fft_x.*conj(fft_y);
wPLI = abs(sum(imag(Sxy),2)./sum(abs(imag(Sxy)),2));

Sxy = mean( fft_x.*conj(fft_y) ,2);
Sxx = mean( fft_x.*conj(fft_x) ,2);
Syy = mean( fft_y.*conj(fft_y) ,2);
% COH = abs(Sxy./sqrt(Sxx.*Syy)); % coherency
COH = abs(Sxy)./sqrt(Sxx.*Syy); % coherency (same as above)
MCO = (abs(Sxy).^2)./(Sxx.*Syy); % magnitude coherency

C = Sxy./sqrt(Sxx.*Syy);
IMC = abs(imag(C));

figure();
subplot(4,1,1);
plot(f,abs(Sxx),'g','LineWidth',1); hold on, plot(f,abs(Syy),'b--','LineWidth',1); legend('Sxx','Syy');
title('Absolute Auto-spectra Sxx Syy');
subplot(4,1,2);
plot(f,abs(Sxy),'k','LineWidth',1); legend('Sxy');
title('Absolute Cross-spectrum Sxy');
subplot(4,1,3);
plot(f,COH,'k','LineWidth',1); hold on; plot(f,MCO,'g','LineWidth',1); plot(f,IMC,'r','LineWidth',1); plot(f,wPLI,'b','LineWidth',1); legend('COH','MCO','IMC','wPLI');
title('Coherence (COH) and Imaginary Part of the Coherence');
subplot(4,1,4);
plot(f,rad2deg(angle(Sxy)).*COH,'k','LineWidth',1);
title('\Delta\phi over frequencies');
xlabel('f (Hz)');

%% RESAMPLE USING ODD-MIRROR
Sxy_original = fft_x.*conj(fft_y);
Sxy_original = Sxy_original'; % transpose so [time,freq]
mirror_len = round(0.250*1/(time_seg-time_overlap)); % mirror length in samples of 250 ms for example
Sxy_original_mirror = cat(1, flipud(Sxy_original(2:mirror_len,:)), Sxy_original, flipud(Sxy_original(end-mirror_len:end-1,:)) );
resample_factor = 2;
Sxy_resample_mirror = resample(Sxy_original_mirror, size(Sxy_original_mirror,1)*resample_factor, size(Sxy_original_mirror,1));
Sxy_resample = Sxy_resample_mirror(mirror_len*resample_factor-1:end-mirror_len*resample_factor-1,:);
t_vec_res = t(window_width+1:step_size/resample_factor:end);

figure(); 
plot(t_vec_plt,abs(Sxy_original),'k'); hold on;
plot(t_vec_res,abs(Sxy_resample),'g--');

figure(); 
plot(t_vec_plt,abs(Sxy_original),'k'); hold on;
plot(t_vec_res,abs(Sxy_resample),'g--');
axis([7.25 7.55 0.276 0.281]);
title('Nothing is perfect');

%% FFT_FC_BAND


function [z_out,f] = fft_fc_band(z_in,fc_band,fs)
    % compute FFT of signal z_in per trial
    fft_z = fft(hann(size(z_in,1)).*z_in);
    % ignore negative frequencies
    L = size(z_in,1);
    fft_z = fft_z(1:floor(L/2)+1,:)./L;
    fft_z(2:end-1,:) = 2*fft_z(2:end-1,:);
    f = fs*(0:(L/2))/L; % one-sided freq vector
    % get relevant frequency band
    z_out = fft_z(f>=min(fc_band) & f<=max(fc_band),:);
    f = f(f>=min(fc_band) & f<=max(fc_band));
end