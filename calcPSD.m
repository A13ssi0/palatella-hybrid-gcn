function PSD = calcPSD(data,triggers,settings,savingName)

% Calculating PSD and windowing the events
disp('Calculating PSD')
PSD.data = compute_psd(data, settings.windowLength, settings.windowShift, settings.eeg.fs, settings.choosenFreq);

nFreq = settings.windowSize/2+1;
freq = linspace(0, settings.eeg.fs/2, nFreq);
freq = freq(2:end);
idxFreq = settings.choosenFreq(1)<=freq & freq<=settings.choosenFreq(2);
freq = freq(idxFreq);
PSD.frequency = freq;

disp('Windowing the events')
direction = 'backward';
windowsTime = proc_pos2win(triggers.time, settings.windowStep, direction, settings.windowSize);
PSD.triggers.time = windowsTime;
PSD.triggers.num = triggers.num;

PSD.settings = settings;


%% Labels the windows for train
disp('Labeling the windows')

t_max = size(data,2)/settings.eeg.fs;

nWindowCue = settings.secCue/settings.windowShift;
nWindowPostMov = settings.secPostMovement/settings.windowShift;
nWindowPreMov = settings.secPreMovement/settings.windowShift;

tw = settings.windowLength : settings.windowShift : (t_max);
windowsLabel = nan(length(tw),1);
trials = nan(length(tw),1);
t = 0;

for i = 1:length(windowsTime)-1
    wPOS = windowsTime(i);
    wlabel = triggers.num(i);

    if( wlabel>0 )
        t = t+1;
        windowsLabel(wPOS-nWindowPreMov : wPOS+nWindowPostMov-1) = wlabel;
        windowsLabel(wPOS-nWindowCue-nWindowPreMov : wPOS-1-nWindowPreMov) = 0;
        trials(wPOS-nWindowCue-nWindowPreMov : wPOS+nWindowPostMov-1) = t;
    end
end

PSD.windowsLabel = windowsLabel;
PSD.trials = trials;
    
    PSD.triggers.time(2:2:end) = PSD.triggers.time(1:2:end) + nWindowPostMov;
    PSD.triggers.time(1:2:end) = PSD.triggers.time(1:2:end) - nWindowPreMov;
    
    
    %% SAVING
    save(savingName, 'PSD','-v7.3');