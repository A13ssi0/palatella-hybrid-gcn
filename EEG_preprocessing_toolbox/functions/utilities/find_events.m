function [events_typ,events_pos] = find_events(triggers,labels)

idx = nan(length(triggers.type), length(labels));
for l = 1:length(labels)
    idx(:,l) = contains(triggers.type,labels{l});
end
tr_idx = any(idx,2);
events_typ = triggers.type(tr_idx);
events_pos = triggers.time(tr_idx);

end

