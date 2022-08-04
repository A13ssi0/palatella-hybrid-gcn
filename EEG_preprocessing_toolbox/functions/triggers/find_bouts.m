function [bouts_typ, bouts_locs] = find_bouts(L_acc,R_acc,settings)

% Parameters
fs = settings.imu.fs;
bouts_start_typ = settings.imu.trigger.BOUTS_START;
bouts_stop_typ = settings.imu.trigger.BOUTS_STOP;

% Compute signal vector magnitude
L_SVM = sqrt(sum(L_acc.^2, 2));
R_SVM = sqrt(sum(R_acc.^2, 2));

% Find signal acquisition begin
ipt_l = findchangepts(L_SVM);
ipt_r = findchangepts(R_SVM);
ipt = max([ipt_l ipt_r]);
L_SVM = L_SVM(ipt+1:end);
R_SVM = R_SVM(ipt+1:end);

% Filter SVM signals
order = 4;
fcutoff = [0.5 2];
[b,a] = butter(order, fcutoff.*2/fs, 'bandpass');
L_SVM_filt = filtfilt(b,a,L_SVM);
R_SVM_filt = filtfilt(b,a,R_SVM);

% Combine left and right leg
SVM_filt = L_SVM_filt.*R_SVM_filt;

% Smooth combined signal
winlen = 2.5; % [sec]
kb = winlen*fs-1;
SVM_smooth = movmean(SVM_filt, [kb 0]);
% SVM_smooth = normalize(SVM_smooth, 'range');

% Otsu image threshold method
% T = graythresh(SVM_smooth);
T = 5.5e-5;
bouts_label = zeros(size(SVM_smooth));
bouts_label(SVM_smooth>T) = 1;

bouts_diff = diff([0; bouts_label]);
bouts_start = find(bouts_diff==1);
bouts_stop = find(bouts_diff==-1);
n_bouts = length(bouts_start);
if length(bouts_stop)<n_bouts
    bouts_stop = [bouts_stop; length(SVM_smooth)];
end
bouts_dur = bouts_stop-bouts_start+1;
rm_bouts = bouts_dur<30*fs;
bouts_start(rm_bouts) = [];
bouts_stop(rm_bouts) = [];
n_bouts = n_bouts-sum(rm_bouts);

bouts_label = zeros(size(bouts_label));
for b = 1:n_bouts
    bouts_label(bouts_start(b):bouts_stop(b)) = 1;
end

time = 0:1/fs:length(SVM_smooth)/fs-1/fs;
figure
subplot(3,1,1)
plot(time,L_SVM)
hold on
plot(time,R_SVM)

subplot(3,1,2)
plot(time,L_SVM_filt)
hold on
plot(time,R_SVM_filt)

subplot(3,1,3)
yyaxis left
plot(time, SVM_smooth)
yline(T)
yyaxis right
plot(time, bouts_label)
ylim([-0.02 1.02])

bouts_typ = [bouts_start_typ*ones(n_bouts,1); bouts_stop_typ*ones(n_bouts,1)];
bouts_locs = [bouts_start+ipt; bouts_stop+ipt];
[bouts_locs,idx] = sort(bouts_locs);
bouts_typ = bouts_typ(idx);

end

