% extractor_evaluate.m
% Clayton Kotulak
% 1/10/2016

%{ 
Generate two output layers, one trained directly on the values of the sample
data, the other trained on the activations of the solution. Display metrics
appropriate to evaluate the accuracy of each.

Arguments: weight matrix, data struct, weight matrix, weight matrix 
Returns: weight matrix, weight matrix
%}
function [input_w layer_w] = extractor_evaluate(...
		solution, sample_data, input_w=[], layer_w=[])
	
	disp("\nEvaluating layer performance...");
	
	inhibit_mask = ones(size(sample_data.inhibit_mask, 1), 1);
	inhibit_mask = inhibit_mask ./ sum(inhibit_mask);
	excite_mask = ones(size(sample_data.excite_mask, 1), 1);
	excite_mask = excite_mask ./ sum(excite_mask);
	
	alpha_mask = [inhibit_mask; excite_mask];
	y = [zeros(size(inhibit_mask)); ones(size(excite_mask))];
	y = [y ~y]; 
	
	% Calculate the layer (solution) activation values
	inhibit_actvs = extractor_fprop({solution}, sample_data.inhibit_data);
	solution_data.inhibit_data = inhibit_actvs;
	excite_actvs = extractor_fprop({solution}, sample_data.excite_data);
	solution_data.excite_data = excite_actvs;
	
	% Optimize randomly initialized weight values if they have not been passed 
	input_x = [sample_data.inhibit_data; sample_data.excite_data];
	if (numel(input_w)==0)
		input_w = unifrnd(-1, 1, [size(input_x, 2)+1 2]);
		input_w = extractor_xopt(input_w, input_x, y, alpha_mask);
	end
	
	layer_x = [solution_data.inhibit_data; solution_data.excite_data];
	if (numel(layer_w)==0)
		layer_w = unifrnd(-1, 1, [size(layer_x, 2)+1 2]);
		layer_w = extractor_xopt(layer_w, layer_x, y, alpha_mask);
	end
	
	fprintf("Total eval instances: %d\n\n", size(input_x, 1));
	 
	% Calculate the error of both nodes
	input_actvs = extractor_fprop({input_w}, input_x).^2;
	layer_actvs = extractor_fprop({layer_w}, layer_x).^2;
	
	% Calculate the number of incorrect classifications
	error_mask = [2 .* ones(size(inhibit_mask, 1), 1);...
			ones(size(excite_mask, 1), 1)];
	
	% Calculate input activation metrics
	[val max_idx] = max(input_actvs, [], 2);
	input_error_n = sum(abs(error_mask .- max_idx))
	fprintf("Percent error: %d\n", input_error_n/size(input_actvs, 1));
	
	input_inhibit_error = sum(sum(~y .* input_actvs))
	input_excite_error = sum(sum(y  .- (y .* input_actvs)))
	
	input_inhibit_min = min(sum(sample_data.inhibit_data, 2))
	input_excite_min = min(sum(sample_data.excite_data, 2))
	disp("");
	
	% Calculate layer activation metrics 
	[val max_idx] = max(layer_actvs, [], 2); 
	layer_error_n = sum(abs(error_mask .- max_idx))
	fprintf("Percent error: %d\n", layer_error_n/size(layer_actvs, 1));
	
	layer_inhibit_error = sum(sum(~y .* layer_actvs))
	layer_excite_error = sum(sum(y  .- (y .* layer_actvs)))
	
	layer_inhibit_min = min(sum(solution_data.inhibit_data, 2))
	layer_excite_min = min(sum(solution_data.excite_data, 2))
	 
end

