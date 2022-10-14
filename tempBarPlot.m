% xaxisNames = {'Parallel Time';'Parallel Freq';'Full Parallel Time';'Full Parallel Freq';...
%     'Sequence Time';'Sequence Freq';'Full Sequence Time';'Full Sequence Freq';...
%     'onlyGCN Time';'onlyGCN Freq';'Full onlyGCN Time';'Full onlyGCN Freq';...
%     'LDA';'Random Forest'};


xTickNames = {'Partial';'Complete';...
    'Partial';'Complete';...
    'Partial';'Complete';...
    'LDA';'Random Forest'};

x = [1:4,6:9,11:14,16:17];
color1 = [0.85 0.325 0.098];
color2 = [0.466 0.674 0.188];
color3 = [0.301 0.745 0.933];
color4 = [0.494 0.184 0.556];

colors = kron([color1;color2;color3;color4],ones(4,1));
colors = colors(1:14,:);
lineStyle = cell(14,1);
lineStyle(:) = {'-'};
lineStyle(2:2:12) = {'-.'};
%x = 1:14
figure()
hold on
for i = 1 : length(x)
    b = bar(x(i),acc.micro(i),'FaceColor','flat');
    b.CData = colors(i,:);
    % frequency dotted
    if rem(i,2) == 0, b.LineStyle = lineStyle{i}; end
end
er = errorbar(x,acc.micro,sdAcc.micro,sdAcc.micro);
er.Color = [0 0 0];
er.LineStyle = 'none';

xticks([1.5,3.5,6.5,8.5,11.5,13.5,16,17])
set(gca,'XTickLabel',xTickNames,'TickLength',[0 0])


legend('','','Parallel','Sequence','OnlyGCN','Machine Learning')


