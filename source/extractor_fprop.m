% extractor_fprop.m 
% Clayton Kotulak 
% 7/29/2014

%{ 
Given the network weight cell w and feature matrix x (including bias x), 
propagate the signal through the network and return the activations of the last 
layer as the matrix 'x'

Arguments: weights cell, input matrix
Returns: activation matrix
%}
function x = extractor_fprop(w, x)

	for i=1:size(w, 2),
		% Add the bias activation to the x matrix. size is now m x nodes+1
		x = [ones(size(x, 1), 1) x];

		% w{i} is the nodes x w weight layer [w==f+1]. z is a m x nodes 
		% weighted activation matrix
		z = x * (w{i});
		x = extractor_sigmoid(z);
	end
	
end
