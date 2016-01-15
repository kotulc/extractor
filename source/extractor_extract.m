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
function template_node = extractor_extract(sample_data)
	
	global PARAMS;
	
    % Initialize the template pool collection structure
	template_pool.instances = [];
	template_pool.weights = [];
	template_pool.fitness = [];
	template_pool.tiles = [];
	
	% Get the list of (target) instances to generate templates from
	[template_data r_data] = extractor_subset(sample_data, PARAMS.template_n);
	
	% Select a single candidate template instance per iteration. NOTE: This is
	% a batch operation, each iteration may be performed in parallel in future 
	% implementations of this system
	for i=1:size(template_data.target_data, 1)
		% Select a random set of null instance tiles to extract templates from
		[eval_data r_tiles] = extractor_subset(...
				sample_data, PARAMS.eval_n);
		
		% Get a new candidate template and related tile data 
		[template_node template_tile] = extractor_template(...
				template_data.target_data(i,:), eval_data);
		
		% Add the newly selected template to the template pool collection
		template_pool.weights = [template_pool.weights template_node.weights];
		template_pool.fitness = [template_pool.fitness; template_node.fitness];
		template_pool.tiles = [template_pool.tiles; template_tile];
	end
	
	
	% Update the format of sample_data by decomposing the instances into tiles
	[null_tiles null_mask] = extractor_decompose(...
			sample_data.null_data, sample_data.null_mask);	
	
	[target_tiles target_mask] = extractor_decompose(...
			sample_data.target_data, sample_data.target_mask);	
	
	% Update sample_data with the instance tiles
	sample_data.null_data = null_tiles;
	sample_data.null_mask = null_mask;
	sample_data.target_data = target_tiles;
	sample_data.target_mask = target_mask;
	
	
	% Select operation
	% template is the most fit candidate template from the template pool
	[val template_idx] = max(template_pool.fitness);
	template_node.weights = template_pool.weights(:, template_idx);
	template_node.fitness = template_pool.fitness(template_idx);
	
	if (PARAMS.db_display)
		fprintf("Starting template fitness: %d\n", template_node.fitness);
		fprintf("Pool fitness values:\n");
		fprintf("%d\n", template_pool.fitness);
		fprintf("\n");
	end

	
	disp("\nReducing template pool...");
	% Reduction phase
	while size(template_pool.weights, 2)>1
		% Reduce re-calculates the weights of each template and eliminates 
		% those found in the bottom half of template_pool in terms of fitness,
		% per pass. Returns reduced template_pool with newly trained templates
		template_pool = extractor_reduce(template_pool, sample_data);
        
		% Compare the new set of templates with the current best template and
		% select the template with the greatest fitness
		[val template_idx] = max([template_node.fitness...
				template_pool.fitness]);
		if template_idx!=1
			template_node.weights = template_pool.weights(:, template_idx-1);
			template_node.fitness = template_pool.fitness(template_idx-1);
		end
		
		if (PARAMS.db_display)
			fprintf("Selected template fitness: %d\n", template_node.fitness);
			fprintf("Reduced pool fitness values:\n");
			fprintf("%d\n", template_pool.fitness);
			fprintf("\n");
		end
	end
	disp("Reduce operations complete.");
	
end

