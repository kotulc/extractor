% extractor_encode.m
% Clayton Kotulak
% 1/10/2016

%{ 
Update the solution by adding (or "packing") the most fit feature map from
the fmap_collection into the solution (network layer), evaluate unsolved 
instances and then update the data alpha_mask vectors accordingly. 

Arguments: weigth matrix, fmap struct, data struct
Returns: weight matrix, data struct
%}
function [solution sample_data] = extractor_encode(...
		solution, fmap_collection, sample_data)
	
	global PARAMS;
	
	% Add the most fit feature to the current solution for the given problem 
	[val fmap_idx] = max(fmap_collection.target_fitness); 
	solution = [solution fmap_collection.target_fmaps(fmap_idx).weights]; 
	
	% Reduce the problem space if possible. 
	% Check for possible reduction of target or null instances. target 
	% instances may be removed from the problem if the sum of their squared 
	% activation values is greater or less then all null instances (i.e. they 
	% are linearly separable). Similar approach for null instance pruning.
	error_data = extractor_evaluate({solution}, sample_data);
	
	% Create masks to prune null and target instances designated as 'solved'
	null_prune_mask = error_data.null_layer < error_data.null_input;
	target_prune_mask = error_data.target_layer < error_data.target_input;

	sum(null_prune_mask)
	sum(target_prune_mask)
	
	% If the problem space can be reduced, update sample_data, the feature
	% fitness values and related data to better interpret the new problem
	if (sum(target_prune_mask)>0 || sum(null_prune_mask)>0)
		sample_data.null_data(null_prune_mask, :) = [];
		sample_data.target_data(target_prune_mask, :) = [];
		
		error_data.null_layer(null_prune_mask, :) = [];
		error_data.target_layer(target_prune_mask, :) = [];
		
		% Update the alpha influence masks with the normalized error 
		sample_data.null_mask = extractor_normalize(error_data.null_layer, 1);
		sample_data.target_mask = extractor_normalize(...
				error_data.target_layer, 1);
		
		fmap_collection = extractor_update(fmap_collection, sample_data);
	else	
		% No need to prune, just update the alpha masks for all samples
		sample_data.null_mask = extractor_normalize(error_data.null_layer, 1);
		sample_data.target_mask = extractor_normalize(...
				error_data.target_layer, 1);
	end
	keyboard();
end

