function AdjMatrix = extractAdjMatrix(loadingName)

if contains(loadingName,'parallel')

    net = load(loadingName);
    net = net.net;
    
    settings.NumChannels = 41;
    Wa = double(net.Layers(7).Wa);
    Aui = triu(ones(settings.NumChannels));
    Al = tril(ones(settings.NumChannels),-1);
    AdjMatrix = Aui;
    AdjMatrix(AdjMatrix>0) = Wa;
    AdjMatrix = AdjMatrix + Al.*AdjMatrix';
    AdjMatrix = normAdjacency(AdjMatrix);
    % Atmp(end-size(Wa,1)+1:end,1:size(Wa,2)) = A(end-size(Wa,1)+1:end,1:size(Wa,2)).*Wa;
    % Atmp(1:size(Wa,2),end-size(Wa,1)+1:end) = A(1:size(Wa,2),end-size(Wa,1)+1:end).*(Wa)';

elseif contains(loadingName,'sequence')

    net = load(loadingName);
    net = net.net;
    
    Wa = double(net.Layers(3).Wa);
    AdjMatrix = double(net.Layers(3).Aui);
    EyeA = double(net.Layers(3).EyeA);
    Al = double(net.Layers(3).Al);

    AdjMatrix(AdjMatrix>0) = Wa;
    AdjMatrix = AdjMatrix + Al.*AdjMatrix' + EyeA;

    AdjMatrix = normAdjacency(AdjMatrix);

end