% extractor_params.m
% Clayton Kotulak
% 1/18/2016


%{ 
The name of the saved feature map data file. If this file does not exist it 
will be created.

A string that forms a valid file name
See extractor_main
%}
# name: fmap_data_file
# type: string
# elements: 1
# length: 11
fmap_data.m


%{ 
The name of the file used to store the solution data. If this file does not 
exist it will be created. If this file already exists, the user will be 
prompted to confirm the overwrite of its contents.

A string that forms a valid file name
See extractor_main
%}
# name: solution_data_file
# type: string
# elements: 1
# length: 15
solution_data.m


%{ 
The name of the file used to store the feature data produced by filtering the
original data through the solution layer. If this file does not exist it will
be created. If this file already exists, the user will be prompted to confirm 
the overwrite of its contents.

A string that forms a valid file name
See extractor_main
%}
# name: feature_data_file
# type: string
# elements: 1
# length: 14
feature_data.m


%{ 
The class label targeted for training against all other numeric classes.

An integer value in the range [0,class_label_n-1]
See extractor_main
%}
# name: target_label
# type: scalar
0


%{ 
The number of training instances randomly selected from *EACH* class for 
feature extraction. The set of sample instances is constructed with equal parts
from each class and therefore the number of sample instances is sample_n*2.
The remaining set of training instances will be used for validation purposes.

An integer value in the range [1,m) where m = number of training instances 
of the label class with the least number of instances
See extractor_main
%}
# name: sample_n
# type: scalar
2000


%{ 
The maximum number of convolutional feature maps utilized for generating the
layer encoding (solution). Up to max_fmaps will be generated per sample pass.

An integer value in the range [1,inf)
See extractor_encode
%}
# name: max_fmaps
# type: scalar
6


%{ 
The number of candidate features extracted and converted to feature maps for 
the target and null classes. 

An integer value in the range [1,inf)
See extractor_solve
%}
# name: feature_n
# type: scalar
6


%{ 
The size of the random subset of the sample_n target and null instances used
to extract and evaluate candidate features per template selection (template_n). 
This value indicates the number of instances included from *EACH* class.
 
An integer value in the range [1,sample_n]
See extractor_solve
%}
# name: subset_n
# type: scalar
200


%{ 
The number of instances randomly selected from the set of 
extraction instances (subset_n instances) for each template extraction 
operation. Selected instances are decomposed into tiles and used to extract and
evaluate the fitness of a set of template tiles.

An integer value in the range [1,subset_n]
See extractor_extract
%}
# name: eval_n
# type: scalar
30


%{ 
The number of candidate feature templates extracted, evaluated and reduced per
feature map generated.

An integer value in the range [1,subset_n]
See extractor_extract
%}
# name: template_n
# type: scalar
5


%{ 
The original dimensions of the features for each training instance.

A 2-element vector with the pattern: [row_n, col_n]
See extractor_main
%}
# name: feature_dim
# type: matrix
# rows: 1
# columns: 2
28 28


%{ 
The feature map receptive field dimensions.

A 2-element vector with the pattern: [row_n, col_n]
See extractor_main
%}
# name: receptive_dim
# type: matrix
# rows: 1
# columns: 2
4 4


%{ 
Note:
a useful equation to calculate the number of tiles per instance:
tile_n = ceil(feature_dim .- receptive_dim .+ 1) /stride_dim.
tile_n+1 if (tile_edge && ((tile_n-1)*stride + tile_dim) < feature_dim)

The stride between the first element of each receptive field.

A 2-element vector with the pattern: [row_n, col_n]
See extractor_tindex
%}
# name: stride_dim
# type: matrix
# rows: 1
# columns: 2
2 2 


%{ 
Additional tiles should be included along the col and row edge if the tiles 
do not fill the dimensions of the feature matrix.

A binary value where 0 indicates the feature is disabled 
See extractor_tindex
%}
# name: tile_edge
# type: scalar
1


%{ 
The term used to scale the influence of the ratio value. This term 
effectively stretches the sigmoid function when rscale_term approaches
zero and compacts it as it approaches infinity. 

A float value in the range (0,inf)
See extractor_fitness
%}
# name: rscale_term
# type: scalar
1.0


%{ 
The weight regularization constant. 

An integer value in the range [0,inf)
See extractor_xopt
%}
# name: lambda
# type: scalar
1


%{ 
The maximum number of iterations for gradient descent optimization used for 
training node weights. Note: This should be a relatively small value [40,80] 
as nodes are trained individually as the layer is "grown."

An integer value in the range [1,inf)
See extractor_xopt
%}
# name: optimization_iter
# type: scalar
40


%{ 
Enable additional terminal debug information.

A binary value where 0 indicates the feature is disabled 
See extractor_encode, extractor_nodes
%}
# name: db_display
# type: scalar
0
