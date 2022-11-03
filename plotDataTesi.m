close all; clearvars; clc;

% load EEGToPlot_v2.mat
% full = eeg.full;
% prn = eeg.prn;
% x = eeg.time;

load EMGToPlot_v2.mat
full = emg.full;
prn = emg.prn;
x = emg.time;

%%
idx = find(x>=-2 & x<=5);
full = full(idx);
prn = prn(idx);
x = x(idx);

hlb = hilbert(prn');
hlb = abs(hlb)';

lol = max(abs(full-mean(full)));
grayColor = [.5 .5 .5];

figure()
subplot(311), plot(x,full), ylim([-lol lol]+mean(full)), yline(mean(full),'--','Color',grayColor)
title('Original EMG'), xlabel('Time [s]'), ylabel('Amplitude')
subplot(312), plot(x,prn), ylim([-lol lol]), yline(0,'--','Color',grayColor)
title('Pre-processed EMG'), xlabel('Time [s]'), ylabel('Amplitude')
subplot(313), plot(x,hlb), ylim([-lol lol]), yline(0,'--','Color',grayColor)
title('Hilbert EMG'), xlabel('Time [s]'), ylabel('Amplitude')

%%
close all

lol = max(abs(hlb));
lol1 = max(abs(prn));
lol = max(lol,lol1);

figure()
subplot(212), plot(x,hlb), ylim([-100 lol*1.4]), yline(0,'--','Color',grayColor)
title('Hilbert EMG'), xlabel('Time [s]'), ylabel('Amplitude')
subplot(211), plot(x,prn), ylim([-lol lol]), yline(0,'--','Color',grayColor)
title('Pre-processed EMG'), xlabel('Time [s]'), ylabel('Amplitude')