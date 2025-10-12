function compute_metrics_for_folder_hybrid(imgDir, outCsv, metrics, functionTypes, py)
%% compute_metrics_for_folder_hybrid
% Computes per-image IQA metrics and writes a single CSV:
%   Frame,<METRIC1>,<METRIC2>,...

% ---- basic checks ----
if numel(metrics) ~= numel(functionTypes)
    error('metrics and functionTypes must have the same length.');
end
if ~isfolder(imgDir)
    error('Image folder not found: %s', imgDir);
end

% ---- collect images (deterministic order) ----
imgs = [ ...
    dir(fullfile(imgDir, '*.png')); ...
    dir(fullfile(imgDir, '*.jpg')); ...
    dir(fullfile(imgDir, '*.jpeg')) ];
if isempty(imgs)
    warning('No images found in %s', imgDir);
end
[~, idx] = sort({imgs.name});
imgs = imgs(idx);

% ---- open CSV & header ----
fid = fopen(outCsv, 'w');
fprintf(fid, 'Frame');
for i = 1:numel(metrics)
    fprintf(fid, ',%s', metrics{i});
end
fprintf(fid, '\n');

% ---- loop over images ----
for k = 1:numel(imgs)
    p = fullfile(imgDir, imgs(k).name);
    scores = nan(1, numel(metrics));

    I = []; I_loaded = false; % lazy load for MATLAB metrics only when needed

    for i = 1:numel(metrics)
        m = upper(string(metrics{i}));
        t = lower(string(functionTypes{i}));

        switch t
            case "matlab"
                if ~I_loaded
                    I = imread(p);
                    % convert to uint8 if needed (some MATLAB IQA funcs expect uint8)
                    if ~isa(I, 'uint8')
                        I = im2uint8(I);
                    end
                    I_loaded = true;
                end
                switch char(m)
                    case 'BRISQUE'
                        try, scores(i) = brisque(I); catch, scores(i) = NaN; end
                    case 'NIQE'
                        try, scores(i) = niqe(I);    catch, scores(i) = NaN; end
                    case 'PIQE'
                        try, scores(i) = piqe(I);    catch, scores(i) = NaN; end
                    otherwise
                        % unsupported MATLAB metric
                        scores(i) = NaN;
                end

            case "python"
                % expects a script: '<metric_lower>_score.py' in py.scriptsDir
                scriptName = lower(strcat(m, "_score.py"));
                pyScript   = fullfile(py.scriptsDir, scriptName);
                if ~isfile(pyScript)
                    scores(i) = NaN;
                else
                    cmd = sprintf('"%s" "%s" "%s"', py.pythonPath, pyScript, p);
                    [status, out] = system(cmd);
                    if status == 0
                        % Prefer "score: <float>", fallback to "last float in text"
                        tokScore = regexp(out, 'score:\s*([+-]?\d+(\.\d+)?([eE][+-]?\d+)?)', 'tokens');
                        if ~isempty(tokScore)
                            scores(i) = str2double(tokScore{1}{1});
                        else
                            tokAny = regexp(out, '([+-]?\d+(\.\d+)?([eE][+-]?\d+)?)', 'tokens');
                            if ~isempty(tokAny)
                                scores(i) = str2double(tokAny{end}{1});
                            else
                                scores(i) = NaN;
                            end
                        end
                    else
                        scores(i) = NaN;
                    end
                end

            otherwise
                scores(i) = NaN;
        end
    end

    % write row
    fprintf(fid, '%s', imgs(k).name);
    for i = 1:numel(metrics)
        if isnan(scores(i))
            fprintf(fid, ','); % empty cell for NaN
        else
            fprintf(fid, ',%.6f', scores(i));
        end
    end
    fprintf(fid, '\n');
end

fclose(fid);
end
