function [data_epoch, trig_epoch, epoch_typ] = extractsteps(data,triggers,settings)
% data must have samples in the first dimension
ndim = ndims(data);
ncolons = repmat({':'},1,ndim-1);

[typ,pos] = find_events(triggers,[settings.leg.L.FC settings.leg.L.IC settings.leg.R.FC settings.leg.R.IC]);
NLEFT = sum(typ == settings.leg.L.FC); NRIGHT = sum(typ == settings.leg.R.FC);
trig_left_steps = cell(NLEFT, 1);
trig_right_steps = cell(NRIGHT, 1);
data_left_steps = cell(NLEFT, 1);
data_right_steps = cell(NRIGHT, 1);
l = 0; r = 0;

[bouts_typ,bouts_pos] = find_events(triggers,[settings.imu.trigger.BOUTS_START settings.imu.trigger.BOUTS_STOP]);
for b = 1:2:length(bouts_typ)-1
    % bouts boundaries
    bstr = bouts_pos(b);
    bstp = bouts_pos(b+1);
    
    typ_b = typ(pos >= bstr & pos <= bstp);
    pos_b = pos(pos >= bstr & pos <= bstp);
    
    l_fc = find(typ_b == settings.leg.L.FC);
    l_ic = find(typ_b == settings.leg.L.IC);
    r_fc = find(typ_b == settings.leg.R.FC);
    r_ic = find(typ_b == settings.leg.R.IC);
    
    l_ic_dur = (pos_b(l_ic(1:end-1)+1) - pos_b(l_ic(1:end-1)));
    l_ic_avg = round(trimmean(l_ic_dur,10));
    r_ic_dur = (pos_b(r_ic(1:end-1)+1) - pos_b(r_ic(1:end-1)));
    r_ic_avg = round(trimmean(r_ic_dur,10));
    
%     fprintf("AVG LEFT STANCE: %d, AVG RIGHT STANCE: %d \n", l_ic_avg, r_ic_avg)
    
    % LEFT
    if length(l_fc) ~= length(l_ic), error("[extractsteps] Error in left steps!"), end
    for i = 1:length(l_fc)
        l = l +1;
        
        trig_left_steps{l} = nan(4,2); % [R_IC; L_FC; L_IC; R_FC]
        trig_left_steps{l}(:,1) = [settings.leg.R.IC; settings.leg.L.FC; settings.leg.L.IC; settings.leg.R.FC]; % typ
        
        if l_fc(i) == 1 % first step (missing right IC)          
            trig_left_steps{l}(1,2) = pos_b(l_fc(i)) - r_ic_avg; % pos
        else
            if typ_b(l_fc(i)-1) == settings.leg.R.IC
                trig_left_steps{l}(1,2) = pos_b(l_fc(i)-1); % pos
            else
                warning("[extractsteps] Missing right IC")
                trig_left_steps{l}(1,2) = pos_b(l_fc(i)) - r_ic_avg; % pos
            end
        end       
        trig_left_steps{l}(2:3,2) = [pos_b(l_fc(i)); pos_b(l_ic(i))]; % pos  
        if l_ic(i) == length(typ_b) % last step (missing right FC)
            trig_left_steps{l}(4,2) = pos_b(l_ic(i)) + l_ic_avg; % pos
        else
            if typ_b(l_ic(i)+1) == settings.leg.R.FC
                trig_left_steps{l}(4,2) = pos_b(l_ic(i)+1); % pos
            else
                warning("[extractsteps] Missing right FC")
                trig_left_steps{l}(4,2) = pos_b(l_ic(i)) + l_ic_avg; % pos
            end
        end
        
        % epoch data
        tstart = trig_left_steps{l}(1,2);
        tstop = trig_left_steps{l}(4,2);
        data_left_steps{l} = data(tstart:tstop, ncolons{:});
        
    end
    
    % RIGHT
    if length(r_fc) ~= length(r_ic), error("[extractsteps] Error in right steps!"), end
    for i = 1:length(r_fc)
        r = r +1;
        
        trig_right_steps{r} = nan(4,2); % [L_IC; R_FC; R_IC; L_FC]
        trig_right_steps{r}(:,1) = [settings.leg.L.IC; settings.leg.R.FC; settings.leg.R.IC; settings.leg.L.FC]; % typ
        
        if r_fc(i) == 1 % first step (missing left IC)          
            trig_right_steps{r}(1,2) = pos_b(r_fc(i)) - l_ic_avg; % pos
        else
            if typ_b(r_fc(i)-1) == settings.leg.L.IC
                trig_right_steps{r}(1,2) = pos_b(r_fc(i)-1); % pos
            else
                warning("[extractsteps] Missing left IC")
                trig_right_steps{r}(1,2) = pos_b(r_fc(i)) - l_ic_avg; % pos
            end
            
        end       
        trig_right_steps{r}(2:3,2) = [pos_b(r_fc(i)); pos_b(r_ic(i))]; % pos  
        if r_ic(i) == length(typ_b) % last step (missing left FC)
            trig_right_steps{r}(4,2) = pos_b(r_ic(i)) + r_ic_avg; % pos
        else
            if typ_b(r_ic(i)+1) == settings.leg.L.FC
                trig_right_steps{r}(4,2) = pos_b(r_ic(i)+1); % pos
            else
                warning("[extractsteps] Missing left FC")
                trig_right_steps{r}(4,2) = pos_b(r_ic(i)) + r_ic_avg; % pos
            end
            
        end
        
        % epoch data
        tstart = trig_right_steps{r}(1,2);
        tstop = trig_right_steps{r}(4,2);
        data_right_steps{r} = data(tstart:tstop, ncolons{:});
        
    end
    
end

if l~=NLEFT || r~=NRIGHT
    warning("[extractsteps] The extracted steps do not correspond to the total number of steps!")
end

data_epoch = cat(1, data_left_steps, data_right_steps);
trig_epoch = cat(1, trig_left_steps, trig_right_steps);
epoch_typ = cat(1, settings.leg.L.label*ones(NLEFT,1), settings.leg.R.label*ones(NRIGHT,1));

end

