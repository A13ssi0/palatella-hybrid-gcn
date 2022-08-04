function EEG = merge_EEG(info,input_type,settings)

info.session_num = info.session_nums(1);
EEG = load_EEG(info,input_type,settings);
for f = 2:length(info.session_nums)
    info.session_num = info.session_nums(f);
    tmp = load_EEG(info,input_type,settings);
    
    % EVENTS
    EEG.other.imu.triggers.event.typ = [EEG.other.imu.triggers.event.typ; ...
        settings.imu.trigger.FILE_BOUNDARY; ...
        tmp.other.imu.triggers.event.typ];
    EEG.other.imu.triggers.event.pos = [EEG.other.imu.triggers.event.pos; ...
        EEG.pnts; tmp.other.imu.triggers.event.pos+EEG.pnts];
    
    % EEG
    EEG.session = strcat(num2str(EEG.session),num2str(tmp.session));
    EEG.data = [EEG.data, tmp.data];
    EEG.pnts = EEG.pnts + tmp.pnts;
    EEG.times = 0:1/EEG.srate*1000:EEG.pnts/EEG.srate*1000-1/EEG.srate*1000;
    EEG.xmax = EEG.times(end)/1000;
    
    % OTHER
    EEG.other.emg.data = [EEG.other.emg.data; tmp.other.emg.data];
    EEG.other.imu.data = [EEG.other.imu.data; tmp.other.imu.data];
    EEG.other.imu.triggers.R.data = [EEG.other.imu.triggers.R.data; tmp.other.imu.triggers.R.data];
    EEG.other.imu.triggers.L.data = [EEG.other.imu.triggers.L.data; tmp.other.imu.triggers.L.data];
    
end

end

