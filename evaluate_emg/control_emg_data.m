
emg = PSD.data;

%%
totalSeconds = 20;

nPoint = totalSeconds/0.02-1;

idxReaching = find(PSD.triggers.num == 8);
timeReaching = PSD.triggers.time(idxReaching(15));
reaching = emg(timeReaching:timeReaching+nPoint,:,:);

idxTwisting = find(PSD.triggers.num == 2);
timeTwisting = PSD.triggers.time(idxTwisting(2));
twisting = emg(timeTwisting:timeTwisting+nPoint,:,:);

idxGrasping = find(PSD.triggers.num == 11,1,'first');
timeGrasping = PSD.triggers.time(idxGrasping);
grasping = emg(timeGrasping:timeGrasping+nPoint,:,:);


xt = (0:totalSeconds)*size(grasping,1)/totalSeconds;
xt(1) = 1;
k = linspace(-5,15,numel(xt));


%%
figure()
for i = 1%:6
    %subplot(2,3,i)
    imagesc(squeeze(reaching(:,:,i)'))
    title(['Channel ',num2str(i)])
    set(gca,'YDir','normal')
    set(gca,'XTick',xt,'XTickLabel',k)
    colorbar
end



%%
a = find(subj.triggers.num == );
aa = subj.triggers.time(a(2));
timeTwisting = h_EMG(:,aa-5*500:aa+30*500-1);

x = -5:1/500:30;
x = x(1:end-1);
figure()
sgtitle(['Twisting'])
for i = 1:6
    subplot(6,1,i)
    plot(x,timeTwisting(i,:))
    xline([0,11,22])
    ylim([-5000 5000])
end

