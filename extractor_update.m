% extractor_update.m
% Clayton Kotulak
% 1/10/2016

%{ 
Update the fitness and all relevant data for each feature map contained in
the null_fmaps and target_fmaps components of fmap_collection.

Arguments: fmap struct, data struct
Returns: fmap struct
%}
function fmap_collection = extractor_update(fmap_collection, sample_data)
	
	if numel(fmap_collection.null_fmaps)>0
		% Perform the update for each null_fmap
		for i=1:numel(fmap_collection.null_fmaps)
			updated_fmap = extractor_fitness(...
					fmap_collection.null_fmaps(i), sample_data, 1);
			fmap_collection.null_fmaps(i) = updated_fmap;
			fmap_collection.null_fitness(i) = updated_fmap.fitness;
		end
	end
	
	% Repeat the above for the target feature maps
	if numel(fmap_collection.target_fmaps)>0
		for i=1:numel(fmap_collection.target_fmaps)
			updated_fmap = extractor_fitness(...
					fmap_collection.target_fmaps(i), sample_data, 1);
			fmap_collection.target_fmaps(i) = updated_fmap;
			fmap_collection.target_fitness(i) = updated_fmap.fitness;
					
		end
	end
	
end

