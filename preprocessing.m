%%
close all; clearvars; clc;

subject = 1;
%sessions = [1];

%% Settings
subj.numSubject = subject;
subj.settings.downsampling = 5;
%subj.session.sessions = sessions;
subj.settings.step_epoch = [-8 1.999]; 
subj.settings.eeg.asr.th = 10; % [std]
subj.settings.eeg.asr.block_size = 10;
subj.settings.eeg.asr.window_length = 1; % [sec]
subj.settings.eeg.asr.window_overlap = 0.66; % [%]
subj.settings.eeg.asr.max_bad_channels = 0.05; %0.2
subj.settings.eeg.asr.auto_calib = true;
subj.settings.eeg.asr.iterative = false;
subj.settings.eeg.asr.iter_th = 0.05; % [%]
subj.settings.eeg.asr.max_iter = 20; % [%]
subj.settings.eeg.fs = 2500/subj.settings.downsampling;

subj.settings.eeg.cca.window_length = 2.0; % 5 [sec]
subj.settings.eeg.cca.window_shift = 1; % 2.5 [sec]
subj.settings.eeg.cca.eigratio = 1e6;
subj.settings.eeg.cca.femg = 25; % [Hz] %15
subj.settings.eeg.cca.ratio = 10;
subj.settings.eeg.cca.range = [0 10];

subj.settings.eeg.ica.method = 'amica';
subj.settings.eeg.ica.chanselect = false;


%% Transforming to matrix the EEG datasets
scaleDownsample = subj.settings.downsampling;
start = zeros(3);
stop = zeros(3);
markerNum = [];
markerTime = cell(3);

% Session 1 ---------------------------------------------------------------
disp('Transforming to matrix EEG session 1 and downsampling')
load(strcat('EEG_session1_sub',int2str(subject),'_reaching_realMove.mat'));
info.reach = nfo;    marker.reach = mrk;  posit.reach = mnt;
n_electrodes = length(mnt.clab);
EEG_matrix_session1_reaching_realMove = zeros(length(ch1),n_electrodes);
for i = 1:n_electrodes
    name = ['ch' num2str(i)];
    EEG_matrix_session1_reaching_realMove(:,i) = eval(name);
end
EEG_matrix_session1_reaching_realMove = downsample(EEG_matrix_session1_reaching_realMove,scaleDownsample);

load(strcat('EEG_session1_sub',int2str(subject),'_twist_realMove.mat'));
info.twist = nfo;    marker.twist = mrk;  posit.twist = mnt;
EEG_matrix_session1_twist_realMove = zeros(length(ch1),n_electrodes);
for i = 1:n_electrodes
    name = ['ch' num2str(i)];
    EEG_matrix_session1_twist_realMove(:,i) = eval(name);
end
EEG_matrix_session1_twist_realMove = downsample(EEG_matrix_session1_twist_realMove,scaleDownsample);

load(strcat('EEG_session1_sub',int2str(subject),'_multigrasp_realMove.mat'));
info.grasp = nfo;    marker.grasp = mrk;  posit.grasp = mnt;
EEG_matrix_session1_multigrasp_realMove = zeros(length(ch1),n_electrodes);
for i = 1:n_electrodes
    name = ['ch' num2str(i)];
    EEG_matrix_session1_multigrasp_realMove(:,i) = eval(name);
end
EEG_matrix_session1_multigrasp_realMove = downsample(EEG_matrix_session1_multigrasp_realMove,scaleDownsample);


