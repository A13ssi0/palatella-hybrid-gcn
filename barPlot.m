function barPlot(data,yname,titleName,sd,yLim)

if ~exist('sd','var'), sd = []; end
if ~exist('yLim','var'), yLim = []; end


idxTime = [1:4, 9:12, 17:20];

dataFeat = data(:,25:26);
sdFeat = sd(:,25:26);

dataTime = [data(:,idxTime) dataFeat];
sdTime = [sd(:,idxTime) sdFeat];
dataFreq = [data(:,setdiff(1:24,idxTime)) dataFeat];

legendNames = {'Partial Connectivity','Total Connectivity','EMG Features','Fixed diagonal'};

figure()
subplot(121)
barFigure(dataTime, yname, ['Time domain'], sdTime, yLim)
subplot(122)
barFigure(dataFreq, yname, ['Frequency domain'], sdTime, yLim)
lgd = legend(legendNames,'location','northeast');%,orientation,'horizontal');
lgd.Position(1) = 0.382;
lgd.Position(2) = 0.79;
lgd.FontWeight = 'normal';
sgtitle(titleName)




