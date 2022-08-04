function [Y_trig,t_vec,fs] = ERDS_triggerBP(Y_bp,group_id,fs,CFG)


[N_samples,N_freqs,N_ch] = size(Y_bp);


if CFG.downsample.enable
    step_size = round(fs/CFG.downsample.fs);
    idx_range = [-CFG.t_range(1)*fs-step_size:1:CFG.t_range(2)*fs];
else
    idx_range = [-CFG.t_range(1)*fs:1:CFG.t_range(2)*fs];
end
t_vec = [-CFG.t_range(1):1/fs:CFG.t_range(2)]';
trig = false(size(group_id));
for i_class = 1:CFG.N_classes
    trig(2:end) = diff(ismember(group_id,CFG.class_vec{i_class})) > 0;
	trig_idx{i_class} = find(trig);
end
N_trials = cellfun(@(x) numel(x),trig_idx);
N_trials = min(N_trials);

Y_trig = NaN(numel(idx_range),N_freqs,N_ch,N_trials,CFG.N_classes);

for i_class = 1:CFG.N_classes
    for i_trials = 1:N_trials
        Y_trig(:,:,:,i_trials,i_class) = Y_bp(trig_idx{i_class}(i_trials)+idx_range,:,:);
    end
end

if CFG.downsample.enable
    Y_tmp = movmean(Y_trig,[step_size,0]);
    Y_trig = Y_tmp(step_size:step_size:end,:,:,:,:);
    t_vec = t_vec(1:step_size:end);
    fs = CFG.downsample.fs;
end

end

