% extractor_load.m
% Clayton Kotulak
% 1/27/2015

%{ 
If input data or feature maps have been saved from a previous extraction, load
them into their respective structures, else build and initialize the structures.

Returns: train data, val data, fmap struct
%}
function [train_data val_data fmap_collection] = extractor_load()

	global PARAMS;
	
	% Check to see if the input_data file exists
	input_data_flag = exist(PARAMS.input_data_file)==2;
	disp("Loading input data...");
	fflush(stdout);
	
	if (input_data_flag)
		% Load input data if the file has already been created
		input_data = load(PARAMS.input_data_file);

		train_data.inhibit_data = input_data.train_instances(...
				input_data.train_labels(:, 2)==0, :);
		train_data.excite_data = input_data.train_instances(...
				input_data.train_labels(:, 2)==1, :);

		val_data.inhibit_data = input_data.val_instances(...
				input_data.val_labels(:, 2)==0, :);
		val_data.excite_data = input_data.val_instances(...
				input_data.val_labels(:, 2)==1, :);
	else		
		% Load and partition the raw input data, then save all data
		image_data = loadMNISTImages('train-images.idx3-ubyte')';
		image_labels = loadMNISTLabels('train-labels.idx1-ubyte');
		
		% Not necessary for this data, already normalized.
		% image_data = extractor_normalize(image_data);
	  
		% Split the data into two classes, target and null (all remaining) 
		train_data.inhibit_data = ...
				image_data(image_labels!=PARAMS.target_label, :);
		train_data.excite_data = ...
				image_data(image_labels==PARAMS.target_label, :);
		
		% Randomly partition the training set into train and validation sets
		validation_n = ceil( min([size(train_data.inhibit_data, 1)...
				size(train_data.excite_data, 1)]) .* PARAMS.validation_percent);
				
		[train_data val_data] = extractor_subset(train_data, validation_n);

		
		image_data = loadMNISTImages('t10k-images.idx3-ubyte')';
		image_labels = loadMNISTLabels('t10k-labels.idx1-ubyte');
		
		test_data.inhibit_data = ...
				image_data(image_labels!=PARAMS.target_label, :);
		test_data.excite_data = ...
				image_data(image_labels==PARAMS.target_label, :);

		train_null_n = size(train_data.inhibit_data, 1);
		train_target_n = size(train_data.excite_data, 1);
		val_null_n = size(val_data.inhibit_data, 1);
		val_target_n = size(val_data.excite_data, 1);
		test_null_n = size(test_data.inhibit_data, 1);
		test_target_n = size(test_data.excite_data, 1);
		
		% Format the train data for export to evalnets tensor flow test scripts
		train_instances = [train_data.inhibit_data; train_data.excite_data];
		train_labels = [ones(train_null_n, 1) zeros(train_null_n, 1);...
				zeros(train_target_n, 1) ones(train_target_n, 1)];
				
		val_instances = [val_data.inhibit_data; val_data.excite_data];
		val_labels = [ones(val_null_n, 1) zeros(val_null_n, 1);...
				zeros(val_target_n, 1) ones(val_target_n, 1)];
				
		test_instances = [test_data.inhibit_data; test_data.excite_data];
		test_labels = [ones(test_null_n, 1) zeros(test_null_n, 1);...
				zeros(test_target_n, 1) ones(test_target_n, 1)];
				
		% Save net partitioned input instances and corresponding labels
		save("-v6", "-z", PARAMS.input_data_file,...
				"train_instances", "train_labels",...
				"val_instances", "val_labels",...
				"test_instances", "test_labels");
				
		disp("Raw image and label data partitioned.");
	end
	
	% Initialize the train data masks
	train_data.inhibit_mask = ones(size(train_data.inhibit_data, 1), 1);
	train_data.excite_mask = ones(size(train_data.excite_data, 1), 1);
		
	% Initialize the validation data masks
	val_data.inhibit_mask = ones(size(val_data.inhibit_data, 1), 1);
	val_data.excite_mask = ones(size(val_data.excite_data, 1), 1);
		
	disp("Input data loaded.\n");
	
	% initialize the feature map and solutions collections
	fmap_collection.weights = {};
	fmap_collection.fitness = [];
	fmap_collection.inhibit_actvsum = [];
	fmap_collection.excite_actvsum = [];
		
	% Load fmap_collection if the file has already been created
	feature_data_flag = exist(PARAMS.feature_data_file)==2;
	
	if (feature_data_flag)
		disp("Loading feature data...");
		fflush(stdout);
		
		feature_data = load(PARAMS.feature_data_file);
		fmap_collection.weights = feature_data.weights;
		disp("Feature data loaded.\n");
	end
	
	fflush(stdout);
	
end

