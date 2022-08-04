function EEG = compute_ica(EEG, settings)

% Select only data in the walking bouts
% bouts_start = find(EEG.other.imu.triggers.event.typ == settings.imu.trigger.BOUTS_START);
% bouts_stop = find(EEG.other.imu.triggers.event.typ == settings.imu.trigger.BOUTS_STOP);
% n_bouts = length(bouts_start);
% data = [];
% for b = 1:n_bouts
%     start = EEG.other.imu.triggers.event.pos(bouts_start(b));
%     stop = EEG.other.imu.triggers.event.pos(bouts_stop(b));
%     data = [data, EEG.data(:, start:stop)];
% end
% EEG = EEG;
% EEG1.data = data;

drk = getrank(EEG.data);
fprintf('[compute_ica] Suggested rank is %d \n', drk)

% Discard channels to make the data full ranked.
if settings.eeg.ica.chanselect
    channelSubset = loc_subsets(EEG.chanlocs, drk);
    EEG = pop_select(EEG,'channel', channelSubset{1});
    EEG = pop_chanedit(EEG, 'eval','chans = pop_chancenter( chans, [],[]);');
end

if strcmp(settings.eeg.ica.method, 'ica')
    [EEG.icaweights,EEG.icasphere]=runica(EEG.data(:,:),'sphering','on','lrate',1e-4,'maxsteps',100);
%     EEG.icaweights = EEG.icaweights;
%     EEG.icasphere = EEG.icasphere;
%     EEG.icawinv=inv(EEG.icaweights*EEG.icasphere);
elseif strcmp(settings.eeg.ica.method, 'amica')
    amica_arglist
    arglist(4) = {size(EEG,1)};
    arglist(6) = {drk};
    [W,S,mods] = runamica15(EEG.data(:,:), arglist{:});
    EEG.icaweights = W;
    EEG.icasphere  = S(1:size(W,1),:);
    EEG.icawinv    = mods.A(:,:,1);
end

% 
EEG = eeg_checkset(EEG, 'ica');

% [EEG.icaweights,EEG.icasphere]=runica(EEG1.data(:,:),'sphering','on','lrate',1e-5,'maxsteps',50);
% EEG.icawinv=inv(EEG.icaweights*EEG.icasphere);

end

