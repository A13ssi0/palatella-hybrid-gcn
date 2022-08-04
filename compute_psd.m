function Sxx = compute_psd(data, winLen, winShift, fc, choosenFreq)
% data = channel x campioni
% Sxx = window x freq x channel

    winSize = winLen*fc;
    winStep = winShift*fc;
    firstFreq = choosenFreq(1);
    lastFreq = choosenFreq(2);

    % creation of the frequency vector
    nFreq = winSize/2+1;
    freq = linspace(0, fc/2, nFreq);
    freq = freq(2:end);
    idxFreq = firstFreq<=freq & freq<=lastFreq;
    freq = freq(idxFreq);    

    window = hanning(winSize);

    nWin = fix( (size(data,2)-(winSize-winStep) )/winStep );
    Sxx = nan(nWin, length(freq), size(data,1));

    for w = 1:nWin
        start = (w-1) * winStep + 1; 
        stop = start + winSize - 1;

        x = data(:,start:stop)';
        x = (x-mean(x)).*window;

        X = fft(x, winSize);
        X = 2/0.375* X(2:nFreq,:) /winSize;
        X = X(idxFreq,:);

        Sxx(w,:,:) = abs(X).^2;
    end
end


function w = hanning(n)
    if ~rem(n,2)
        w = .5*(1 - cos(2*pi*(1:n/2)'/(n+1)));
        w = [w; w(end:-1:1)];
    else
        w = .5*(1 - cos(2*pi*(1:(n+1)/2)'/(n+1)));
        w = [w; w(end-1:-1:1)];
    end
end



