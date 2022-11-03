function dataOk = correctData(data)
dataOk = data;

idxOk = [1:4:24
         2:4:24
         3:4:24
         4:4:24]';

% idx = [10 11 12 24
%         1  2  3 21
%        13 14 15 25
%         4  5  6 22
%        16 17 18 26
%         7  8  9 23];

idx = [10 12 11 24
        1  3  2 21
       13 15 14 25
        4  6  5 22
       16 18 17 26
        7  9  8 23];

for i = 1:size(idx,1)
    dataOk.micro(:,idxOk(i,:)) = data.micro(:,idx(i,:));
    dataOk.macro(:,idxOk(i,:)) = data.macro(:,idx(i,:));
end

dataOk.micro(:,25:26) = data.micro(:,19:20);
dataOk.macro(:,25:26) = data.macro(:,19:20);