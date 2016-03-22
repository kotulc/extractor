% extractor_main.m
% Clayton Kotulak
% 3/16/2015

%{ 
Driver function for extractor v1.2

MNIST data files may be downloaded here:
http://yann.lecun.com/exdb/mnist/train-labels-idx1-ubyte.gz
http://yann.lecun.com/exdb/mnist/train-images-idx3-ubyte.gz
http://yann.lecun.com/exdb/mnist/t10k-labels-idx1-ubyte.gz
http://yann.lecun.com/exdb/mnist/t10k-images-idx3-ubyte.gz

The driver function for the convolutional neural network feature extractor.
PARAMS is a global variable used to simplify function calls. See
extractor_params.m file for details concerning parameter definitions.
%}
function extractor_main(encode=0)

	global PARAMS;
	
	PARAMS = load('extractor_params.m');
	warning ('off', 'Octave:broadcast'); 
	
	% Load saved data and features
	[train_data val_data fmap_collection] = extractor_load();
	
	% Uncomment below to display a subset of the MNIST data
	%displayMNISTinstance(images, labels);
	
	if (encode==0)	
		% Pass sample_n random 'training' instances to the extract operation
		% Half of the sample data set should be from each class 
		sample_data = extractor_subset(train_data, PARAMS.sample_n);
	
		% Expand the feature map collection
		fmap_collection = extractor_extract(fmap_collection, sample_data);
		fmap_collection = extractor_extract(fmap_collection, sample_data, 1);			
		
		% Save the expanded feature map collection data 
		save("-v6", "-z", PARAMS.feature_data_file,...
				"-struct", "fmap_collection", "weights");
		disp("Extraction complete.\n");
	else
		% Encode a solution using the feature map collection
		solution = extractor_encode(fmap_collection, train_data);
		
		% Evaluate all solutions contained within the collection on train data
		fprintf("\n\nTrain data:");
		[input_w layer_w] = extractor_evaluate(solution, train_data);
		
		% Add the required masks and then evaluate against validation data
		fprintf("\n\nValidation data:");
		extractor_evaluate(solution, val_data, input_w, layer_w);
		
		disp("Encoding complete.\n");
		
		% Provide the option to overwrite existing layer data with the recently 
		% generated layer solution data
		q_string = cstrcat("\n\nWould you like to overwrite the data in ",...
				PARAMS.solution_data_file, "? (y/n): ");
		answer = input(q_string, "s");
	  
		% Save feature maps and activations for later use
		if (strcmp(answer, "y") || strcmp(answer, "Y"))
			% Save weights from layer encoding
			save("-v6", "-z", PARAMS.solution_data_file, "solution");
					
			disp("Solution weight values saved.\n");
		else
			disp("Solution weight values discarded.\n");
		end	
	end
	
end

