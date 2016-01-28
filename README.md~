# extractor
An Octave based feature extractor and encoder

Version 1.1 (as of 1-27-16 commit)

The Extractor project has been developed as a platform for exploration of supervised feature extraction as it relates to Artificial Neural Networks. The primary goal of this project is to extract useful features from a subset of the training data and then encode these feature into a Convolutional Neural Network layer. 

In order to determine the efficacy of the employed encoding, the output of this project (a ANN layer) may be directly compared to the performance of a traditionally trained layer of similar size against a benchmark data set such as MNIST. For this functionality see the EvalNets project at https://github.com/kotulc/evalnets

This project has been designed iteratively based on my current understanding of the related concepts. If you are interested in this project or would like to contribute please feel free to fork it. I will review well commented and relevant pull requests.

For more detail concerning this project, please take a look at the documentation located in this repository.


1-27-16: Update to v1.1
With this update the entire flow of the project has been refined to reduce unnecessary operations and improve encoding performance. Also, features are now generated for both the target and null classes.

The project now generates a single solution and aggregates the generated feature maps into fmap_data.m. Several new functions have been added and existing functions changed. All of these updates will be added to the documentation shortly. For now a new (overly simplified) flow chart has been created to reflect these changes.


Pending updates: 
- Update documentation to reflect v1.1
- Continue to improve encoding function performance
- Continue to simplify project structure e.g. limit reduction to one or two operations, generate nodes in reduction step instead of template extraction step
- Check all functions for consistency (style and comments)

Note: version 1.1 performance needs to be evaluated and further simplification may be necessary.

version 1.0 is under performing when compared to previous versions, (before initial project commit) though previous iterations were much slower as they evaluated feature bias through node generation. v1.1 changes will hopefully eliminate unnecessary complexity and improve the performance of the encoded layer.
