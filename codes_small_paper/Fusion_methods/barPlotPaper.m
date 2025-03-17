function fig = barPlotPaper(data,yname,titleName,sd,yLim)

if ~exist('sd','var'), sd = []; end
if ~exist('yLim','var'), yLim = []; end


legendNames = {'EEG','EMG','Naive','Bayes','Fuzzy'};

fig = figure();
barFigurePaper(data, yname, sd, yLim)
lgd = legend(legendNames,'location','northeast');%,orientation,'horizontal');
% lgd.Position(1) = 0.382;
% lgd.Position(2) = 0.79;
lgd.FontWeight = 'normal';
lgd.FontSize = 10;
sgtitle(titleName)