start(1,:) = [marker.reach.misc.pos(1) marker.twist.misc.pos(1) marker.grasp.misc.pos(1)];
stop(1,:) = [marker.reach.misc.pos(2) marker.twist.misc.pos(2) marker.grasp.misc.pos(2)];
markerNum = [markerNum; marker.reach.toe'; marker.twist.toe'; marker.grasp.toe'];
markerTime{1,1} = round(marker.reach.pos'/scaleDownsample);
markerTime{1,2} = round(marker.twist.pos'/scaleDownsample); 
markerTime{1,3} = round(marker.grasp.pos'/scaleDownsample);
classOneHot{1}.reach = marker.reach.y;
classOneHot{1}.grasp = marker.grasp.y;
classOneHot{1}.twist = marker.twist.y;
numClass{1}.reach = marker.reach.toe;
numClass{1}.grasp = marker.grasp.toe;
numClass{1}.twist = marker.twist.toe;
className.reach = marker.reach.className;
className.grasp = marker.grasp.className;
className.twist = marker.twist.className;


% Session 2 ---------------------------------------------------------------
disp('Transforming to matrix EEG session 2 and downsampling')
load(strcat('EEG_session2_sub',int2str(subject),'_reaching_realMove.mat'));
info.reach = nfo;    marker.reach = mrk;  posit.reach = mnt;
EEG_matrix_session2_reaching_realMove = zeros(length(ch1),n_electrodes);
for i = 1:n_electrodes
    name = ['ch' num2str(i)];
    EEG_matrix_session2_reaching_realMove(:,i) = eval(name);
end
EEG_matrix_session2_reaching_realMove = downsample(EEG_matrix_session2_reaching_realMove,scaleDownsample);


load(strcat('EEG_session2_sub',int2str(subject),'_twist_realMove.mat'));
info.twist = nfo;    marker.twist = mrk;  posit.twist = mnt;
EEG_matrix_session2_twist_realMove = zeros(length(ch1),n_electrodes);
for i = 1:n_electrodes
    name = ['ch' num2str(i)];
    EEG_matrix_session2_twist_realMove(:,i) = eval(name);
end
EEG_matrix_session2_twist_realMove = downsample(EEG_matrix_session2_twist_realMove,scaleDownsample);


load(strcat('EEG_session2_sub',int2str(subject),'_multigrasp_realMove.mat'));
info.grasp = nfo;    marker.grasp = mrk;  posit.grasp = mnt;
EEG_matrix_session2_multigrasp_realMove = zeros(length(ch1),n_electrodes);
for i = 1:n_electrodes
    name = ['ch' num2str(i)];
    EEG_matrix_session2_multigrasp_realMove(:,i) = eval(name);
end
EEG_matrix_session2_multigrasp_realMove = downsample(EEG_matrix_session2_multigrasp_realMove,scaleDownsample);


start(2,:) = [marker.reach.misc.pos(1) marker.twist.misc.pos(1) marker.grasp.misc.pos(1)];
stop(2,:) = [marker.reach.misc.pos(2) marker.twist.misc.pos(2) marker.grasp.misc.pos(2)];
markerNum = [markerNum; marker.reach.toe'; marker.twist.toe'; marker.grasp.toe'];
markerTime{2,1} = round(marker.reach.pos'/scaleDownsample);
markerTime{2,2} = round(marker.twist.pos'/scaleDownsample);
markerTime{2,3} = round(marker.grasp.pos'/scaleDownsample);
classOneHot{2}.reach = marker.reach.y;
classOneHot{2}.grasp = marker.grasp.y;
classOneHot{2}.twist = marker.twist.y;
numClass{2}.reach = marker.reach.toe;
numClass{2}.grasp = marker.grasp.toe;
numClass{2}.twist = marker.twist.toe;



% Session 3 ---------------------------------------------------------------
disp('Transforming to matrix EEG session 3 and downsampling')
load(strcat('EEG_session3_sub',int2str(subject),'_reaching_realMove.mat'));
info.reach = nfo;    marker.reach = mrk;  posit.reach = mnt;
EEG_matrix_session3_reaching_realMove = zeros(length(ch1),n_electrodes);
for i = 1:n_electrodes
    name = ['ch' num2str(i)];
    EEG_matrix_session3_reaching_realMove(:,i) = eval(name);
end
EEG_matrix_session3_reaching_realMove = downsample(EEG_matrix_session3_reaching_realMove,scaleDownsample);


load(strcat('EEG_session3_sub',int2str(subject),'_twist_realMove.mat'));
info.twist = nfo;    marker.twist = mrk;  posit.twist = mnt;
EEG_matrix_session3_twist_realMove = zeros(length(ch1),n_electrodes);
for i = 1:n_electrodes
    name = ['ch' num2str(i)];
    EEG_matrix_session3_twist_realMove(:,i) = eval(name);
end
EEG_matrix_session3_twist_realMove = downsample(EEG_matrix_session3_twist_realMove,scaleDownsample);


load(strcat('EEG_session3_sub',int2str(subject),'_multigrasp_realMove.mat'));
info.grasp = nfo;    marker.grasp = mrk;  posit.grasp = mnt;
EEG_matrix_session3_multigrasp_realMove = zeros(length(ch1),n_electrodes);
for i = 1:n_electrodes
    name = ['ch' num2str(i)];
    EEG_matrix_session3_multigrasp_realMove(:,i) = eval(name);
end
EEG_matrix_session3_multigrasp_realMove = downsample(EEG_matrix_session3_multigrasp_realMove,scaleDownsample);


start(3,:) = [marker.reach.misc.pos(1) marker.twist.misc.pos(1) marker.grasp.misc.pos(1)];
stop(3,:) = [marker.reach.misc.pos(2) marker.twist.misc.pos(2) marker.grasp.misc.pos(2)];
markerNum = [markerNum; marker.reach.toe'; marker.twist.toe'; marker.grasp.toe'];
markerTime{3,1} = round(marker.reach.pos'/scaleDownsample);
markerTime{3,2} = round(marker.twist.pos'/scaleDownsample);
markerTime{3,3} = round(marker.grasp.pos'/scaleDownsample);
classOneHot{3}.reach = marker.reach.y;
classOneHot{3}.grasp = marker.grasp.y;
classOneHot{3}.twist = marker.twist.y;
numClass{3}.reach = marker.reach.toe;
numClass{3}.grasp = marker.grasp.toe;
numClass{3}.twist = marker.twist.toe;



%% Transforming to matrix the EMG datasets
% Session 1 ---------------------------------------------------------------
disp('Transforming to matrix EMG session 1 and downsampling')
load(strcat('EMG_session1_sub',int2str(subject),'_reaching_realMove.mat'));
n_electrodes = length(mnt.clab);
EMG_matrix_session1_reaching_realMove = zeros(length(ch1),n_electrodes);
for i = 1:n_electrodes
    name = ['ch' num2str(i)];
    EMG_matrix_session1_reaching_realMove(:,i) = eval(name);
end
EMG_matrix_session1_reaching_realMove = downsample(EMG_matrix_session1_reaching_realMove,scaleDownsample);


load(strcat('EMG_session1_sub',int2str(subject),'_twist_realMove.mat'));
EMG_matrix_session1_twist_realMove = zeros(length(ch1),n_electrodes);
for i = 1:n_electrodes
    name = ['ch' num2str(i)];
    EMG_matrix_session1_twist_realMove(:,i) = eval(name);
end
EMG_matrix_session1_twist_realMove = downsample(EMG_matrix_session1_twist_realMove,scaleDownsample);


load(strcat('EMG_session1_sub',int2str(subject),'_multigrasp_realMove.mat'));
EMG_matrix_session1_multigrasp_realMove = zeros(length(ch1),n_electrodes);
for i = 1:n_electrodes
    name = ['ch' num2str(i)];
    EMG_matrix_session1_multigrasp_realMove(:,i) = eval(name);
end
EMG_matrix_session1_multigrasp_realMove = downsample(EMG_matrix_session1_multigrasp_realMove,scaleDownsample);


% Session 2 ---------------------------------------------------------------
disp('Transforming to matrix EMG session 2 and downsampling')
load(strcat('EMG_session2_sub',int2str(subject),'_reaching_realMove.mat'));
EMG_matrix_session2_reaching_realMove = zeros(length(ch1),n_electrodes);
for i = 1:n_electrodes
    name = ['ch' num2str(i)];
    EMG_matrix_session2_reaching_realMove(:,i) = eval(name);
end
EMG_matrix_session2_reaching_realMove = downsample(EMG_matrix_session2_reaching_realMove,scaleDownsample);


load(strcat('EMG_session2_sub',int2str(subject),'_twist_realMove.mat'));
EMG_matrix_session2_twist_realMove = zeros(length(ch1),n_electrodes);
for i = 1:n_electrodes
    name = ['ch' num2str(i)];
    EMG_matrix_session2_twist_realMove(:,i) = eval(name);
end
EMG_matrix_session2_twist_realMove = downsample(EMG_matrix_session2_twist_realMove,scaleDownsample);


load(strcat('EMG_session2_sub',int2str(subject),'_multigrasp_realMove.mat'));
EMG_matrix_session2_multigrasp_realMove = zeros(length(ch1),n_electrodes);
for i = 1:n_electrodes
    name = ['ch' num2str(i)];
    EMG_matrix_session2_multigrasp_realMove(:,i) = eval(name);
end
EMG_matrix_session2_multigrasp_realMove = downsample(EMG_matrix_session2_multigrasp_realMove,scaleDownsample);


% Session 3 ---------------------------------------------------------------
disp('Transforming to matrix EMG session 3 and downsampling')
load(strcat('EMG_session3_sub',int2str(subject),'_reaching_realMove.mat'));
EMG_matrix_session3_reaching_realMove = zeros(length(ch1),n_electrodes);
for i = 1:n_electrodes
    name = ['ch' num2str(i)];
    EMG_matrix_session3_reaching_realMove(:,i) = eval(name);
end
EMG_matrix_session3_reaching_realMove = downsample(EMG_matrix_session3_reaching_realMove,scaleDownsample);


load(strcat('EMG_session3_sub',int2str(subject),'_twist_realMove.mat'));
EMG_matrix_session3_twist_realMove = zeros(length(ch1),n_electrodes);
for i = 1:n_electrodes
    name = ['ch' num2str(i)];
    EMG_matrix_session3_twist_realMove(:,i) = eval(name);
end
EMG_matrix_session3_twist_realMove = downsample(EMG_matrix_session3_twist_realMove,scaleDownsample);


load(strcat('EMG_session3_sub',int2str(subject),'_multigrasp_realMove.mat'));
EMG_matrix_session3_multigrasp_realMove = zeros(length(ch1),n_electrodes);
for i = 1:n_electrodes
    name = ['ch' num2str(i)];
    EMG_matrix_session3_multigrasp_realMove(:,i) = eval(name);
end
EMG_matrix_session3_multigrasp_realMove = downsample(EMG_matrix_session3_multigrasp_realMove,scaleDownsample);


clearvars ch*
clear dat mrk nfo mnt info posit n_electrodes name 

%% Resolving information resampling
start = round(start/scaleDownsample);
stop = round(stop/scaleDownsample);
%% Concatenating data
disp('Concatenating EEG and EMG data')
 
% Session 1 ---------------------------------------------------------------
EEG = [EEG_matrix_session1_reaching_realMove(start(1,1):stop(1,1),:)
       EEG_matrix_session1_twist_realMove(start(1,2):stop(1,2),:)
       EEG_matrix_session1_multigrasp_realMove(start(1,3):stop(1,3),:)];
clearvars EEG_matrix_session1*

EMG = [EMG_matrix_session1_reaching_realMove(start(1,1):stop(1,1),:)
       EMG_matrix_session1_twist_realMove(start(1,2):stop(1,2),:)
       EMG_matrix_session1_multigrasp_realMove(start(1,3):stop(1,3),:)];
clearvars EMG_matrix_session1*

% Session 2 ---------------------------------------------------------------
EEG = [EEG
       EEG_matrix_session2_reaching_realMove(start(2,1):stop(2,1),:)
       EEG_matrix_session2_twist_realMove(start(2,2):stop(2,2),:)
       EEG_matrix_session2_multigrasp_realMove(start(2,3):stop(2,3),:)];
clearvars EEG_matrix_session2*

EMG = [EMG
       EMG_matrix_session2_reaching_realMove(start(2,1):stop(2,1),:)
       EMG_matrix_session2_twist_realMove(start(2,2):stop(2,2),:)
       EMG_matrix_session2_multigrasp_realMove(start(2,3):stop(2,3),:)];
clearvars EMG_matrix_session2*


% Session 3 ---------------------------------------------------------------
EEG = [EEG
       EEG_matrix_session3_reaching_realMove(start(3,1):stop(3,1),:)
       EEG_matrix_session3_twist_realMove(start(3,2):stop(3,2),:)
       EEG_matrix_session3_multigrasp_realMove(start(3,3):stop(3,3),:)];
clearvars EEG_matrix_session3*

EMG = [EMG
       EMG_matrix_session3_reaching_realMove(start(3,1):stop(3,1),:)
       EMG_matrix_session3_twist_realMove(start(3,2):stop(3,2),:)
       EMG_matrix_session3_multigrasp_realMove(start(3,3):stop(3,3),:)];
clearvars EMG_matrix_session3*


%% Creating triggers vectors
disp('Creating the triggers structure')
trigger.start = start;
trigger.stop = stop;
trigger.num = markerNum;
trigger.time = [0];
trigger.type = cell(size(trigger.num));
trigger.numPointsSession = zeros(4,1);
idxOffset = 0;
for i = 1:3
    offset1 = - start(i,1) + trigger.time(end);
    time1 = markerTime{i,1} + offset1;
    offset2 = stop(i,1) + offset1 - start(i,2);
    time2 = offset2 + markerTime{i,2};
    offset3 = stop(i,2) + offset2 - start(i,3);
    time3 = offset3 + markerTime{i,3};
    trigger.time = [trigger.time; time1; time2; time3];

    [class_reach,~] = find(classOneHot{i}.reach==1);     n_reach = length(numClass{i}.reach);
    [class_twist,~] = find(classOneHot{i}.twist==1);     n_twist = length(numClass{i}.twist);
    [class_grasp,~] = find(classOneHot{i}.grasp==1);     n_grasp = length(numClass{i}.grasp);
    trigger.type(idxOffset+(1:n_reach)) = strcat('R_',className.reach(class_reach));
    idxOffset = idxOffset + n_reach;
    trigger.type(idxOffset+(1:n_twist)) = strcat('T_',className.twist(class_twist));
    idxOffset = idxOffset + n_twist;
    trigger.type(idxOffset+(1:n_grasp)) = strcat('G_',className.grasp(class_grasp));
    idxOffset = idxOffset + n_grasp;
    trigger.numPointsSession(i+1) = idxOffset-sum(trigger.numPointsSession(1:i));
end
trigger.type(contains(trigger.type,'rest','IgnoreCase',true)) = {'_Rest'};
trigger.time = trigger.time(2:end);
trigger.numPointsSession = trigger.numPointsSession(2:end);
trigger.nameClasses = flip(unique(trigger.type));

for i = 1:length(trigger.nameClasses)
    nameClass = cell2mat(trigger.nameClasses(i));
    trigger.num(contains(trigger.type,nameClass)) = i-1;
end

clearvars class_* idxOffset markerNum offset* n_* time* start stop subject marker* class* numClass

subj.triggers = trigger;
clearvars -except EEG EMG subj


%% Filtering
disp('Filtering EEG')
fs = subj.settings.eeg.fs;

fc_l = 1;   fc_h = 40;
order = 4;

subj.settings.eeg.preprocessing.HP_cutoff = fc_l;
subj.settings.eeg.preprocessing.LP_cutoff = fc_h;
subj.settings.eeg.preprocessing.order = order;

for i = 1:size(EEG,2)
    % High pass filtering @1 Hz
    [b,a] = butter(order,fc_l/(fs/2),'high');
    EEG(:,i) = filtfilt(b,a,EEG(:,i)); 

    % Low pass filtering @40 Hz
    [b,a] = butter(order,fc_h/(fs/2),'low');
    EEG(:,i) = filtfilt(b,a,EEG(:,i)); 
end

disp('Filtering EMG')
fc_l = 5;
order = 4;

subj.settings.emg.preprocessing.HP_cutoff = fc_l;
subj.settings.emg.preprocessing.order = order;

for i = 1:size(EMG,2)
    % High pass filtering @1 Hz
    [b,a] = butter(order,fc_l/(fs/2),'high');
    EMG(:,i) = filtfilt(b,a,EMG(:,i)); 
end 

clearvars -except EEG EMG subj

%% Find Electrodes to Keep and Deleting the others
disp('Deleting Electrodes')
load chanlocs60.mat
chanlocs7 = readlocs('chanlocs7.locs');
subj.eeg = make_EEGLab_struct(EEG',chanlocs60,subj.settings);
subj.emg = make_EEGLab_struct(EMG',chanlocs7,subj.settings);
clearvars EEG EMG

labels = struct2cell(chanlocs60);
labels = squeeze(labels(1,1,:));
delete= {'7','8','AF','O','FP','IZ'};
idx = zeros(length(labels),1);
for i=1:length(delete)
    idx = idx + contains(upper(labels),delete(i));
end
idx_good = idx==0;
subj.settings.eeg.preprocessing.channelSubset = labels(idx_good);
subj.eeg = pop_select(subj.eeg, 'channel', subj.settings.eeg.preprocessing.channelSubset);
subj.eeg.data = double(subj.eeg.data);

labels = struct2cell(chanlocs7);
labels = squeeze(labels(3,1,:));
delete= {'7'};
idx = zeros(length(labels),1);
for i=1:length(delete)
    idx = idx + contains(upper(labels),delete(i));
end
idx_good = idx==0;
subj.settings.emg.preprocessing.channelSubset = labels(idx_good);
subj.emg = pop_select(subj.emg, 'channel', subj.settings.emg.preprocessing.channelSubset);
subj.emg.data = double(subj.emg.data);
subj.settings.NumEMG = 6;

clearvars -except subj

%% Re-referencing And Interpolating
disp('Re-referencing And Interpolating FCz')
subj.eeg.data = filter_car(subj.eeg.data,1);

load chanlocs35.mat
FCz = eeginterp(subj.eeg.data,subj.eeg.chanlocs, chanlocs35(35));
subj.eeg.data = [subj.eeg.data
                    FCz];
subj.eeg.chanlocs = chanlocs35;
subj.eeg.nbchan = 35;
subj.settings.NumEEG = subj.eeg.nbchan;

%% ASR
subj.eeg = compute_asr(subj.eeg, subj.settings);

%% CCA
subj.eeg = compute_cca(subj.eeg, subj.settings);
settings.doCCA = 'yes';
save subj7 subj -v7.3

%% ICA
subj.eeg = compute_ica(subj.eeg, subj.settings);
settings.doICA = 'yes';
save subj7 subj -v7.3

%% IC selection
% EEG1 = compute_extractepochs(subj);
% EEG1.icaact = geticaact(EEG1);
% EEG1 = iclabel(EEG1);
% [art_comps] = ADJUST(EEG1,'report.txt');
% pop_viewprops(EEG1, 0);
% 
% prompt = 'Enter the components to remove:\n';
% rm_comps = (str2num(input(prompt, "s")))';
% EEG = pop_subcomp(EEG,rm_comps);

%% SAVING
%   subj.eeg = EEG;
%   save subj1 subj


