function [Pred, Score] = bayesian_fusion(O1, O2, CM1, CM2, priors, group1, group2, mode)

if nargin < 5 || isempty(priors)
    NumClasses = max([size(CM1,1), size(CM2,1)]);
    priors = ones(1, NumClasses)/NumClasses;
else
    NumClasses = length(priors);
end
if nargin < 6 || isempty(group1)
    group1 = 1:NumClasses;
end
if nargin < 7 || isempty(group2)
    group2 = 1:NumClasses;
end
if nargin < 8
    mode = 'column-normalized';
end

Score = nan(1, NumClasses);
if strcmp(mode, 'row-normalized')
    
    CM1 = CM1./repmat(sum(CM1, 2), [1 size(CM1, 2)]);
    CM2 = CM2./repmat(sum(CM2, 2), [1 size(CM2, 2)]);    
    for c = 1:NumClasses
        Score(c) = priors(c)* CM1(O1, group1(c)) * CM2(O2, group2(c));
    end
    
elseif strcmp(mode, 'column-normalized')
    
    CM1 = CM1./repmat(sum(CM1, 1), [size(CM1, 1) 1]);
    CM2 = CM2./repmat(sum(CM2, 1), [size(CM2, 1) 1]);
    for c = 1:NumClasses
        Score(c) = (CM1(group1(c), O1) * CM2(group2(c), O2)) / priors(c);
    end
    
else
    error('[bayesian_fusion] Unknown fusion mode!')
end
[~, Pred] = max(Score);
Score = Score./sum(Score);

end

