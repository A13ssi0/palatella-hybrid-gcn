function [Pred, Score] = naive_fusion_v2(S1, S2, group1, group2)
% [Pred, Score] = naive_fusion_v2(S1, S2, group1, group2)
% - S1 S2 are the scores vectors of the predictions (1xclasses)
% - Group1 and group2 are the vectors for the classes. Group2 is the smallest and have to be the same length of group1 
%   eventually with the classes repeated (1xClasses)

if nargin < 3
    NumClasses = length(S1);
    group1 = 1:NumClasses;
    group2 = 1:NumClasses;
else
    NumClasses = length(group1);
end

if NumClasses ~= length(group2)
    error('[naive_fusion] The length of the two groups is different!')
end

S_1 = S1(group1); S_2 = S2(group2); 
Score = (S_1 + S_2)./2;
[~, Pred] = max(Score);
Score = Score./sum(Score);

