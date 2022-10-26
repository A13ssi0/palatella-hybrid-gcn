function createPlotTimeAccuracies(x,y,ttle,ymin,ymax)

color1 = [0.3010 0.7450 0.9330];
color2 = [0.4660 0.6740 0.1880];
color3 = [0.494 0.184 0.556];

zoomPoint = 1.2;

figure()

p = plot(nan(5));
p(1).Color = color1;
p(2).Color = color2;
p(3).LineStyle = '-.';
p(5).LineStyle = ':';
p(5).LineWidth = zoomPoint;
p(3).Color = [0 0 0];
p(4).Color = [0 0 0];
p(5).Color = [0 0 0];
hold on

plot(x,y(:,6))
p = plot(x,y);
p(1).Color = color1;
p(2).Color = color1;
p(3).Color = color1;
p(4).Color = color2;
p(5).Color = color2;
p(6).Color = color2;

p(1).LineStyle = '-.';
p(3).LineStyle = ':';
p(3).LineWidth = zoomPoint;
p(4).LineStyle = '-.';
p(6).LineStyle = ':';
p(6).LineWidth = zoomPoint;
xlabel('time [s]')
ylabel('Accuracy')
ylim([ymin ymax])

ytickformat("percentage")
title(ttle)
legend('Time','Frequency','Partial coherence','Total coherence','Fixed diagonal');

