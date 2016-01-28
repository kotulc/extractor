% extractor_main.m
% Clayton Kotulak
% 1/27/2015

%{ 
Driver function for extractor v1.1

MNIST data files may be downloaded here:
http://yann.lecun.com/exdb/mnist/train-labels-idx1-ubyte.gz
http://yann.lecun.com/exdb/mnist/train-images-idx3-ubyte.gz
http://yann.lecun.com/exdb/mnist/t10k-labels-idx1-ubyte.gz
http://yann.lecun.com/exdb/mnist/t10k-images-idx3-ubyte.gz

The driver function for the convolutional neural network feature extractor.
PARAMS is a global variable used to simplify function calls. See
extractor_params.m file for details concerning parameter definitions.
%}
function extractor_main()

	global PARAMS;

	PARAMS = load('extractor_params.m');
	warning ('off', 'Octave:broadcast'); 
  
	disp("Loading training data...");
	% Load and process the training data
	image_data = loadMNISTImages('train-images.idx3-ubyte')';
	image_labels = loadMNISTLabels('train-labels.idx1-ubyte');
	
	% Not necessary for this data, already normalized.
	% image_data = extractor_normalize(image_data);
  
	% Split the data into two classes, target and null (all remaining) class
	train_data.null_data = image_data(image_labels!=PARAMS.target_label, :);
	train_data.target_data = image_data(image_labels==PARAMS.target_label, :);
	train_data.null_mask = ones(size(train_data.null_data, 1), 1);
	train_data.target_mask = ones(size(train_data.target_data, 1), 1);
	disp("Training data loaded.\n");
	
	
	disp("Loading test data...");
	image_data = loadMNISTImages('t10k-images.idx3-ubyte')';
	image_labels = loadMNISTLabels('t10k-labels.idx1-ubyte');
	
	test_data.null_data = image_data(image_labels!=PARAMS.target_label, :);
	test_data.target_data = image_data(image_labels==PARAMS.target_label, :);
	
	% Add the required masks and check generalization performance
	test_data.null_mask = ones(size(test_data.null_data, 1), 1);
	test_data.target_mask = ones(size(test_data.target_data, 1), 1);
	disp("Test data loaded.\n");
	
	% Uncomment below to display a subset of the MNIST data
	%displayMNISTinstance(images, labels);
	
	% Load saved features
	fmap_collection = extractor_load(PARAMS.fmap_data_file);
	
	
	% Pass sample_n random 'training' instances to each sample operation
	% Half of the data set should be from each class
	[sample_data val_data] = extractor_subset(train_data, PARAMS.sample_n);
	[solution fmap_collection] = extractor_solve(fmap_collection, sample_data);
	
	% Save or append the fmap data to the data file if it exists
	save("-6", PARAMS.fmap_data_file, "-struct",...
			"fmap_collection", "null_fmaps", "target_fmaps");
	
	
	% Add the required masks and then evaluate against validation data
	val_data.null_mask = ones(size(val_data.null_data, 1), 1);
	val_data.target_mask = ones(size(val_data.target_data, 1), 1);
	fprintf("\nValidation data:");
	extractor_evaluate(solution, val_data);
	
	% Solve, Add solution (optional debug step)
	% Evaluate all solutions contained within the collection on train data
	fprintf("\nTrain data:");
	[train_error train_actvs] = extractor_evaluate(solution, train_data);
	
	% Evaluate with the test data set
	fprintf("\nTest data:");
	[test_error test_actvs] = extractor_evaluate(solution, test_data);
	
	
	% Provide the option to overwrite existing data with the recently generated
	% network data
	q_string = cstrcat("\n\nWould you like to overwrite the data in  ",...
			PARAMS.solution_data_file, " and ",...
			PARAMS.feature_data_file, "? (y/n): ");
	answer = input(q_string, "s");
  
	% Save feature maps and activations for later use
	if (strcmp(answer, "y") || strcmp(answer, "Y"))
		% Format the layer output for tensor flow test script
		train_features = [train_actvs.null_actvs; train_actvs.target_actvs];
		train_labels = [zeros(size(train_actvs.null_actvs, 1), 1);...
				ones(size(train_actvs.target_actvs, 1), 1)];
				
		test_features = [test_actvs.null_actvs; test_actvs.target_actvs];
		test_labels = [zeros(size(test_actvs.null_actvs, 1), 1);...
				ones(size(test_actvs.target_actvs, 1), 1)];
		
		% Save weights from layer encoding
		save("-6", PARAMS.solution_data_file, "solution");
		
		% Save net activations and corresponding labels
		save("-6", PARAMS.feature_data_file, "train_features",....
				"train_labels", "test_features", "test_labels");
				
		disp("\nWeights and features have been saved.\n");
	else
		disp("\nWeights and features have been discarded.\n");
	end
	
end

