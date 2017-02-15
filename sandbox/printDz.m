% Load and print a z-grid in ascii format (?)

% Directory to dump file.
loadPath = [pwd '/'];
savePath = [pwd '/'];

% Prefix before each grid name
prefix = 'zgrid_';

% Three grids to compare.
name = '101b';
%name = 'flex';

% Load z-grid. Grid is contained in a structure called 'zgrid':
%	zgrid.delz is the dz grid.
%	zgrid.zF   is the face-points (and has length(delz)+1)
loadName = [loadPath prefix name '.mat'];
load(loadName)

% File name to save.
fileName = [ savePath 'dz5_v' name '.txt' ];

% Open file 
fileID = fopen(fileName, 'w');

% Print dz data.  The format has 5 columns.
for ii = 1:length(zgrid.delz)

	% Print dz data.
	fprintf(fileID, '%12.6f,', zgrid.delz(ii));
	% Start new line every 5th column.
	if mod(ii, 5) == 0, fprintf(fileID, '\n'); end

end

disp(['Printed dz file ''' fileName ''''])
