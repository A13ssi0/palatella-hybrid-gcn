function xr = resample_withmirror(x,p,q,dim,mirror_len)

if nargin < 5
    mirror_len = 100; % mirror length in samples
end
if nargin < 4
    dim = 1;
end
if nargin < 3
    error('[resample_withmirror] Not enough input arguments!')
end
if q ~= size(x,dim)
    error('[resample_withmirror] The functions expects q to be the length of the vectors to resample!')
end

subs = repmat({':'},1,ndims(x));
subs_pre = subs; subs_pre{dim} = 2:mirror_len+1;
subs_post = subs; subs_post{dim} = size(x,dim)-mirror_len:size(x,dim)-1;
x_mirror = cat(dim, flip(x(subs_pre{:}),dim), x, flip(x(subs_post{:}),dim));

resample_factor = p/q;
mirror_len_res = round(mirror_len*resample_factor);
p_mirror = p + 2*mirror_len_res; q_mirror = size(x_mirror,dim);
xr_mirror = resample(x_mirror,p_mirror,q_mirror,'Dimension',dim);

subs{dim} = mirror_len_res+1:size(xr_mirror,dim)-mirror_len_res;
xr = xr_mirror(subs{:});

end

