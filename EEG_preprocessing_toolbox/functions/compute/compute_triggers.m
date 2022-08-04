function EEG = compute_triggers(EEG,settings)

% Identify walking bouts
% L_IMU = settings.imu.shank.acc.L.labels;
% R_IMU = settings.imu.shank.acc.R.labels;
% L_acc = EEG.other.imu.data(:,fidx(L_IMU, EEG.other.imu.label));
% R_acc = EEG.other.imu.data(:,fidx(R_IMU, EEG.other.imu.label));
% [bouts_typ, bouts_locs] = find_bouts(L_acc, R_acc,settings);

if isfield(EEG.other.imu, 'triggers')
    bouts_typ = EEG.other.imu.triggers.event.typ(...
        EEG.other.imu.triggers.event.typ==settings.imu.trigger.BOUTS_START | ...
        EEG.other.imu.triggers.event.typ==settings.imu.trigger.BOUTS_STOP);
    bouts_locs = EEG.other.imu.triggers.event.pos(...
        EEG.other.imu.triggers.event.typ==settings.imu.trigger.BOUTS_START | ...
        EEG.other.imu.triggers.event.typ==settings.imu.trigger.BOUTS_STOP);
else
    [bouts_typ,bouts_locs] = insert_bouts_v2(EEG,settings);
end

% Compute triggers
switch settings.imu.trigger.method
    case 'velocity_threshold'
        L_IMU = settings.imu.trigger.(settings.imu.trigger.method).L_IMU;
        R_IMU = settings.imu.trigger.(settings.imu.trigger.method).R_IMU;
        
        L_speed = EEG.other.imu.data(:,fidx(L_IMU, EEG.other.imu.label));
        R_speed = EEG.other.imu.data(:,fidx(R_IMU, EEG.other.imu.label));
        
        [L_trig_pks, L_trig_locs, L_swg_pks, L_swg_locs, L_speed_filt] = ...
            find_swing_trig(L_speed,settings.imu.fs,'L',bouts_locs,settings);
        [R_trig_pks, R_trig_locs, R_swg_pks, R_swg_locs, R_speed_filt] = ...
            find_swing_trig(R_speed,settings.imu.fs,'R',bouts_locs,settings);

        figure
        plot_triggers(L_speed_filt, R_speed_filt, ...
            L_IMU, R_IMU, L_trig_locs, L_trig_pks, ...
            R_trig_locs, R_trig_pks, bouts_locs)
               
        % Exclude unwanted trials
        prompt = 'Exclude left events:\n';
        left_exclude = str2num(input(prompt, "s"));
        prompt = 'Exclude right events:\n';
        right_exclude = str2num(input(prompt, "s"));
        
        L_trig_locs(left_exclude) = []; L_trig_pks(left_exclude) = [];
        R_trig_locs(right_exclude) = []; R_trig_pks(right_exclude) = [];
        
        plot_triggers(L_speed_filt, R_speed_filt, ...
            L_IMU, R_IMU, L_trig_locs, L_trig_pks, ...
            R_trig_locs, R_trig_pks, bouts_locs)
        
        % Merge left and right triggers
        LEFT_LABEL = settings.leg.L.label;
        RIGHT_LABEL = settings.leg.R.label;
        n_left = length(L_trig_locs);
        n_right = length(R_trig_locs);
        trig_typ = [LEFT_LABEL*ones(n_left,1); RIGHT_LABEL*ones(n_right,1); bouts_typ];       
        trig_locs = [L_trig_locs; R_trig_locs; bouts_locs];
        [trig_locs, sort_idx] = sort(trig_locs);
        trig_typ = trig_typ(sort_idx);
        
        triggers.R.data = R_speed_filt;
        triggers.L.data = L_speed_filt;
        
        triggers.event.typ = trig_typ;
        triggers.event.pos = trig_locs;
        
    case 'toe_off'
        L_IMU = settings.imu.trigger.(settings.imu.trigger.method).L_IMU;
        R_IMU = settings.imu.trigger.(settings.imu.trigger.method).R_IMU;
        
        L_speed = EEG.other.imu.data(:,fidx(L_IMU, EEG.other.imu.label));
        R_speed = EEG.other.imu.data(:,fidx(R_IMU, EEG.other.imu.label));
        
        [L_swg_pks, L_swg_locs, L_toff_pks, L_toff_locs, L_speed_filt] = ...
            find_swing_toeoff(L_speed,settings.imu.fs,'L',settings);
        [R_swg_pks, R_swg_locs, R_toff_pks, R_toff_locs, R_speed_filt] = ...
            find_swing_toeoff(R_speed,settings.imu.fs,'R',settings);
        
        plot_triggers(L_speed_filt, R_speed_filt, ...
            L_IMU, R_IMU, L_toff_locs, L_toff_pks, ...
            R_toff_locs, R_toff_pks, bouts_locs)
               
        % Exclude unwanted trials
        prompt = 'Exclude left events:\n';
        left_exclude = str2num(input(prompt, "s"));
        prompt = 'Exclude right events:\n';
        right_exclude = str2num(input(prompt, "s"));
        
        L_toff_locs(left_exclude) = []; L_toff_pks(left_exclude) = [];
        R_toff_locs(right_exclude) = []; R_toff_pks(right_exclude) = [];
        
        plot_triggers(L_speed_filt, R_speed_filt, ...
            L_IMU, R_IMU, L_toff_locs, L_toff_pks, ...
            R_toff_locs, R_toff_pks, bouts_locs)
        
        % Merge left and right triggers
        LEFT_LABEL = settings.leg.L.label;
        RIGHT_LABEL = settings.leg.R.label;
        n_left = length(L_toff_locs);
        n_right = length(R_toff_locs);
        trig_typ = [LEFT_LABEL*ones(n_left,1); RIGHT_LABEL*ones(n_right,1); bouts_typ];       
        trig_locs = [L_toff_locs; R_toff_locs; bouts_locs];
        [trig_locs, sort_idx] = sort(trig_locs);
        trig_typ = trig_typ(sort_idx);
        
        triggers.R.data = R_speed_filt;
        triggers.L.data = L_speed_filt;
        
        triggers.event.typ = trig_typ;
        triggers.event.pos = trig_locs;
        
    case 'TKO'
    case 'swing'
        
        L_IMU = settings.imu.trigger.(settings.imu.trigger.method).L_IMU;
        R_IMU = settings.imu.trigger.(settings.imu.trigger.method).R_IMU;
        
        L_speed = -EEG.other.imu.data(:,fidx(L_IMU, EEG.other.imu.label));
        R_speed = EEG.other.imu.data(:,fidx(R_IMU, EEG.other.imu.label));
        
        [L_swg_pks, L_swg_locs, L_speed_filt] = ...
            find_swing(L_speed,settings.imu.fs,'L',bouts_locs,settings);
        [R_swg_pks, R_swg_locs, R_speed_filt] = ...
            find_swing(R_speed,settings.imu.fs,'R',bouts_locs,settings);

        figure
        plot_triggers(L_speed_filt, R_speed_filt, ...
            L_IMU, R_IMU, L_swg_locs, L_swg_pks, ...
            R_swg_locs, R_swg_pks, bouts_locs)
        
