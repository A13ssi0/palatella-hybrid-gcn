function b = barPlot(data,yname,titleName,sd,yLim)

xTickNames = {'Parallel';'Sequential';'onlyGCN';'LDA';'RF'};

x = [1:6,8:13,15:20,22:23];
color1 = [0.3010 0.7450 0.9330];
color2 = [0.4660 0.6740 0.1880];
color3 = [0.494 0.184 0.556];
%color4 = [0.494 0.184 0.556];

colors = [color1; color1; color1; color2; color2; color2];
colors = [colors;colors;colors; color3; color3];

figure()
hold on
% set legend
for i = 1:3
    b = bar(i,nan,'FaceColor','flat');
    b.CData = colors(3+8*(i-1),:);
end
bar(1,nan,'white','LineStyle','-.');
bar(1,nan,'white');
bar(1,nan,'white','LineStyle',':');


for i = 1 : length(x)
    b = bar(x(i),data(i),'FaceColor','flat');
    b.CData = colors(i,:);
    % frequency dotted
    if i==4 || i==10 || i==16 || (rem(i,2) == 1 && rem(i,3) == 1 && i<= 18)
        b.LineStyle = '-.'; 
        b.LineWidth = 0.85;
    elseif rem(i,3) == 0 && i<=18
        b.LineStyle = ':'; 
        b.LineWidth = 0.85;
    end
end

% set error
if exist('sd','var')
    er = errorbar(x,data,sd,sd);
    er.Color = [0 0 0];
    er.LineStyle = 'none';
end
% set limit
if exist('yLim','var')
    ylim(yLim)
end


xticks([3.5,10.5,17.5,22,23])
set(gca,'XTickLabel',xTickNames,'TickLength',[0 0],'FontWeight','bold')

if contains(yname,'accuracy','IgnoreCase',true), ytickformat("percentage"), end

lgd = legend('Time','Frequency','Features','Partial connectivity','Total connectivity','Fixed diagonal');
lgd.FontWeight = 'normal';
ylabel(yname)
title(titleName)