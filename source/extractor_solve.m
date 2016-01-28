% extractor_solve.m
% Clayton Kotulak
% 1/12/2015

%{ 
Operating in the restricted scope of sample_data, iteratively extract a 
feature, generate a feature map and add it to the collection, finally pack 
the most fit feature map of the feature map collection into the solution.

Arguments: fmap struct, data struct
Returns: weight matrix, fmap struct
%}
function [solution fmap_collection] = extractor_solve(...
        fmap_collection, sample_data)
	
	global PARAMS;
	
	solution = [];
	
	% Initialize excitatory and inhibitory mask vectors in sample_data
	sample_data.null_imask = ones(size(sample_data.null_data, 1), 1);
	sample_data.null_emask = sample_data.null_imask;
	
	sample_data.target_imask = ones(size(sample_data.target_data, 1), 1);
	sample_data.target_emask = sample_data.target_imask;
	
	% Update the fmap_collection if it contains features
	if (numel(fmap_collection.null_fmaps)>0 ||...
			numel(fmap_collection.target_fmaps)>0)
		[fmap_collection sample_data] = extractor_update(...
				fmap_collection, sample_data);
    end
	
	% Generate feature_n fmaps used to generate a solution (ANN layer)
	for i=1:PARAMS.feature_n	
		% Select a random subset of instances for the extraction operation
		subset_data = extractor_subset(sample_data, PARAMS.subset_n);
		
		% Extract, select, reduce operations
		% Generate a feature map with the extracted template
		[null_feature target_feature] = extractor_extract(subset_data);
		null_fmap.weights = extractor_fmap(null_feature.weights);
		target_fmap.weights = extractor_fmap(target_feature.weights);
				
		% Update sample_data alpha masks based on the fmap_collection
		% for null fmaps, use activation sum from null fmaps, norm of inverse?
		[fmap_collection sample_data] = extractor_update(...
				fmap_collection, sample_data, null_fmap, target_fmap);
	end

	% Encode a solution using the feature map collection
	solution = extractor_encode(fmap_collection, sample_data);
	
end

