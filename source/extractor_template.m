% extractor_template.m
% Clayton Kotulak
% 12/14/2015

%{ 
Decompose template_instance and eval_data into receptive field tiles, and 
then attempt to generate a node that maximizes target class activation while 
minimizing null class activation.

Arguments: instance vector, data struct
Returns: node struct, node struct
%}
function [null_node target_node] = extractor_template(...
		null_instance, target_instance, eval_data) 

	global PARAMS;
    
	% Decompose the template instance into tiles
	null_templates = extractor_decompose(null_instance);
	target_templates = extractor_decompose(target_instance);
	
	% Update the format of eval_data by decomposing the instances into tiles
	[null_tiles null_imask null_emask] = extractor_decompose(...
			eval_data.null_data, eval_data.null_imask, eval_data.null_emask);
			
	[target_tiles target_imask target_emask] = extractor_decompose(...
			eval_data.target_data, eval_data.target_imask,...
			eval_data.target_emask);
		
	
	% Scale the values of each tile instance to sum to 1
	null_sum = sum(null_tiles, 2);
	null_norm_tiles = null_tiles ./ (null_sum + (null_sum==0));
	
	target_sum = sum(target_tiles, 2);
	target_norm_tiles = target_tiles ./ (target_sum + (target_sum==0));

	% Calculate the bias of each template tile
	% [m x f] * [f x n] = [m x n]
	null_bias = null_templates * (null_norm_tiles .* null_emask)'; 
	% [m x f] * [f x n] = [m x n]	
	target_bias = null_templates * (target_norm_tiles .* null_imask)';  
	% [m x 1]
	class_bias = sum(null_bias, 2) .- sum(target_bias, 2); 

	% Get the template with the greatest class bias
	[val max_idx] = max(class_bias);
	null_tile = null_templates(max_idx, :);
	
	
	% Repeat for the target templates
	null_bias = target_templates * (null_norm_tiles .* target_imask)'; 
	target_bias = target_templates * (target_norm_tiles .* target_emask)';  
	class_bias = sum(target_bias, 2) .- sum(null_bias, 2); 
	
	[val max_idx] = max(class_bias);
	target_tile = target_templates(max_idx, :);
	
	
	% Update eval_data with the instance tiles to train and evaluate the null node
	eval_data.null_data = target_tiles;
	eval_data.null_mask = null_imask;
	eval_data.target_data = null_tile;
	eval_data.target_mask = 1;	

	% Generate the template node against the training data and get its fitness
	null_node = extractor_nodes(eval_data);
	
	eval_data.target_data = null_tiles;
	eval_data.target_mask = null_emask;	
	
	null_node = extractor_fitness(null_node, eval_data);
	null_node.tile = null_tile;

	
	% Repeat the above steps, this time for the target feature
	eval_data.null_data = null_tiles;
	eval_data.null_mask = target_imask;
	eval_data.target_data = target_tile;
	eval_data.target_mask = 1;
	
	target_node = extractor_nodes(eval_data);
	
	eval_data.target_data = target_tiles;
	eval_data.target_mask = target_emask;
	
	target_node = extractor_fitness(target_node, eval_data);
	target_node.tile = target_tile;
	
end

