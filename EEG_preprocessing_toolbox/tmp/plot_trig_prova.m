%%
progait_settings;
L_speed_filt = EEG.other.imu.triggers.L.data;
R_speed_filt = EEG.other.imu.triggers.R.data;
L_FC_locs = EEG.other.imu.triggers.event.pos(EEG.other.imu.triggers.event.typ == settings.leg.L.FC);
L_FC_pks = L_speed_filt(L_FC_locs);
L_IC_locs = EEG.other.imu.triggers.event.pos(EEG.other.imu.triggers.event.typ == settings.leg.L.IC);
L_IC_pks = L_speed_filt(L_IC_locs);
R_FC_locs = EEG.other.imu.triggers.event.pos(EEG.other.imu.triggers.event.typ == settings.leg.R.FC);
R_FC_pks = R_speed_filt(R_FC_locs);
R_IC_locs = EEG.other.imu.triggers.event.pos(EEG.other.imu.triggers.event.typ == settings.leg.R.IC);
R_IC_pks = R_speed_filt(R_IC_locs);
bouts_locs = EEG.other.imu.triggers.event.pos(EEG.other.imu.triggers.event.typ == settings.imu.trigger.BOUTS_START ...
    | EEG.other.imu.triggers.event.typ == settings.imu.trigger.BOUTS_STOP);

[b,a] = butter(2,5*2/250,'high');
L_TA = filtfilt(b,a,EEG.other.emg.data(:, 5));
R_TA = filtfilt(b,a,EEG.other.emg.data(:, 6));

figure
plot_FC_MS_IC(L_speed_filt, R_speed_filt, ...
    L_FC_locs, L_FC_pks, L_IC_locs, L_IC_pks, ...
    R_FC_locs, R_FC_pks, R_IC_locs, R_IC_pks, ...
    bouts_locs,L_TA,R_TA)


%%
function plot_FC_MS_IC(L_speed_filt, R_speed_filt, ...
    L_FC_locs, L_FC_pks, L_IC_locs, L_IC_pks, ...
    R_FC_locs, R_FC_pks, R_IC_locs, R_IC_pks, ...
    bouts_locs,L_TA,R_TA)

% yyaxis left

p_L = plot(1:length(L_speed_filt), L_speed_filt, '-b');
hold on
p_R = plot(1:length(R_speed_filt), R_speed_filt, '-r');
scatter(L_FC_locs, L_FC_pks, 'bo');
scatter(L_IC_locs, L_IC_pks, 'bo');
scatter(R_FC_locs, R_FC_pks, 'ro');
scatter(R_IC_locs, R_IC_pks, 'ro');
for b = 1:length(bouts_locs)
    xline(bouts_locs(b))
end
hold off

% yyaxis right
% delta_L = 3000;
% delta_R = 3000;
% hold on
% p_Lm = plot(1:length(L_TA),L_TA+delta_L, '-c');
% p_Rm = plot(1:length(R_TA),R_TA-delta_R, '-m');
% hold off
% ylim([-4000 5000])

% legend([p_L, p_R, p_Lm, p_Rm], {'LEFT IMU', 'RIGHT IMU', 'LEFT TA', 'RIGHT TA'})

end