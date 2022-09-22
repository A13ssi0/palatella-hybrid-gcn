function [EEG_interp, nearestchans] = eeginterp(EEG, original_chanlocs, desired_chanlocs, method, k)
%EEGINTERP Performs channel interpolation on EEG data
%   Receives the EEG data at the original channel configuration, the disered final chanlocs to
%   have on the data and the interpolation method. The algorithm interpolates the new channels 
%   using the original data in the channels that are spatially closer over
%   the scalp in spherical coordinates. If EEG data is an empty matrix, the
%   function outputs the list of the orginal channels that are the nearest
%   to the new channels.
%   
%   Input:
%   EEG                         -   the EEG data [old_chans x samples]
%   original_chanlocs     -   struct array of original channels specification [1 x old_chans]
%   desired_chanlocs     -   struct array of new channels specification [1 x new_chans]
%   method                    -   ['spherical' (default)] interpolation method
%
%   Output:
%   EEG_interp         -   EEG data interpolated in the new channels
%                                 location [new_chans x samples]
%   nearestchans     -   cell array matching the new channels to the
%                                 nearest original channels [new_chans x 2]
%
%   Author: Stefano Tortora (tortora@dei.unipd.it) 2020 - All rights reserved

if nargin < 4
    method = 'spherical';
end
if strcmpi(method, 'k-nearest') && nargin < 5
    k = 3;
end

EEG_interp = [];
nearestchans = [];

% get theta, rad of electrodes
% ----------------------------
xelec = [ original_chanlocs.X ];
yelec = [ original_chanlocs.Y ];
zelec = [ original_chanlocs.Z ];
rad = sqrt(xelec.^2+yelec.^2+zelec.^2);
xelec = xelec./rad;
yelec = yelec./rad;
zelec = zelec./rad;
xnew = [ desired_chanlocs.X ];
ynew = [ desired_chanlocs.Y ];
znew = [ desired_chanlocs.Z ];
rad = sqrt(xnew.^2+ynew.^2+znew.^2);
xnew = xnew./rad;
ynew = ynew./rad;
znew = znew./rad;

if ~isempty(EEG) 
    
    if strcmpi(method, 'spherical')
        
        EEG_interp = spheric_spline( xelec, yelec, zelec, xnew, ynew, znew, EEG );
        
    elseif strcmpi(method, 'nearest')
        
        [~, EEG_interp] = nearest_neighbors( xelec, yelec, zelec, xnew, ynew, znew, EEG, 1 );
        
    elseif strcmpi(method, 'k-nearest')
        
        [~, EEG_interp] = nearest_neighbors( xelec, yelec, zelec, xnew, ynew, znew, EEG, k );
        
    else
        error('[eeginterp] Unknown interpolation method! Please select between spherical, nearest and k-nearest methods.')
    end
    
else
    
    nearchans = nearest_channels( xelec, yelec, zelec, xnew, ynew, znew );
    nearestchans = [{desired_chanlocs.labels}' {original_chanlocs(nearchans).labels}'];
    
end

%nearest neighbor function
% ------------------
function [nearestchans, allres] = nearest_neighbors( xelec, yelec, zelec, xnew, ynew, znew, values, k )

newchans = length(xnew);

D = computeD( xelec, yelec, zelec, xnew, ynew, znew );

if k == 1
    nearestchans = nan(newchans, 1);
    while any(isnan(nearestchans))
        % take first unassigned electrode
        i = find(isnan(nearestchans), 1, 'first');
        
        % find nearest electrode
        [d, j] = sort(D(i, :));
        
        count = 1;
        % if the nearest electrode is not assigned yet
        while ~isempty(find(nearestchans == j(count), 1))
            % check which electrode is the closest
            if d(count) < D(nearestchans == j(count), j(count))
                nearestchans(nearestchans == j(count)) = nan;
            else
                count = count + 1;
            end
        end
        nearestchans(i) = j(count);
    end
    
    % apply results
    allres = values(nearestchans, :);
    
