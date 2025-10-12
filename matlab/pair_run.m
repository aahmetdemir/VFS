function pair_run(realVideo, fakeVideo, outDir, pythonPath, pyScriptsDir, metrics, functionTypes)
%% pair_run
% End-to-end pipeline for a single REAL & FAKE video pair:
%   1) Face extraction with Python + dlib
%   2) IQA metrics (MATLAB + Python) -> per-frame CSVs
%   3) VFS method summary (effect-size style comparison) -> CSV

% ----------------------------
% Defaults & checks
% ----------------------------
if ~exist('outDir','var') || isempty(outDir)
    outDir = fullfile(pwd, 'OUT_pair');
end
if ~exist(outDir,'dir'); mkdir(outDir); end

if ~exist('metrics','var') || isempty(metrics)
    metrics = {'BRISQUE','NIQE','PIQE'}; % minimal default
    functionTypes = {'matlab','matlab','matlab'};
end

% ----------------------------
% Step 1) Python + dlib face extraction
% ----------------------------
this = fileparts(mfilename('fullpath'));
pyExtractor = fullfile(this, 'pair_extract_faces.py');
if ~isfile(pyExtractor)
    error('pair_extract_faces.py not found at %s', pyExtractor);
end

cmd = sprintf('"%s" "%s" "%s" "%s" "%s"', pythonPath, pyExtractor, realVideo, fakeVideo, outDir);
status = system(cmd);
if status ~= 0
    error('Failed to run pair_extract_faces.py. Command:\n%s', cmd);
end

realCropDir = fullfile(outDir, 'real_crops');
fakeCropDir = fullfile(outDir, 'fake_crops');

% ----------------------------
% Step 2) Metric computation
% ----------------------------
py.pythonPath = pythonPath;
py.scriptsDir = pyScriptsDir;

realCsv = fullfile(outDir, 'real_iqm.csv');
fakeCsv = fullfile(outDir, 'fake_iqm.csv');

compute_metrics_for_folder_hybrid(realCropDir, realCsv, metrics, functionTypes, py);
compute_metrics_for_folder_hybrid(fakeCropDir, fakeCsv, metrics, functionTypes, py);

% ----------------------------
% Step 3) VFS summary (effect-size style)
% ----------------------------
summaryCsv = fullfile(outDir, 'vfs_summary.csv');
compute_vfs_between_csvs(realCsv, fakeCsv, summaryCsv);

fprintf(['Done.\nOutputs:\n  %s\n  %s\n  %s\n'], realCsv, fakeCsv, summaryCsv);
end
