% extractor_encode.m
% Clayton Kotulak
% 1/10/2016

%{ 
Update the solution by adding (or "packing") the most fit feature map from
the fmap_collection into the solution (network layer), evaluate unsolved 
instances and then update the data alpha_mask vectors accordingly. 

Arguments: weight matrix, fmap struct, data struct
Returns: weight matrix
%}
function solution = extractor_encode(fmap_collection, sample_data)
	
	global PARAMS;

	% Initialize solution matrix by selecting the most fit feature map
	[null_val null_idx] = max(fmap_collection.null_fitness);
	[target_val target_idx] = max(fmap_collection.target_fitness); 
	
	if (target_val < null_val)
		solution = [fmap_collection.null_fmaps(null_idx).weights]; 
		fmap_collection.null_fmaps(null_idx) = [];
		fmap_collection.null_fitness(null_idx) = [];
		fmap_collection.null_iactvsum(:, null_idx) = [];
		fmap_collection.null_eactvsum(:, null_idx) = [];
	else
		solution = [fmap_collection.target_fmaps(target_idx).weights];
		fmap_collection.target_fmaps(null_idx) = [];
		fmap_collection.target_fitness(null_idx) = [];
		fmap_collection.target_iactvsum(:, null_idx) = [];
		fmap_collection.target_eactvsum(:, null_idx) = [];
	end
	
	% Continue to add up to the maximum number of feature maps
	for i=2:PARAMS.max_fmaps
		% Determine if the solution is sufficient, if not, reduce the problem 
		% space if possible. target instances may be removed from the problem 
		% if the sum of their squared activation values is greater or less then
		% all null instances (i.e. they are separable). Same for null pruning
		disp("Encoding layer:");
		[error_data actv_data] = extractor_evaluate(solution, sample_data);
		
		% Create masks to prune null and target instances designated as solved
		null_prune_mask = error_data.null_layer < error_data.null_input;
		target_prune_mask = error_data.target_layer < error_data.target_input;
		sum(null_prune_mask)
		sum(target_prune_mask)
		
		% If the problem space can be reduced, update sample_data, the feature
		% fitness values and related data to better interpret the new problem
		if (sum(target_prune_mask)>0 || sum(null_prune_mask)>0)
			sample_data.null_data(null_prune_mask, :) = [];
			sample_data.target_data(target_prune_mask, :) = [];
			
			sample_data.null_imask(target_prune_mask, :) = [];
			sample_data.null_emask(null_prune_mask, :) = [];
			sample_data.target_imask(null_prune_mask, :) = [];
			sample_data.target_emask(target_prune_mask, :) = [];
			
			error_data.null_layer(null_prune_mask, :) = [];
			error_data.target_layer(target_prune_mask, :) = [];
		end
		
		% Check the number of instances remaining
		null_instances = size(sample_data.null_data, 1);
		target_instances = size(sample_data.target_data, 1);
		if (null_instances==0 && target_instances==0)
			% The current layer encoding is sufficient, return the solution
			break;
		end
		
		% Update sample_data alpha masks based on make-up of fmap_collection.
		% for null fmaps, use activation sum from null fmaps, norm of inverse?
		[fmap_collection sample_data] = extractor_update(...
				fmap_collection, sample_data);	
		
		
		% Determine which fmap class to select next. Select from the null class
		% if the sum of the null activation error is greater than that of the 
		% target class
		null_esum = sum(error_data.null_layer, 2);
		null_error = sum(null_esum);
		target_esum = sum(error_data.target_layer, 2);
		target_error = sum(target_esum);
		
		if (null_error > target_error)
			% Add null fmaps to reduce null instance activations errors 
			% Add the most fit feature to the solution for the given problem 
			[val fmap_idx] = max(fmap_collection.null_fitness); 
			solution = [solution fmap_collection.null_fmaps(fmap_idx).weights]; 
			
			% Remove the feature map from the collection so it cant be 
			% selected again
			fmap_collection.null_fmaps(fmap_idx) = [];
			fmap_collection.null_fitness(fmap_idx) = [];
			fmap_collection.null_iactvsum(:, fmap_idx) = []; 
			fmap_collection.null_eactvsum(:, fmap_idx) = [];
		else
			% Add a target fmap instead
			[val fmap_idx] = max(fmap_collection.target_fitness); 
			solution = [solution fmap_collection.target_fmaps(fmap_idx).weights]; 
			
			fmap_collection.target_fmaps(fmap_idx) = [];
			fmap_collection.target_fitness(fmap_idx) = [];
			fmap_collection.target_iactvsum(:, fmap_idx) = []; 
			fmap_collection.target_eactvsum(:, fmap_idx) = [];
		end
		
	end
	
end

