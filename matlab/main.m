%% Example: Run the hybrid VFS pair pipeline (MATLAB + Python)
% This demo compares one *real* and one *fake* video.
% It extracts face crops, computes quality metrics (BRISQUE + deep IQA models),
% and outputs per-frame metric CSVs plus a VFS summary.

% -------------------------------------------------------------------------
% 1. Add the pipeline folder to MATLAB path
% -------------------------------------------------------------------------
addpath('path/to/pair_hybrid_pipeline');  % Folder containing pair_run.m, etc.

% -------------------------------------------------------------------------
% 2. Define input videos
% -------------------------------------------------------------------------
realVideo = 'path/to/real/video/folder/125.mp4';       % Example real video
fakeVideo = 'path/to/fake/video/folder/125_038.mp4';   % Corresponding fake

% -------------------------------------------------------------------------
% 3. Define output directory
% -------------------------------------------------------------------------
outDir = 'path/to/output/folder/results';   % Results will be saved here

% -------------------------------------------------------------------------
% 4. Define Python environment and metric scripts
% -------------------------------------------------------------------------
pythonPath   = 'path/to/anaconda/envs/matlab_env/python';  
pyScriptsDir = 'path/to/python_metrics/folder'; % Folder containing liqe_score.py, maniqa_score.py, etc.

% -------------------------------------------------------------------------
% 5. Select metrics and their execution type
% -------------------------------------------------------------------------
metrics = {'BRISQUE','LIQE','MANIQA','MUSIQ','DBCNN','TRES'};
% For each metric, specify whether it runs in MATLAB or via Python script
functionTypes = {'matlab','python','python','python','python','python'};

% -------------------------------------------------------------------------
% 6. Run the pipeline
% -------------------------------------------------------------------------
pair_run(realVideo, fakeVideo, outDir, pythonPath, pyScriptsDir, metrics, functionTypes);

% -------------------------------------------------------------------------
% Output files
% -------------------------------------------------------------------------
% outDir/
%   ├── real_crops/           % face crops from the real video
%   ├── fake_crops/           % face crops from the fake video
%   ├── real_iqm.csv          % per-frame metric scores (real)
%   ├── fake_iqm.csv          % per-frame metric scores (fake)
%   └── VFS_summary.csv  % VFS comparison for each metric
