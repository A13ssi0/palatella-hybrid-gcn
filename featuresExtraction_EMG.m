function feature = featuresExtraction_EMG(dataEMG, winLen, winShift, fc, choosenFreq)
% dataEMG = channel x campioni
% Sxx = window x freq x channel
% MAV = sd = zCross = RMS = WL = avFreq = medianFreq = channel x window


    winSize = winLen*fc;
    winStep = winShift*fc;
%     firstFreq = choosenFreq(1);
%     lastFreq = choosenFreq(2);
% 
%     % creation of the frequency vector
%     nFreq = winSize/2+1;
%     freq = linspace(0, fc/2, nFreq);
%     freq = freq(2:end);
%     idxFreq = firstFreq<=freq & freq<=lastFreq;
%     freq = freq(idxFreq);    
% 
%     window = hanning(winSize);

    nWin = fix( (size(dataEMG,2)-(winSize-winStep) )/winStep );
%     feature.Sxx = nan(nWin, length(freq), size(dataEMG,1));
    feature.MAV = nan(size(dataEMG,1), nWin);
    feature.sd = feature.MAV;
    feature.RMS = feature.MAV;
    feature.WL = feature.MAV;
    feature.avFreq = feature.MAV;
    feature.medianFreq = feature.MAV;

    fprintf(['Total windows: ',num2str(nWin), '  '])
    for w = 1:nWin
        
        if rem(w,fix(nWin/10))==0
            fprintf('.')
        end

        start = (w-1) * winStep + 1; 
        stop = start + winSize - 1;

        x = dataEMG(:,start:stop)';

        % PSD
%         X = (x-mean(x)).*window;
%         X = fft(X, winSize);
%         X = 2/0.375* X(2:nFreq,:) /winSize;
%         X = X(idxFreq,:);
%         feature.Sxx(w,:,:) = abs(X).^2;

        % Mean Absolute Value
        %disp('Calculating MAV')
        feature.MAV(:,w) = mean(abs(x))';

        % Standard Deviation
        %disp('Calculating sd')
        feature.sd(:,w) = std(x)';
    
        % Zero crossing
        %disp('Calculating zCross')
        feature.zCross(:,w) = zerocrossrate(x)';

        % Root mean square
        %disp('Calculating RMS')
        x2 = x.^2;
        feature.RMS(:,w) = sqrt(mean(x2))';

        % Waveform Length
        %disp('Calculating WL')
        feature.WL(:,w) = sum(abs(diff(x)))';

        % Mean Frequency
        %disp('Calculating avFreq')
        feature.avFreq(:,w) = meanfreq(x,fc)';

        % Median Frequency
        %disp('Calculating medianFreq')
        feature.medianFreq(:,w) = medfreq(x,fc)';
    end

    fprintf('\n')
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



