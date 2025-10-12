function compute_vfs_between_csvs(realCsv, fakeCsv, outCsv)
%% compute_vfs_between_csvs
% Computes VFS = between REAL and FAKE per metric column


Treal = readtable(realCsv);
Tfake = readtable(fakeCsv);

% Identify metric columns (everything except 'Frame')
allCols = Treal.Properties.VariableNames;
if strcmpi(allCols{1}, 'Frame')
    metrics = allCols(2:end);
else
    metrics = allCols; % fallback if header differs
end

fid = fopen(outCsv,'w');
fprintf(fid, 'Metric,VFS,Mean_real,Mean_fake,N_real,N_fake\n');

for i = 1:numel(metrics)
    m = metrics{i};
    if ~ismember(m, Tfake.Properties.VariableNames)
        fprintf(fid, '%s,NaN,NaN,NaN,NaN,NaN\n', m);
        continue;
    end

    x = Treal.(m);
    y = Tfake.(m);

    % Remove NaNs
    x = x(~isnan(x)); y = y(~isnan(y));

    if isempty(x) || isempty(y)
        fprintf(fid, '%s,NaN,NaN,NaN,%d,%d\n', m, numel(x), numel(y));
        continue;
    end

    % Cohen's d as VFS
    mx = mean(x); my = mean(y);
    sx = std(x);  sy = std(y);
    pooled = sqrt((sx.^2 + sy.^2)/2);
    vfs = abs((mx - my) ./ pooled);

    fprintf(fid, '%s,%.6f,%.6f,%.6f,%d,%d\n', ...
        m, vfs, mx, my, numel(x), numel(y));
end

fclose(fid);
end