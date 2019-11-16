% This script runs trackers on diverse datasets
% (OTB, UAV123, LaSOT avaliable at present)
% with minimum modification and great scalability,
% generating raw results with the same format as ground truth
% and overall visualization results.
% @YuzheSHI, Computer Science, HUST
% Nov, 2019

close all
clear
clc
warning off all;

data_path = '/media/shi/Staff/Datasets/';
% absolute path to datasets(end with '/')
% error('Please set dataset path and comment this line!');
% comment the line above after you set dataset path

datasets = {
%                     'OTB',...
                    'UAV',...
                    'LaSOT'
                    };
% the datasets to test the tracker, entire datasets by default
% if you want to remove a dataset, comment its line

trackers = {
%             struct('name', 'MOSSE'),...
%             struct('name', 'CSK'),...
            struct('name', 'KCF'),...
%             struct('name', 'DCF'),... 
%             struct('name', 'DSST'),...
%             struct('name', 'SRDCF'),...
%             struct('name', 'SAMF'),...
%             struct('name', 'CCOT'),...
%             struct('name', 'ECO_HC'),...
%             struct('name', 'ECO')
            };
% the trackers to evaluate
% if you want remove a tracker, comment its line

addpath('./OTB');
addpath('./UAV');
addpath('./LaSOT');
% add path of toolkit subfolders

% make execution in parallel pools
for idds = 1:length(datasets)
    ds = datasets{idds};
    switch ds
    case 'OTB'
        evalType = {'OPE', 'SRE', 'TRE'}; 
        % evaluation methodology according to the paper
        cd('./OTB');
        for idotb = 1:length(evalType)
            run_OTB(data_path, evalType{idotb}, trackers);
        end
        perfPlot(data_path, trackers);
        cd('../');
    case 'UAV'
        evalType = {'OPE', 'SRE'}; 
        cd('./UAV');
        % evaluation methodology according to the paper
        for iduav = 1:length(evalType)
            run_UAV(data_path, evalType{iduav}, trackers);
        end
        perfPlot(data_path, trackers);
        cd('../');
    case 'LaSOT'
        cd('./LaSOT');
        run_LaSOT(data_path, trackers);
        % One Pass Evaluation only according to the paper
        cd('../');
    end
end

