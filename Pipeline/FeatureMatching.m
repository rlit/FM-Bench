function FeatureMatching(wkdir, dataset, matcher)
% Matching descriptors and save results
disp('Matching Features...');

dataset_dir = [wkdir 'Dataset/' dataset '/'];
feature_dir = [wkdir 'Features/' dataset '/'];

matches_dir = [wkdir 'Matches/' dataset '/'];
if exist(matches_dir, 'dir') == 0
    mkdir(matches_dir);
end

pairs_gts = dlmread([dataset_dir 'pairs_with_gt.txt']);
pairs_which_dataset = importdata([dataset_dir 'pairs_which_dataset.txt']);

%% GT data
plot_gt = 1;
if plot_gt
    F_gts = pairs_gts(:,3:11);
    fig = figure(10);
    hold on
    ax = cla(fig);
end
%%

pairs = pairs_gts(:,1:2);
l_pairs = pairs(:,1);
r_pairs = pairs(:,2);

num_pairs = size(pairs,1);
Matches = cell(num_pairs, 1);
for idx = 1 : num_pairs
    l = l_pairs(idx);
    r = r_pairs(idx);
    
    I1 = imread([dataset_dir pairs_which_dataset{idx} 'Images/' sprintf('%.8d.jpg', l)]);
    I2 = imread([dataset_dir pairs_which_dataset{idx} 'Images/' sprintf('%.8d.jpg', r)]);
    
    size_l = size(I1);
    size_l = size_l(1:2);
    size_r = size(I2);
    size_r = size_r(1:2);
    
    path_l = [feature_dir sprintf('%.4d_l', idx)];
    path_r = [feature_dir sprintf('%.4d_r', idx)];
    
    keypoints_l = read_keypoints([path_l '.keypoints']);
    keypoints_r = read_keypoints([path_r '.keypoints']);
    descriptors_l = read_descriptors([path_l '.descriptors']);
    descriptors_r = read_descriptors([path_r '.descriptors']);
    
    if plot_gt
        [X_l, X_r, scores] = match_descriptors(keypoints_l, keypoints_r, descriptors_l, descriptors_r);
        %%
        F_gt = reshape(F_gts(idx,:), 3, 3)';
        
        % two epipolar lines
        epiLines_r = epipolarLine(F_gt , X_l);
        epiLines_l = epipolarLine(F_gt', X_r);

        % distances in two images
        d_l = d_from_point_to_line(X_l, epiLines_l);
        d_r = d_from_point_to_line(X_r, epiLines_r);
        err = max(d_l, d_r);

        clf(fig);hold on;
        scatter(scores, err, 'b*')
%         scatter(scores, d_r, 'ro')
%         scatter(scores, d_l, 'kx')
        xlabel('scores');ylabel('errors');
    else
        [X_l, X_r] = match_descriptors(keypoints_l, keypoints_r, descriptors_l, descriptors_r);
    end
    
    
    Matches{idx}.size_l = size_l;
    Matches{idx}.size_r = size_r;
    
    Matches{idx}.X_l = X_l;
    Matches{idx}.X_r = X_r;
end

matches_file = [matches_dir matcher '.mat'];
save(matches_file, 'Matches');
end

function distance = d_from_point_to_line(points, lines)
    points(:,3) = 1;
    distance = abs(sum(lines.* points, 2)) ./ (sqrt(sum(lines(:,1:2).^2,2)) + 1e-10);
end