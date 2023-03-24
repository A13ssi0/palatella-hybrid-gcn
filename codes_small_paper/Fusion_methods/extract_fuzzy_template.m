function FT = extract_fuzzy_template(S1, S2, Z1, Z2, group1, group2)
%%%% - S1 and S2 matrices (Nxclasses) of the degree of support by the two classifier
% - Z is the training data labels

Z1 = double(Z1);
Z2 = double(Z2);
NumClasses = length(unique(Z1));

if nargin < 5 || isempty(group1)
    group1 = 1:NumClasses;
end
if nargin < 6 || isempty(group2)
    group2 = 1:NumClasses;
end

%group1 = repmat(group1,[length(Z), 1]);
%group2 = repmat(group2,[length(Z), 1]);

%S_1 = reshape(S1',1,NumClasses,length(Z1)); % 1 x classes x N
%S_2 = reshape(S2',1,NumClasses,length(Z2)); 
%D = [S_1 ; S_2];    % 2 x classes x N

FT = nan(2, NumClasses, NumClasses);
for i = 1:NumClasses
    FT(1,:,i) = mean(S1(Z1==i,:));
    FT(2,:,i) = mean(S2(Z2==i,:));
end