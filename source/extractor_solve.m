% extractor_solve.m
% Clayton Kotulak
% 1/12/2015

%{ 
Operating in the restricted scope of sample_data, iteratively extract a 
feature, generate a feature map and add it to the collection, finally pack 
the most fit feature map of the feature map collection into the solution.

Arguments: 
Returns: 
%}
function fmap_collection = extractor_extract(...
		fmap_collection, sample_data, invert=0)
	
	global PARAMS;
	
	if (invert)
		% Swap the excitatory and inhibitory data for inhibitory fmaps
		excite_data = sample_data.inhibit_data;
		sample_data.inhibit_data = sample_data.excite_data;
		sample_data.excite_data = excite_data;
	end
	
	if (size(fmap_collection.weights, 2)>0)
		disp("Updating feature data...");
		fflush(stdout);
		[fmap_collection sample_data] = extractor_update(...
				fmap_collection, sample_data);
		disp("Feature data updated.\n");
	else
		% Initialize the sample data masks
		sample_data.inhibit_mask = ones(size(sample_data.excite_data, 1), 1);
		sample_data.excite_mask = ones(size(sample_data.inhibit_data, 1), 1);
	end

	% Generate feature_n excitatory fmaps used to generate a solution (layer)
	for i=1:PARAMS.feature_n	
		% Extract, select, reduce operations
		% Generate a feature map with the extracted template
		feature = extractor_feature(sample_data);
		fmap.weights{1} = extractor_fmap(feature.weights);
		
		% Update sample_data alpha masks based on the fmap_collection
		[fmap_collection sample_data] = extractor_update(...
				fmap_collection, sample_data, fmap);
	end

end

