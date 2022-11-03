function barFigure(data,yname,titleName,sd,yLim)

xTickNames = {'Parallel';'Sequential';'onlyGCN';'LDA';'RF'};
legendNames = {'Partial Connectivity','Total Connectivity','EMG Features','Fixed diagonal'};

x = [1:4,6:9,11:14,16:17];
xTickVals = [2.5 7.5 12.5 16 17];
%x = 1:length(data);
color1 = [0.3010 0.7450 0.9330];
color2 = [0.4660 0.6740 0.1880];
color3 = [0.494 0.184 0.556];
%color4 = [0.494 0.184 0.556];

colors = [color1; color1; color2; color2];
colors = [colors;colors;colors; color3; color3];

%figure()
hold on
% set legend
for i = 1:3
    b = bar(i,nan,'FaceColor','flat');
    b.CData = colors(2+6*(i-1),:);
end
bar(1,nan,'white','LineStyle','-.');
% bar(1,nan,'white');
% bar(1,nan,'white','LineStyle',':');


for i = 1 : length(x)
    b = bar(x(i),data(i),'FaceColor','flat');
    b.CData = colors(i,:);
    % frequency dotted
    if rem(i,2) == 0 && i < length(x)
        b.LineStyle = '-.'; 
        b.LineWidth = 0.85;
    end
end

% set error
if ~isempty(sd)
    er = errorbar(x,data,sd,sd);
    er.Color = [0 0 0];
    er.LineStyle = 'none';
end
% set limit
if ~isempty(yLim)
    ylim(yLim)
end

xticks(xTickVals)
set(gca,'XTickLabel',xTickNames,'TickLength',[0 0],'FontWeight','bold')

if contains(yname,'accuracy','IgnoreCase',true), ytickformat("percentage"), end

% lgd = legend(legendNames);
% lgd.FontWeight = 'normal';
ylabel(yname)
title(titleName)