function [ERDS_stats] = ERDS_statsERDS(ERDS,t_vec,CFG)

if strcmp(CFG.stats.method,'bootstrap')
    B = CFG.stats.B;
    [N_samples,N_freqs,N_ch,N_trials,N_classes] = size(ERDS);
    ERDS_stats = ERDS;
    for i_f = 1:N_freqs
        for i_ch = 1:N_ch
            for i_class = 1:N_classes
                x = squeeze(ERDS(:,i_f,i_ch,:,i_class))';
                bs_CI = bootci(B,{@median,x},'alpha',CFG.stats.alpha,'type','bca');
                idx = sign(bs_CI(1,:)) == sign(bs_CI(2,:));
                ERDS_stats(idx,i_f,i_ch,:,i_class) = 0;
            end
        end
    end
else
    error('%s: method %s is not defined.',mfilename,CFG.stats.method);
end

end

