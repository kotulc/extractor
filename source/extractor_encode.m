% extractor_encode.m
% Clayton Kotulak
% 1/10/2016

%{ 
Update the solution by adding (or "packing") the most fit feature map from
the fmap_collection into the solution (network layer), after each feature 
map selection, update the data masks to reflect the new problem state.

Arguments: fmap struct, data struct
Returns: weight matrix
%}
function solution = extractor_encode(fmap_collection, sample_data)
	
	global PARAMS;

	solution = [];
	
	if (numel(fmap_collection.weights)==0)
		disp("No feature maps in the collection, aborting encode.");
		return;
	end

	% Initialize the sample data masks
	sample_data.inhibit_mask = ones(size(sample_data.inhibit_data, 1), 1);
	sample_data.excite_mask = ones(size(sample_data.excite_data, 1), 1);
	
	% Re-calculate the fitness values for all features
	[fmap_collection sample_data] = extractor_update(...
			fmap_collection, sample_data);
	
	excite_actvsum = zeros(size(sample_data.excite_data, 1), 1);
	inhibit_actvsum = zeros(size(sample_data.inhibit_data, 1), 1);
	
	% Calculate the maximum number of feature maps to add
	encode_steps = min([PARAMS.max_fmaps numel(fmap_collection.fitness)]);
	
	% Append feature maps to the solution collection
	for i=1:encode_steps	
		% Initialize solution matrix by selecting feature map with the greatest
		% absolute fitness value
		[val fmap_idx] = max(abs(fmap_collection.fitness));
		solution = [solution fmap_collection.weights{fmap_idx}]; 
		
		% Update the inhibit and excitatory masks
		fitness_val = fmap_collection.fitness(fmap_idx);
		excite_actvsum = excite_actvsum .+ (fitness_val...
				.* fmap_collection.excite_actvsum(:, fmap_idx));
		inhibit_actvsum = inhibit_actvsum .+ (fitness_val...
				.* fmap_collection.inhibit_actvsum(:, fmap_idx));
				
		sample_data.inhibit_mask = extractor_normalize(inhibit_actvsum, 1);
		sample_data.excite_mask = extractor_normalize(-1.*excite_actvsum, 1);
		
		% Remove the feature map from the collection so it cant be added again
		fmap_collection.weights(fmap_idx) = [];
		fmap_collection.fitness(fmap_idx) = [];
		fmap_collection.inhibit_actvsum(:, fmap_idx) = []; 
		fmap_collection.excite_actvsum(:, fmap_idx) = [];
		
		fprintf("\n\nEncoding layer:");
		extractor_evaluate(solution, sample_data);
		
		% Update the fmap fitness values and masks
		[fmap_collection sample_data] = extractor_update(...
				fmap_collection, sample_data, [], 0);		
	end
	
end

