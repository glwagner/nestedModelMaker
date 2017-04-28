function [dirz, parent, child] = checkAndProcessInput(dirz, parent, child)

% Directory management

% Directories to store the child grids and obcs.
dirz.home  = [ './models/' child.name '/'];
dirz.childGrid = [ dirz.home 'grids/' ];
dirz.childInput = [ dirz.home 'input/' ];

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


% Child grid.

% Zoom-factor between child- and parent-grid resolution.
child.zoom = child.res / parent.res;

% Properties of the global llc grid on which the child lives.
child.llc.nii = [ [1 1 1]*child.res [3 3]*child.res ];
child.llc.njj = [ [3 3]*child.res [1 1 1]*child.res ];

% Length of the open boundary condition to be extracted.  Due to the MITgcm's
% linear interpolation of open boundary conditions, The number of months of 
% boundary condition to be extracted is 3 + the number of months in the forward 
% simulation.
child.nObcMonths = 2 + 12*(child.tspan.years(2)-child.tspan.years(1)) ...
    + (child.tspan.months(2)-child.tspan.months(1));            

% Count open boundaries.
child.nOb = 0;
for face = 1:5, for side = 1:2, 
    if strcmp(child.bcs.ii{face}{side}, 'open')
        child.nOb = child.nOb+1; 
    elseif strcmp(child.bcs.jj{face}{side}, 'open')
        child.nOb = child.nOb+1; 
    end
end, end


% Parent grid
parent.llc.nii = [ parent.res([1 1 1]) 3*parent.res([1 1]) ];
parent.llc.njj = [ 3*parent.res([1 1]) parent.res([1 1 1]) ];

for face = 1:5
    if parent.ii(face, 1) ~= 0
        parent.nii(face) = parent.ii(face, 2) - parent.ii(face, 1) + 1;
        parent.njj(face) = parent.jj(face, 2) - parent.jj(face, 1) + 1;
    else
        parent.nii(face) = 0;
        parent.njj(face) = 0;
    end

    parent.offset.ii(face) = max(parent.ii(face,1) - 1, 0); 
    parent.offset.jj(face) = max(parent.jj(face,1) - 1, 0);
end

% Check ocean point

% Open boundary conditions output

% Check that code and grid directories exist

% Check that MITgcm tools like read_slice(), etc are in the path.

