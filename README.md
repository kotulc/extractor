# extractor
An Octave based feature extractor and encoder

Version 1.0

The Extractor project has been developed as a platform for exploration of supervised feature extraction as it relates to Artificial Neural Networks. The primary goal of this project is to extract useful features from a subset of the training data and then encode these feature into a Convolutional Neural Network layer. 

In order to determing the efficacy of the employed encoding, the output of this project (a ANN layer) may be directly compared to the performance of a traditionally trained layer of similar size against a benchmark data set such as MNIST. For this functionality see the EvalNets project at https://github.com/kotulc/evalnets

For more detail concerning this project, please take a look at the documentation.

Pending updates: pending updates will be included in V1.1.
- Remove several unnecessary iterative steps, returning only a single solution for now
- Collect all features in one step, reformat encode function.
- Update fitness function and add functionality currently included in update
- Update encode to add most fit feature from either target or null collection

Priority updates:
- Update documentation to reflect above structural changes
- Continue to simplify structure until performance issues are resolved. 

The current version is under performing when compared to previous versions, (before initial project commit) though previous iterations were much slower as they evaluated feature bias through node generation. The above changes will hopefully eliminate unnecessary complexty and improve the performance of the encoded layer.
