function emg = deleteSeventhChannel(emg)

for i = 1:length(emg)
    temp = emg{i};
    emg{i} = temp(1:6,:,:,:);
end