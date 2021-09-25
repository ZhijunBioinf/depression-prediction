function [cvEval_vec, finalFeature] = seqInvolve_rmRedun(train, sortInd, topPercent, kFoldCV, taskType, isDisplay)

% Inputs:
%   train: training set, a matrix where the data in the 1st column is Y and the remainder are X.
%   sortInd: the feature ranking returned by a filter, such as 'mRMR_MIC'.
%   topPercent: percent (if < 1) or the number of top features (if > 1) that should be scanned.
%   kFoldCV: k-fold cross-validation (CV) used for obtaining a evaluation measure under a combination of hyper-parameters in a grid search process.
%   taskType: a character vector indicating the type of learning task, 'classify' or 'regress'.
%   isDisplay: if print program output, 1 do, 0 not.
% Outputs:
%   cvEval_vec: a vector indicating the evaluation measures corresponding to the selected features.
%   finalFeature: indices of optimal feature subset.

tr_Y = train(:,1);
tr_X = train(:,2:end);
x_num = size(tr_X,2);

if nargin < 6
    isDisplay = 0;
end
if topPercent <= 1
    topN = ceil(x_num*topPercent);
else
    topN = topPercent;
end
if isDisplay
    fprintf('Top %d features are initialized\n', topN)
end
sortInd = sortInd(1:topN);

if strcmp(taskType, 'classify')
    best_para = classifier([tr_Y tr_X(:,sortInd(1))], [], 0, kFoldCV, 1, ...
        'libsvm', 'classify', ' -s 0 -t 2 -q ', 0);
elseif strcmp(taskType, 'regress')
    best_para = classifier([tr_Y tr_X(:,sortInd(1))], [], 0, kFoldCV, 1, ...
        'libsvm', 'regress', ' -s 3 -t 2 -q ');
end
cvEval_vec = nan(1,topN);
cvEval_vec(1) = best_para(1);

m = 2;
count = 1;
while count < topN
    if strcmp(taskType, 'classify')
        best_para = classifier([tr_Y tr_X(:,sortInd(1:m))], [], 0, kFoldCV, 1, ...
            'libsvm', 'classify', ' -s 0 -t 2 -q ', 0); % 'best_para = [cv_acc,bestC,bestG]', returned by a grid search for hyper-parameter tuning of a learner (e.g. SVM) in a cross-validation manner.
    elseif strcmp(taskType, 'regress')
        best_para = classifier([tr_Y tr_X(:,sortInd(1:m))], [], 0, kFoldCV, 1, ...
            'libsvm', 'regress', ' -s 3 -t 2 -q '); % 'best_para = [cv_mse,bestC,bestG,bestP]'
    end
    cvEval = best_para(1);
    count = count + 1;
    if isDisplay
        fprintf('count = %d\n', count);
    end
    
    if strcmp(taskType, 'classify')
        if cvEval < cvEval_vec(m-1) % compare Acc or MCC for classification
            sortInd(m) = [];
            continue
        end
        if cvEval == 1
            cvEval_vec(m) = cvEval;
            if isDisplay
                fprintf('TS-%d: cvEval(MCC for classification, MSE for regression) = %g\n', m, cvEval)
            end
            m = m+1;
            break
        end
    elseif strcmp(taskType, 'regress')
        if round(cvEval,6) > round(cvEval_vec(m-1),6) % compare MSE for regression
            sortInd(m) = [];
            continue
        end
    end
    
    cvEval_vec(m) = cvEval;
    if isDisplay
        fprintf('TS-%d: cvEval(MCC for classification, MSE for regression) = %g\n', m, cvEval)
    end
    m = m+1;
end
cvEval_vec(m:end) = [];
finalFeature = sortInd(1:m-1);

