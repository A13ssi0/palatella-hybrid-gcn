function y = set_snr(x, snr)

if isinf(snr)
    y = x;
else
    NumChans = size(x, 1);
    y = nan(size(x));
    for c = 1:NumChans
        y(c,:) = awgn(x(c,:),snr,'measured');
    end
end

end

