% extractor_extract.m
% Clayton Kotulak
% 1/6/2015

%{ 
Extract features from the tiles of sample_data, generate a list of candidate
template nodes and iteratively merge and reduce this pool. Select and return 
the most fit candidate.

Arguments: data struct
Returns: node struct
%}
function [null_feature target_feature] = extractor_extract(sample_data)
	
	global PARAMS;
	
    % Initialize the template pool and tile collection structures
	node_pool.null_nodes.weights = [];
	node_pool.null_nodes.fitness = [];
	node_pool.target_nodes.weights = [];
	node_pool.target_nodes.fitness = [];
	
	tiles.null_tiles = [];
	tiles.target_tiles = [];
	
	% Initialize excitatory and inhibitory sum vectors in sample_data
	% these objects are used to steer template extraction and hopefully avoid
	% extracting duplicate features.
	sample_data.null_iactvsum = sample_data.target_imask;
	sample_data.null_eactvsum = sample_data.null_emask;

	sample_data.target_iactvsum = sample_data.null_imask;
	sample_data.target_eactvsum = sample_data.target_emask;
	
	
	% Get the lists of instances to extract template features from
	template_data = extractor_subset(sample_data, PARAMS.template_n);
	
	% Select a single candidate template instance per iteration
	disp("\nExtracting templates...");
	for i=1:PARAMS.template_n
		% Select a random set of evaluation instances to evaluate templates
		eval_data = extractor_subset(...
				sample_data, PARAMS.eval_n);
		
		% Add a new pair of template features to the pool
		[null_node target_node] = extractor_template(...
				template_data.null_data(i,:),...
				template_data.target_data(i,:), eval_data);
		
		[sample_data node_pool tiles] = extractor_pool(...
				sample_data, node_pool, tiles, null_node, target_node);
	end
	disp("Extraction complete.\n");
	
	
	% Update the format of sample_data by decomposing the instances into tiles
	[null_tiles null_imask null_emask] = extractor_decompose(...
			sample_data.null_data, sample_data.null_imask,...
			sample_data.null_emask);	
	
	[target_tiles target_imask target_emask] = extractor_decompose(...
			sample_data.target_data, sample_data.target_imask,...
			sample_data.null_emask);	
	
	% Clean up sample data, it is no longer required.
	clear sample_data;
	
	% Create the data structures used to used to reduce the pools
	null_data.null_data = target_tiles;
	null_data.null_mask = target_imask;
	null_data.target_data = null_tiles;
	null_data.target_mask = null_emask;
	
	target_data.null_data = null_tiles;
	target_data.null_mask = null_imask;
	target_data.target_data = target_tiles;
	target_data.target_mask = target_emask;
	
	
	% Select operation
	% template is the most fit candidate template from the template pool
	[val template_idx] = max(node_pool.null_nodes.fitness);
	null_feature.weights = node_pool.null_nodes.weights(:, template_idx);
	null_feature.fitness = node_pool.null_nodes.fitness(template_idx);
	
	[val template_idx] = max(node_pool.target_nodes.fitness);
	target_feature.weights = node_pool.target_nodes.weights(:, template_idx);
	target_feature.fitness = node_pool.target_nodes.fitness(template_idx);
	
	if (PARAMS.db_display)
		fprintf("Starting null and target fitness: %12.6d %d\n",...
				null_feature.fitness, target_feature.fitness);
		fprintf("Null and target pool fitness values:\n");
		fprintf("%12.6d %d\n", node_pool.null_nodes.fitness,...
				node_pool.target_nodes.fitness);
		fprintf("\n");
	end
	
	
	disp("\nReducing template pools...");
	% Reduction phase
	while size(node_pool.null_nodes.weights, 2)>1
		% Reduce re-calculates the weights of each template and eliminates 
		% those found in the bottom half of template_pool in terms of fitness,
		% per pass. Returns reduced template_pool with newly trained templates
		node_pool.null_nodes = extractor_reduce(...
				node_pool.null_nodes, tiles.null_tiles, null_data);

		% Compare the new set of templates with the current best template and
		% select the template with the greatest fitness
		[val template_idx] = max(...
				[null_feature.fitness node_pool.null_nodes.fitness]);		
		if template_idx!=1
			null_feature.weights =...
					node_pool.null_nodes.weights(:, template_idx-1);
			null_feature.fitness =...
					node_pool.null_nodes.fitness(template_idx-1);
		end
		
		if (PARAMS.db_display)
			fprintf("Starting null fitness: %12.6d\n",...
				null_feature.fitness);
			fprintf("Reduced null pool fitness values:\n");
			fprintf("%12.6d\n", node_pool.null_nodes.fitness);
			fprintf("\n");
		end
	end
	
	% Repeat above for target templates
	while size(node_pool.target_nodes.weights, 2)>1
		node_pool.target_nodes = extractor_reduce(...
				node_pool.target_nodes, tiles.target_tiles, target_data);
	
		[val template_idx] = max(...
				[target_feature.fitness node_pool.target_nodes.fitness]);			
		if template_idx!=1
			target_feature.weights =...
					node_pool.target_nodes.weights(:, template_idx-1);
			target_feature.fitness =...
					node_pool.target_nodes.fitness(template_idx-1);
		end
		
		if (PARAMS.db_display)
			fprintf("Starting target fitness: %12.6d\n",...
				target_feature.fitness);
			fprintf("Reduced target pool fitness values:\n");
			fprintf("%12.6d\n", node_pool.target_nodes.fitness);
			fprintf("\n");
		end
	end
	
	disp("Reduction complete.\n");
	
end

