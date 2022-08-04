function [Y_bp,f_vec_mean] = ERDS_computeBP(y,fs,CFG)

[N_samples,N_ch] = size(y);

f_vec = [CFG.f_range(1)-CFG.f_width/2:CFG.f_step:CFG.f_range(2)-CFG.f_width/2];
f_vec_end = f_vec + CFG.f_width;
f_vec_mean = mean([f_vec;f_vec_end]);


N_freqs = numel(f_vec);
Y = NaN(N_samples,N_freqs,N_ch);
for i_freq = 1:N_freqs
    [b,a] = butter(2,[f_vec(i_freq) f_vec_end(i_freq)]/(fs/2),'bandpass');
    Y(:,i_freq,:) = filtfilt(b,a,y);
end

Y_bp = Y.^2;
if ~(CFG.t_smooth == 0)
    Y_bp = movmean(Y_bp,[CFG.t_smooth*fs,0]);
end

end

