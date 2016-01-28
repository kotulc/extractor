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
            size(data_set.null_data, 1), size(data_set.target_data, 1)]);
	
	% Shuffle the rows in the data_set by generating a new random ordering
	rand_vals = rand(size(data_set.null_data, 1), 1);
	[vals idx] = sort(rand_vals);
  
	% Assign the first subset_n elements of the null permutation to the subset
	% and the remaining elements to the difference set
	null_perm = data_set.null_data(idx, :);
	subset_data.null_data = null_perm(1:subset_n, :);
	% Assign remaining elements of null_perm to diff_data
	diff_data.null_data = null_perm(subset_n+1:end, :);
  
	% Assume if the data_set contains null_imask it also has null_emask
	if isfield(data_set, "null_imask")
		% The data set has inhibitory and excitatory masks, assign and 
		% partition each accordingly
		null_perm = data_set.null_imask(idx, :);
		subset_data.null_imask = null_perm(1:subset_n, :);
		null_perm = data_set.null_emask(idx, :);
		subset_data.null_emask = null_perm(1:subset_n, :);
	end

	
	% Repeat the process on the target class data
	rand_vals = rand(size(data_set.target_data, 1), 1);
	[vals idx] = sort(rand_vals);

	target_perm = data_set.target_data(idx, :);
	subset_data.target_data = target_perm(1:subset_n, :);
	diff_data.target_data = target_perm(subset_n+1:end, :);
	
	if isfield(data_set, "target_imask") 
		target_perm = data_set.target_imask(idx, :);
		subset_data.target_imask = target_perm(1:subset_n, :);
		target_perm = data_set.target_emask(idx, :);
		subset_data.target_emask = target_perm(1:subset_n, :);
	end
	
end

