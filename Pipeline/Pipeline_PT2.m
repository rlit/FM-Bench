clear; clc; close all;
set(0,'DefaultFigureWindowStyle','docked')
wkdir = '../'; % The root foler of FM-Bench
addpath([wkdir 'vlfeat-0.9.21/toolbox/']);
vl_setup;

% Datasets = {'TUM', 'KITTI', 'Tanks_and_Temples', 'CPC'};
Datasets = {'TUM'};

% estimator='RANSAC';
estimator='LMedS';

desc_name = 'HardNet';
match_method = 'PT';

for d = 1.1:0.1:1.9
    matcher = [desc_name '-' match_method '+D' num2str(d)];
    disp(['matcher ' matcher]);

    for th = 0.4:0.1:0.9
%     matcher = [desc_name '-' match_method '+D' num2str(d) '-' estimator  '-TH' num2str(th) '.mat'
        for s = 1 : length(Datasets)
            dataset = Datasets{s};

            % An example for RANSAC based FM estimation
            GeometryEstimation2(wkdir, dataset, matcher, estimator, th);

        end
    end
end    
