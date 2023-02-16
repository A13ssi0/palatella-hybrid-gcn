function FT = extract_fuzzy_template(S1, S2, Z, group1, group2)
%%%% - S1 and S2 matrices (Nxclasses) of the degree of support by the two classifier
% - Z is the training data labels

Z = double(Z);
NumClasses = length(unique(Z));

if nargin < 4 || isempty(group1)
    group1 = 1:NumClasses;
end
if nargin < 5 || isempty(group2)
    group2 = 1:NumClasses;
end

group1 = repmat(group1,[length(Z), 1]);
group2 = repmat(group2,[length(Z), 1]);

S_1 = reshape(S1(group1),1,NumClasses,length(Z)); % 1 x classes x N
S_2 = reshape(S2(group2),1,NumClasses,length(Z)); % N x classes
D = [S_1 ; S_2];    % 2 x classes x N

FT = nan(2, NumClasses, NumClasses);
for i = 1:NumClasses
    FT(:,:,i) = mean(D(:,:,Z==i),3);
end

end