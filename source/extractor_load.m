% extractor_load.m
% Clayton Kotulak
% 1/27/2015

%{ 
If feature maps have been saved from a previous extraction, load them into the
feature map collection, else initialize an empty fmap collection

Arguments: file string
Returns: fmap struct
%}
function fmap_collection = extractor_load(file_name)

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
	fmap_data_flag = exist(file_name)==2;
	if (fmap_data_flag)
		disp("Loading feature data...");
		fflush(stdout);
		
		fmap_data = load(file_name);
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
		fflush(stdout);
	end
	
end

