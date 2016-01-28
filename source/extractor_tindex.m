% extractor_tindex.m
% Clayton Kotulak
% 6/2/15

%{ 
Generate a matrix of index pairs (n x 2 matrix) for the starting and 
stopping positions respectively for a tile with the dimensions, stride, etc., 
defined in extractor_params.

Arguments: length value
Returns: index vector
%}
function tile_indices = extractor_tindex(mask_length)
	
	global PARAMS;
	
	tile_indices = [];
	tile_edge = PARAMS.tile_edge;
	stride_dim = PARAMS.stride_dim;
	feature_dim = PARAMS.feature_dim;
	receptive_dim = PARAMS.receptive_dim;
	
	progress = -1;
	
	% Check the stride_percent parameter to ensure that it is within bounds 
	if (stride_dim(1) < 1 || stride_dim(2) < 1)
		disp("extractor_tindex error: invalid stride_dim parameter.");
		return;
	end
	if (receptive_dim(1) > feature_dim(1) || receptive_dim(2) > feature_dim(2))
		disp("extractor_tindex error: tile dimensions > instance dimensions.");
		return;
	end
	if ((tile_edge != 0) && (tile_edge != 1))
		disp("extractor_tindex error: invalid tile_edge parameter.");
		return;
	end
	
	% The number of partial tile iterations in each dimension
	steps = ((feature_dim - receptive_dim) ./ stride_dim);
	% The number of complete tile iterations in each dimension
	full_steps = floor(steps);
	% The number of elements remaining at each edge of the instance after 
	% tiling
	edge_gap = (steps - full_steps) .* stride_dim;
	% Boolean flag identifying an unfilled space between the last tile and 
	% instance boundary
	tile_edge = (edge_gap > 0) .* tile_edge;
	% Calculate the total number of tiles in each dimension, not including 
	% edge tiles
	tiles = 1 .+ full_steps;
	
	row_length = feature_dim(2);
	
	if (PARAMS.db_display)
		disp("Calculating tile bounds...");
	end
	
	% Iterate through all tile positions
	for i=0:(tiles(1) - 1)
	
		% Iterate through each column of tiles
		for j=0:(tiles(2) - 1)
			
			start_idx = 1 + i*row_length*stride_dim(1) + j*stride_dim(2);
			end_idx = start_idx + mask_length - 1;
			tile_indices = [tile_indices; start_idx end_idx];
		end
		% Reached last column of this row.
		% If there is a gap at the instance col edge...
		if (tile_edge(2))
			% The gap between the row of the last tile and the row boundary 
			% of the instance 
			start_idx = 1 + i*row_length*stride_dim(1) +...
					(feature_dim(2)-receptive_dim(2));
			end_idx = start_idx + mask_length - 1;
			% This tile is offset in order to stay in bounds
			tile_indices = [tile_indices; start_idx end_idx];
		end
		
	end
	
	% Reached last row of the matrix
	% If there is a gap at the instance row edge...
	if (tile_edge(1))
		
		% Account for the 
		row_offset = 1 + (feature_dim(1) - receptive_dim(1))*row_length;	
		for i=0:(tiles(2) - 1)
		
			% Calculate the starting index of this row of tiles
			start_idx = row_offset + i*stride_dim(2);
			end_idx = start_idx + mask_length - 1;
			tile_indices = [tile_indices; start_idx end_idx];
			
		end
		% If there is a gap at the instance col edge...
		if (tile_edge(2))
			% Adjust the starting and ending indices to fall within bounds
			end_idx = feature_dim(1)*feature_dim(2);
			tile_indices = [tile_indices; end_idx-mask_length+1 end_idx];
		end
			
	end
	
	if (PARAMS.db_display)
		disp("Tile bounds generated.");
	end
	
end
