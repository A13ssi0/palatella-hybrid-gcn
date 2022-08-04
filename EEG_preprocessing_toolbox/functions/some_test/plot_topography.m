function [h,pc] = plot_topography(ch_list, values, montage, CFG)

%% CHECKING INPUTS
if nargin < 2
    error('%s: Not enough inputs.',mfilename);
end
values = values(:);
if nargin < 3
    montage = 'default';
end
if nargin < 4
    CFG.plot_contour = false;
    CFG.plot_channels = false;
    CFG.plot_ch_names = false;
    CFG.interp_points = 500;
    CFG.pos_factor = 0.7;
    CFG.ch_names_size = 10;
	CFG.colormap = flipud(my_colormap(2));
else
    if ~isfield(CFG,'plot_contour')
        CFG.plot_contour = false;
    end
    if ~isfield(CFG,'plot_channels')
        CFG.plot_channels = false;
    end
    if ~isfield(CFG,'plot_ch_names')
        CFG.plot_ch_names = false;
    end
    if ~isfield(CFG,'interp_points')
        CFG.interp_points = 500;
    end
    if ~isfield(CFG,'pos_factor')
        CFG.pos_factor = 0.7;
    end
    if ~isfield(CFG,'ch_names_size')
        CFG.ch_names_size = 10;
    end
	if ~isfield(CFG,'colormap')
        CFG.colormap = flipud(my_colormap(2));
    end
end

% Loading electrode locations
if ischar(montage)
    switch montage
        case 'default'
            montage = struct2array(load('EEG_HD_montage.mat','mon'));
        otherwise
            error('%s: montage %s is not defined.',mfilename,montage);                
    end
end

% Finding the desired electrodes
if ~iscell(ch_list)
    if strcmpi(ch_list,'all')
        idx = 1:length(montage.ch_names);
        if length(values) ~= length(idx)
            error('%s: There must be a value for each of the %i channels.',mfilename,length(idx));
        end
    else
        error('%s: ch_list must be "all" or a cell array.',mfilename);
    end
else
    if length(values) ~= length(ch_list)
        error('%s: values must have the same length as ch_list.',mfilename);
    end
    idx = NaN(numel(ch_list),1);
    rmv_ch = false(size(idx));
    for i_ch = 1:numel(ch_list)
        ch_idx = find(strcmpi(montage.ch_names,ch_list{i_ch}));
        if isempty(ch_idx)
            warning('%s: Cannot find the %s electrode.',mfilename,ch_list{i_ch});
            rmv_ch(i_ch) = true;
        else
            idx(i_ch) = ch_idx;
        end
    end
    ch_list(rmv_ch) = [];
    values(rmv_ch) = [];
    idx(rmv_ch)   = [];
end

%% GLOBAL HEAD PARAMETERS
% Head readius r_HEAD should be 0.6388 for the 10-20 system based on the 
% distance from FPZ to OZ d=2*0.511 and the circle of the head corssing 
% nasion and inion -> 5d/8 = 0.6388.
r_HEAD  = 5*2*0.511/8;  % 1/2  of the nasion-inion distance
r_EXTRA = r_HEAD/5;     % 1/10 of the nasion-inion distance
k = 4;                  % k nearest neighbors to consider

%% Interpolate input data
% Creating the rectangle grid (-1,1)
ch_x = montage.x(idx)*CFG.pos_factor;
ch_y = montage.y(idx)*CFG.pos_factor;
% Points out of the head to reach more natural interpolation
r_ext_points = 1.2;
[add_x, add_y] = pol2cart(0:pi/4:7*pi/4,r_ext_points*ones(1,8));
linear_grid = linspace(-r_ext_points,r_ext_points,CFG.interp_points);         % Linear grid (-1,1)
[interp_x, interp_y] = meshgrid(linear_grid, linear_grid);

%% Interpolate and create the mask
outer_rho = max(sqrt(ch_x.^2 + ch_y.^2));
if outer_rho > r_HEAD
    r_MASK = r_HEAD + r_EXTRA;
else
    r_MASK = r_HEAD;
end
mask = (sqrt(interp_x.^2 + interp_y.^2) <= r_MASK); 
add_values = compute_nearest_values([add_x(:), add_y(:)], [ch_x(:), ch_y(:)], values, k);
interp_z = griddata([ch_x(:); add_x(:)], [ch_y(:); add_y(:)], [values; add_values(:)], interp_x, interp_y, 'natural');
interp_z(mask == 0) = NaN;

%% Plotting the final interpolation
pc = pcolor(interp_x, interp_y, interp_z);
colormap(CFG.colormap);
if isfield(CFG,'climits')
    caxis(CFG.climits);
