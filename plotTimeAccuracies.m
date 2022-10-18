function plotTimeAccuracies(data,typeOfData)

parallel = data(:,1:4);
sequential = data(:,5:8);
gcn = data(:,9:12);
ml = data(:,13:14);

ymax = max(data,[],"all")*1.1;
ymin = min(data,[],"all")*0.9;

color1 = [0.3010 0.7450 0.9330];
color2 = [0.4660 0.6740 0.1880];
color3 = [0.494 0.184 0.556];

x = 0.02:0.02:2;
figure()
p = plot(nan(4));
p(1).Color = color1;
p(2).Color = color2;
p(3).LineStyle = '-.';
p(3).Color = [0 0 0];
p(4).Color = [0 0 0];
hold on
p = plot(x,parallel);
p(1).Color = color1;
p(2).Color = color1;
p(3).Color = color2;
p(4).Color = color2;
p(1).LineStyle = '-.';
p(3).LineStyle = '-.';
xlabel('time [s]')
ylabel('Accuracy')
ylim([ymin ymax])
title(['Parallel on ',typeOfData])
legend('Time','Frequency','Partial coherence','Total coherence');

figure()
p = plot(nan(4));
p(1).Color = color1;
p(2).Color = color2;
p(3).LineStyle = '-.';
p(3).Color = [0 0 0];
p(4).Color = [0 0 0];
hold on
p = plot(x,sequential);
p(1).Color = color1;
p(2).Color = color1;
p(3).Color = color2;
p(4).Color = color2;
p(1).LineStyle = '-.';
p(3).LineStyle = '-.';
xlabel('time [s]')
ylabel('Accuracy')
ylim([ymin ymax])
title(['Sequential on ',typeOfData])
legend('Time','Frequency','Partial coherence','Total coherence');


figure()
p = plot(nan(4));
p(1).Color = color1;
p(2).Color = color2;
p(3).LineStyle = '-.';
p(3).Color = [0 0 0];
p(4).Color = [0 0 0];
hold on
p = plot(x,gcn);
p(1).Color = color1;
p(2).Color = color1;
p(3).Color = color2;
p(4).Color = color2;
p(1).LineStyle = '-.';
p(3).LineStyle = '-.';
xlabel('time [s]')
ylabel('Accuracy')
ylim([ymin ymax])
title(['Only GCN on ',typeOfData])
legend('Time','Frequency','Partial coherence','Total coherence');


figure()
p = plot(x,ml);
xlabel('time [s]')
ylabel('Accuracy')
ylim([ymin ymax])
title(['Machine Learning on ',typeOfData])
legend('LDA','RF');
