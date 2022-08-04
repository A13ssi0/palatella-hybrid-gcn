function [data_epoch, trig_epoch] = extractstepcycles(data,triggers,settings)
% data must have samples in the first dimension
ndim = ndims(data);
ncolons = repmat({':'},1,ndim-1);

step_phases = [settings.leg.R.FC; settings.leg.R.IC; settings.leg.L.FC; settings.leg.L.IC; settings.leg.R.FC];
nphases = length(step_phases);

[typ,pos] = find_events(triggers,[settings.leg.R.FC; settings.leg.R.IC; settings.leg.L.FC; settings.leg.L.IC]);
trig_epoch = {};
data_epoch = {};
count = 0;

[bouts_typ,bouts_pos] = find_events(triggers,[settings.imu.trigger.BOUTS_START settings.imu.trigger.BOUTS_STOP]);
for b = 1:2:length(bouts_typ)-1
    % bouts boundaries
    bstr = bouts_pos(b);
    bstp = bouts_pos(b+1);
    
    typ_b = typ(pos >= bstr & pos <= bstp);
    pos_b = pos(pos >= bstr & pos <= bstp);
    
    K = strfind(typ_b',step_phases');
    for i = 1:length(K)
        count = count+1;
        trig_epoch = cat(1, trig_epoch, nan(nphases,2)); % [typ pos]
        trig_epoch{count}(:,1) = step_phases; % typ
        trig_epoch{count}(:,2) = pos_b(K(i):K(i)+nphases-1); % pos
        
        % epoch data
        tstart = trig_epoch{count}(1,2);
        tstop = trig_epoch{count}(end,2);
        data_epoch = cat(1, data_epoch, data(tstart:tstop, ncolons{:}));    
    end
    
end

end

