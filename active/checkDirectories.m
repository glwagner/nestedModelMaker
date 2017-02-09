function checkDirectories(dirz)

if exist(dirz.child.home) == 0
	mkdir(dirz.child.home);
	fprintf('Making directory %s\n', dirz.child.home);
end

if exist(dirz.child.grid) == 0
	mkdir(dirz.child.grid);
	fprintf('Making directory %s\n', dirz.child.grid);
end

if exist(dirz.child.obcs) == 0
	mkdir(dirz.child.obcs);
	fprintf('Making directory %s\n', dirz.child.obcs);
end

% Open boundary conditions output

% Check that code and grid directories exist

% Check that MITgcm tools like read_slice(), etc are in the path.

