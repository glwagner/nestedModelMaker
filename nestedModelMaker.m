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
parentObuv = getParentOpenBoundaryConditions(dirz, parent, child, parentObij);

% Check-point open boundary files.
save([dirz.childObcs 'obij_parent.mat'], 'parentObij')
save([dirz.childObcs 'obuv_parent.mat'], 'parentObuv')

% Construct child model obcs and grid - - - - - - - - - - - - - - - - - - - - - 

% Get boundary indices for child grid.
childObij = transcribeOpenBoundary(child.zoom, parentObij);

% Get grid info along boundary and then extract obcs from full 3d parent fields.
childObij = getOpenBoundaryHorizontalGrid(dirz.childGlobalGrids, child, childObij);

% Messy treatment of vertical grid for now.
load([ dirz.childGrid 'zgrid.mat' ], 'zgrid')
childObij = getOpenBoundaryVerticalGrid_child(dirz.childBathy, child, ...
                childObij, zgrid);

% Interpolate open boundary conditions to child grid.
childObuv = getChildOpenBoundaryConditions(childObij, parentObij, parentObuv);

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
% Extract tidal amplitudes and phases at open boundaries (using parent model
% date information -- make sure the child model is started at that time!).
childObTides = getTidalData(childObij, datenum(child.tspan.years(1), ...
    child.tspan.months(1), 1));

% Generate the child domain - - - - - - - - - - - - - - - - - - - - - - - - - - 
child = initializeDomain(child);
child = snapDomainToSuperGrid(child, child.nSuperGrid);
child = getDomainBathymetry(dirz.childBathy, child);

[childObij, childObuv] = snapOpenBoundaryToSuperGrid(childObij, childObuv, child);

% Re-get open boundary grid info.
childObij = getOpenBoundaryHorizontalGrid(dirz.childGlobalGrids, child, childObij);

fig = 1; visualizeChildDomain(dirz, child, fig)
input('Press enter to continue.')

% Get child grid  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
% We need to verify this is done correctly.
child = getDomainGrid(dirz.childGlobalGrids, child);

% Generate initial conditions - - - - - - - - - - - - - - - - - - - - - - - - - 
%initialCondition = getInitialConditions(dirz, parent, child);

% Next... - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
% 1. Figure out how to write data, data.obcs, data.exch2, etc.

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

%{
% Compare bathymetry along parent and child open boundaries.
figure(2), clf, hold on
plot(1/2 + [0:parentObij{iOb}.nn-1], parentObij{iOb}.depth1, 'k-')
plot(1/child.zoom + [0:1/child.zoom:parentObij{iOb}.nn-1/child.zoom], childObij{iOb}.depth1, 'r-')
xlabel('kkp'), ylabel('depth'), legend('parent grid', 'child grid')
title(sprintf('Open boundary on the %s edge of face %d', childObij{iOb}.edge, childObij{iOb}.face))

pause(0.1)
%}
