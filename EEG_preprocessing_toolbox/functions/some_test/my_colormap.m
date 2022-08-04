function [cmap] = my_colormap(option)

N = 256;

if option == 1
    color_palette = [0.0, 0.0 ,0.5; ... % dark blue
                     0.0, 0.0, 1.0; ... % blue
                     1.0, 1.0, 1.0; ... % white
                     1.0, 0.0, 0.0; ... % red
                     0.5, 0.0, 0.0];    % dark red
    N_colors = size(color_palette,1);
    stepwidth = floor(N/(N_colors-1));
    cmap = NaN(stepwidth*(N_colors-1),3);
    cmap(1,:) = color_palette(1,:);
    for i_color = 1:N_colors-1
        cmap(stepwidth*i_color,:) = color_palette(i_color+1,:);
    end
    cmap = fillmissing(cmap,'linear');
elseif option == 2
        color_palette = [0.0, 0.0 ,0.5; ... % dark blue
                     0.0, 0.0, 1.0; ... % blue
                     0.0, 1.0, 1.0; ... % cyan
                     1.0, 1.0, 1.0; ... % white
                     1.0, 1.0, 0.0; ... % yellow
                     1.0, 0.0, 0.0; ... % red
                     0.5, 0.0, 0.0];    % dark red
    N_colors = size(color_palette,1);
    stepwidth = floor(N/(N_colors-1));
    cmap = NaN(stepwidth*(N_colors-1),3);
    cmap(1,:) = color_palette(1,:);
    for i_color = 1:N_colors-1
        cmap(stepwidth*i_color+1,:) = color_palette(i_color+1,:);
    end
    cmap = fillmissing(cmap,'linear');
else
    error('%s: Option %d is not supported',mfilename,option);
end

end

