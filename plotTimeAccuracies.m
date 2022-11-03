function plotTimeAccuracies(data,typeOfData)

scaleAcc = 100;
data = scaleAcc*data;

parallel = data(:,1:8);
sequential = data(:,9:16);
gcn = data(:,17:24);
ml = data(:,25:26);

ymax = max(data,[],"all")*1.05;
ymin = min(data,[],"all")*0.9;

x = 0.04:0.04:2;

createPlotTimeAccuracies(x,parallel,['Parallel net on ',typeOfData],ymin,ymax)
createPlotTimeAccuracies(x,sequential,['Sequential net on ',typeOfData],ymin,ymax)
createPlotTimeAccuracies(x,gcn,['Only GCN net on ',typeOfData],ymin,ymax)
% 
figure()
plot(x,ml);
xlabel('Time [s]')
ylabel('Accuracy')
ylim([ymin ymax])
title(['EMG features on ',typeOfData])
ytickformat("percentage")
legend('LDA','RF');
