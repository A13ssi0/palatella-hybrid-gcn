function attenuated_signal = signal_attenuation(signal, attenuation, mode)
% signal = channel x N

if strcmp(mode, 'max') || nargin < 3 || isempty(mode)
signal_max = repmat(max(signal, [], 2), [1 size(signal, 2)]);
norm_signal = signal ./ signal_max;
elseif strcmp(mode, 'minmax')
    signal_max = repmat(max(signal, [], 2), [1 size(signal, 2)]);
    signal_min = repmat(min(signal, [], 2), [1 size(signal, 2)]);
    norm_signal = (signal - signal_min) ./ (signal_max - signal_min);
else
    error('[signal_attenuation] Unknown attenuation mode!')
end

attenuated_signal = signal .* (1 - (repmat((attenuation), size(signal)) .* norm_signal));

end

