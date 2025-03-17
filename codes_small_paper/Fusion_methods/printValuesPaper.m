function fig = printValuesPaper(mtrValues, yname, titleName, ylim)

if nargin<4,    ylim = [];  end

idxNan = isnan(mtrValues);
if sum(idxNan,'all')>0, mtrValues(idxNan) = 0;  end

%type = settings.type;
%att = settings.att;

meanV = squeeze(mean(mtrValues));
sdV = squeeze(std(mtrValues));

meanV = reshape(meanV,1,[]);
sdV = reshape(sdV,1,[]);

fig = barPlotPaper(meanV,yname,titleName,sdV,ylim);
