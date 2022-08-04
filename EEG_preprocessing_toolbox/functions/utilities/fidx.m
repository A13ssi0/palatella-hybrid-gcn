function idx = fidx(list,ChInfo)

idx = [];
for i = 1:length(list)
    ci = find(strcmpi(list{i},ChInfo));
    if isempty(ci)
        error(['Member ', list{i}, ' is not present!'])
    else
        idx = [idx; ci];
    end
end

end