end
shading interp;
hold on;

%% PLOT CONTOUR
if CFG.plot_contour
    [~, hfigc] = contour(interp_x, interp_y, interp_z); 
    set(hfigc, 'LineWidth', 0.75, 'Color', [0.2 0.2 0.2]); 
    hold on;
end

%% PLOT HEAD MODEL
L = plot_HEADMODEL(r_HEAD,r_MASK);

%% PLOT ELECTRODES
if CFG.plot_channels
    if numel(ch_x) <= 16
        scatter(ch_x, ch_y, 20,'k', 'LineWidth',1.5);
    else
        scatter(ch_x, ch_y,'.k');
    end
end

%% PLOT CHANNEL NAMES
if CFG.plot_ch_names
    text(ch_x, ch_y, ch_list, 'FontSize', CFG.ch_names_size);
end

%% FIT PLOT
xlim([-L, L]);
ylim([-L, L]);  
axis square;
axis off;
hold off;
h = gcf;

end

function add_val = compute_nearest_values(coor_add, coor_neigh, val_neigh, k)
% Compute the mean values of the k-nearest neighbors
%   - coor_add:     XY coordinates of the virtual electrodes
%   - coor_neigh:   XY coordinates of the real electrodes
%   - val_neigh:    Values of the real electrodes
%   - k:            Number of neighbors to consider
    add_val = NaN(size(coor_add,1),1);
    L = length(add_val);
    
    for i = 1:L
        % Distances between the added electrode and the original ones
        target = repmat(coor_add(i,:),size(coor_neigh,1),1);
        d = sqrt(sum((target-coor_neigh).^2,2));
        
        % K-nearest neighbors
        [~, idx] = sort(d,'ascend');
        idx = idx(2:1+k);
        
        % Final value as the mean value of the k-nearest neighbors
        add_val(i) = mean(val_neigh(idx));
    end
end

function L = plot_HEADMODEL(r_HEAD,r_MASK)
    head_rho = r_HEAD; % Head radius
    % HEAD
    head_theta  = linspace(0,2*pi,1000);        % From 0 to 360 deg
    head_x      = head_rho.*cos(head_theta);    % Cartesian X of the head
    head_y      = head_rho.*sin(head_theta);    % Cartesian Y of the head
    plot(head_x, head_y, 'Color', 'k', 'LineWidth',3);
    
    % NOSE
    nt = 0.12;      % Half-nose width (in percentage of pi/2)
    nr = 0.18;      % Nose length (in radius units)
    nose_rho   = [head_rho, head_rho+head_rho*nr, head_rho];
    nose_theta = [(pi/2)+(nt*pi/2), pi/2, (pi/2)-(nt*pi/2)];
    nose_x     = nose_rho.*cos(nose_theta);
    nose_y     = nose_rho.*sin(nose_theta);
    plot(nose_x, nose_y, 'Color', 'k', 'LineWidth',3);
    
    % EARS
    ellipse_a = 0.07;           % horizontal exentricity
    ellipse_b = 0.15;           % Vertical exentricity
    ear_angle = 0.9*pi/8;       % Mask angle
    offset    = 0.05*head_rho;  % Ear offset
    ear_rho   = @(ear_theta) 1./(sqrt(((cos(ear_theta).^2)./(ellipse_a^2)) ...
        +((sin(ear_theta).^2)./(ellipse_b^2))));    % Ellipse formula in polar coords
    ear_theta_right = linspace(-pi/2-ear_angle,pi/2+ear_angle,1000);
    ear_theta_left  = linspace(pi/2-ear_angle,3*pi/2+ear_angle,1000);
    ear_x_right = ear_rho(ear_theta_right).*cos(ear_theta_right);          
    ear_y_right = ear_rho(ear_theta_right).*sin(ear_theta_right); 
    ear_x_left  = ear_rho(ear_theta_left).*cos(ear_theta_left);         
    ear_y_left  = ear_rho(ear_theta_left).*sin(ear_theta_left); 
    plot(ear_x_right+head_rho+offset, ear_y_right, 'Color', 'k', 'LineWidth',3);
    plot(ear_x_left-head_rho-offset, ear_y_left, 'Color', 'k', 'LineWidth',3);
    
    % GET MAX VALUES FOR PLOT
    max_height = max([max(nose_y), r_MASK]);
    min_height = -r_MASK;
    max_width  = max([max(ear_x_right+head_rho+offset), r_MASK]);
    min_width  = -max_width;
    L = max([min_height, max_height, min_width, max_width]);
end
