function net = load_net_paper(netPath,numSubject,dataType,isMacro,isTime,cutEnd)

if nargin<6
    cutEnd = true;
end

loadName = [netPath,'nn_'];


if strcmpi(dataType,'EEG')
    loadName = [loadName,'CNN_2LSTM_EEG_'];
else
    loadName = [loadName,'2LSTM_EMG_'];
end

if isMacro,     loadName = [loadName,'macro_'];     end
if isTime && strcmpi(dataType,'EMG'),      loadName = [loadName,'timeRaw_'];   end

loadName = [loadName,'subj',num2str(numSubject)];


if nargout>0
    net = load(loadName,'net');     
else 
    net = load(loadName);
    return
end

if cutEnd
    net = layerGraph(net);
    net = removeLayers(net,'classification');
end


