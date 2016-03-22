% extractor_update.m
% Clayton Kotulak
% 1/10/2016

%{ 
For each fmap passed, update the feature map fitness and add it to the 
collection. Then update sample_data alpha masks to reflect the new 
concentration of features that activate a given instance.

Arguments: collection struct, data struct, fmap struct (opt)
Returns: collection struct, data struct
%}
function [fmap_collection sample_data] = extractor_update(...
		fmap_collection, sample_data, fmap=[], mask_update=1)
	
	% If passed a new feature map, calculate fitness and add to the collection
	if (numel(fmap)>0)
		% Calculate the fmap activation and fitness values 
		fmap = extractor_fitness(fmap, sample_data, 1);
	
		% Add the feature map components to fmap_collection
		fmap_collection.weights{end+1} = fmap.weights{1};
		fmap_collection.fitness = [fmap_collection.fitness fmap.fitness];
		fmap_collection.inhibit_actvsum =...
				[fmap_collection.inhibit_actvsum fmap.inhibit_actvsum];
		fmap_collection.excite_actvsum =...
				[fmap_collection.excite_actvsum fmap.excite_actvsum];
		
	% Otherwise update all feature maps contained in the collection
	else
		% Calculate the updated fmap activation and fitness values 
		fmap_collection = extractor_fitness(fmap_collection, sample_data, 1);
	end
	
	if (mask_update)
			% Calculate the total activation sum for all instances of a given class
		inhibit_actvsum = sum(...
				fmap_collection.inhibit_actvsum .* fmap_collection.fitness, 2);
		excite_actvsum = sum(...
				fmap_collection.excite_actvsum .* fmap_collection.fitness, 2);
		
		% Normalize and scale actvsum values to generate the new masks
		sample_data.inhibit_mask = extractor_normalize(inhibit_actvsum, 1);
		sample_data.excite_mask = extractor_normalize(-1.*excite_actvsum, 1);
	end
	 
end

