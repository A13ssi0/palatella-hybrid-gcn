function dataOk = correctData(data)
dataOk = data;

idxOk = [ 1:3:18
          2:3:18
          3:3:18]';

idx = [10 11 12
       1 2 3
      13 14 15
       4 5 6
      16 17 18
       7 8 9];

for i = 1:size(idx,1)
    dataOk.micro(:,idxOk(i,:)) = data.micro(:,idx(i,:));
    dataOk.macro(:,idxOk(i,:)) = data.macro(:,idx(i,:));
end

dataOk.micro(:,18:19) = data.micro(:,18:19);
dataOk.macro(:,18:19) = data.macro(:,18:19);