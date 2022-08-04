function [Y_diff,Y_diff_raw,P] = ERDS_statsDiff(Y_trig,CFG)
if CFG.statsDiff.log
    Y_trig = log(Y_trig);
end
[N_samples,N_freqs,N_ch,N_trials,N_classes] = size(Y_trig);
combs = nchoosek(1:N_classes,2);
N_combs = size(combs,1);

Y_diff_raw = zeros(N_samples,N_freqs,N_ch,N_combs);
P = zeros(N_samples,N_freqs,N_ch,N_combs);
if strcmp(CFG.statsDiff.method,'perm')
    [~,idx] = sort(rand(N_trials*2,CFG.statsDiff.B),1);
    for i_comb = 1:N_combs
        for i = 1:N_samples
            for i_f = 1:N_freqs
                for i_ch = 1:N_ch
                    x = squeeze(Y_trig(i,i_f,i_ch,:,combs(i_comb,1)));
                    y = squeeze(Y_trig(i,i_f,i_ch,:,combs(i_comb,2)));
                    Y_diff_raw(i,i_f,i_ch,i_comb) = nanmedian(x) - nanmedian(y);
                    z = [x;y];
                    z_perm = z(idx);
                    stat_perm = nanmedian(z_perm(1:N_trials,:)) - nanmedian(z_perm(N_trials+1:end,:));
                    P(i,i_f,i_ch,i_comb) = (sum(abs(Y_diff_raw(i,i_f,i_ch,i_comb)) < abs(stat_perm))+1) / (CFG.statsDiff.B+1);
                end
            end
        end
    end
    Y_diff = Y_diff_raw.*(P < CFG.statsDiff.alpha);
else
    error('%s: method %s is not defined.',mfilename,CFG.statsDiff.method);
end

end

