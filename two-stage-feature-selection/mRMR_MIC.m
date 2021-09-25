function [fea] = mRMR_MIC(data, K, ncpus)

% Inputs:
%   data: a matrix where the data in the 1st column is Y and the remainder are X.
%   K: the number of top K features that should be returned.
%   ncpus: the number of cpu(s) used for computing feature ranking in parallel.
% Outputs:
%   fea: the ranking of top K features.

Y = data(:,1);
X = data(:,2:end);
x_num = size(X,2);
if nargin < 3
    ncpus = 2; % number of cpus used for parallel computing
end
if nargin < 2
    K = x_num;
end

disp('Calculating MICs between Y and each feature...')
tic
MIC_xy = nan(x_num,1);
for m = 1:x_num
    minestats = mine(X(:,m)', Y');
    MIC_xy(m) = minestats.mic;
end
fprintf('Calculating MICs between Y and each feature: done!! Elapsed time is %gs.\n', toc)

[~, idxs] = sort(-MIC_xy);
fea = nan(1,K);
fea(1) = idxs(1);
% set the maximum K as 5000 (you may change it to a larger number) allowing for efficient feature ranking.
KMAX = min([5000, x_num]);
if K > KMAX
    error('The number of top K features should be less than KMAX')
end
idxleft = idxs(2:KMAX);

MIC_array = zeros(x_num, K-1);
tic
disp('Calculating significance order of features using mRMR-MIC...')
c = parcluster;
c.NumWorkers = ncpus;
p = c.parpool(ncpus);
for sel_num = 1:K-1
    rem_num = length(idxleft);
    
    tmp_xx_vec = nan(rem_num,1);
    parfor n = 1:rem_num
        tmp_X = X;
        tmp_fea = fea;
        left_id = tmp_fea(sel_num);
        minestats = mine(tmp_X(:,left_id)', tmp_X(:,idxleft(n))');
        tmp_xx_vec(n) = minestats.mic;
    end
    MIC_array(idxleft, sel_num) = tmp_xx_vec;
    MIC_xx = mean(MIC_array(idxleft,1:sel_num),2);
    
    [~, maxid] = max(MIC_xy(idxleft) - MIC_xx);
    fea(sel_num+1) = idxleft(maxid);
    idxleft(maxid) = [];
    
    num_cur_fea = sel_num+1;
    fprintf('Top-%d: cur_fea = %d, num_outpool = %d, cost_time = %gs.\n', num_cur_fea, fea(num_cur_fea), length(idxleft), toc)
end
disp('Calculating significance order of features using mRMR-MIC: done!!')
p.delete
% poolobj = gcp('nocreate');
% delete(poolobj);


