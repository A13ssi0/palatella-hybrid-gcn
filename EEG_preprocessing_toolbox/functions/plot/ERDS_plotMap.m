function [c,plt] = ERDS_plotMap(ERDS,t_vec,f_vec,fs,climits,CFG,is_es)

if ndims(ERDS) == 2
[N_samples,N_freqs] = size(ERDS);
else
    [N_samples,N_freqs,N_trials] = size(ERDS);
end

if ~(CFG.t_smooth_plt == 0)
    ERDS = movmean(ERDS,[CFG.t_smooth_plt*fs,0],1);
end

if ndims(ERDS) == 3
    % ERDS = trimmean(ERDS,10,3);
    ERDS = median(ERDS,3);
end


% cmp = flipud(jet(256));
% cmp = flipud(my_colormap(2));
if is_es
    cmp = my_colormap(2);
else
    cmp = jet(256);
end

% t_vec_label = [t_vec(1):CFG.t_step_label:t_vec(end)]';
t_vec_label = [t_vec(1) 0 t_vec(end)]';
f_vec_label = [f_vec(1):CFG.f_step_label:f_vec(end)]';

[~,c] = contourf(t_vec,f_vec,ERDS',256); 
hold on; grid on;
c.LineStyle = 'none';
if exist('climits','var')
    caxis(climits)
else
    caxis([-1 1])
end
colormap(cmp);
plt = plot([CFG.t_indicator CFG.t_indicator],[ylim],'k');
set(gca,'XTick',t_vec_label);
set(gca,'YTick',f_vec_label);

end

