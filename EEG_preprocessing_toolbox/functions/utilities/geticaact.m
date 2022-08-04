function icaact = geticaact(EEG)

if isempty(EEG.icaact)
    disp('EEG.icaact not present. Recomputed from data.');
    if length(size(EEG.data))==3
        icaact = reshape(EEG.icaweights*EEG.icasphere*reshape(EEG.data,[size(EEG.data,1)...
            size(EEG.data,2)*size(EEG.data,3)]),[size(EEG.icawinv,2) size(EEG.data,2) size(EEG.data,3)]);
    else icaact = EEG.icaweights*EEG.icasphere*EEG.data;
    end
else icaact = EEG.icaact;
end

end

