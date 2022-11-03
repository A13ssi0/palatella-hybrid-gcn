function createPlotTimeAccuracies(x,y,ttle,ymin,ymax)

color1 = [0.3010 0.7450 0.9330];
color2 = [0.4660 0.6740 0.1880];
%color3 = [0.494 0.184 0.556];

legendNames = {'Partial Connectivity','Total Connectivity','Fixed diagonal'};

yTime = y(:,1:4);
yFreq = y(:,5:8);

figure()

subplot(121)
p = plot(x,yTime);
p(1).Color = color1;
p(2).Color = color1;
p(3).Color = color2;
p(4).Color = color2;
p(2).LineStyle = '-.'; 
p(2).LineWidth = 0.85;
p(4).LineStyle = '-.'; 
p(4).LineWidth = 0.85;

xlabel('Time [s]')
ylabel('Accuracy')
ylim([ymin ymax])
ytickformat("percentage")
title('Time domain')


subplot(122)
p = plot(nan(3));
p(1).Color = color1;
p(2).Color = color2;
p(3).LineStyle = '-.';
p(3).Color = [0 0 0];
hold on

p = plot(x,yFreq);
p(1).Color = color1;
p(2).Color = color1;
p(3).Color = color2;
p(4).Color = color2;
p(2).LineStyle = '-.'; 
p(2).LineWidth = 0.85;
p(4).LineStyle = '-.'; 
p(4).LineWidth = 0.85;

xlabel('Time [s]')
ylabel('Accuracy')
ylim([ymin ymax])
ytickformat("percentage")
title('Frequency domain')

lgd = legend(legendNames,'location','northeast');%,orientation,'horizontal');
lgd.Position(1) = 0.389;
lgd.Position(2) = 0.8;

sgtitle(ttle) 

