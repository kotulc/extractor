% extractor_encode_old.m
% Clayton Kotulak
% 1/10/2016

%{ 
Deprecated version of this function included for reference only.
Update the solution by adding (or "packing") the most fit feature map from
the fmap_collection into the solution (network layer), evaluate unsolved 
instances and then update the data alpha_mask vectors accordingly. 

Arguments: weigth matrix, fmap struct, data struct
Returns: weight matrix, data struct
%}
function [solution sample_data] = extractor_encode_old(...
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
	null_actvs = extractor_fprop({solution}, sample_data.null_data).^2;
	null_actvsums = sum(null_actvs, 2);
	target_actvs = extractor_fprop({solution}, sample_data.target_data).^2;
	target_actvsums = sum(target_actvs, 2);
	
	[null_maxactv idx] = max(null_actvsums)
	[null_minactv idx] = min(null_actvsums)
	[target_maxactv idx] = max(target_actvsums)
	[target_minactv idx] = min(target_actvsums)
	
	% Create masks to prune null and target instances designated as 'solved'
	null_prune_mask = ((null_actvsums > target_maxactv) .+
			(null_actvsums < target_minactv)) > 0;
	
	target_prune_mask = ((target_actvsums > null_maxactv) .+
			(target_actvsums < null_minactv)) > 0;
	
	sum(null_prune_mask)
	sum(target_prune_mask)
	
	% If the problem space has been reduced, update sample_data, the feature
	% fitness values and related data to better interpret the new problem
	if (sum(target_prune_mask)>0 || sum(null_prune_mask)>0)
		sample_data.null_data(null_prune_mask, :) = [];
		sample_data.null_mask(null_prune_mask, :) = [];
		sample_data.target_data(target_prune_mask, :) = [];
		sample_data.target_mask(target_prune_mask, :) = [];
		fmap_collection = extractor_update(fmap_collection, sample_data);
	end
	
	% Update the learning influence mask, currently two different variants
	if PARAMS.encoding_variant==1
		% Generate the alpha training influence masks. The null alpha mask is 
		% the list of normalized null instance activation sum values while the
		% target class alpha mask is the inverse of the normalized target 
		% instance activation sum values
		null_actvsums(null_prune_mask) = [];
		target_actvsums(target_prune_mask) = [];
		sample_data.null_mask = extractor_normalize(null_actvsums, 1);
		sample_data.target_mask = extractor_normalize(-1.*target_actvsums, 1);
		keyboard();
	else	
		% Alternate encoding: deviates from previous step by using the standard 
		% normalized activation distributions for both null and target class, 
		% as opposed to an inverse norm for the target class
		null_actvsums(null_prune_mask) = [];
		target_actvsums(target_prune_mask) = [];
		sample_data.null_mask = extractor_normalize(null_actvsums, 1);
		sample_data.target_mask = extractor_normalize(target_actvsums, 1);
	end
	
end

