function [data, marker, channels] = load_dataTesi(filename)

%loadName =
%[signal,'_session',num2str(session),'_sub',int2str(subject),'_',movement,'_realMove.mat'];clear

load(filename)

channels = mnt.clab;
n_electrodes = length(channels);
n_samples = length(ch1);
data = zeros(n_samples,n_electrodes);

for i = 1:n_electrodes
    name = ['ch' num2str(i)];
    data(:,i) = eval(name);
end

marker = mrk;