%         % Exclude unwanted trials
%         prompt = 'Exclude left events:\n';
%         left_exclude = str2num(input(prompt, "s"));
%         prompt = 'Exclude right events:\n';
%         right_exclude = str2num(input(prompt, "s"));
%         
%         L_swg_locs(left_exclude) = []; L_swg_pks(left_exclude) = [];
%         R_swg_locs(right_exclude) = []; R_swg_pks(right_exclude) = [];
%         
%         plot_triggers(L_speed_filt, R_speed_filt, ...
%             L_IMU, R_IMU, L_swg_locs, L_swg_pks, ...
%             R_swg_locs, R_swg_pks, bouts_locs)
        
        % Merge left and right triggers
        LEFT_LABEL = settings.leg.L.label;
        RIGHT_LABEL = settings.leg.R.label;
        n_left = length(L_swg_locs);
        n_right = length(R_swg_locs);
        trig_typ = [LEFT_LABEL*ones(n_left,1); RIGHT_LABEL*ones(n_right,1); bouts_typ];       
        trig_locs = [L_swg_locs; R_swg_locs; bouts_locs];
        [trig_locs, sort_idx] = sort(trig_locs);
        trig_typ = trig_typ(sort_idx);
        
        triggers.R.data = R_speed_filt;
        triggers.L.data = L_speed_filt;
        
        triggers.event.typ = trig_typ;
        triggers.event.pos = trig_locs;
        
    case 'step_cycle'
        L_IMU = settings.imu.trigger.(settings.imu.trigger.method).L_IMU;
        R_IMU = settings.imu.trigger.(settings.imu.trigger.method).R_IMU;
        
        L_speed = -EEG.other.imu.data(:,fidx(L_IMU, EEG.other.imu.label));
        R_speed = EEG.other.imu.data(:,fidx(R_IMU, EEG.other.imu.label));
        
        [L_FC_pks, L_FC_locs, L_MS_pks, L_MS_locs, ...
            L_IC_pks, L_IC_locs, L_speed_filt] = find_FC_MS_IC(L_speed,settings.imu.fs,'L',bouts_locs,settings);
        [R_FC_pks, R_FC_locs, R_MS_pks, R_MS_locs, ...
            R_IC_pks, R_IC_locs, R_speed_filt] = find_FC_MS_IC(R_speed,settings.imu.fs,'R',bouts_locs,settings);
        
        figure
        plot_FC_MS_IC(L_speed_filt, R_speed_filt, L_IMU, R_IMU, ...
            L_FC_locs, L_FC_pks, L_MS_locs, L_MS_pks, L_IC_locs, L_IC_pks, ...
            R_FC_locs, R_FC_pks, R_MS_locs, R_MS_pks, R_IC_locs, R_IC_pks, ...
            bouts_locs)
        
        % Exclude unwanted trials
        prompt = 'Exclude left events:\n';
        left_exclude = str2num(input(prompt, "s"));
        prompt = 'Exclude right events:\n';
        right_exclude = str2num(input(prompt, "s"));
        
        L_FC_locs(left_exclude) = []; L_FC_pks(left_exclude) = [];
        L_MS_locs(left_exclude) = []; L_MS_pks(left_exclude) = [];
        L_IC_locs(left_exclude) = []; L_IC_pks(left_exclude) = [];
        
        R_FC_locs(right_exclude) = []; R_FC_pks(right_exclude) = [];
        R_MS_locs(right_exclude) = []; R_MS_pks(right_exclude) = [];
        R_IC_locs(right_exclude) = []; R_IC_pks(right_exclude) = [];
        
        plot_FC_MS_IC(L_speed_filt, R_speed_filt, L_IMU, R_IMU, ...
            L_FC_locs, L_FC_pks, L_MS_locs, L_MS_pks, L_IC_locs, L_IC_pks, ...
            R_FC_locs, R_FC_pks, R_MS_locs, R_MS_pks, R_IC_locs, R_IC_pks, ...
            bouts_locs)
        
        % Merge left and right triggers
        FC_LEFT = settings.leg.L.FC;
        IC_LEFT = settings.leg.L.IC;
        FC_RIGHT = settings.leg.R.FC;
        IC_RIGHT = settings.leg.R.IC;
        n_left = length(L_MS_locs);
        n_right = length(R_MS_locs);
        trig_typ = [FC_LEFT*ones(n_left,1); IC_LEFT*ones(n_left,1);...
            FC_RIGHT*ones(n_right,1); IC_RIGHT*ones(n_right,1); bouts_typ];
        trig_locs = [L_FC_locs; L_IC_locs; R_FC_locs; R_IC_locs; bouts_locs];
        [trig_locs, sort_idx] = sort(trig_locs);
        trig_typ = trig_typ(sort_idx);
        
        triggers.R.data = R_speed_filt;
        triggers.L.data = L_speed_filt;
        
        triggers.event.typ = trig_typ;
        triggers.event.pos = trig_locs;
        
    otherwise
        error('[compute_triggers] Unknown trigger method!')
