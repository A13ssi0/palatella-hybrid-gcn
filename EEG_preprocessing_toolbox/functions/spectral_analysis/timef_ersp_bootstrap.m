%%%% Function to perform statistical permutation of ERSP trials (P) using bootstraping %%%%
%%% Codes extracted from newtimef() function from EEGLAB %%%%
% Stefano Tortora, University of Padova, stefano.tortora@unipd.it, 2022/04/06
function [maskersp,Pboot,Pboottrials] = timef_ersp_bootstrap(P,timesout,baseln,g)

% naccu adjustment
% --------------------
if (round(g.naccu*g.alpha) < 10)
    g.naccu = round(10/g.alpha);
end

if ~isempty(find(~isnan(g.pboot))) % if ERSP bootstrap limits provided already
    Pboot = g.pboot(:);
else
    if size(g.baseboot,2) == 1
        if g.baseboot == 0, baselntmp = [];
        elseif ~isnan(g.baseline(1))
            baselntmp = baseln;
        else baselntmp = find(timesout <= 0); % if it is empty use whole epoch
        end
    else
        baselntmp = [];
        for index = 1:size(g.baseboot,1)
            tmptime   = find(timesout >= g.baseboot(index,1) & timesout <= g.baseboot(index,2));
            if isempty(tmptime),
                fprintf('Warning: empty baseline interval [%3.2f %3.2f]\n', g.baseboot(index,1), g.baseboot(index,2));
            end
            baselntmp = union_bc(baselntmp, tmptime);
        end
    end
    if prod(size(g.baseboot)) > 2
        fprintf('Permutation statistics will use data in multiple selected windows.\n');
    elseif size(g.baseboot,2) == 2
        fprintf('Permutation statistics will use data in range %3.2g-%3.2g ms.\n', g.baseboot(1),  g.baseboot(2));
    elseif g.baseboot
        fprintf('   %d permutation statistics windows in baseline (times<%g).\n', length(baselntmp), g.baseboot)
    end
    
    % power significance
    % ------------------
    if strcmpi(g.boottype, 'shuffle')
        formula = 'mean(arg1,3);';
        [ Pboot Pboottrialstmp Pboottrials] = bootstat(P, formula, 'boottype', 'shuffle', ...
            'label', 'ERSP', 'bootside', 'both', 'naccu', g.naccu, ...
            'basevect', baselntmp, 'alpha', g.alpha, 'dimaccu', 2 );
        clear Pboottrialstmp;
    else
        center = 0;
        if strcmpi(g.basenorm, 'off'), center = 1; end
        
        % bootstrap signs
        Pboottmp    = P;
        Pboottrials = zeros([ size(P,1) size(P,2) g.naccu ]);
        for index = 1:g.naccu
            Pboottmp = (Pboottmp-center).*(ceil(rand(size(Pboottmp))*2-1)*2-1)+center;
            Pboottrials(:,:,index) = mean(Pboottmp,3);
        end
        Pboot = [];
    end
    if size(Pboot,2) == 1, Pboot = Pboot'; end
end

% average the power
% -----------------
P = mean(P, 3);

% correction for multiple comparisons
% -----------------------------------
maskersp = [];
if isempty(find(~isnan(g.pboot))) % if ERSP lims not provided
    if ndims(Pboottrials) < 3, Pboottrials = Pboottrials'; end
    exactp_ersp = compute_pvals(P, Pboottrials);
    if strcmpi(g.mcorrect, 'fdr')
        alphafdr = fdr(exactp_ersp, g.alpha);
        if alphafdr ~= 0
            fprintf('ERSP correction for multiple comparisons using FDR, alpha_fdr = %3.6f\n', alphafdr);
        else fprintf('ERSP correction for multiple comparisons using FDR, nothing significant\n', alphafdr);
        end
        maskersp = exactp_ersp <= alphafdr;
    else
        maskersp = exactp_ersp <= g.alpha;
    end
end

% convert to log
% ----------------
if ~isempty(Pboot)
    Pboot = 10 * log10(Pboot);
end
if isempty(Pboot) && exist('maskersp')
    Pboot = maskersp;
end

end

