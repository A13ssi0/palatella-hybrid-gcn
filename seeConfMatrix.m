
subject = 7;
gridHiddenUnits = 5:10:55;
gridDropOut = 0:0.3:0.9;
savingPath='/home/palatella/workspace/palatella_net/';

i = 6;
acc = max(accuracies(i,:,:),[],'all');
[j,m] = find(squeeze(accuracies(i,:,:))==acc);

x = gridHiddenUnits(i);
y = gridDropOut(j);
z = gridDropOut(m);


savingName = [savingPath,'subj',num2str(subject),'_net_','hdn',num2str(x),'_drop',num2str(y),'_',num2str(z)];
net = load(savingName,'-mat');


figure()
confusionchart(net.confMatrix,'ColumnSummary','absolute','RowSummary','absolute','Normalization','row-normalized');
