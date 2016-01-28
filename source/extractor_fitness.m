% extractor_fitness.m
% Clayton Kotulak
% 10/04/2015

%{ 
Update the list of fitness values of the nodes struct. The fitness metric
is the product of sigmoid(r) and log(e_sum). If db_display is true, display all
relevant node information including their respective fitness.

Arguments: nodes struct, data struct, boolean (optional)
Returns: nodes struct
%}
function nodes_collection = extractor_fitness(...
		nodes_collection, sample_data, fmap=0)
	
	global PARAMS;
	
	% If the collection contains fmaps, nodes represents a fmap_collection, 
	% process each fmap iteratively. Perform another sum operation for the null
	% and target activation matrices
	if (fmap==0)
		% Passed object is not a feature map, adapt its structure 
		nodes_collection(1) = nodes_collection;
	end
	
	% Collect information for db_display
	fitness_vals = [];
	ratio_vals = [];
	null_actvals = [];
	target_actvals = [];
	null_actvsums = [];
	target_actvsums = [];
	node_weights = [];
	
	% Each iteration processes one group of nodes or a feature map
	for i=1:size(nodes_collection, 2)
		% node_collection(i).weights contains a matrix of weights where each 
		% column vector represents a node. Calculate the fitness for each node
		node_weights = [node_weights nodes_collection(i).weights];
		
		null_actvs = extractor_fprop(...
				{nodes_collection(i).weights}, sample_data.null_data).^2;
		target_actvs = extractor_fprop(...
				{nodes_collection(i).weights}, sample_data.target_data).^2;

		% Calculate the target-to-null instance scaling value to account for
		% sets of different sizes when calculating the activation ratio
		actvsum_scale = size(sample_data.target_data, 1) / ...
				size(sample_data.null_data, 1); 
				
		null_actvsum = sum(...
				null_actvs .* sample_data.null_mask) .* actvsum_scale;
		target_actvsum = sum(target_actvs .* sample_data.target_mask);
		
		if (fmap)
			% An additional sum over each node in the feature map is required
			null_actvsum = sum(null_actvsum);
			target_actvsum = sum(target_actvsum);
		end
		
		null_actvals = [null_actvals; null_actvsum];
		target_actvals = [target_actvals; target_actvsum];
		
		% Save the activation sum for each class 
		null_actvsums = [null_actvsums sum(null_actvs, 2)];
		target_actvsums = [target_actvsums sum(target_actvs, 2)];
		
		ratio = target_actvsum ./ (null_actvsum .+ (null_actvsum==0));
		ratio_vals = [ratio_vals; ratio];

		% r is the scaled, offset value used to compute a sigmoid function with a
		% x-intercept at 1. The parameter rscale_term scales the ratio term, 
		% effectively reducing the influence of the ratio term for values > 1 and
		% and increasing it's influence for values < 1. rscale_term must be > 0.
		r = (ratio .- 1) .* PARAMS.rscale_term;
		r_sigmoid = r ./ (1 .+ abs(r));
		
		% The fitness metric is the product of the parametrized ratio and log of
		% the sum of a nodes excitatory activation
		fitness = r_sigmoid .* log(null_actvsum .+ 1);
		fitness_vals = [fitness_vals fitness];
	end
	
	% Rebuild the nodes_collection structure with the gathered data
	nodes_collection = [];
	nodes_collection.weights = node_weights;
	nodes_collection.fitness = fitness_vals;
	nodes_collection.null_actvsum = null_actvsums;
	nodes_collection.target_actvsum = target_actvsums;
	
	
	% Display debug output
	if (PARAMS.db_display)
        instance_n = size(sample_data.null_data, 1) +...
                size(sample_data.target_data, 1);
		fprintf("\nFitness values (%i total instances):\n", instance_n);
        fprintf("n_asum        t_asum          ratio        fitness\n");
        
		for i=1:numel(fitness_vals)
			fprintf("%12.4f %12.4f %12.4f %12.4f\n", null_actvals(i),
					target_actvals(i), ratio_vals(i), fitness_vals(i));
		end
		fprintf("\n\n");
		fflush(stdout);
	end
	
end

