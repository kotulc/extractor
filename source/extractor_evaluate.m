% extractor_evaluate.m
% Clayton Kotulak
% 1/10/2016

%{ 
Generate two output layers, one trained directly on the values of the sample
data, the other trained on the activations of the solution. Display metrics
appropriate to evaluate the accuracy of each.

Arguments: weight matrix, data struct
Returns: error struct
%}
function [error_data actv_data] = extractor_evaluate(solution, sample_data)
	
	% Calculate the layer (solution) activation values and reset the 
	% alpha_mask to its default state
	null_actvs = extractor_fprop({solution}, sample_data.null_data).^2;
	layer_data.null_data = null_actvs;
	layer_data.null_mask = ones(size(null_actvs,1),1) ./...
			sum(size(null_actvs,1));
	
	target_actvs = extractor_fprop(...
			{solution}, sample_data.target_data).^2;
	layer_data.target_data = target_actvs;
	layer_data.target_mask = ones(size(target_actvs,1),1) ./...
			sum(size(target_actvs,1));
	
	% Save and return the activations for the encoded layer
	actv_data.null_actvs = null_actvs;
	actv_data.target_actvs = target_actvs;
	
	
	disp("\nEvaluating layer performance...");
	% Train a node on the original training data
	input_node = extractor_nodes(sample_data);
	
	% Train a node on the activations of the solution layer
	layer_node = extractor_nodes(layer_data);
	
	
	% Calculate the error of both nodes and display results
	null_actvs = extractor_fprop(...
			{input_node.weights}, sample_data.null_data).^2;
	target_actvs = extractor_fprop(...
			{input_node.weights}, sample_data.target_data).^2;
	
	% Create a structure to encapsulate and the error data	
	error_data.null_input = null_actvs;
	error_data.target_input =  1 .- target_actvs;
	
	% Display input error information
	null_input_esum = sum(null_actvs)
	target_input_esum = sum(error_data.target_input)


	null_actvs = extractor_fprop(...
			{layer_node.weights}, layer_data.null_data).^2;
	target_actvs = extractor_fprop(...
			{layer_node.weights}, layer_data.target_data).^2;
	
	error_data.null_layer = null_actvs;
	error_data.target_layer = 1 .- target_actvs;
	
	% Display layer error information
	null_layer_esum = sum(error_data.null_layer)
	target_layer_esum = sum(error_data.target_layer)	
	
end

