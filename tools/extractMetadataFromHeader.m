function metadata = extractMetadataFromHeader(filePath)
%% extractMetadataFromHeader.m
% Title: Metadata extractor for MATLAB file headers (Dublin Core style)
% Author: Przemysław Nosal
% ORCID: 0000-0001-9751-0071
% Affiliation: AGH University of Krakow
% Contact: pnosal@agh.edu.pl
% Date: 2025-04-25
% Version: 1.0
% Description: Extracts structured metadata from the header of a MATLAB file.
%              Supports multiline fields and automatically fills missing 
%              entries with defaults based on Dublin Core standard.
% Dependencies: none
% License: CC-BY 4.0

% -------------------------------------------------------------------------
% INPUTS:
% filePath   – string or char array specifying the path to the MATLAB file
%
% OUTPUTS:
% metadata   – structure containing metadata fields
% -------------------------------------------------------------------------

% Open the file
fid = fopen(filePath, 'r');
if fid == -1
    error('Could not open file: %s', filePath);
end

metadata = struct();
currentKey = '';
line = fgetl(fid);

% Read header line by line
while ischar(line)
    % Skip separator lines or non-comment lines
    if contains(line, '===') || ~startsWith(strtrim(line), '%')
        line = fgetl(fid);
        continue
    end

    % Try to match a key-value pair: % Key : Value
    tokens = regexp(line, '%\s*(\w[\w\s]*)\s*:\s*(.+)', 'tokens');
    if ~isempty(tokens)
        % New key-value pair found
        currentKey = strrep(strtrim(tokens{1}{1}), ' ', '');
        metadata.(currentKey) = strtrim(tokens{1}{2});
    elseif ~isempty(currentKey)
        % Continuation of previous field
        if regexp(line, '^%\s{2,}')
            continuation = strtrim(regexprep(line, '^%\s*', ''));
            metadata.(currentKey) = [metadata.(currentKey), ' ', continuation];
        else
            % Line does not look like continuation
            currentKey = '';
        end
    end

    % Read next line
    line = fgetl(fid);
end

% Close the file
fclose(fid);

% Fill in missing metadata fields with defaults
defaults = struct( ...
    'Title',        'Development of an elasto-plastic model based on Cosserat theory using the peridynamics method', ...
    'Identifier',   'DEC-2024/08/X/ST8/00273', ...
    'Creator',      'Przemysław Nosal', ...
    'ORCID',        '0000-0001-9751-0071', ...
    'Affiliation',  'AGH University of Krakow', ...
    'Contact',      'pnosal@agh.edu.pl', ...
    'Subject',      'Computational Mechanics, Peridynamics, Cosserat Theory, Elasto-plasticity', ...
    'Description',  'MATLAB implementation of a Cosserat-based peridynamic model.', ...
    'Publisher',    'AGH University of Krakow', ...
    'Contributor',  'N/A – single-author project', ...
    'Date',         datestr(now, 'yyyy-mm-dd'), ...
    'ExportDate',   datestr(now, 'yyyy-mm-dd'), ...
    'Version',      '1.0', ...
    'Type',         'Software', ...
    'Format',       'MATLAB .m code', ...
    'Language',     'en', ...
    'Relation',     'https://osf.io/, https://zenodo.org/', ...
    'Coverage',     'Simulated elastic-plastic material behavior under quasi-static loading', ...
    'Rights',       'CC BY 4.0 International', ...
    'Software',     'MATLAB R2022b' ...
);

fields = fieldnames(defaults);
for i = 1:numel(fields)
    if ~isfield(metadata, fields{i}) || isempty(metadata.(fields{i}))
        metadata.(fields{i}) = defaults.(fields{i});
    end
end

end