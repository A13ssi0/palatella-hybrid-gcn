function barFigurePaper(data,yname,sd,yLim)

xTickNames = {'15%';'10%';'5%';'1%'};

x = [1:5 
    7:11
    13:17
    19:23];
xTickVals = mean(x,2);
x = reshape(x',1,[]);

color1 = [0.3010 0.7450 0.9330];
color2 = [0.4660 0.6740 0.1880];
color3 = [0.494 0.184 0.556];
color4 = [0.6350 0.0780 0.1840];
color5 = [0 0.4470 0.7410];

colors = [color1; color2; color3; color4; color5];
colors = [colors; colors; colors; colors];


hold on
% set legend
for i = 1:5
    b = bar(i,nan,'FaceColor','flat');
    b.CData = colors(i,:);
end
bar(1,nan,'white','LineStyle','-.');
% bar(1,nan,'white');
% bar(1,nan,'white','LineStyle',':');

for i = 1 : length(x)
    b = bar(x(i),data(i),'FaceColor','flat');
    b.CData = colors(i,:);
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
set(gca,'XTickLabel',xTickNames,'TickLength',[0 0],'FontWeight','bold','FontSize',10)

if contains(yname,'accuracy','IgnoreCase',true), ytickformat("percentage"), end

xlabel('Percentage of recalibration')
ylabel(yname)
