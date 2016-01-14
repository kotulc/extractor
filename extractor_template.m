% extractor_template.m
% Clayton Kotulak
% 12/14/2015

%{ 
Decompose template_instance and eval_data into receptive field tiles, and 
then attempt to generate a node that maximizes target class activation while 
minimizing null class activation.

Arguments: instance vector, data struct
Returns: node struct, instance vector
%}
function [template_node template_tile] = extractor_template(...
		template_instance, eval_data) 

	global PARAMS;
    
	% Decompose the template instance into tiles
	candidate_tiles = extractor_decompose(template_instance);
	
	% Update the format of eval_data by decomposing the instances into tiles
	[null_tiles null_mask] = extractor_decompose(...
			eval_data.null_data, eval_data.null_mask);
	[target_tiles target_mask] = extractor_decompose(...
			eval_data.target_data, eval_data.target_mask);
	
	% Update eval_data with the instance tiles
	eval_data.null_data = null_tiles;
	eval_data.null_mask = null_mask;
	eval_data.target_data = target_tiles;
	eval_data.target_mask = target_mask;		
			
	
	% Scale the values of each tile instance to sum to 1
	null_sum = sum(eval_data.null_data, 2);
	null_tiles = eval_data.null_data ./ (null_sum + (null_sum==0));
	target_sum = sum(eval_data.target_data, 2);
	target_tiles = eval_data.target_data ./ (target_sum + (target_sum==0));

	% Calculate the bias of each candidate for either the null or target class
	null_bias = candidate_tiles * null_tiles';   % m x f * f x n = m x n
	target_bias = candidate_tiles * target_tiles';   % m x f * f x n = m x n
	class_bias = sum(target_bias, 2) .- sum(null_bias, 2);   % m x 1

	
	% Get the candidate tile with greatest target bias
	[val max_idx] = max(class_bias);
	template_tile = candidate_tiles(max_idx, :);
	
	% Create training data for the template node
	train_data.null_data = eval_data.null_data;
	train_data.null_mask = eval_data.null_mask;
	train_data.target_data = template_tile;
	train_data.target_mask = 1;
	
	% Generate the template node against the training data and get its fitness
	template_node = extractor_nodes(train_data);
	template_node = extractor_fitness(template_node, eval_data);

end

