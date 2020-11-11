clear; clc; close all;
set(0,'DefaultFigureWindowStyle','docked')
wkdir = '../'; % The root foler of FM-Bench
addpath([wkdir 'vlfeat-0.9.21/toolbox/']);
vl_setup;

do_plot = 0;

Datasets = {'TUM', 'KITTI', 'Tanks_and_Temples', 'CPC'};
% Datasets = {'KITTI', 'TUM'};

pt_score_th = 0.2;
matcher='SIFT-PT'; % SIFT with Ratio Test
estimator='RANSAC';

for s = 1 : length(Datasets)
    dataset = Datasets{s};
    disp(['Data set ' dataset]);

    % An example for exhaustive nearest neighbor matching with ratio test
    PT_Matching(wkdir, dataset, matcher, pt_score_th, do_plot);
    
    % An example for RANSAC based FM estimation
    GeometryEstimation(wkdir, dataset, matcher, estimator);
    
end


