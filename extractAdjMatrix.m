function [AdjMatrix,EyeA] = extractAdjMatrix(loadingName, isFixedDiagonal)

if contains(loadingName,'parallel')

    net = load(loadingName);
    net = net.net;
    
    settings.NumChannels = 41;
    Wa = double(net.Layers(7).Wa);
    Aui = triu(ones(settings.NumChannels));
    Al = tril(ones(settings.NumChannels),-1);
    AdjMatrix = Aui-eye(settings.NumChannels);
    AdjMatrix(AdjMatrix>0) = Wa;
    EyeA = eye(settings.NumChannels);
    AdjMatrix = AdjMatrix + Al.*AdjMatrix'+EyeA;
    AdjMatrix = normAdjacency(AdjMatrix);
    % Atmp(end-size(Wa,1)+1:end,1:size(Wa,2)) = A(end-size(Wa,1)+1:end,1:size(Wa,2)).*Wa;
    % Atmp(1:size(Wa,2),end-size(Wa,1)+1:end) = A(1:size(Wa,2),end-size(Wa,1)+1:end).*(Wa)';

    

elseif contains(loadingName,'sequence')

    net = load(loadingName);
    net = net.net;
    
    Wa = double(net.Layers(3).Wa);
    AdjMatrix = double(net.Layers(3).Aui);
    if isFixedDiagonal
        EyeA = double(net.Layers(3).EyeA);
    else
        EyeA = zeros(size(AdjMatrix));
    end
    Al = double(net.Layers(3).Al);

    AdjMatrix(AdjMatrix>0) = Wa;
    AdjMatrix = AdjMatrix + Al.*AdjMatrix';

    AdjMatrix = normAdjacency(AdjMatrix);
    AdjMatrix = AdjMatrix+EyeA;

end