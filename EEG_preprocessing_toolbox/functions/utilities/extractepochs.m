function [data_epoch, trials_typ] = extractepochs(data,triggers,labels,epoch,fs)
% data must have samples in the first dimension

[trials_typ,trials_pos] = find_events(triggers,labels);

nsamps = (epoch(2)-epoch(1))*fs;
ndim = ndims(data);
ncolons = repmat({':'},1,ndim-1);
ntrials = length(trials_typ);

data_epoch = [];
for t = 1:ntrials
    tstart = trials_pos(t) + epoch(1)*fs;
    tstop = tstart + nsamps - 1;
    data_epoch = cat(ndim+1, data_epoch, data(tstart:tstop, ncolons{:}));
end

end

