% extractor_pool.m
% Clayton Kotulak
% 1/10/2016

%{ 


Arguments: data struct, pool struct , pool struct, node struct, node struct
Returns: data struct, pool struct , pool struct
%}
function [sample_data node_pool tiles] = extractor_pool(...
		sample_data, node_pool, tiles, null_node, target_node)
			
	% Add the new nodes to their respective pools
	node_pool.null_nodes.weights = [node_pool.null_nodes.weights...
			null_node.weights];
	node_pool.null_nodes.fitness = [node_pool.null_nodes.fitness...
			null_node.fitness];
	
	node_pool.target_nodes.weights = [node_pool.target_nodes.weights...
			target_node.weights];
	node_pool.target_nodes.fitness = [node_pool.target_nodes.fitness...
			target_node.fitness];
	
	tiles.null_tiles = [tiles.null_tiles; null_node.tile];
	tiles.target_tiles = [tiles.target_tiles; target_node.tile];
	
	% Calculate activations for the new template nodes
	null_fmap = extractor_fmap(null_node.weights);
	null_iactv = extractor_fprop({null_fmap}, sample_data.target_data).^2;
	null_eactv = extractor_fprop({null_fmap}, sample_data.null_data).^2;
	
	target_fmap = extractor_fmap(target_node.weights);
	target_iactv = extractor_fprop({target_fmap}, sample_data.null_data).^2;
	target_eactv = extractor_fprop({target_fmap}, sample_data.target_data).^2;
	
	% Update pool masks
	sample_data.null_iactvsum =...
			sample_data.null_iactvsum .+ sum(null_iactv, 2);
	sample_data.null_eactvsum =...
			sample_data.null_eactvsum .+ sum(null_eactv, 2);
	
	sample_data.target_iactvsum =...
			sample_data.target_iactvsum .+ sum(target_iactv, 2);
	sample_data.target_eactvsum =...
			sample_data.target_eactvsum .+ sum(target_eactv, 2);
	
	% Update sample data masks. These will be used to focus template extraction
	% on under represented instances and opposing instances with high error
	% null_imask is the activation error for null features (target_data actvs) 
	sample_data.null_imask =...
			extractor_normalize(sample_data.null_iactvsum, 1);
	% null_emask are under represented instances in null_data
	sample_data.null_emask =...
			extractor_normalize(-1 .* sample_data.null_eactvsum, 1);
	
	sample_data.target_imask =...
			extractor_normalize(sample_data.target_iactvsum, 1);
	sample_data.target_emask =...
			extractor_normalize(-1 .* sample_data.target_eactvsum, 1);
	
end

