function [Pred, Score] = bayesian_fusion_v2(O1, O2, CM1, CM2, priors, group1, group2)%, mode)
% [Pred, Score] = bayesian_fusion_v2(O1, O2, CM1, CM2, priors, group1, group2)
% - O1 and O2 are the predicted classes of the models
% - CM1 and CM2 are confusion matrices of the classifiers
% - Priors is a vector (1xClasses) to evaluate the priori probabilities of the classes


% - Mode is used to track how the confusion matrices are normalized (default: column-normalized)

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

O1 = double(O1);
O2 = double(O2);
Score = nan(1, NumClasses);

CM1 = CM1./sum(CM1,1);
CM2 = CM2./sum(CM2,1);
for c = 1:NumClasses
    Score(c) = CM1(group1(c), O1) * CM2(group2(c), O2) / priors(c);
end

[~, Pred] = max(Score);
Score = Score./sum(Score);

end