else
    
    numpoints = size(values,2);

    % find nearest electrodes
    [d, j] = sort(D, 2);
    nearestchans = j(:, 1:k);
    
    % apply results
    allres = nan(newchans, numpoints);
    for i = 1:newchans
        allres(i, :) = mean(values(nearestchans(i, :), :), 1);
    end
    
end

% compute proximity matrix D function
% ------------------
function D = computeD( xelec, yelec, zelec, xnew, ynew, znew )

oldchans = length(xelec);
newchans = length(xnew);

% create matrices of electrodes coordinates
xelecmat = repmat(xelec, [newchans 1]);
yelecmat = repmat(yelec, [newchans 1]);
zelecmat = repmat(zelec, [newchans 1]);

xnewmat = repmat(xnew', [1 oldchans]);
ynewmat = repmat(ynew', [1 oldchans]);
znewmat = repmat(znew', [1 oldchans]);

% compute distance between each pair of electrodes
D = sqrt((xnewmat - xelecmat).^2 + (ynewmat - yelecmat).^2 + (znewmat - zelecmat).^2);

%%%% functions modified from eeg_interp.m of EEGLAB toolbox %%%%%%%
%%% ------------------------------
%spheric spline function
% ------------------
function allres = spheric_spline( xelec, yelec, zelec, xnew, ynew, znew, values)

newchans = length(xnew);
numpoints = size(values,2);

Gelec = computeg(xelec,yelec,zelec,xelec,yelec,zelec);
Gsph  = computeg(xnew,ynew,znew,xelec,yelec,zelec);

% compute solution for parameters C
meanvalues = mean(values); 
values = values - repmat(meanvalues, [size(values,1) 1]); % make mean zero

values = [values;zeros(1,numpoints)];
C = pinv([Gelec;ones(1,length(Gelec))]) * values;
clear values;
allres = zeros(newchans, numpoints);

% apply results
for j = 1:size(Gsph,1)
    allres(j,:) = sum(C .* repmat(Gsph(j,:)', [1 size(C,2)]));        
end
allres = allres + repmat(meanvalues, [size(allres,1) 1]);

% compute G function
% ------------------
function g = computeg(x,y,z,xelec,yelec,zelec)

unitmat = ones(length(x(:)),length(xelec));
EI = unitmat - sqrt((repmat(x(:),1,length(xelec)) - repmat(xelec,length(x(:)),1)).^2 +... 
                (repmat(y(:),1,length(xelec)) - repmat(yelec,length(x(:)),1)).^2 +...
                (repmat(z(:),1,length(xelec)) - repmat(zelec,length(x(:)),1)).^2);

g = zeros(length(x(:)),length(xelec));
%dsafds
m = 4; % 3 is linear, 4 is best according to Perrin's curve
for n = 1:7
    if ismatlab
        L = legendre(n,EI);
    else % Octave legendre function cannot process 2-D matrices
        for icol = 1:size(EI,2)
            tmpL = legendre(n,EI(:,icol));
            if icol == 1, L = zeros([ size(tmpL) size(EI,2)]); end
            L(:,:,icol) = tmpL;
        end
    end
    g = g + ((2*n+1)/(n^m*(n+1)^m))*squeeze(L(1,:,:));
end
g = g/(4*pi);    

%nearest channels function
% ------------------
function nearestchans = nearest_channels( xelec, yelec, zelec, xnew, ynew, znew )

newchans = length(xnew);

D = computeD( xelec, yelec, zelec, xnew, ynew, znew );

nearestchans = nan(newchans, 1);
while any(isnan(nearestchans))
    % take first unassigned electrode
    i = find(isnan(nearestchans), 1, 'first');
    
    % find nearest electrode
    [d, j] = sort(D(i, :));
    
    count = 1;
    % if the nearest electrode is not assigned yet
    while ~isempty(find(nearestchans == j(count), 1))
        % check which electrode is the closest
        if d(count) < D(nearestchans == j(count), j(count))
            nearestchans(nearestchans == j(count)) = nan;
        else
            count = count + 1;
        end
    end
    nearestchans(i) = j(count);
end
    
