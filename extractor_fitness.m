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
function nodes = extractor_fitness(nodes, sample_data, fmap=0)
	
	global PARAMS;
	
	node_n = size(nodes.weights, 2);
	
	null_actvs = extractor_fprop({nodes.weights}, sample_data.null_data).^2;
	target_actvs = extractor_fprop({nodes.weights}, sample_data.target_data).^2;

	% Calculate the target-to-null instance scaling value to account for sets 
	% of different sizes when calculating the activation ratio
	actvsum_scale = size(sample_data.target_data, 1) / ...
			size(sample_data.null_data, 1); 
	null_actvsums = sum(null_actvs .* sample_data.null_mask) * actvsum_scale;
    target_actvsums = sum(target_actvs .* sample_data.target_mask);
	
	% If fmap is true, nodes represents a single fmap, perform another sum 
	% operation for the null and target activation matrices
	if (fmap)
		node_n = 1;
		null_actvsums = sum(null_actvsums);
		target_actvsums = sum(target_actvsums);
	end
	
	ratio = target_actvsums ./ (null_actvsums .+ (null_actvsums==0));

	% r is the scaled, offset value used to compute a sigmoid function with a
	% x-intercept at 1. The parameter rscale_term scales the ratio term, 
	% effectively reducing the influence of the ratio term for values > 1 and
	% and increasing it's influence for values < 1. rscale_term must be > 0.
	r = (ratio .- 1) .* PARAMS.rscale_term;
	r_sigmoid = r ./ (1 .+ abs(r));
	
	% The fitness metric is the product of the parametrized ratio and log of
	% the sum of a nodes excitatory activation
	fitness = r_sigmoid .* log(null_actvsums .+ 1);
	nodes.fitness = fitness;
	
	% Display debug output
	if (PARAMS.db_display)
        instance_n = size(sample_data.null_data, 1) +...
                size(sample_data.target_data, 1);
		fprintf("\nFitness values (%i total instances):\n", instance_n);
        fprintf("t_asum        n_asum          ratio        fitness\n");
        
		for i=1:node_n
			fprintf("%12.4f %12.4f %12.4f %12.4f\n",...
					target_actvsums(i), null_actvsums(i), ratio(i), fitness(i));
		end
		fprintf("\n\n");
		fflush(stdout);
	end
	
end

