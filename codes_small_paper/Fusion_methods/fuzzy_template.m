function [Pred, Score] = fuzzy_template(S1, S2, FT, group1, group2)
% - S1 and S2 vectors of the degree of support by the two classifier

NumClasses = size(FT, 3);

if nargin < 4 || isempty(group1)
    group1 = 1:NumClasses;
end
if nargin < 5 || isempty(group2)
    group2 = 1:NumClasses;
end

D = [S1(group1); S2(group2)]; 

Score = zeros(1, NumClasses);
for i = 1:NumClasses
    for k = 1:2
        for s = 1:NumClasses
            Score(i) = Score(i) + ( FT(k,s,i) - D(k,s) )^2;
        end
    end
end

Score = ones(1, NumClasses) - Score./(2*NumClasses);
[~, Pred] = max(Score);
Score = Score./sum(Score);
