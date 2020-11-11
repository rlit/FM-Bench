function PT_Matching(wkdir, dataset, matcher, score_th, plot_gt)
% Matching descriptors and save results
dataset_dir = [wkdir 'Dataset/' dataset '/'];
feature_dir = [wkdir 'Features/' dataset '/'];
pt_dir = [wkdir 'PT_Matches/' dataset '/'];

matches_dir = [wkdir 'Matches/' dataset '/'];
if exist(matches_dir, 'dir') == 0
    mkdir(matches_dir);
end

pairs_gts = dlmread([dataset_dir 'pairs_with_gt.txt']);
pairs_which_dataset = importdata([dataset_dir 'pairs_which_dataset.txt']);

%% GT data
if plot_gt
    F_gts = pairs_gts(:,3:11);
    threshold = 0.003;
    
    fig1 = figure(11);
%     fig2 = figure(12);
%     hold on
    ax = cla(fig1);
end
%%


pairs = pairs_gts(:,1:2);
l_pairs = pairs(:,1);
r_pairs = pairs(:,2);

num_pairs = size(pairs,1);
Matches = cell(num_pairs, 1);
for idx = progress(1 : num_pairs, 'Title', 'Converting matches') 
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
    
    pt_matchs = load([pt_dir sprintf('%.4d.mat', idx)]);
    
    %%
    if length(pt_matchs.labels_l) < length(pt_matchs.labels_r)
        num_matches = length(pt_matchs.labels_l);
        matches = uint32([pt_matchs.labels_l ; 1:num_matches]');
        scores = 1-pt_matchs.probas_l';
    else
        num_matches = length(pt_matchs.labels_r);
        matches = uint32([1:num_matches ; pt_matchs.labels_r]');
        scores = 1-pt_matchs.probas_r';
    end
    
    X_l = keypoints_l(matches(:,1),1:2);
    X_r = keypoints_r(matches(:,2),1:2);

    if plot_gt
        F_gt = reshape(F_gts(idx,:), 3, 3)';
        
        % two epipolar lines
        epiLines_r = epipolarLine(F_gt , X_l);
        epiLines_l = epipolarLine(F_gt', X_r);

        % distances in two images
        d_l = d_from_point_to_line(X_l, epiLines_l);
        d_r = d_from_point_to_line(X_r, epiLines_r);
        err = max(d_l, d_r);

        clf(fig1);hold on;
        scatter(scores, err, 'r*')
%         scatter(scores, d_r, 'ro')
%         scatter(scores, d_l, 'kx')
        xlabel('scores');ylabel('errors');
        
        t_l = norm(size_l) * threshold;
        t_r = norm(size_r) * threshold;

        mask = (d_r < t_l & d_r < t_r);
        A = string([sum(mask), sum(mask & scores<score_th) ;
            sum(mask) / length(mask) ,sum(mask & scores<score_th) / sum(scores<score_th)]);
        title(A)
%         before = sum(mask) / length(mask);
%         after = sum(mask & inliers) / sum(inliers);

    end
    
    mask = scores < score_th;
    X_l = X_l(mask,:);
    X_r = X_r(mask,:);
    
    %%

    
    Matches{idx}.size_l = size_l;
    Matches{idx}.size_r = size_r;
    
    Matches{idx}.X_l = X_l;
    Matches{idx}.X_r = X_r;

    Matches{idx}.score = scores;

end

matches_file = [matches_dir matcher '.mat'];
save(matches_file, 'Matches');
end


function distance = d_from_point_to_line(points, lines)
    points(:,3) = 1;
    distance = abs(sum(lines.* points, 2)) ./ (sqrt(sum(lines(:,1:2).^2,2)) + 1e-10);
end