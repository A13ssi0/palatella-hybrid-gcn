function [input, output] = createInputOutputMatrices(data, indicesToTake, onsetNum, settings)

nMonwinSize = settings.movwinLength/settings.windowShift;
nMonwinShift = settings.movwinShift/settings.windowShift;
nWindowsTrial = onsetNum(2,2)-onsetNum(1,2);

input = cell(length(indicesToTake)*nWindowsTrial,1);
output = nan(size(input));
for i = 1:length(indicesToTake)
    if onsetNum(indicesToTake(i),1) ~= 0
        idx = onsetNum(indicesToTake(i),2):onsetNum(indicesToTake(i)+1,2)-1;
    else        
        idx = (-nWindowsTrial:-1) + onsetNum(indicesToTake(i)-1,2);
    end
    for j = idx
        start = (i-1)*nMonwinShift+1; stop = start + nMonwinSize - 1;
        input{i} = data(:,:,:,start:stop);
    end
    output((1:nWindowsTrial)+(i-1)*nWindowsTrial) = onsetNum(indicesToTake(i),1);
end
output = categorical(output);