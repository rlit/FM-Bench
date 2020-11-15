function GeometryEstimation(wkdir, dataset, matcher, estimator, th)
% Matching descriptors and save results
disp('Running FM estimation...');

dataset_dir = [wkdir 'Dataset/' dataset '/'];
matches_dir = [wkdir 'Matches/' dataset '/'];

results_dir = [wkdir 'Results/' dataset '/'];
if exist(results_dir, 'dir') == 0
    mkdir(results_dir);
end

results_file = [results_dir matcher '-' estimator  '-TH' num2str(th) '.mat'];
if exist(results_file, 'file') > 0
    disp(['Result file "' results_file '" exists, skipping ' ]);
    return
end

pairs_gts = dlmread([dataset_dir 'pairs_with_gt.txt']);
pairs_which_dataset = importdata([dataset_dir 'pairs_which_dataset.txt']);

pairs = pairs_gts(:,1:2);
l_pairs = pairs(:,1);
r_pairs = pairs(:,2);
F_gts = pairs_gts(:,3:11);

loaded = load([matches_dir matcher '.mat']);
Results = loaded.Matches;
num_pairs = size(pairs,1);

is_failed = false(num_pairs);
for idx = progress(1 : num_pairs, 'Title', 'FM estimation') 
    l = l_pairs(idx);
    r = r_pairs(idx);
    
    Results{idx}.dataset = dataset;
    Results{idx}.subset = pairs_which_dataset{idx};
    Results{idx}.l = l;
    Results{idx}.r = r;
    Results{idx}.F_gt = reshape(F_gts(idx,:), 3, 3)';
    
    scores = Results{idx}.scores;
    X_l = Results{idx}.X_l_(scores > th, :);
    X_r = Results{idx}.X_r_(scores > th, :);
    
    F_hat = [];
    inliers = [];
    status = 3; % 0 stands for good, others are bad estimations.
    
    try
        [F_hat, inliers, status] = estimateFundamentalMatrix(X_l, X_r, ...
            'Method', estimator, ...
            'NumTrials', 2000);
    catch
        is_failed(idx) = true;
%         disp('Estimation Crash');
    end
    
    Results{idx}.F_hat = F_hat;
    Results{idx}.inliers = inliers;
    Results{idx}.status = status;
end

if any(is_failed)
    disp([sum(is_failed) ' pairs failed'])
end

save(results_file, 'Results');

disp('Finished.');
end