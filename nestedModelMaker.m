% User-defined functions:
%
%	- specifyParentModelAndDirectories.m
%	- specifyOpenBoundaries.m
%
% Add important paths to source code and user-defined functions.
disp(' ')
%
% ----------------------------------------------------------------------------- 
%%% Parameters.

% Define the names of both the parent model, and of child model to be built.
child.name = 'gulfStreamComparison';
parent.name = 'ASTE';

% Number of months
parent.model.nMonths = 12;			

% ----------------------------------------------------------------------------- 
%%% Automation.

% Initialize the script by copying code to active directory and moving there.
eval( '!cp ./src/*.m ./active/')
eval(['!cp ./models/' child.name '/*.m ./active/'])

% Add active directory to pathEnter active directory active directory to path
addpath('./active/')

% Enter parameters of the parent model.
[dirz, parent] = specifyParentModelAndDirectories(parent, child);

% Check to make sure all's ok.
checkDirectories(dirz)
% checkParentModel(parent) 				% This function must be written.
% checkOpenBoundaries(parent, obij) 	% This function must be written.


% Specify boundaries (should be automated).
parentObij = parseOpenBoundaries(parent);
%parentObij = specifyOpenBoundaries(parent); %parent.nOb = length(parentObij);

% Get grid info along boundary and then extract obcs from full 3d parent fields.
parentObij = getOpenBoundaryHorizontalGrid(dirz.globalGrids.parent, parent, parentObij);
parentObij = getOpenBoundaryVerticalGrid_aste(dirz.globalGrids.parent, parent, parentObij);
parentObuv = getOpenBoundaryConditions(dirz, parent, child, parentObij);

% Check-point open boundary files.
save([dirz.child.obcs 'obij_parent.mat'], 'parentObij')
save([dirz.child.obcs 'obuv_parent.mat'], 'parentObuv')

% ----------------------------------------------------------------------------- 

% Hack the 'initial' child open boundaries together.
child.res  = 1080;
child.zoom = child.res / parent.res;
child.nOb  = parent.nOb;

% Global grid that the child lives on
child.llc.nx = [ [1 1 1]*child.res [3 3]*child.res ];
child.llc.ny = [ [3 3]*child.res [1 1 1]*child.res ];

% Get boundary indices for child grid.
for iOb = 1:child.nOb
	childObij{iOb} = transcribeOpenBoundary(child.zoom, parentObij{iOb});
end

% Get grid info along boundary and then extract obcs from full 3d parent fields.
childObij = getOpenBoundaryHorizontalGrid(dirz.globalGrids.child, child, childObij);
%childObij = getOpenBoundaryVerticalGrid(dirz.zgrid.child, child, childObij);

% Messy treatment of vertical grid for now.
load([ dirz.child.grid 'zgrid.mat' ], 'zgrid')

% Store grid properties for each open boundary condition.
for iOb = 1:child.nOb
	% Store properties of the vertical grid.
	childObij{iOb}.zF  = zgrid.zf';
	childObij{iOb}.zC  = 1/2*(zgrid.zf(2:end)+zgrid.zf(1:end-1))';
	childObij{iOb}.dzF = zgrid.delz';
	childObij{iOb}.dzC = childObij{iOb}.zC(2:end)'-childObij{iOb}.zC(1:end-1)';

    % Ensure grid convention is positive upwards.
    childObij{iOb}.zF  = -abs(childObij.{iOb}.zF);
    childObij{iOb}.zC  = -abs(childObij.{iOb}.zC);

    % Load bathymetry.

end

% Loop over the horizontal index of the open boundary
for iOb = 1:child.nOb
    switch childObij{iOb}.edge
        case 'south'
            for ii = childObij{iOb}

% ----------------------------------------------------------------------------- 
% Plot.
for iOb = 1:parent.nOb

	[ii, jj] = getOpenBoundaryIndices(parentObij{iOb}, 'local', parent.offset);

	% Plot bathymetry on the LLC grid with open boundary marked.
	visualizeOpenBoundary(dirz, parentObij{iOb})

	% Make a quick movie
	quickOpenBoundaryMovie(parent, parentObuv{iOb}, parentObij{iOb})

end

% Copy user-defined functions into model directory when script is complete.
%eval(['!cp -r ' pwd '/user ' dirz.child.home])
