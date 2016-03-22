% extractor_nodes.m
% Clayton Kotulak
% 12/22/2015

%{ 
Generate a set of nodes with the goal of exciting instances contained in
excite_data and inhibiting those in inhibit_data. Use cross-entropy optimization.

Arguments: data struct, batch int
Returns: nodes struct
%}
function nodes = extractor_nodes(train_data, batch_size=0)
	
	global PARAMS;
	
	if (PARAMS.db_display)
		fprintf("Generating node(s)...\n");
	end
	
	% Join the influence vectors to create the learning influence mask	
	if (isfield(train_data, "inhibit_mask") &&...
			isfield(train_data, "excite_mask"))
		inhibit_alpha = train_data.inhibit_mask ./ sum(train_data.inhibit_mask);
		excite_alpha = train_data.excite_mask ./ sum(train_data.excite_mask);
	else
		% If the dataset does not contain masks, initialize them
		inhibit_alpha = ones(size(train_data.inhibit_data, 1), 1);
		inhibit_alpha = inhibit_alpha ./ sum(inhibit_alpha);
		excite_alpha = ones(size(train_data.excite_data, 1), 1);
		excite_alpha = excite_alpha ./ sum(excite_alpha);
	end
	
	inhibit_n = size(train_data.inhibit_data, 1);
	node_n = size(excite_alpha, 2);
	
	if (batch_size>0 && node_n>1)
		% Calculate the number of batches required
		batch_n = ceil(node_n/batch_size);
		
		% Initialize the label vector and weight matrix
		y = zeros(inhibit_n, 1);
		weights = [];
		 
		% Batch process batch_size nodes per iteration
		for i=1:batch_n
			% Calculate the number of nodes to process in each batch
			node_idx = (i-1)*batch_size + 1;
			batch_nodes = min([batch_size node_n-node_idx+1]); % IS THIS RIGHT?
			
			% Expand the inhibitory alpha mask to match the number of nodes
			ialpha_batch = inhibit_alpha .* ones(1, batch_nodes);
			
			% Select the slice of the excitatory alpha mask and instances 
			% corresponding to the batch of selected nodes
			excite_mask = excite_alpha(:, node_idx:node_idx+batch_nodes-1);
			excite_mask = (sum(excite_mask, 2) > 0);
			excite_instances = train_data.excite_data(excite_mask, :);
			ealpha_batch = excite_alpha(...
					excite_mask, node_idx:node_idx+batch_nodes-1);
			
			% Join the excitatory and inhibitory batch alpha masks
			alpha_batch = [ialpha_batch; ealpha_batch];
			
			% Initialize and optimize the node weights
			x_batch = [train_data.inhibit_data; excite_instances];
			y_batch = [y; ones(size(excite_instances, 1), 1)];
			w_batch = unifrnd(-1, 1, [size(x_batch, 2)+1 size(alpha_batch, 2)]);
			w_batch = extractor_xopt(w_batch, x_batch, y_batch, alpha_batch);
			weights = [weights w_batch];
		end
	else
		if (size(inhibit_alpha, 2) != size(excite_alpha, 2))
			inhibit_alpha = inhibit_alpha(:, 1) .*...
					ones(1, size(excite_alpha, 2));
		end
		alpha_mask = [inhibit_alpha; excite_alpha];
		
		% Join the two data sets for optimization
		x = [train_data.inhibit_data; train_data.excite_data];
		y = [zeros(inhibit_n, 1); ones(size(train_data.excite_data, 1), 1)];
		
		% The returned node is initialized with the calculated weight values
		weights = unifrnd(-1, 1, [size(x, 2)+1 size(alpha_mask, 2)]);
		weights = extractor_xopt(weights, x, y, alpha_mask);
	end
	
	nodes.weights = weights;
	
	if (PARAMS.db_display)
		fprintf("Node(s) generated.\n");
		fflush(stdout);
	end
	
end

