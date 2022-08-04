function [c,plt] = ERSP_plotMap(ERSP,t_vec,f_vec,CFG,t_indicator,t_indicator_lbl, cmap)

if exist('cmap','var') || strcmp(cmap, 'jet')
    cmp = jet(256);
elseif strcmp(cmap, 'white')
    cmp = my_colormap(2);
end

if ~exist('CFG','var')
    CFG.tlimits = [t_vec(1) t_vec(end)];
    CFG.flimits = [f_vec(1) f_vec(end)];
    CFG.climits = [-1 1];
    CFG.f_steps = 10;
end

if ~isfield(CFG, 'tlimits')
    CFG.tlimits = [t_vec(1) t_vec(end)];
end
if ~isfield(CFG, 'flimits')
    CFG.flimits = [f_vec(1) f_vec(end)];
end
if ~isfield(CFG, 'f_steps')
    CFG.f_steps = 10;
end

if isempty(t_indicator_lbl)
    t_indicator_lbl = string(t_indicator);
end

t_idx = t_vec >= CFG.tlimits(1) & t_vec <= CFG.tlimits(2);
f_idx = f_vec >= CFG.flimits(1) & f_vec <= CFG.flimits(2);
t_vec = t_vec(t_idx); f_vec = f_vec(f_idx); ERSP = ERSP(t_idx,f_idx);

t_vec_pos = [t_vec(1) t_indicator t_vec(end)]';
t_vec_label = [num2str(CFG.tlimits(1)) t_indicator_lbl num2str(CFG.tlimits(end))]';

if ~isempty(t_indicator)
    if t_indicator(1) == CFG.tlimits(1)
        t_vec_label(1) = [];
        t_vec_pos(2) = [];
    end
    if t_indicator(end) == CFG.tlimits(end)
        t_vec_label(end) = [];
        t_vec_pos(end-1) = [];
    end
end

f_vec_pos = [f_vec(1):CFG.f_steps:f_vec(end)]';
f_vec_label = round([f_vec(1):CFG.f_steps:f_vec(end)]');

[~,c] = contourf(t_vec,f_vec(1:CFG.fdown:end),ERSP(:,1:CFG.fdown:end)',256); 
hold on; grid on;
c.LineStyle = 'none';
if isfield(CFG, 'climits')
    if ~isempty(CFG.climits)
        caxis(CFG.climits)
    end
end
colormap(cmp);
if ~isempty(t_indicator)
    for i = 1:length(t_indicator)
        plt = xline(t_indicator(i));
    end
end
set(gca,'XTick',t_vec_pos); set(gca, 'XTickLabel', t_vec_label);
set(gca,'YTick',f_vec_pos); set(gca, 'YTickLabel', f_vec_label);

end

