function plotTimeAccuracies(data,typeOfData)

scaleAcc = 100;
data = scaleAcc*data;

parallel = data(:,1:6);
sequential = data(:,7:12);
gcn = data(:,13:18);
ml = data(:,19:20);

ymax = max(data,[],"all")*1.1;
ymin = min(data,[],"all")*0.9;

x = 0.02:0.02:2;

createPlotTimeAccuracies(x,parallel,['Parallel on ',typeOfData],ymin,ymax)
createPlotTimeAccuracies(x,sequential,['Sequential on ',typeOfData],ymin,ymax)
createPlotTimeAccuracies(x,gcn,['Only GCN on ',typeOfData],ymin,ymax)

figure()
plot(x,ml);
xlabel('time [s]')
ylabel('Accuracy')
ylim([ymin ymax])
title(['Machine Learning on ',typeOfData])
ytickformat("percentage")
legend('LDA','RF');
