% extractor_params.m
% Clayton Kotulak
% 1/18/2016


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
# length: 17
solution_data.dat


%{ 
The name of the file used to store the input data partitioned into training, 
validation and test sets. If this file does not exist it will be created once
the raw MNIST data has been partitioned. If this file exists, the system will 
load input data from this file instead of the default MNIST data files.

A string that forms a valid file name
See extractor_load
%}
# name: input_data_file
# type: string
# elements: 1
# length: 14
input_data.dat


%{ 
The name of the saved feature map data file. If this file does not exist it 
will be created.

A string that forms a valid file name
See extractor_main, extractor_load
%}
# name: feature_data_file
# type: string
# elements: 1
# length: 16
feature_data.dat


%{ 
The fraction of training instances to reserve for validation purposes. Note 
that the number of null and target training instances must be equal, thus the 
size of the validation set is based on min([size(excite_data) size(inhibit_data)])

An float value in the range (0,1)
See extractor_load
%}
# name: validation_percent
# type: scalar
0.50


%{ 
The class label targeted for training against all other numeric classes.

An integer value in the range [0,class_label_n-1]
See extractor_load
%}
# name: target_label
# type: scalar
8


%{ 
The number of training instances randomly selected from *EACH* class for 
feature extraction. The set of sample instances is constructed with equal parts
from each class and therefore the total number of sample instances is 
sample_n*2. The remaining set of training instances will be used for validation.

An integer value in the range [1,m) 
See extractor_main
%}
# name: sample_n
# type: scalar
1000


%{ 
The maximum number of convolutional feature maps utilized for generating the 
layer encoding (solution).

An integer value in the range [1,inf)
See extractor_encode
%}
# name: max_fmaps 
# type: scalar
6


%{ 
The number of candidate features extracted and converted to feature maps for 
both the inhibitory and excitatory classes.  feature_n*2 features extracted.

An integer value in the range [1,inf)
See extractor_extract
%}
# name: feature_n
# type: scalar
3


%{ 
Enable optional reduction step for each feature extraction operation.

A binary value where 0 indicates reduce is disabled 
See extractor_feature
%}
# name: reduce
# type: scalar
0


%{ 
The number of inhibitory instances (subset_n instances) randomly selected to 
train template nodes. Selected instances are decomposed into tiles and used to 
extract and evaluate the fitness of a set of template tiles.

An integer value in the range [1,subset_n]
See extractor_feature
%}
# name: node_eval_n
# type: scalar
30


%{ 
The number of nodes generated per weight optimization batch operation

An integer value in the range [0,inf)
See extractor_feature, extractor_reduce
%}
# name: node_batch_size
# type: scalar
100


%{ 
The number of instances randomly selected from the set of extraction instances 
(subset_n instances) for each template extraction operation. Selected instances
are decomposed into tiles and used to evaluate the fitness of a set of template
tiles.

An integer value in the range [1,subset_n]
See extractor_template
%}
# name: template_eval_n
# type: scalar
80


%{ 
The number of candidate feature template instances decomposed into template
tiles and used to generate each feature node (template_tiles nodes)

An integer value in the range [1,subset_n]
See extractor_template
%}
# name: template_n
# type: scalar
30


%{ 
The number of extracted template tiles (may be less).

A float value in the range (0,inf)
See extractor_template
%}
# name: template_tiles
# type: scalar
200


%{ 
The term used to scale the influence of the ratio value. This term 
effectively stretches the sigmoid function when rscale_term approaches
zero and compacts it as it approaches infinity. 

A float value in the range (0,inf)
See extractor_fitness
%}
# name: rscale_term
# type: scalar
1.00


%{ 
The value used to scale the influence of the excitatory activation term 
(e_term). The influence of e_term increases as escale_term approaches 0.
e_term = escale_term + log(1 + excitatory_actv_sum) 

A float value in the range (0,inf)
See extractor_fitness
%}
# name: escale_term
# type: scalar
0.075


%{ 
The original dimensions of the features for each training instance.

A 2-element vector with the pattern: [row_n, col_n]
See extractor_tindex
%}
# name: feature_dim
# type: matrix
# rows: 1
# columns: 2
28 28


%{ 
The feature map receptive field dimensions.

A 2-element vector with the pattern: [row_n, col_n]
See extractor_tindex
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
1


%{ 
The maximum number of node fitness value to display if debug output is enabled.

An integer value in the range [1,inf)
See extractor_fitness, extractor_feature
%}
# name: db_fitness
# type: scalar
20

