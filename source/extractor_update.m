% extractor_update.m
% Clayton Kotulak
% 1/10/2016

%{ 
For each fmap passed, update the feature map fitness and add it to the 
collection. Then update sample_data alpha masks to reflect the new 
concentration of features that activate a given instance.

Arguments: collection struct, data struct, fmap struct (opt), fmap struct (opt)
Returns: collection struct, data struct
%}
function [fmap_collection sample_data] = extractor_update(...
		fmap_collection, sample_data, null_fmap=[], target_fmap=[])
	
	% Save sample_data null and target data for fitness evaluation below
	null_data = sample_data.null_data;
	target_data = sample_data.target_data;
	
	% Check for new feature maps to be added to the collection
	if (numel(null_fmap)>0)
		% Add masks to sample_data and swap data sets for fitness evaluation
		sample_data.null_data = target_data;
		sample_data.null_mask = sample_data.null_imask;
		sample_data.target_data = null_data;
		sample_data.target_mask = sample_data.null_emask;
		
		% Calculate the fmap activation and fitness values 
		null_fmap = extractor_fitness(null_fmap, sample_data, 1);
	
		% Add the feature map components to fmap_collection
		fmap_collection.null_fmaps = [...
		        fmap_collection.null_fmaps null_fmap];
		fmap_collection.null_fitness = [...
		        fmap_collection.null_fitness null_fmap.fitness];
		fmap_collection.null_iactvsum = [...
				fmap_collection.null_iactvsum null_fmap.null_actvsum];
		fmap_collection.null_eactvsum = [...
				fmap_collection.null_eactvsum null_fmap.target_actvsum];
	end
	
	% Repeat the above for the target fmap
	if (numel(target_fmap)>0)
		sample_data.null_data = null_data;
		sample_data.null_mask = sample_data.target_imask;
		sample_data.target_data = target_data;
		sample_data.target_mask = sample_data.target_emask;
		
		target_fmap = extractor_fitness(target_fmap, sample_data, 1);
	
		fmap_collection.target_fmaps = [...
		        fmap_collection.target_fmaps target_fmap];
		fmap_collection.target_fitness = [...
		        fmap_collection.target_fitness target_fmap.fitness];
		fmap_collection.target_iactvsum = [...
				fmap_collection.target_iactvsum target_fmap.null_actvsum];
		fmap_collection.target_eactvsum = [...
				fmap_collection.target_eactvsum target_fmap.target_actvsum];
	end
	
	
	% If both feature map parameters are empty, update the collection instead 
	if (numel(null_fmap)==0 && numel(target_fmap)==0)
		% Add masks to sample_data and swap data sets for fitness evaluation
		sample_data.null_data = target_data;
		sample_data.null_mask = sample_data.null_imask;
		sample_data.target_data = null_data;
		sample_data.target_mask = sample_data.null_emask;
		
		% Calculate the updated fmap activation and fitness values 
		null_fmaps = extractor_fitness(fmap_collection.null_fmaps, sample_data, 1);
		
		% Update the collection
		fmap_collection.null_fitness = null_fmaps.fitness;
		fmap_collection.null_iactvsum = null_fmaps.null_actvsum;
		fmap_collection.null_eactvsum = null_fmaps.target_actvsum;
		
		% Repeat for target data
		sample_data.null_data = null_data;
		sample_data.null_mask = sample_data.target_imask;
		sample_data.target_data = target_data;
		sample_data.target_mask = sample_data.target_emask;
		
		target_fmaps = extractor_fitness(fmap_collection.target_fmaps, sample_data, 1);
		
		fmap_collection.target_fitness = target_fmaps.fitness;
		fmap_collection.target_iactvsum = target_fmaps.null_actvsum;
		fmap_collection.target_eactvsum = target_fmaps.target_actvsum;
	end
	
	
	% Update the sample_data alpha influence masks to be equal to the inverse
	% of the normalized concentration of instance activations. The actvsum 
	% vectors should be contain a list of values, one for the activation sum of
	% each instance for all features
	null_iactvsum = sum(fmap_collection.null_iactvsum, 2);
	null_eactvsum = sum(fmap_collection.null_eactvsum, 2);

	target_iactvsum = sum(fmap_collection.target_iactvsum, 2);
	target_eactvsum = sum(fmap_collection.target_eactvsum, 2);
	
	% Normalize and scale actvsum values to generate the masks
	sample_data.null_imask = extractor_normalize(null_iactvsum, 1);
	sample_data.null_emask = extractor_normalize(-1.*null_eactvsum, 1);
    sample_data.target_imask = extractor_normalize(target_iactvsum, 1);
    sample_data.target_emask = extractor_normalize(-1.*target_eactvsum, 1);
	 
end

