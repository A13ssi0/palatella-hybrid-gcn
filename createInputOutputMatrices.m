function [input, output] = createInputOutputMatrices(data, indicesToTake, onsetNum, settings)

nMonwinSize = settings.movWinLength/settings.windowShift;
nMonwinShift = settings.movWinShift/settings.windowShift;
%nWindowsTrial = onsetNum(2,2)-onsetNum(1,2);
nWindowsTrial = settings.nWindowsTrial;

if exist('settings.dataSingle','var') && settings.dataSingle
    data = single(data);
end

input = cell(length(indicesToTake)*nWindowsTrial,1);
output = nan(size(input));

%disp(num2str(length(indicesToTake)))
for i = 1:length(indicesToTake)

    if onsetNum(indicesToTake(i),1) ~= 0
        idxSequency = onsetNum(indicesToTake(i),2):onsetNum(indicesToTake(i)+1,2)-1;
    else        
        idxSequency = (-nWindowsTrial:-1) + onsetNum(indicesToTake(i)-1,2);
    end

    countTrial = 0;
    for j = idxSequency
        countTrial = countTrial+1;
        start = (j-1)*nMonwinShift+1; stop = start + nMonwinSize - 1;
        seq_I{countTrial} = data(:,:,:,start:stop);
    end
    %disp(num2str(i))
    input((1:nWindowsTrial)+(i-1)*nWindowsTrial) = seq_I;
    output((1:nWindowsTrial)+(i-1)*nWindowsTrial) = onsetNum(indicesToTake(i),1);
end
countClasses = histcounts(output);

while max(countClasses)>3*min(countClasses)
    [numClass,typeClass] = max(countClasses);
    idxToDelete = datasample(find(output==typeClass-1),numClass-3*min(countClasses),'Replace',false);
    input(idxToDelete) = [];
    output(idxToDelete) = [];
    countClasses = histcounts(output);
end

output = categorical(output);

