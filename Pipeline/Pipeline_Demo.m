clear; clc; close all;
set(0,'DefaultFigureWindowStyle','docked')
wkdir = '../'; % The root foler of FM-Bench
addpath([wkdir 'vlfeat-0.9.21/toolbox/']);
addpath([wkdir 'MatlabProgressBar/']);
vl_setup;

Datasets = {'TUM', 'KITTI', 'Tanks_and_Temples', 'CPC'};
% Datasets = {'TUM'};

use_hardnet = true;
if use_hardnet
    matcher='HardNet-RT'; %
    desc_suffix = 'HardNet';
else
    matcher='SIFT-RT'; % SIFT with Ratio Test
    desc_suffix = 'descriptors';
end

estimator='RANSAC';
estimator='LMedS';

for s = 1 : length(Datasets)
     dataset = Datasets{s};
    disp(['Data set ' dataset]);

    % An example for DoG detector
    FeatureDetection(wkdir, dataset);

    % An example for SIFT descriptor
    FeatureExtraction(wkdir, dataset);

    % An example for exhaustive nearest neighbor matching with ratio test
    FeatureMatching(wkdir, dataset, matcher, desc_suffix);
    
    % An example for RANSAC based FM estimation
    GeometryEstimation(wkdir, dataset, matcher, estimator);
    
end


