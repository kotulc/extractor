% extractor_fmap.m
% Clayton Kotulak
% 01/22/2015

%{ 
Generate a feature map from the given weight template. The feature map is 
generated according to the original feature dimension, receptive field window,
and stride parameters from extractor_params.

Arguments: weight vector
Returns: weights matrix
%}
function weights = extractor_fmap(weight_template)
	
	global PARAMS;
	
	feature_dim = PARAMS.feature_dim;
	receptive_dim = PARAMS.receptive_dim;
	weights = [];
	
	if (0)
		disp("\nGenerating feature map weights...");
	end
	
	% The length of the template_mask should be equal to the number of all 
	% contiguous row-wise elements between the first and the last member of a
	% tile extracted from the set matrix
	mask_length = (receptive_dim(1) - 1)*feature_dim(2) + receptive_dim(2);
	
	% Generate a binary mask to be used as a template
	template_mask = zeros(mask_length, 1);
	element_id = 1;
	
	template = weight_template(2:end);
	template_idx = 1;
	
	% Assign active (1) elements to the template tile mask row by row
	for i=1:receptive_dim(1)
		template_mask(element_id:(element_id + receptive_dim(2) - 1)) = ...
			template(template_idx:(template_idx + receptive_dim(2) -1));
		element_id = element_id + feature_dim(2);
		template_idx = template_idx + receptive_dim(2);	
	end
	
	% tile_indices is an n x 2 matrix of starting and ending indices for all 
	% (n) tile positions in a single feature map 
	tile_indices = extractor_tindex(mask_length);
	
	% Initialize all masks for each tile to zero
	weights = zeros(feature_dim(1)*feature_dim(2), size(tile_indices,1));
	
	% Iterate through all tile positions
	for i=1:size(tile_indices,1)
		weights(tile_indices(i,1):tile_indices(i,2),i) = template_mask;
	end
	
	bias = weight_template(1);
	bias = bias .* ones(1,size(weights,2));
	weights = [bias; weights];
	
	if (0)
		disp("Feature map weights generated.\n");
	end
	
end
