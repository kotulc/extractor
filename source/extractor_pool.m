% extractor_pool.m
% Clayton Kotulak
% 1/10/2016

%{ 
Add a single node, attempting to separate the last pair of tiles contained in 
the tiles structure

Arguments: data struct, pool struct, tile struct
Returns: data struct, pool struct
%}
function node_pool = extractor_pool(node_pool, tiles)
	
	tile_data.inhibit_data = tiles.inhibit_tiles;
	tile_data.inhibit_mask = tiles.inhibit_bias;
	tile_data.excite_data = tiles.excite_tiles;
	tile_data.excite_mask = ones(size(tiles.excite_tiles, 1), 1);
	
	% Generate the template node against the training data and get its fitness
	node_pool = extractor_nodes(tile_data);
	node_pool = extractor_fitness(node_pool, tile_data);
	
end

