% extractor_xopt.m
% Clayton Kotulak
% 12/07/2014

%{ 
Utilize fmincg to optimize the weights matrix theta with respect to the 
included input and label values who's influence is weighted by alpha. Cost
is calculated with cross-entropy loss.

Arguments: weights matrix, input matrix, label matrix, alpha vector
Returns: weights matrix
%}
function theta = extractor_xopt(theta, X, Y, alpha)
	
	global PARAMS;
	
	opt_iter = PARAMS.optimization_iter;
	lambda = PARAMS.lambda;
	
	% Create the training optimization option set
	train_opt = optimset('MaxIter', opt_iter);
	theta_dim = [size(theta,1) size(theta,2)];
	theta = theta(:);
	cost_params = [];
	
	% Add the bias value to the input 
	X = [ones(size(X,1),1) X];
	
	% Create costFunct for minimization, which takes a single parameter, 
	% cost_params, the vector theta
	costFunct = @(cost_params) extractor_xcost(cost_params,...
			theta_dim, X, Y, alpha, lambda);
	
	% Get the initial cost of theta
	[cost, gradient] = extractor_xcost(theta,...
			theta_dim, X, Y, alpha, lambda);
	
	if (PARAMS.db_display)
		fprintf('\nInitial cost of theta for the training set: %f\n',cost);
	end
	
	% Utilize fmincg to minimize the node weight parameters theta
	warning('off', 'Octave:possible-matlab-short-circuit-operator');
	[theta, train_cost] = fmincg(costFunct, theta, train_opt);
	
	if (numel(train_cost)>0 && PARAMS.db_display)
		% Print the final cost of the optimized parameter matrix theta.
		fprintf('Final cost of theta for the training set: %f\n',...
				train_cost(end));
	end
	
	% Reshape theta
	theta = reshape(theta, theta_dim(1), theta_dim(2));
	
end

