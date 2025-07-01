function writeCitationFile(metadata, filename)
%% writeCitationFile.m
% Title: Generate a CITATION.cff file from metadata
% Author: Przemysław Nosal
% ORCID: 0000-0001-9751-0071
% Affiliation: AGH University of Krakow
% Contact: pnosal@agh.edu.pl
% Date: 2025-04-25
% Version: 1.0
% Description: Creates a CITATION.cff file compatible with GitHub and other
%              repositories, using metadata extracted from the file header.
%              Automatically fills in required fields and handles optional extras.
% Dependencies: extractMetadataFromHeader.m
% License: CC-BY 4.0

% -------------------------------------------------------------------------
% INPUTS:
% metadata   – structure containing metadata fields
% filename   – (optional) name of the CITATION file to create (default = 'CITATION.cff')
%
% OUTPUTS:
% (none) – file is written directly to disk
%
% NOTE:
% The generated file follows the Citation File Format (CFF) specification v1.2.0
% See: https://citation-file-format.github.io/
% -------------------------------------------------------------------------

% Set default filename if not provided
if nargin < 2
    filename = 'CITATION.cff';
end

fid = fopen(filename, 'w');
if fid == -1
    error('Could not open file for writing: %s', filename);
end

% Write basic required fields
fprintf(fid, 'cff-version: 1.2.0\n');
fprintf(fid, 'message: "If you use this software, please cite it as below."\n');
fprintf(fid, 'title: "%s"\n', metadata.Title);
fprintf(fid, 'version: %s\n', metadata.Version);
fprintf(fid, 'date-released: %s\n', metadata.ExportDate);

% Write author block
fprintf(fid, 'authors:\n');
fprintf(fid, '  - family-names: Nosal\n');
fprintf(fid, '    given-names: Przemysław\n');
fprintf(fid, '    orcid: https://orcid.org/%s\n', strrep(metadata.ORCID, '-', ''));

% Write additional fields
fprintf(fid, 'affiliation: %s\n', metadata.Affiliation);
fprintf(fid, 'license: %s\n', metadata.Rights);
fprintf(fid, 'type: software\n');

% Optional extras
if isfield(metadata, 'Relation') && ~isempty(metadata.Relation)
    relationSplit = strsplit(metadata.Relation, ',');
    fprintf(fid, 'repository-code: %s\n', strtrim(relationSplit{1}));
end
if isfield(metadata, 'Identifier') && ~isempty(metadata.Identifier)
    fprintf(fid, 'doi: %s\n', metadata.Identifier);
end

% Close file
fclose(fid);
fprintf('CITATION.cff generated successfully as "%s".\n', filename);

end
