# Created by kotulc
# name: dataFile
# type: string
# elements: 1
# length: 13
trainData.mat


%{ 
The class label targeted for training against all other numeric classes.

An integer value in the range [0,class_label_n-1]
See extractor_main
%}
# name: target_label
# type: scalar
0


%{ 
The number of sample passes to attempt and local solutions generated. Each 
sample operation returns it's extracted feature maps which are pooled in the
fmap_collection and passed to the next sample operation.

An integer value in the range [1,inf)
See extractor_main 
%}
# name: solution_n
# type: scalar
2


%{ 
The number of training instances randomly selected from *EACH* class for each 
sample operation. The set of sample instances is constructed with equal parts
from each class and therefore the number of sample instances is sample_n*2.
The remaining set of training instances will be used for validation purposes.

An integer value in the range [1,m*2) where m = number of training instances 
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
See extractor_sample
%}
# name: max_fmaps
# type: scalar
6


%{ 
The size of the random subset of the sample_n target and null instances used
to extract and evaluate candidate features per selected template (template_n). 
This value indicates the number of instances included from *EACH* class.

An integer value in the range [1,sample_n]
See extractor_sample
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
50


%{ 
The number of candidate feature templates extracted, evaluated and reduced. 
The templates are used to generate each feature map. A total of 
template_n*m candidate templates are processed in each extract operation,
where m is the number of tiles per feature map. This should be much lower then
subset_n. Note: The total number of templates processed is 
solution_n*max_fmaps*template_n*m

An integer value in the range [1,subset_n]
See extractor_extract
%}
# name: template_n
# type: scalar
20


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
The minimum (squared) instance activation sum that needs to be reached before 
a new opposing classification component can be generated.

A float value in the range [0,inf)
See extractor_extract
%}
# name: actv_threshold
# type: scalar
0.25


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
1
