% User-defined functions:
%
%    - specifyParentModelAndDirectories.m
%    - specifyOpenBoundaries.m
%
% Add important paths to source code and user-defined functions.
disp(' ')
%
% ----------------------------------------------------------------------------- 
%%% Parameters.

% Define the names of both the parent model, and of child model to be built.
child.name = 'gulfStreamComparison';
parent.name = 'ASTE';

% ----------------------------------------------------------------------------- 
%%% Automation.

% Initialize the script by copying code to active directory and moving there.
if ~isdir('./active'), mkdir('./active'), end
eval( '!cp ./src/*.m ./active/')
eval(['!cp ./models/' child.name '/*.m ./active/'])

% Add active directory to pathEnter active directory active directory to path
addpath('./active/')

% Enter parameters of the parent model.
[dirz, parent] = specifyParentModelAndDirectories(parent, child);

% Check to make sure all's ok.
checkDirectories(dirz)
% checkParentModel(parent)                 % This function must be written.

% Parse parent data structure for open boundary information.
parentObij = parseOpenBoundaries(parent);

% Get grid info along boundary and then extract obcs from full 3D parent fields.
parentObij = getOpenBoundaryHorizontalGrid(dirz.globalGrids.parent, parent, parentObij);
parentObij = getOpenBoundaryVerticalGrid_aste(dirz.globalGrids.parent, parent, parentObij);

parentObuv = getOpenBoundaryConditions(dirz, parent, child, parentObij);

% Check-point open boundary files.
save([dirz.child.obcs 'obij_parent.mat'], 'parentObij')
save([dirz.child.obcs 'obuv_parent.mat'], 'parentObuv')

% ----------------------------------------------------------------------------- 
%%% Child grid stuff

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

% Messy treatment of vertical grid for now.
load([ dirz.child.grid 'zgrid.mat' ], 'zgrid')
childObij = getOpenBoundaryVerticalGrid_child(dirz.child.bathy, child, ...
                childObij, zgrid);

% Interpolate open boundary condition to child grid.
for iOb = 1:child.nOb
    childObuv{iOb} = interpolateOpenBoundaryCondition(childObij{iOb}, ...
                        parentObij{iOb}, parentObuv{iOb});
end

% ----------------------------------------------------------------------------- 
% Extract tidal amplitudes and phases at open boundaries (using parent model
% date information -- make sure the child model is started at that time!).
childObTides = getTidalData(childObij, datenum(parent.tspan.years(1), ...
    parent.tspan.months(1), 1));

% ----------------------------------------------------------------------------- 
% Generate the full child domain, pad the open boundaries, etc.

% ----------------------------------------------------------------------------- 
% Plot.
for iOb = 1:parent.nOb

    [ii, jj] = getOpenBoundaryIndices(parentObij{iOb}, 'local', parent.offset);

    % Plot bathymetry on the LLC grid with open boundary marked.
    visualizeOpenBoundary(dirz, parentObij{iOb})

    % Make a quick movie
    quickOpenBoundaryMovie(parentObuv{iOb}, parentObij{iOb}, parent.nObcMonths)

    input('Now the child boundary conditions.')

    % Make a quick movie
    quickOpenBoundaryMovie(childObuv{iOb}, childObij{iOb}, parent.nObcMonths)

end

% Copy user-defined functions into model directory when script is complete.
%eval(['!cp -r ' pwd '/user ' dirz.child.home])
