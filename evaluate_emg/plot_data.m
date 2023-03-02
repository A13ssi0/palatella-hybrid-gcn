close all; clearvars; clc;

loadPath = 'C:\Users\aless\OneDrive\Desktop\only emg data\';

secondsToPlot = 2;
fs = 500;

x = (-secondsToPlot*fs:secondsToPlot*fs)';

%%

for i = 7%[7 11 15 19 23]

    load([loadPath,'s',num2str(i),'_raw'])
    ch7 = EMG(:,7);
    EMG = EMG(:,1:6);

    fc_l = 5;
    order = 4;
    [b,a] = butter(order,fc_l/(fs/2),'high');
    
    for k = 1:size(EMG,2)    
        EMG(:,k) = filtfilt(b,a,EMG(:,k)); 
    end 

%     for k = 1:size(EMG,2)
%         EMG(:,k) = EMG(:,k)-ch7; 
%     end  

    EMG = hilbert(EMG);
    EMG = abs(EMG);

    num = trigger.num;
    pos = trigger.time;

    pos_tws = pos(num>=1 & num<=2)';
    pos_rch = pos(num>=3 & num<=8)';
    pos_grp = pos(num>=9 & num<=11)';

    idx_tws = x+pos_tws;
    idx_rch = x+pos_rch;
    idx_grp = x+pos_grp;

%     disp('Filtering EMG')
    fc_l = 6;
    order = 4;
    [b,a] = butter(order,fc_l/(fs/2),'low');
    
    for k = 1:size(EMG,2)    
        EMG(:,k) = filtfilt(b,a,EMG(:,k)); 
    end 


    for j = 1:size(EMG,2)
        disp(['Plotting channel ',num2str(j)])
        tws_data = reshape(EMG(idx_tws,j),size(idx_tws));
        rch_data = reshape(EMG(idx_rch,j),size(idx_rch));
        grp_data = reshape(EMG(idx_grp,j),size(idx_grp));

        tws_mean = mean(tws_data,2);
        tws_std = std(tws_data,0,2);
        rch_mean = mean(rch_data,2);
        rch_std = std(rch_data,0,2);
        grp_mean = mean(grp_data,2);
        grp_std = std(grp_data,0,2);

%         figure()
%         sgtitle(['Channel ',num2str(j)])
%         subplot(311), plot(x/500, tws_data), ylim([-100 2500]), ylabel('Twisting')
%         subplot(312), plot(x/500, rch_data), ylim([-100 2500]), ylabel('Reaching')
%         subplot(313), plot(x/500, grp_data), ylim([-100 2500]), ylabel('Grasping')

        figure()
        sgtitle(['Channel ',num2str(j)])
        subplot(311), plot(x/500, tws_mean-tws_std, '--', x/500, tws_mean, x/500, tws_mean+tws_std ,'--'), ylabel('Twisting'), ylim([-5e4 5e4])
        subplot(312), plot(x/500, rch_mean-rch_std, '--', x/500, rch_mean, x/500, rch_mean+rch_std ,'--'), ylabel('Reaching'), ylim([-5e4 5e4])
        subplot(313), plot(x/500, grp_mean-grp_std, '--', x/500, grp_mean, x/500, grp_mean+grp_std ,'--'), ylabel('Reaching'), ylim([-5e4 5e4])

    end


end