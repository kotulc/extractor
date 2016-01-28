% extractor_nodes.m
% Clayton Kotulak
% 12/22/2015

%{ 
Generate a set of nodes with the goal of exciting instances contained in
target_data and inhibiting those in null_data. Use cross-entropy optimization

Arguments: data struct
Returns: nodes struct
%}
function nodes = extractor_nodes(train_data)
	
	global PARAMS;
	
	if (PARAMS.db_display)
		fprintf("Generating nodes...");
	end
	
	% Generate a pair of standard nodes, one for each class
	null_n = size(train_data.null_data, 1);
	target_n = size(train_data.target_data, 1);
	
	% Join the two data sets for training
	x = [train_data.null_data; train_data.target_data];
	y = [zeros(null_n,1); ones(target_n,1)];
		
	% Join the influence vectors to create the learning influence mask
	alpha_null = train_data.null_mask ./ sum(train_data.null_mask);
	alpha_target = train_data.target_mask ./ sum(train_data.target_mask);
	alpha_mask = [alpha_null; alpha_target];

	% Randomly initialize the weights 
	weights = unifrnd(-1, 1, [size(x, 2)+1 1]);
	weights = extractor_xopt(weights, x, y, alpha_mask);
	
	% The returned node is initialized with the calculated weight values
	nodes.weights = weights;
	
	if (PARAMS.db_display)
		fprintf("Nodes generated.\n");
	end
	
end

