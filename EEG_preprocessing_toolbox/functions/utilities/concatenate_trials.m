function data_rep = concatenate_trials(data)

data_rep = reshape(data, [size(data,1) size(data,2)*size(data,3)]);

end

