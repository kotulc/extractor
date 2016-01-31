% extractor_load.m
% Clayton Kotulak
% 1/27/2015

%{ 
If input data or feature maps have been saved from a previous extraction, load
them into their respective structures, else build and initialize the structures

Returns: train data, val data, test data, fmap struct
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

		train_data.null_data = input_data.train_instances(...
				input_data.train_labels(:, 2)==0, :);
		train_data.target_data = input_data.train_instances(...
				input_data.train_labels(:, 2)==1, :);

		val_data.null_data = input_data.val_instances(...
				input_data.val_labels(:, 2)==0, :);
		val_data.target_data = input_data.val_instances(...
				input_data.val_labels(:, 2)==1, :);
	else
		% Load and partition the raw input data, then save all data
		image_data = loadMNISTImages('train-images.idx3-ubyte')';
		image_labels = loadMNISTLabels('train-labels.idx1-ubyte');
		
		% Not necessary for this data, already normalized.
		% image_data = extractor_normalize(image_data);
	  
		% Split the data into two classes, target and null (all remaining) 
		train_data.null_data = ...
				image_data(image_labels!=PARAMS.target_label, :);
		train_data.target_data = ...
				image_data(image_labels==PARAMS.target_label, :);
		
		% Randomly partition the training set into train and validation sets
		validation_n = ceil( min([size(train_data.null_data, 1)...
				size(train_data.target_data, 1)]) .* PARAMS.validation_percent);
		[train_data val_data] = extractor_subset(train_data, validation_n);

		
		image_data = loadMNISTImages('t10k-images.idx3-ubyte')';
		image_labels = loadMNISTLabels('t10k-labels.idx1-ubyte');
		
		test_data.null_data = ...
				image_data(image_labels!=PARAMS.target_label, :);
		test_data.target_data = ...
				image_data(image_labels==PARAMS.target_label, :);

		train_null_n = size(train_data.null_data, 1);
		train_target_n = size(train_data.target_data, 1);
		val_null_n = size(val_data.null_data, 1);
		val_target_n = size(val_data.target_data, 1);
		test_null_n = size(test_data.null_data, 1);
		test_target_n = size(test_data.target_data, 1);
		
		% Format the train data for export to evalnets tensor flow test scripts
		train_instances = [train_data.null_data; train_data.target_data];
		train_labels = [ones(train_null_n, 1) zeros(train_null_n, 1);...
				zeros(train_target_n, 1) ones(train_target_n, 1)];
				
		val_instances = [val_data.null_data; val_data.target_data];
		val_labels = [ones(val_null_n, 1) zeros(val_null_n, 1);...
				zeros(val_target_n, 1) ones(val_target_n, 1)];
				
		test_instances = [test_data.null_data; test_data.target_data];
		test_labels = [ones(test_null_n, 1) zeros(test_null_n, 1);...
				zeros(test_target_n, 1) ones(test_target_n, 1)];
				
		% Save net partitioned input instances and corresponding labels
		save("-6", PARAMS.input_data_file,...
				"train_instances", "train_labels",...
				"val_instances", "val_labels",...
				"test_instances", "test_labels");
	end
	
	disp("Input data loaded.\n");
	
	
	% initialize the feature map and solutions collections
	fmap_collection.null_fmaps = [];
	fmap_collection.null_fitness = [];
	fmap_collection.null_iactvsum = [];
	fmap_collection.null_eactvsum = [];
	fmap_collection.target_fmaps = [];
	fmap_collection.target_fitness = [];
	fmap_collection.target_iactvsum = [];
	fmap_collection.target_eactvsum = [];
		
	% Load fmap_collection if the file has already been created
	fmap_data_flag = exist(PARAMS.fmap_data_file)==2;
	
	if (fmap_data_flag)
		disp("Loading feature data...");
		fflush(stdout);
		
		fmap_data = load(PARAMS.fmap_data_file);
		fmap_collection.null_fmaps = fmap_data.null_fmaps;
		fmap_collection.target_fmaps = fmap_data.target_fmaps;

		% Fill the feature map fitness attribute arrays
		for i=1:size(fmap_collection.null_fmaps, 2)
			null_fmap = fmap_collection.null_fmaps(i);
			fmap_collection.null_fitness = [...
					fmap_collection.null_fitness null_fmap.fitness];
		end
		
		for i=1:size(fmap_collection.target_fmaps, 2)
			target_fmap = fmap_collection.target_fmaps(i);
			fmap_collection.target_fitness = [...
					fmap_collection.target_fitness target_fmap.fitness];
		end
		disp("Feature data loaded.\n");
	end
	
	fflush(stdout);
	
end

