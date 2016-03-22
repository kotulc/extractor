% extractor_normalize.m 
% Clayton Kotulak 
% 1/11/2016

%{ 
Normalize the row-vectors of x to be in the range [0,1]. The column 
parameter indicates if the matrix should be normalized  by column-vectors. The
scale parameter indicates if the resulting vectors should be scaled so that 
each has a sum of 1.

Arguments: instance matrix, boolean (opt), boolean (opt)
Returns: normalized matrix
%}
function norm_x = extractor_normalize(x, column=0, scale=0)

	% Normalization 
	% (x.i - min_x) / (max_x - min_x)

	% Default to row-vector normalization
	if (column)
		% Normalize matrix column-vectors
		max_x = max(x);
		min_x = min(x);
	else
		max_x = max(x, [], 2);
		min_x = min(x, [], 2);
	end
	
	range = max_x .- min_x;
	
	% Catch the case where the max and min values are equal 
	norm_x = (x .- min_x) ./ (range + (range==0));
	
	% If all values in a particular row vector are zero resulting from the 
	% above step, make them 1 instead for this implementation
	% norm_x(range==0, :) = 1;
	
	if (scale)
		% Scale each vector to sum to 1
		if (column)
			norm_sum = sum(norm_x);
		else
			norm_sum = sum(norm_x, 2);
		end	
		
		norm_x = norm_x ./ (norm_sum .+ (norm_sum==0));	
	end
	
end