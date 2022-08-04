function tko_en = compute_tko(x, Ts)

nsamples = length(x);
tko_en = nan(size(x));
for n = 3:nsamples-2
    tko_en(n) = (2*x(n)^2 + ...
        (x(n+1)-x(n-1))^2 - ...
        x(n)*(x(n+2)+x(n-2)))/(4*Ts^2);
end

tko_en(1:2) = tko_en(3);
tko_en(end-1:end) = tko_en(end-2);

end

