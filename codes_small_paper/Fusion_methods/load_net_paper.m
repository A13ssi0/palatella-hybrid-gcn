function net = load_net_paper(netPath,numSubject,dataType,settings,endNameEEG)

disp(['Loading ',dataType,' net for subject ',num2str(numSubject)])

if nargin<5,    endNameEEG = '';    end

%isMacro = settings.macro;

%loadName = [netPath,'nn_'];


if strcmpi(dataType,'EEG')
    loadName = [netPath,'nn_CNN_2LSTM_EEG_macro_subj',num2str(numSubject),endNameEEG];
    net = load(loadName);
    return
end
    

% loadName = [netPath,'EMG filtered 25 Hz/',settings.type,'/'];
loadName = [netPath];

if strcmpi(settings.type,'healthy')
    net = load([loadName,'nn_2LSTM_EMG_macro_subj',num2str(numSubject),'_25Hz_raw']);
elseif strcmpi(settings.type,'fatigue')
    net = load([loadName,'nn_2LSTM_EMG_macro_subj',num2str(numSubject),'_smaller_attenuation',num2str(fix(settings.attenuation*100))]);
elseif strcmpi(settings.type,'paraplegic')
    net = load([loadName,'nn_2LSTM_EMG_macro_subj',num2str(numSubject),'smaller_25Hz_raw_snr',num2str(settings.snr),'.mat']);
end


% loadName = [loadName,'subj',num2str(numSubject)];
% 
% 
% if nargout>0
%     net = load(loadName,'net','confMatrix');   
% else 
%     net = load(loadName);
%     return
% end


