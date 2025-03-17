function kappaMatrix = extractKappaFromCM(cmRes)

kappaMatrix = nan(size(cmRes));

for perc = 1:size(kappaMatrix,3)
    for type = 1:size(kappaMatrix,2)
        for sbj = 1:size(kappaMatrix,1)
            kappaMatrix(sbj,type,perc) = kappa(cmRes{sbj,type,perc});
        end
    end
end