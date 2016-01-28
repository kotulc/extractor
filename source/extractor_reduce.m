% extractor_reduce.m
% Clayton Kotulak
% 12/4/2015

%{ 
Reduce the size of the set of nodes by half, compressing the representation 
of the excitatory instances in target_data trained against a collection of 
inhibitory instances null_data.

Arguments: nodes struct, data struct
Returns: nodes struct
%}
function nodes = extractor_reduce(nodes, tiles, train_data)
	
	global PARAMS;
	
	% If the collection does not contain any nodes, return
	if (numel(nodes) == 0)
		return;
	end
	
	% Generate a vector of node indices
	node_idx = 1:size(nodes.weights, 2);
	
	% Calculate the node activation values
	actvs = extractor_fprop({nodes.weights}, tiles);
	
	% Determine the per-instance maximum activation distribution among all 
	% nodes and then generate a map, assigning instances to nodes that maximize
	% their activation
	[val max_idx] = max(actvs, [], 2);
	actv_map = (node_idx == max_idx);
	
	% If a node does not have any instances mapped, remove it
	prune_flag = (sum(actv_map) == 0);
	actv_map(:, prune_flag) = [];
	
	% Update the nodes collection
	nodes.weights(:, prune_flag) = [];
	nodes.fitness(prune_flag) = [];
	
	% Generate the learning mask for optimization based on the activation map 
	target_mask = actv_map ./ sum(actv_map);
	null_mask = train_data.null_mask .* ones(1, size(nodes.weights, 2));
	null_mask = null_mask ./ sum(train_data.null_mask);
	alpha_mask = [target_mask; null_mask];
	
	% Combine the inhibitory and excitatory instance collections for training
	x = [tiles; train_data.null_data];
	y = [ones(size(tiles, 1), 1);...
			zeros(size(train_data.null_data, 1), 1)];
	
	% Optimize the remaining nodes using x-entropy loss 
	nodes.weights = extractor_xopt(nodes.weights, x, y, alpha_mask);
	
	% Get the updated fitness and related information for all remaining nodes
	nodes = extractor_fitness(nodes, train_data);

	% Sort by the nodes by their fitness values (increasing order), then halve 
	% the size of the node collection, removing nodes with lowest scaled ratio
	[vals node_idx] = sort(nodes.fitness);
	
	% Reduce the number of nodes in the collection by half
	node_n = size(nodes.weights, 2);
	prune_idx = node_idx(1:floor(node_n*0.5));
	
	nodes.weights(:, prune_idx) = [];
	nodes.fitness(prune_idx) = [];

end

