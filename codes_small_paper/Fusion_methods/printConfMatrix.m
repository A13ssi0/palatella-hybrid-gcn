function printConfMatrix(cmRes, att)

if att>0.5 && att<1
    netSettings.emg.attenuation = att;
    netSettings.emg.type = 'fatigue';
    k = fix(att*100);
    tp = netSettings.emg.type;
    tp(1) = upper(tp(1));
    titleName =[tp, ' with an attenuation of ', num2str(k), '%'];
else
    netSettings.emg.snr = att;
    netSettings.emg.type = 'paraplegic';
    k = att;
    tp = netSettings.emg.type;
    tp(1) = upper(tp(1));
    titleName =[tp, ' with a snr of ', num2str(k), 'dB'];
end


mnCm = cell(4,5);
for perc = 1:4
    for type = 1:5
        mn = zeros(3);
        for sbj = 1:5
            mn = mn + cmRes{sbj,type,perc};
        end
        mnCm{perc,type} = floor(mn/5);
    end
end

%%
yTickNames = {'15%';'10%';'5%';'1%'};
xTickNames = {'EEG','EMG','Naive','Bayes','Fuzzy'};

fig = figure;
for perc = 1:4
    for type = 1:5
        subplot(4,5,type+(perc-1)*5)
        cm = confusionchart(mnCm{perc,type},'Normalization','row-normalized');
    
        if type==1, cm.YLabel = {yTickNames{perc};' ';'True Class'};    end
        if perc==4, cm.XLabel = {'Predicted Class'; ' '; xTickNames{type}}; end

    end

end
han = axes(fig,'Visible','off');
han.Title.Visible = 'on';
han.XLabel.Visible = 'on';
han.YLabel.Visible = 'on';

yL = ylabel(han,'Percentage of recalibration');
yL.FontSize = 20;
yL.FontWeight = 'bold';
yL.Position(1) = yL.Position(1)*1.05;
set(gcf, 'Position', get(0,'ScreenSize'));

sgtitle(['Confusion matrices for ', titleName])
saveas(fig, ['/home/palatella/workspace/palatella-hybrid-gcn/codes_small_paper/Fusion_methods/', tp, num2str(k), '_meanCM.jpg'])




