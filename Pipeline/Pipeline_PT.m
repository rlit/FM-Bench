clear; clc; close all;
set(0,'DefaultFigureWindowStyle','docked')
wkdir = '../'; % The root foler of FM-Bench
addpath([wkdir 'vlfeat-0.9.21/toolbox/']);
addpath([wkdir 'MatlabProgressBar/']);
vl_setup;

Datasets = {'TUM', 'KITTI', 'Tanks_and_Temples', 'CPC'};
Datasets = {'TUM'};

match_methods = {'RT', 'pyRT', 'pyRT+GMS', 'PT'};
match_methods = {'PT'};
% match_methods{end+1} = 'PT+GMS';


for d = {'HardNet','SIFT'}
    desc_name = d{1};
    for e = {'RANSAC', 'LMedS'}
        estimator = e{1};
        for match_method = match_methods
            matcher = [desc_name '-' match_method{1}];
            for s = 1 : length(Datasets)
                dataset = Datasets{s};
%                 disp(['Data set ' dataset]);
                
                % % An example for exhaustive nearest neighbor matching with ratio test
                % FeatureMatching(wkdir, dataset, matcher, desc_suffix);
                
                % An example for RANSAC based FM estimation
                GeometryEstimation(wkdir, dataset, matcher, estimator);
                
            end
        end
    end
end    
