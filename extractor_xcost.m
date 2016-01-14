% extractor_xcost.m
% Clayton Kotulak
% 2/28/2015

%{ 
Calculate the cost of the parameter values theta respective to the input 
values X and labels Y, where each instance in X is weighted by the vector of 
alpha values.

Arguments: weights matrix, dim vector, input matrix, label vector, 
alpha vector, lambda value
Returns: cost value, gradient matrix
%}
function [cost gradient] = extractor_xcost(theta, theta_dim, X, Y, alpha, lambda)
	
	% Reshape theta
	theta = reshape(theta, theta_dim(1), theta_dim(2));
	
	% Calculate the node activation values
	Z = X * theta;
	A = extractor_sigmoid(Z);
		
	% A is a m x output nodes matrix from a forward propagation, Y is a m x 1 
	% vector of solutions. 
	cost = -1 * sum( sum((Y .* log(A) + (1 - Y) .* log(1 - A)) .* alpha) );
	
	% Add the regularization cost
	m = size(X, 1);
	cost = cost + lambda/(2*m) * sum( sum(theta(2:end,:).^2) );
	
	delta = (A .- Y) .* alpha;
	gradient = X' * delta;
	
	% Add the regularization gradient
	reg = [zeros(1,size(theta,2)); theta(2:end,:)];
	gradient = gradient + ((lambda/m) * reg);
	gradient = gradient(:);

end

