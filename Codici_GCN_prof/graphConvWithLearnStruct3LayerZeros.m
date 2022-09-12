classdef graphConvWithLearnStruct3LayerZeros < nnet.layer.Layer 
    %& nnet.layer.Formattable ... % (Optional) 
        % & nnet.layer.Acceleratable % (Optional)

    properties
        A
    end
        
        
    properties (Learnable)
        % (Optional) Layer learnable parameters.

        % Declare learnable parameters here.
        W
        Wa
        Wi
    end

    methods
        function layer = graphConvWithLearnStruct3LayerZeros(numFeatures,numOut,numChannels1,numChannels2,args)
            % (Optional) Create a myLayer.
            % This function must have the same name as the class.

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
            layer.W = rand([numFeatures numOut]);
            layer.Wa = rand([numChannels1 numChannels2]);
            layer.A = eye(numChannels1+numChannels2);
            layer.A(end-numChannels1+1:end,1:numChannels2) = ones([numChannels1 numChannels2]);
            layer.A(1:numChannels2,end-numChannels1+1:end) = ones([numChannels2 numChannels1]);
            layer.A = dlarray(layer.A);
            layer.Wi = rand([1 numChannels1+numChannels2]);
%             layer.W = initializeGlorot([numFeatures numOut],numOut,numFeatures,"double");
%             layer.NumInputs = 2;
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
            
            Atmp = layer.A;
            Atmp(end-size(layer.Wa,1)+1:end,1:size(layer.Wa,2)) = layer.A(end-size(layer.Wa,1)+1:end,1:size(layer.Wa,2)).*layer.Wa;
            Atmp(1:size(layer.Wa,2),end-size(layer.Wa,1)+1:end) = layer.A(1:size(layer.Wa,2),end-size(layer.Wa,1)+1:end).*(layer.Wa)';
            Atmp(1:size(Atmp,1)+1:end) = Atmp(1:size(Atmp,1)+1:end) .* layer.Wi;
%             Atmp(end-size(layer.Wa,1)+1:end,1:size(layer.Wa,2),1,:) = A(end-size(layer.Wa,1)+1:end,1:size(layer.Wa,2),1,:).*layer.Wa;
%             Atmp(1:size(layer.Wa,2),end-size(layer.Wa,1)+1:end,1,:) = pagetranspose(Atmp(end-size(layer.Wa,1)+1:end,1:size(layer.Wa,2),1,:));
            Anorm = normAdjacency(Atmp);
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
