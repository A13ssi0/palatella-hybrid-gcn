function [P, F] = spectrumplot(x,fs,display,VarNames)
% [P, F] = spectrumplot(x,fs)
%
% The function computes and plot the power spectrum of the columns of x
%
% Input arguments:
%   - x                         Data matrix [samples x channels]
%   - fs                        Sampling frequency [Hz]
%   - display                Flag for plotting (default True)
%   - VarNames           Names of x columns
%
% Output arguments:
%   - P          Power spectrum of x
%   - F          Frequency vector
%                              
%
% SEE ALSO: pspectrum
%
% Stefano Tortora, 2022, stefano.tortora@unipd.it

% Inputs
if nargin<4
    VarNames = {};
elseif nargin<3
    display = True;
end

% Parameters
frequencyLimits = [0 fs/2]; % Hz

% % Index into signal time region of interest
% or_eeg_ROI = or_eeg(:);
% sampleRate = 250; % Hz
% startTime = 0; % seconds
% minIdx = ceil(max((timeLimits(1)-startTime)*sampleRate,0))+1;
% maxIdx = floor(min((timeLimits(2)-startTime)*sampleRate,length(or_eeg_ROI)-1))+1;
% or_eeg_ROI = or_eeg_ROI(minIdx:maxIdx);

% Compute spectral estimate
% Run the function call below without output arguments to plot the results
[P, F] = pspectrum(x,fs,'FrequencyLimits',frequencyLimits);

% Display power spectrum in dB
if display
    hold on
    for c = 1:size(P,2)
        plot(F, pow2db(P(:,c)))
    end
    hold off
    xlabel('frequency')
    ylabel('power spectrum [dB]')
    xlim(frequencyLimits)
    axis square
    if ~isempty(VarNames)
        legend(VarNames)
    end
end

end