end

EEG.other.imu.triggers = triggers;

end

function plot_triggers(L_speed_filt, R_speed_filt, ...
    L_IMU, R_IMU, L_trig_locs, L_trig_pks, ...
    R_trig_locs, R_trig_pks, bouts_locs)

plot(1:length(L_speed_filt), L_speed_filt, 1:length(R_speed_filt), R_speed_filt)
legend(cat(1,L_IMU, R_IMU))
hold on
scatter(L_trig_locs, L_trig_pks, 'bo');
scatter(R_trig_locs, R_trig_pks, 'ro');
for b = 1:length(bouts_locs)
    xline(bouts_locs(b))
end
hold off
end

function plot_FC_MS_IC(L_speed_filt, R_speed_filt, L_IMU, R_IMU, ...
    L_FC_locs, L_FC_pks, L_MS_locs, L_MS_pks, L_IC_locs, L_IC_pks, ...
    R_FC_locs, R_FC_pks, R_MS_locs, R_MS_pks, R_IC_locs, R_IC_pks, ...
    bouts_locs)

p_L = plot(1:length(L_speed_filt), L_speed_filt);
hold on
p_R = plot(1:length(R_speed_filt), R_speed_filt);
scatter(L_FC_locs, L_FC_pks, 'bo');
scatter(L_MS_locs, L_MS_pks, 'bo');
scatter(L_IC_locs, L_IC_pks, 'bo');
scatter(R_FC_locs, R_FC_pks, 'ro');
scatter(R_MS_locs, R_MS_pks, 'ro');
scatter(R_IC_locs, R_IC_pks, 'ro');
for b = 1:length(bouts_locs)
    xline(bouts_locs(b))
end

delta_y = 7;
for i = 1:length(L_MS_locs)
    text(L_MS_locs(i),L_MS_pks(i)+delta_y, num2str(i), 'Color','blue','FontSize',12)
end
for i = 1:length(R_MS_locs)
    text(R_MS_locs(i),R_MS_pks(i)+delta_y, num2str(i), 'Color','red','FontSize',12)
end
hold off
legend([p_L, p_R], {'LEFT', 'RIGHT'})

end

