% extractor_mask.m
% Clayton Kotulak
% 01/24/2015

%{ 
Generate a binary mask where each active element (1) represents membership
to a tile to be extracted from the flattened matrix. The original dimensions
of the matrix and pattern of the mask are defined in the dimension args.

Arguments: feature dimension vector, tile dimension vector
Returns: mask vector
%}
function template_mask = extractor_mask(feature_dim, tile_dim)
	
	template_mask = [];
	
	% Quit if the tile or set dimensions are not positive
	if (feature_dim(1) <= 0 || feature_dim(2) <= 0 ||...
			tile_dim(1) <= 0 || tile_dim(2) <= 0)
		disp("extractor_mask error: tile or feature dimensions == 0.");
		return;
	end
	if (feature_dim(1) < tile_dim(1) || feature_dim(2) < tile_dim(2))
		disp("extractor_mask error: tile dimensions > set dimensions.");
		return;
	end
	
	% The length of the template_mask should be equal to the number of all 
	% contiguous row-wise elements between the first and the last member of a
	% tile extracted from the set matrix
	template_length = (tile_dim(1) - 1)*feature_dim(2) + tile_dim(2);
	
	% Generate a binary mask to be used as a template
	template_mask = zeros(1, template_length);
	element_index = 1;
	
	% Assign active (1) elements to the template tile mask row by row
	for i=1:tile_dim(1)
	
		template_mask( element_index:(element_index + tile_dim(2) - 1) ) = 1;
		element_index = element_index + feature_dim(2);
		
	end
	
	% Display the template_mask in a zero matrix of the setMatrix dimensions.
	%setMatrix = zeros(1, feature_dim(1)*feature_dim(2));
	%setMatrix(1:size(template_mask,2)) = template_mask;
	%reshape(setMatrix,feature_dim(2),feature_dim(1))'
	
end

