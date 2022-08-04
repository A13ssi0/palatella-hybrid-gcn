classdef graphConvWithLearnStruct3Layer < nnet.layer.Layer 
    %& nnet.layer.Formattable ... % (Optional) 
        % & nnet.layer.Acceleratable % (Optional)

    properties
        Aui
        Al
    end
       
    properties (Learnable)
        Wa
        W
    end

    methods
        function layer = graphConvWithLearnStruct3Layer(numFeatures,numOut,numChannels1,numChannels2,args)

            % Define layer constructor function here.
            arguments
                numFeatures
                numOut
                numChannels1
                numChannels2
                args.Name = "";
            end

            % Set layer name.
            layer.Name = args.Name;
            layer.Description = "graphConvolution layer with " + numFeatures + " features";
            totalChannel = numChannels1+numChannels2;

            layer.Aui = triu(ones(totalChannel));
            layer.Al = tril(ones(totalChannel),-1);

            layer.W = rand([numFeatures numOut]);
%             layer.Wi = eye(totalChannel);

%             layer.Wa = tril(randn(totalChannel),-1);
%             layer.Wa = layer.Wa + layer.Wa';

            layer.Wa = rand([1 totalChannel*(totalChannel+1)/2]);
%             idx = 0;
%             for i=1:totalChannel
%                 idx = idx+i;
%                 layer.Wa(idx) = 1;
%             end

%             layer.A = zeros(numChannels1+numChannels2);
%             layer.A(end-numChannels1+1:end,1:numChannels2) = ones([numChannels1 numChannels2]);
%             layer.A(1:numChannels2,1:end) = ones([numChannels2 numChannels1+numChannels2]);
%             layer.A = dlarray(layer.A);

        end

        function Z = predict(layer,X)
            % Forward input data through the layer at prediction time and
            % output the result and updated state.
            %
            % Inputs:
            %         layer - Layer to forward propagate through 
            %         X     - Input data
            % Outputs:
            %         Z     - Output of layer forward function
            %         state - (Optional) Updated layer state
            %
            %  - For layers with multiple inputs, replace X with X1,...,XN, 
            %    where N is the number of inputs.
            %  - For layers with multiple outputs, replace Z with 
            %    Z1,...,ZM, where M is the number of outputs.
            %  - For layers with multiple state parameters, replace state 
            %    with state1,...,stateK, where K is the number of state 
            %    parameters.

            % Define layer predict function here.

%             a = triu(ones(size(X,1)));
%             a(a > 0) = layer.Wa;
%             WaMatrix = (a + a')./(eye(totalChannel)+1);

%             WaMatrix = diag(vec(1:size(layer.A,1))) + squareform(vec(size(layer.A,1)+1:end));

%             Atmp = layer.A.*(layer.Wa + layer.Wa' + layer.Wi);
            A = layer.Aui;
            A(A>0) = layer.Wa;
            A = A + layer.Al.*A';
            A = dlarray(A);

            Anorm = normAdjacency(A);
            Z = pagemtimes(pagemtimes(Anorm,X),layer.W);
        end
    end
end


function Anorm = normAdjacency(A)
degree = sum(extractdata(A), 2);
degreeInvSqrt = sqrt(1./abs(degree)); % TODO remove abs()
D = dlarray(diag(degreeInvSqrt));
Anorm = D * A * D;
end
