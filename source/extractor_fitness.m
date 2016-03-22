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
	
	if (PARAMS.db_display)
		fprintf("\nCalculating fitness...\n");
		fflush(stdout);
	end
	
	% Collect information for db_display
	fitness_vals = [];
	ratio_vals = [];
	inhibit_actvals = [];
	excite_actvals = [];
	inhibit_actvsums = [];
	excite_actvsums = [];
	
	if (~fmap)
		fmap_n = 1;
	else
		fmap_n = size(nodes_collection.weights, 2);
	end
	
	% Each iteration processes one group of nodes or a feature map
	for i=1:fmap_n
		% node_collection.weights contains a matrix of weights where each 
		% column vector represents a node. Calculate the fitness for each node
		if (fmap)
			inhibit_actvs = extractor_fprop(...
				{nodes_collection.weights{i}}, sample_data.inhibit_data).^2;
			excite_actvs = extractor_fprop(...
				{nodes_collection.weights{i}}, sample_data.excite_data).^2;
				
			% If this is a feature map, combine node activation values
			inhibit_actvs = sum(inhibit_actvs, 2);
			excite_actvs = sum(excite_actvs, 2);
		else
			inhibit_actvs = extractor_fprop(...
				{nodes_collection.weights}, sample_data.inhibit_data).^2;
			excite_actvs = extractor_fprop(...
				{nodes_collection.weights}, sample_data.excite_data).^2;
		end
		
		% Calculate the excite-to-inhibit instance scaling value to account for
		% sets of different sizes when calculating the activation ratio
		actvsum_scale = size(sample_data.excite_data, 1) / ...
				size(sample_data.inhibit_data, 1); 
		
		inhibit_actvsum = sum(inhibit_actvs) .* actvsum_scale;
		excite_actvsum = sum(excite_actvs);
		
		inhibit_actvals = [inhibit_actvals; inhibit_actvsum];
		excite_actvals = [excite_actvals; excite_actvsum];
		
		% Save the activation sum for each class 
		if (fmap)
			inhibit_actvsums = [inhibit_actvsums sum(inhibit_actvs, 2)];
			excite_actvsums = [excite_actvsums sum(excite_actvs, 2)];
		else
			inhibit_actvsums = [inhibit_actvsums sum(inhibit_actvs)];
			excite_actvsums = [excite_actvsums sum(excite_actvs)];
		end
		
		ratio = excite_actvsum ./ (inhibit_actvsum .+ (inhibit_actvsum==0));
		ratio_vals = [ratio_vals; ratio];

		% r is the scaled, offset value used to compute a sigmoid function with 
		% a x-intercept at 1. The parameter rscale_term scales the ratio term, 
		% effectively reducing the influence of the ratio term for values > 1 
		% and increasing it's influence for values < 1. rscale_term must be > 0.
		r = (ratio .- 1) .* PARAMS.rscale_term;
		r_sigmoid = r ./ (1 .+ abs(r));
		
		excite_norm = sum(excite_actvs .* sample_data.excite_mask) ./...
				sum(sample_data.excite_mask);
		e_term = PARAMS.escale_term .+ log(1 .+ excite_norm);
		
		fitness = r_sigmoid .* e_term;
		fitness_vals = [fitness_vals fitness]; 
	end
	
	% Update the nodes_collection structure with the gathered data
	nodes_collection.fitness = fitness_vals;
	nodes_collection.inhibit_actvsum = inhibit_actvsums;
	nodes_collection.excite_actvsum = excite_actvsums;
	nodes_collection.ratios = ratio_vals;

	
	% Display debug output
	if (PARAMS.db_display)
		min_val = min(nodes_collection.fitness);
		max_val = max(nodes_collection.fitness);
		mean_val = mean(nodes_collection.fitness);
		fprintf("Fitness min: %4d, max: %4d, mean %4d\n",...
				min_val, max_val, mean_val);
				
        instance_n = size(sample_data.inhibit_data, 1) +...
                size(sample_data.excite_data, 1);
		fprintf("\nFitness values (%i nodes, %i total instances):\n",...
				numel(fitness_vals), instance_n);
		
        fprintf("i_asum        e_asum          ratio        fitness\n");
        
		display_n = min([PARAMS.db_fitness numel(fitness_vals)]);
		for i=1:display_n
			fprintf("%12.4f %12.4f %12.4f %12.6f\n", inhibit_actvals(i),
					excite_actvals(i), ratio_vals(i), fitness_vals(i));
		end
		fprintf("\nFitness calculated.\n\n");
		fflush(stdout);
	end
	
end

