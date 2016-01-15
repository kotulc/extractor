% extractor_sigmoid.m 
% Clayton Kotulak 
% 7/29/2014

%{ 
Given the scalar, vector, or matrix z, compute the sigmoid for each element.

Arguments: value matrix
Returns: sigmoid matrix
%}
function g = extractor_sigmoid(z)

	g = 1 ./ (1 + e .^ ( -1 .* z ));

end