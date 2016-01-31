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
	
	% Load saved data and features
	[train_data val_data fmap_collection] = extractor_load();
	
	% Uncomment below to display a subset of the MNIST data
	%displayMNISTinstance(images, labels);
	
	
	% Pass sample_n random 'training' instances to the solve operation
	% Half of the sample data set should be from each class (target and null)
	[sample_data diff_data] = extractor_subset(train_data, PARAMS.sample_n);
	[solution fmap_collection] = extractor_solve(fmap_collection, sample_data);
	
	% Save or append the fmap data to the data file if it exists
	save("-6", PARAMS.fmap_data_file, "-struct",...
			"fmap_collection", "null_fmaps", "target_fmaps");
	
	
	% Solve, Add solution (optional debug step)
	% Evaluate all solutions contained within the collection on train data
	keyboard();
	fprintf("\n\nTrain data:");
	extractor_evaluate(solution, train_data);
	
	% Add the required masks and then evaluate against validation data
	fprintf("\n\nValidation data:");
	extractor_evaluate(solution, val_data);
	
	
	disp("Extraction complete.\n");
	
	% Provide the option to overwrite existing layer data with the recently 
	% generated layer solution data
	q_string = cstrcat("\n\nWould you like to overwrite the data in ",...
			PARAMS.solution_data_file, "? (y/n): ");
	answer = input(q_string, "s");
  
	% Save feature maps and activations for later use
	if (strcmp(answer, "y") || strcmp(answer, "Y"))
		% Save weights from layer encoding
		save("-6", PARAMS.solution_data_file, "solution");
				
		disp("Solution weight values saved.\n");
	else
		disp("Solution weight values discarded.\n");
	end
	
end

