# depression-prediction
Improving depression prediction using a novel feature selection algorithm coupled with context-aware analysis

## Directory: two-stage-feature-selection
### mRMR_MIC.m
A multivariate filter, namely MIC (Maximal Information Coefficient)-based minimum Redundancy Maximum Relevance (mRMR), to obtain importance ranking of features. <br>

### seqInvolve_rmRedun.m
A wrapper, namely sequential involvement and eliminating redundancy with support vector machine (SIER-SVM), to determine the optimal feature subset. <br>

## Directory: feature-vector-construction
### topicWise_feature_mapping_eachSession.m
A function to construct feature vector for each session using context-aware analysis. <br>

### topicWise_feature_mapping.m
A function invoking the 'topicWise_feature_mapping_eachSession.m' to construct feature vector for all the sessions. <br>

### merge_all_features.m
A function to merge all types of features, including topic presence, audio features, video features, and semantic features. <br>

* the MIC score calculated in mRMR-MIC is returned by the 'mine' function, which is included in the minepy library (version 1.2.4), an open-source library for the Maximal Information-based Nonparametric Exploration.
* The SVM model is implemented by the LIBSVM software package.

## Attention:
The codes released in this repository are free for academic usage. For other purposes, please contact Zhijun Dai (daizhijun@hunau.edu.cn)
