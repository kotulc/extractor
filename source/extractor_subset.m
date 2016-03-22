% extractor_subset.m
% Clayton Kotulak
% 1/7/2015

%{ 
Randomly select subset_n instances from data_set. diff_data is the 
difference set, the values remaining in data after removing instances included 
in subset_data.

Arguments: data struct, subset int (optional)
Returns: data struct, data struct
%}
function [subset_data diff_data] = extractor_subset(data_set, subset_n=0)
	
	subset_label = [];
	
	% Check to make sure subset_n is compatible with data set size
	[subset_n idx] = min([subset_n,...
            size(data_set.inhibit_data, 1), size(data_set.excite_data, 1)]);
	
	% Shuffle the rows in the data_set by generating a new random ordering
	rand_vals = rand(size(data_set.inhibit_data, 1), 1);
	[vals idx] = sort(rand_vals);
  
	% Assign the first subset_n elements of the null permutation to the subset
	% and the remaining elements to the difference set
	null_perm = data_set.inhibit_data(idx, :);
	subset_data.inhibit_data = null_perm(1:subset_n, :);
	% Assign remaining elements of null_perm to diff_data
	diff_data.inhibit_data = null_perm(subset_n+1:end, :);

	% If the data structures contains an inhibitory mask, shuffle and select 
	% according to null perm
	if isfield(data_set, "inhibit_mask") 
		% The data set has inhibitory and excitatory masks, assign and 
		% partition each accordingly
		null_perm = data_set.inhibit_mask(idx, :);
		subset_data.inhibit_mask = null_perm(1:subset_n, :);
	end
	
	
	% Repeat the process on the target class data
	rand_vals = rand(size(data_set.excite_data, 1), 1);
	[vals idx] = sort(rand_vals);

	target_perm = data_set.excite_data(idx, :);
	subset_data.excite_data = target_perm(1:subset_n, :);
	diff_data.excite_data = target_perm(subset_n+1:end, :);
	
	% If the data structures contains an excitatory mask, shuffle and select 
	% according to target perm
	if isfield(data_set, "excite_mask")
		% The data set has inhibitory and excitatory masks, assign and 
		% partition each accordingly
		target_perm = data_set.excite_mask(idx, :);
		subset_data.excite_mask = target_perm(1:subset_n, :);
	end

end

