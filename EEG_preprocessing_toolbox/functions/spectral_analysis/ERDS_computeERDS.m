function [ERDS,ES,ES2] = ERDS_computeERDS(Y_trig,t_vec,t_ref,flag_bl,flag_trb)

if nargin<5
    flag_trb = true;
end
if nargin<4
    flag_bl = true;
end

idx_ref = t_vec >= t_ref(1) & t_vec <= t_ref(2);
Y_trig = log(Y_trig);

if flag_trb 
    ERDS = Y_trig - trimmean(Y_trig(idx_ref,:,:,:),10,1);
else
    Y_ref_mean = trimmean(Y_trig(idx_ref,:,:,:),10,1);
    Y_ref_mean = squeeze(trimmean(Y_ref_mean(:,:,:,:),10,4));
    Y_ref_mean = repmat(Y_ref_mean, [1 1 size(Y_trig, 1)]);
    ERDS = trimmean(Y_trig,10,4) - permute(Y_ref_mean, [3 1 2]);
end

% ES_1 = (nanmedian(Y_trig - nanmean(Y_trig(idx_ref,:,:,:,:)),4)) ./ (0.7413*abs(diff(prctile(nanmean(Y_trig(idx_ref,:,:,:,:)),[25,75],4),[],4)));
% delta = Y_trig - nanmean(Y_trig(idx_ref,:,:,:),1);
if flag_trb
    delta = ERDS;
    SD_difference_scores = 0.7413*iqr(delta,4);
    ES = (nanmedian(delta,4)) ./ SD_difference_scores;
    ES2 = (trimmean(delta,10,4)) ./ nanstd(delta,[],4);
else
    delta = ERDS;
    Y_ref_mean = trimmean(Y_trig(idx_ref,:,:,:),10,1);
    Y_ref_std = squeeze(std(Y_ref_mean(:,:,:,:),[],4));
    ES = delta ./ permute(Y_ref_std, [3 1 2]);
    ES2 = ES;
end


if flag_bl
    ERDS(idx_ref,:,:,:) = [];
    ES(idx_ref,:,:,:) = [];
    ES2(idx_ref,:,:,:) = [];
end

end

