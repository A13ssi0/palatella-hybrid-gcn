function macroConf = confMatrixMicroToMacro(confusionMatrix)

idx{1} = 1:2;
idx{2} = 3:8;
idx{3} = 9:11;

macroConf = nan(3);

for i = 1:3
    for j = 1:3
        macroConf(i,j) = sum(confusionMatrix(idx{i},idx{j}),'all');
    end
end

