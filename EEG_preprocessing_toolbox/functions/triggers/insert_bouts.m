function [bouts_typ,bouts_locs] = insert_bouts(EEG,settings)

L_IMU = settings.imu.shank.gyr.L.labels;
R_IMU = settings.imu.shank.gyr.R.labels;
L_gyr = EEG.other.imu.data(:,fidx(L_IMU, EEG.other.imu.label));
R_gyr = EEG.other.imu.data(:,fidx(R_IMU, EEG.other.imu.label));
L_gyr_SVM = sqrt(sum(L_gyr.^2, 2));
R_gyr_SVM = sqrt(sum(R_gyr.^2, 2));

L_IMU = settings.imu.shank.acc.L.labels;
R_IMU = settings.imu.shank.acc.R.labels;
L_acc = EEG.other.imu.data(:,fidx(L_IMU, EEG.other.imu.label));
R_acc = EEG.other.imu.data(:,fidx(R_IMU, EEG.other.imu.label));
L_acc_SVM = sqrt(sum(L_acc.^2, 2));
R_acc_SVM = sqrt(sum(R_acc.^2, 2));

tb = table([L_acc_SVM, R_acc_SVM], 'VariableNames', {'Acc.'});
tb = [tb table([L_gyr_SVM, R_gyr_SVM], 'VariableNames', {'Gyr'})];
figure, stackedplot(tb)

prompt = 'Enter first walking bouts in samples (onset1 offset1 onset2 ...):\n';
bouts_locs = (str2num(input(prompt, "s")))';
if mod(length(bouts_locs),2)
    bouts_locs = [bouts_locs; length(L_acc_SVM)];
end
bouts_typ = settings.imu.trigger.BOUTS_START*ones(length(bouts_locs),1);
bouts_typ(2:2:end) = settings.imu.trigger.BOUTS_STOP*ones(length(bouts_locs)/2,1);

end

