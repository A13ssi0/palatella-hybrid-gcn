function [input, output] = createInputOutputVectors(data, indicesToTake, onsetNum, onsetTime, windowsLabel, settings)

nWindowsTrial = (settings.secPostMovement+settings.secPreMovement)/settings.windowShift; 

timeSeries = zeros(nWindowsTrial*length(indicesToTake),1);
for i = 1:length(indicesToTake)
    if onsetNum(indicesToTake) ~= 0
        timeSeries( (1:nWindowsTrial)+nWindowsTrial*(i-1) ) = onsetTime(indicesToTake(i)):onsetTime(indicesToTake(i)+1)-1;
    else        
        timeSeries( (1:nWindowsTrial)+nWindowsTrial*(i-1) ) = (-nWindowsTrial:-1) + onsetTime(indicesToTake(i)-1);
    end
end



input = zeros([settings.inputSize length(timeSeries)]);
for i = 1:length(timeSeries)
    input(:,:,1,i) = squeeze(data(timeSeries(i),:,:))';
end

output = categorical(windowsLabel(timeSeries));