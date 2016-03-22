% extractor_decompose.m
% Clayton Kotulak
% 01/16/2015

%{ 
Extract tiles from each instance in the instances matrix according to the 
receptive field window and stride parameters from extractor_params. If passed a 
mask vector, generate a new tile mask that is patterned from the instance mask.

Arguments: instance matrix, mask vector (optional)
Returns: tile matrix, mask vector (empty if no mask is given)
%}
function [tiles tile_mask] = extractor_decompose(instances, mask=[])
	
	global PARAMS;
	
	feature_dim = PARAMS.feature_dim;
	receptive_dim = PARAMS.receptive_dim;
	display = 0;
	
	if (display)
		disp("Decomposing instances to tiles...");
	end
	
	tiles = [];
	tile_mask = [];
	
	if (numel(instances)==0)
		disp("No instances to decompose.")
		return;
	end
	
	% Generate a binary mask to use as a template for tile extraction from
	% 'instances'
	template_mask = extractor_mask(feature_dim, receptive_dim);
	mask_length = size(template_mask,2);
	
	% If there is a dimension mismatch, template_mask is empty, quit
	if (mask_length == 0)
		disp("extractor_decomp error: Invalid template_mask.");
		return;
	end
	
	% Generate a list of the tile indices, where each tile is a row with the
	% format [start_idx end_idx]. size(tile_indices,1) == number of tiles
	tile_indices = extractor_tindex(mask_length);
	
	% Calculate the number of elements resulting from this operation. Assuming 
	% this is octave compiled for 32bit, can't have more than 2e9 elements in 
	% a matrix
	final_matx_n = size(tile_indices,1)*size(instances,1);
	final_elem_n = final_matx_n*receptive_dim(1)*receptive_dim(2);
	if (final_elem_n >= 2e9)
		disp("extractor_decomp error: final matrix size exceeds octave max.");
		return;
	end
	
	% Perform batch processing to extract tiles within memory constraints
	% Calculate the number of elements per receptive field processed
	rfield_elem_n = size(instances,1)*mask_length;
	% Determine how many receptive fields [windows] to process per batch, keep
	% memory utilization well below the limit
	tile_idx_n = floor(2e7/rfield_elem_n);
	batch_n = ceil(size(tile_indices,1)/tile_idx_n);
	%disp("");
	
	for j=0:batch_n-1
		
		start_idx = tile_idx_n*j + 1;
		end_idx = min([(start_idx + tile_idx_n - 1) size(tile_indices,1)]);
		tile_idx_batch = tile_indices(start_idx:end_idx,:);
		
		tile_set = [];
		progress = -1;
		% Iterate through all tile positions, extracting a given tile from all
		% instances in each iteration
		
		for i=1:size(tile_idx_batch,1)

			% Add m instance tiles to tile_set, where m is the number of rows 
			% in 'instances'
			tile_set = [tile_set; instances(:,...
					tile_idx_batch(i,1):tile_idx_batch(i,2))];
			
			% Print iteration progress information 
			if (floor( i*100/size(tile_idx_batch,1) )>progress &&...
					display)
				progress = floor( i*100/size(tile_idx_batch,1) );
				fprintf("Extracted %d tiles, %d%% | Batch: %d\r",...
						i*size(instances,1), progress, j+1);
				fflush(stdout);
			end
			
		end
		
		% Each tile in tile_set extracted from 'instances' contain all 
		% contiguous elements between the tiles starting and ending index.
		% Remove all elements not included in the tile using template_mask 
		trim_col_mask = find(template_mask==0);
		tile_set(:,trim_col_mask) = [];
		tiles = [tiles; tile_set];
	
	end
	
	if numel(mask)>0
		% Expand the instance_mask vector to match each extracted tile
		tile_mask = repmat(mask, size(tile_indices,1), 1);
    end
	
	if (display)
		fprintf("Extracted %d tiles, 100%% | Batch: %d      \n", final_matx_n, j+1);
		disp("Decompose operation complete.\n");
		fflush(stdout);
	end
	
end

