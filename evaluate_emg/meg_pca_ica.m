
EMG = EMG';

[~, Y] = pca(EMG(:,1:6));

%%
figure
for i = 1:6
    subplot(2,3,i)
    plot(Y(i,1:4000))
    title(['Component ',num2str(i)])
end

%%
% %%
% drk = getrank(EMG);
% amica_arglist
% arglist(4) = {size(EMG,1)};
% arglist(6) = {drk};
% %%
% [W,S,mods] = runamica15(EMG, arglist{:});
% EMG_ica.icaweights = W;
% EMG_ica.icasphere  = S(1:size(W,1),:);
% EMG_ica.icawinv    = mods.A(:,:,1);

%%
EMG_projICA = W*EMG;

figure()
for i = 1:6
    subplot(6,1,i)
    plot(EMG_projICA(i,1:4000))
end

%%

disp('Filtering EMG')
fc_l = 25;
order = 4;

[b,a] = butter(order,fc_l/(500/2),'high');
for i = 1:size(EMG,1)
    EMG_f(i,:) = filtfilt(b,a,EMG(i,:)); 
end 

fc_l = 1;
order = 4;

[b,a] = butter(order,fc_l/(500/2),'high');
for i = 1:size(EMG,1)
    EMG_fplot(i,:) = filtfilt(b,a,EMG(i,:)); 
end 

%%
figure()
for i = 1:6
    subplot(6,1,i)
    plot(EMG_fplot(i,4000:7000),'r'), hold on
    plot(EMG_f(i,4000:7000),'LineWidth',0.75,'Color','b')
    xlim([1 3000])
end



