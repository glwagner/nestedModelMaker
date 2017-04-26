function checkDirectories(dirz)

if exist(dirz.home) == 0
	mkdir(dirz.home);
	fprintf('Making directory %s\n', dirz.home);
end

if exist(dirz.childGrid) == 0
	mkdir(dirz.childGrid);
	fprintf('Making directory %s\n', dirz.childGrid);
end

if exist(dirz.childInput) == 0
	mkdir(dirz.childInput);
	fprintf('Making directory %s\n', dirz.childInput);
end

% Open boundary conditions output

% Check that code and grid directories exist

% Check that MITgcm tools like read_slice(), etc are in the path.

