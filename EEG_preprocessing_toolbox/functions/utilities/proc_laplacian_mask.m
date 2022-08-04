function [Mask, NumChans] = proc_laplacian_mask(Montage, NumNeightbours, MaskTyp)
% [Mask, NumChans] = proc_laplacian_mask(Montage, NumNeightbours [, MaskTyp])
%
% The function creates a laplacian mask according to the Montage provided
% as argument. Montage is a two dimensional matrix with the indexes of the
% channels and zero-padding for empty elements (see also:
% proc_get_montage). The function check the correct format of the Montage.
% NumNeightbours represents the number of neightbours to be considered 
% when the mask is created. The optional argument MaskTyp represents the 
% typology of mask to be created ('standard': all neightbours [default], 
% 'cross': excluding diagonal elements).
%
% Laplacian weights are computed by taking into account the number of
% neightbours of each channel.
%
% The function returns a square matrix (NumChans x NumChans) with the
% laplacian weights.
%
% SEE ALSO: proc_get_montage, proc_laplacian



    if nargin < 3
        MaskTyp = 'standard';
    end
    
    NumRows  = size(Montage, 1);
    NumCols  = size(Montage, 2);
    %NumChans = sum(sum(Montage > 0));
    NumChans = max(max(Montage));
    
%     % Check if a proper montage is provided
%     if isequal(1:NumChans, sort(Montage(Montage > 0))') == false
%         warning('chk:mtg', ['[' mfilename '] Mi format for montage indexing']);
%     end
    
    % Check for the montage (missing electrodes)
    warning('backtrace', 'off')
    Missing = setxor(1:NumChans, sort(Montage(Montage > 0))');
    if isempty(Missing) == false
        warning('chk:mtg', ['[' mfilename '] Mssing electrodes in the laplacian montage: ' num2str(Missing)]);
    end
    warning('backtrace', 'on')
    
    % Iterate for each channel index (different from 0) and retrieve
    % neigthbours. Apply a submask to the selected neightbours according to
    % the mask type provided.
    Mask = zeros(NumRows, NumCols);
    for rId = 1:NumRows
        for cId = 1:NumCols
            cchan = Montage(rId, cId);
            if cchan > 0
                selrows = max(1, rId-NumNeightbours):min(NumRows, rId+NumNeightbours);
                selcols = max(1, cId-NumNeightbours):min(NumCols, cId+NumNeightbours);
    
                submontage = Montage(selrows, selcols);
                
                % Switch between submask types
                switch lower(MaskTyp)
                    case 'standard'
                        % do nothing
                    case 'cross'
                        submask = true(size(submontage));
                        [i, j]  = find(submontage == cchan);
                        submask(i, :) = false; 
                        submask(:, j) = false;  
                        submontage(submask) = 0;
                    otherwise
                        error('chk:msktyp', ['[' mfilename '] Unknown mask type: ' MaskTyp]);
                end
                
                % Retrieve neightbours (excluding the channels itself and
                % the neightbours with id equal to 0)
                NbrsId  = setdiff(submontage(submontage>0), cchan);
                NumNbrs = length(NbrsId);
                
                % Populate the laplacian mask
                Mask(cchan, cchan)  = 1;
                Mask(NbrsId, cchan) = -1/NumNbrs;           
            end
        end
    end
end
