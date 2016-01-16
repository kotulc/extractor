% extractor_main.m
% Clayton Kotulak
% 1/7/2015

%{ 
MNIST data files may be downloaded here:
http://yann.lecun.com/exdb/mnist/train-labels-idx1-ubyte.gz
http://yann.lecun.com/exdb/mnist/train-images-idx3-ubyte.gz
http://yann.lecun.com/exdb/mnist/t10k-labels-idx1-ubyte.gz
http://yann.lecun.com/exdb/mnist/t10k-images-idx3-ubyte.gz

The driver function for the convolutional neural network feature extractor.
PARAMS is a global variable is used to simplify function calls. See
extractor_params.m file for details concerning the definition of this 
constants struct.
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
	% Normalize the training data set to the range of [0,1]
	% image_data = extractor_normalize(image_data);
  
	% Split the data into two classes, target and null (all remaining) class
	train_data.null_data = image_data(image_labels!=PARAMS.target_label, :);
	train_data.target_data = image_data(image_labels==PARAMS.target_label, :);
	% The alpha mask modifies the influence each instance has on the opt. cost
	% to shape the properties of each successive feature map. Add the alpha 
	% mask (one row for each instance)for each data class
	train_data.null_mask = ones(size(train_data.null_data, 1), 1);
	train_data.target_mask = ones(size(train_data.target_data, 1), 1);
	disp("Training data loaded.\n");
	
	% Uncomment below to display a subset of the MNIST data
	%displayMNISTinstance(images, labels);
	
	% initialize the feature map and solutions collections
	fmap_collection.null_fmaps = [];
	fmap_collection.null_fitness = [];
	fmap_collection.target_fmaps = [];
	fmap_collection.target_fitness = [];
	solutions = {};
	
	% Build solutions
	% Perform solution_n sample processing operations, with each pass adding
	% max_fmaps new features to the feature map collection 
	disp("Sampling training data:");
	for i=1:PARAMS.solution_n
		printf("Processing sample %d of %d...\n\n", i, PARAMS.max_fmaps);
		% Pass sample_n random 'training' instances to each sample operation
		% Half of the data set should be from each class
		[sample_data val_data] = extractor_subset(train_data, PARAMS.sample_n);
		[solution fmap_collection] = extractor_sample(...
		        fmap_collection, sample_data);
	
		% Evaluate against validation data and Add solution to collector
		extractor_evaluate({solution}, val_data);
		solutions{end + 1} = solution;
	end	
	disp("Sampling completed.\n");
	
	% Solve, Add solution (optional debug step)
	% Evaluate all solutions contained within the collection on train data
	extractor_evaluate(solutions, train_data);
	
	solution_final = []
	for i=1:PARAMS.max_fmaps
		% Perform a final encode operation with the sample space of val_data
		solution_final = extractor_encode(...
				solution_final, fmap_collection, val_data);
	end
	% Evaluate the performance of this solution on all train data as well
	[error_data train_actvs] = extractor_evaluate({solution_final}, train_data);
	
	% Evaluate with the test data set
	disp("Loading test data...");
	image_data = loadMNISTImages('t10k-images.idx3-ubyte')';
	image_labels = loadMNISTLabels('t10k-labels.idx1-ubyte');
	test_data.null_data = image_data(image_labels!=PARAMS.target_label, :);
	test_data.target_data = image_data(image_labels==PARAMS.target_label, :);
	test_data.null_mask = ones(size(test_data.null_data, 1), 1);
	test_data.target_mask = ones(size(test_data.target_data, 1), 1);
	disp("Test data loaded.\n");
	
	% Check generalization performance
	[error_data test_actvs] = extractor_evaluate({solution_final}, test_data);
	
	keyboard();
	% Provide the option to save the newly generated network data
	q_string = "Would you like to overwrite the data in ";
	q_string = strcat(q_string, "fmap_weights.m and features.m? (y/n): ");
	answer = input(q_string, "s");
  
	% Save feature maps and activations for later use
	if strcmp(answer, "y") || strcmp(answer, "Y"),
		% Format the layer output for tensor flow test script
		train_features = [train_actvs.null_data; train_actvs.target_data];
		train_labels = [zeros(size(train_data.null_data, 1), 1);...
				ones(size(train_data.target_data, 1), 1)];
		test_features = [test_actvs.null_data; test_actvs.target_data];
		test_labels = [zeros(size(test_data.null_data, 1), 1);...
				ones(size(test_data.target_data, 1), 1)];
		
		% Save weights from layer encoding
		save("-6","fmap_weights.m","solution_final"); 
		% Save net activations and labels
		%save("-6","features.m","train_features","train_labels",...
        %    "test_features","test_labels"); % Work on this next
		disp("\nWeights and features saved.\n");
	else
		disp("\nWeights and features discarded.\n");
	end
	
end

