function net = load_net_paper(netPath,numSubject,dataType,settings)

disp(['Loading ',dataType,' net for subject ',num2str(numSubject)])

isMacro = settings.macro;

loadName = [netPath,'nn_'];


if strcmpi(dataType,'EEG')
    loadName = [loadName,'CNN_2LSTM_EEG_'];
    isTime = false;
else
    loadName = [loadName,'2LSTM_EMG_'];
    isTime = settings.timeDomain;
end

if isMacro,     loadName = [loadName,'macro_'];     end
if isTime && strcmpi(dataType,'EMG'),      loadName = [loadName,'timeRaw_'];   end

loadName = [loadName,'subj',num2str(numSubject)];


if nargout>0
    net = load(loadName,'net','confMatrix');   
else 
    net = load(loadName);
    return
end


