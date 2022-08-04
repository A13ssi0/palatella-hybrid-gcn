function triggers = compute_tko_triggers(sig, fs)

% Teager-Kaiser Operator (TKO) energy
tko_en = compute_tko(sig, 1/fs);

% Half-wave rectification
tko_en(tko_en<0) = 0;

% Three-sample moving maximum
tmp = tko_en;
for n = 2:length(tko_en)-1
    tko_en(n) = max([tmp(n-1), tmp(n), tmp(n+1)]);
end
tko_en(1) = 0; tko_en(end) = 0;

% Five-sample moving average
tmp = tko_en;
for n = 3:length(tko_en)-2
    tko_en(n) = sum(tmp(n-2:n+2))/5;
end
tko_en(1:2) = 0; tko_en(end-1:end) = 0;

% Find heel strikes (HS)
min_height = mean(tko_en)/2;

[c,lags] = xcov(tko_en);
st = (length(c)-1)/2;
c = c(st:end);
[pks, locs] = findpeaks(c,'MinPeakHeight', 0.2*max(c));
figure
plot(1:length(c),c), hold on, stem(locs(2), pks(2))
tau = locs(2);
% tau = 6000;
min_dist = floor(0.7*tau);

[hs_pks, hs_locs] = findpeaks(tko_en, ...
    'MinPeakDistance', min_dist, ...
    'MinPeakHeight', min_height);

hs_pks = hs_pks(2:end);
hs_locs = hs_locs(2:end);

triggers.hs.peaks = hs_pks;
triggers.hs.locs = hs_locs;

% Find toe off (TO)
delt = floor(0.15*tau);
chi_en = tko_en;
for m = 1:length(hs_locs)
    chi_en(hs_locs(m)-delt:hs_locs(m)+delt) = zeros(2*delt+1,1);
end

% moving maximum
delt = floor(0.075*tau);
tmp = chi_en;
for n = delt:length(chi_en)-delt+1
    chi_en(n) = max([tmp(n-delt+1:n+delt-1)]);
end
chi_en(1:delt-1) = 0; chi_en(end-delt:end) = 0;

% moving average
delt = floor(0.15*tau);
tmp = chi_en;
for n = delt:length(chi_en)-delt+1
    chi_en(n) = sum(tmp(n-delt+1:n+delt-1))/(2*delt);
end
chi_en(1:delt-1) = 0; chi_en(end-delt:end) = 0;

min_height = mean(chi_en)/1.5;

[to_pks, to_locs] = findpeaks(chi_en, ...
    'MinPeakDistance', min_dist, ...
    'MinPeakHeight', min_height);

%% Plot
figure
subplot(3,1,1)
hold on
plot(1:length(sig), sig)
stem(hs_locs, sig(hs_locs))
stem(to_locs, sig(to_locs))
hold off
xlabel('samples')
ylabel('Shank Acceleration')

subplot(3,1,2)
hold on
plot(1:length(tko_en), tko_en)
stem(hs_locs, tko_en(hs_locs))
stem(to_locs, tko_en(to_locs))
hold off
xlabel('samples')
ylabel('TKO energy')

subplot(3,1,3)
hold on
plot(1:length(chi_en), chi_en)
stem(hs_locs, chi_en(hs_locs))
stem(to_locs, chi_en(to_locs))
hold off
xlabel('samples')
ylabel('TKO energy smoothed')

end

