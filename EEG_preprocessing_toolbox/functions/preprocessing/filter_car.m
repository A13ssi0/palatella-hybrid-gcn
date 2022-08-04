function signal_filt = filter_car(signal,dim)
% [signal_filt] = filter_car(signal, dim)
%
% The function computes the Common Average Reference (CAR) filter on the input signal along a given direction.
%
% Input arguments:
%   - signal              Data matrix
%   - dim            Matrix dimension along which the filter is applied
%                       (es. for a matrix [samples x channels] apply the
%                       car filter over the second dimension)
%
% Output arguments:
%   - signal_filt          Output data matrix filtered over the desired direction
%                               of the same dimension as the input data matrix
%                              
%
% SEE ALSO: repmat
%
% Stefano Tortora, 2019, stefano.tortora@phd.unipd.it

if(nargin<2)
    dim = 2;
end

rep_size = ones(size(size(signal)));
rep_size(dim) = size(signal,dim);

% signal_filt = signal - repmat(mean(signal, dim), [1 size(signal,dim)]);
signal_filt = signal - repmat(mean(signal, dim), rep_size);

end

