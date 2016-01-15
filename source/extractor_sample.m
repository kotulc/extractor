% extractor_sample.m
% Clayton Kotulak
% 1/12/2015

%{ 
Operating in the restricted scope of sample_data, iteratively extract a 
feature, generate a feature map and add it to the collection, finally pack 
the most fit feature map of the feature map collection into the solution.

Arguments: fmap struct, data struct
Returns: weight matrix, fmap struct
%}
function [solution fmap_collection] = extractor_sample(...
        fmap_collection, sample_data)
	
	global PARAMS;
	
	solution = [];
	
	% The alpha mask modifies the influence each instance has on the opt. cost
	% to shape the properties of each successive feature map
	null_instances = size(sample_data.null_data, 1);
    target_instances = size(sample_data.target_data, 1);
	
	% Add the alpha mask to each data set
    sample_data.null_mask = ones(null_instances, 1);
    sample_data.target_mask = ones(target_instances, 1);
    
	% If fmap_collection is not empty, update the metrics and activations
	% with those from this local sample space
    fmap_collection = extractor_update(fmap_collection, sample_data);
    
	% Generate max_fmaps fmaps to encode each layer classification component
	for i=1:PARAMS.max_fmaps	
		% Select a random subset of instances for the extraction operation
		[subset_data d_data] = extractor_subset(sample_data, PARAMS.subset_n);
		
		% Extract, select, reduce operations
		% Generate a feature map with the extracted template
		feature_map = extractor_extract(subset_data);
		feature_map.weights = extractor_fmap(feature_map.weights);
		feature_map = extractor_fitness(feature_map, sample_data, 1);
		
		% Add the new feature map to the fmap_collection
		fmap_collection.target_fmaps = [...
		        fmap_collection.target_fmaps; feature_map];
		fmap_collection.target_fitness = [...
				fmap_collection.target_fitness; feature_map.fitness];
		
		% Attempt to encode a solution. Evaluate it in order to infer sample 
		% instances that are poorly represented and need more influence
		[solution sample_data] = extractor_encode(....
		        solution, fmap_collection, sample_data);
	end
	
end

