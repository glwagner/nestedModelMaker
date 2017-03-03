clear all

% User-defined functions:
%
%    - specifyParentProperties.m
%    - specifyChildProperties.m
%
% Parameters  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

% Define the names of both the parent model, and of child model to be built.
child.name = 'gulfStreamComparison';

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
% Initialize the script by copying code to active directory and moving there.
if ~isdir('./active'), mkdir('./active'), end

eval( '!cp ./src/*.m ./active/')
eval(['!cp ./models/' child.name '/*.m ./active/'])

% Add active directory to path.
addpath('./active/')

% Initialize dirz structure.
dirz = [];

% Call user-defined functions - - - - - - - - - - - - - - - - - - - - - - - - - 
% Specify properties of the parent model.
[dirz, parent] = specifyParentProperties(dirz);

% Specify properties of the child model. 
[dirz, child] = specifyChildProperties(dirz, child);

% Zoom-factor between child- and parent-grid resolution.
child.zoom = child.res / parent.res;

% Extra: directory to high-res bathymetry.
bathyName  = 'SandS14p1_ibcao_4320x56160.bin';
dirz.plotBathy = ['/data5/glwagner/Numerics/nestedModelMaker/bathymetry/' bathyName ];

checkDirectories(dirz)

% Get open boundary conditions and grid info  - - - - - - - - - - - - - - - - - 
% Parse parent data structure for open boundary information.
parentObij = parseOpenBoundaries(child);

% Get grid info along boundary and then extract obcs from full 3D parent fields.
parentObij = getOpenBoundaryHorizontalGrid(dirz.parentGlobalGrids, parent, parentObij);
parentObij = getOpenBoundaryVerticalGrid_aste(dirz.parentGlobalGrids, parent, parentObij);
parentObuv = getOpenBoundaryConditions(dirz, parent, child, parentObij);

% Check-point open boundary files.
save([dirz.childObcs 'obij_parent.mat'], 'parentObij')
save([dirz.childObcs 'obuv_parent.mat'], 'parentObuv')

% Construct child model obcs and grid - - - - - - - - - - - - - - - - - - - - - 

% Get boundary indices for child grid.
for iOb = 1:child.nOb
    childObij{iOb} = transcribeOpenBoundary(child.zoom, parentObij{iOb});
end

% Get grid info along boundary and then extract obcs from full 3d parent fields.
childObij = getOpenBoundaryHorizontalGrid(dirz.childGlobalGrids, child, childObij);

% Messy treatment of vertical grid for now.
load([ dirz.childGrid 'zgrid.mat' ], 'zgrid')
childObij = getOpenBoundaryVerticalGrid_child(dirz.childBathy, child, ...
                childObij, zgrid);

% Interpolate open boundary condition to child grid.
for iOb = 1:child.nOb
    childObuv{iOb} = interpolateOpenBoundaryCondition(childObij{iOb}, ...
                        parentObij{iOb}, parentObuv{iOb});
end

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
% Extract tidal amplitudes and phases at open boundaries (using parent model
% date information -- make sure the child model is started at that time!).
childObTides = getTidalData(childObij, datenum(child.tspan.years(1), ...
    child.tspan.months(1), 1));

% Generate the child domain - - - - - - - - - - - - - - - - - - - - - - - - - - 
child = initializeChildGrid(child);
child = snapToSuperGrid(child, child.nSuperGrid);
child = getChildBathymetry(dirz.childBathy, child);

% Write this function:
%for iOb = 1:child.nOb
%   [childObij{iOb}, childObuv{iOb}] = snapOpenBoundariesToSuperGrid( ...
%        childObij{iOb}, childObuv{iOb}, child);
%end

fig = 1; visualizeChildDomain(dirz, child, fig)
input('Press enter to continue.')

% Next... - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
% 1. Generate initial conditions.
% 2. Figure out how to write data, data.obcs, data.exch2, etc.

% Plot  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
for iOb = 1:child.nOb

    [ii, jj] = getOpenBoundaryIndices(parentObij{iOb}, 'local', parent.offset);

    % Plot bathymetry on the LLC grid with open boundary marked.
    fig = 3; visualizeOpenBoundary(dirz.plotBathy, parentObij{iOb}, fig)

    % Make a quick movie
    %fig = 4; quickOpenBoundaryMovie(parentObuv{iOb}, parentObij{iOb}, child.nObcMonths, fig)
    fig = 4; quickOpenBoundaryMovie(childObuv{iOb}, childObij{iOb}, child.nObcMonths, fig)

end

% Copy user-defined functions into model directory when script is complete.
%eval(['!cp -r ' pwd '/user ' dirz.child.home])
