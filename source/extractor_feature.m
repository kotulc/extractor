% extractor_feature.m
% Clayton Kotulak
% 1/6/2015

%{ 
Generate a series of feature nodes using excitatory template tiles extracted
from sample_data. Calculate the fitness of each generated node and perform 
either a single select operation or iteratively reduce the set of feature nodes
to select the node with the greatest fitness.

Arguments: data struct
Returns: node struct
%}
function feature_node = extractor_feature(sample_data)
	
	global PARAMS;

	% Update the collection of template tiles
	tile_data.excite_data = extractor_template(sample_data);
	tile_data.excite_mask = eye(size(tile_data.excite_data, 1));
	
	% Select a random set of inhibitory sample instances to train nodes against
	eval_data = extractor_subset(sample_data, PARAMS.node_eval_n);
			
	% Decompose the data set for fitness calculations
	[inhibit_tiles inhibit_mask] = extractor_decompose(...
			sample_data.inhibit_data, sample_data.inhibit_mask);
	[excite_tiles excite_mask] = extractor_decompose(...
			sample_data.excite_data, sample_data.excite_mask);
	sample_data.inhibit_data = inhibit_tiles;
	sample_data.inhibit_mask = inhibit_mask;
	sample_data.excite_data = excite_tiles;
	sample_data.excite_mask = excite_mask;

	% Initialize tile data set for node training 
	[inhibit_tiles inhibit_mask] = extractor_decompose(...
			eval_data.inhibit_data, eval_data.inhibit_mask);
			
	tile_data.inhibit_data = inhibit_tiles;
	tile_data.inhibit_mask = inhibit_mask;

	% Generate the template node against the tile data
	node_pool = extractor_nodes(tile_data, PARAMS.node_batch_size);
	
	% Select operation
	node_pool = extractor_fitness(node_pool, sample_data);

	
	% template is the most fit candidate from the template pool
	[val template_idx] = max(node_pool.fitness);
	feature_node.weights = node_pool.weights(:, template_idx);
	feature_node.fitness = node_pool.fitness(template_idx);
	feature_node.ratio = node_pool.ratios(template_idx);
	feature_node.excite_actvsum = node_pool.excite_actvsum(template_idx);

	if (PARAMS.db_display)
		fprintf("Starting node fitness: %d\n", feature_node.fitness);
		fprintf("Starting node ratio: %d\n", feature_node.ratio);
		fprintf("Starting node sum: %d\n", feature_node.excite_actvsum);
		fflush(stdout);
	end

	
	% Reduction phase
	if (PARAMS.reduce)
		disp("\nReducing template pools...");
		
		% Remove excitatory tiles associated with negative nodes
		prune_mask = (node_pool.fitness<=0);
		if (sum(prune_mask)==0)
			disp("extractor_extract warning: No positive bias tiles in set.");
			return;
		end
		tile_data.excite_data = tile_data.excite_data(~prune_mask, :);
		
		% Update tile_data excitatory mask proportional to fitness  
		excite_mask = node_pool.fitness(~prune_mask)';
		tile_data.excite_mask = extractor_normalize(excite_mask, 1).^2;
	
		% Revert size of tile inhibitory mask to m x 1
		tile_data.inhibit_mask = inhibit_mask;
		
		while size(node_pool.weights, 2)>1
			% Reduce re-calculates the weights of each template and eliminates 
			% those found in the bottom half of template_pool in terms of fitness,
			% per pass. Returns reduced template_pool with newly trained templates
			node_pool = extractor_reduce(node_pool, sample_data, tile_data);
			
			% Compare the new set of templates with the current best template and
			% select the template with the greatest fitness
			[val template_idx] = max([feature_node.fitness node_pool.fitness]);		
			if template_idx!=1
				feature_node.weights = node_pool.weights(:, template_idx-1);
				feature_node.fitness = node_pool.fitness(template_idx-1);
				feature_node.ratio = node_pool.ratios(template_idx-1);
				feature_node.excite_actvsum = ...
						node_pool.excite_actvsum(template_idx-1);
			end
			
			if (PARAMS.db_display)
				fprintf("Selected node fitness: %d\n", feature_node.fitness);
				fprintf("Selected node ratio: %d\n", feature_node.ratio);
				fprintf("Selected node sum: %d\n", feature_node.excite_actvsum);
				fflush(stdout);
			end
			
		end
		
		disp("Reduction complete.\n");
	end
	
end

