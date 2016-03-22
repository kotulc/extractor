% extractor_reduce.m
% Clayton Kotulak
% 12/4/2015

%{ 
Reduce the size of the set of nodes by half, compressing the representation 
of the excitatory instances in excite_data trained against a collection of 
inhibitory instances in sample_data.

Arguments: nodes struct, data struct, data struct
Returns: nodes struct
%}
function node_pool = extractor_reduce(node_pool, sample_data, tile_data)
		
	global PARAMS;
	
	% If the collection does not contain any nodes, return
	if (numel(node_pool) == 0)
		return;
	end
	
	% Generate a vector of node indices
	node_idx = 1:size(node_pool.weights, 2);
	
	% Calculate the node activation values
	actvs = extractor_fprop({node_pool.weights}, tile_data.excite_data);
	
	% Determine the per-instance maximum activation distribution among all 
	% nodes and then generate a map, assigning instances to nodes that maximize
	% their activation
	[val max_idx] = max(actvs, [], 2);
	actv_map = (node_idx == max_idx);
	
	% If a node does not have any instances mapped, remove it
	prune_flag = (sum(actv_map) == 0);
	actv_map(:, prune_flag) = [];
	
	% Update the learning mask for optimization based on the activation map 
	tile_data.excite_mask = actv_map .* (tile_data.excite_mask .+ 0.001);
	
	node_pool = extractor_nodes(tile_data, PARAMS.node_batch_size);
	
	% Get the updated fitness and related information for all remaining nodes
	node_pool = extractor_fitness(node_pool, sample_data);
	node_n = size(node_pool.fitness, 2);
	
	% Sort by the nodes by their fitness values (increasing order), then halve 
	% the size of the node collection, removing nodes with lowest scaled ratio
	[vals node_idx] = sort(abs(node_pool.fitness));
	
	% Reduce the number of nodes in the collection by half
	prune_idx = node_idx(1:floor(node_n*0.5));
	node_pool.weights(:, prune_idx) = [];
	node_pool.fitness(prune_idx) = [];
	node_pool.ratios(prune_idx) = [];
	node_pool.excite_actvsum(prune_idx) = [];

end

