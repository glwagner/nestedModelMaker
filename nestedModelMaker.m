clear all

% Define the names of both the parent model, and of child model to be built.
child.name = 'gulfStreamComparison';

% Initialize the script by copying code to active directory and adding the path.
if ~isdir('./active'), mkdir('./active'), end
eval( '!cp ./src/*.m ./active/')
eval(['!cp ./models/' child.name '/*.m ./active/'])
addpath('./active/')

% Directory to high-res bathymetry.
bathyName  = 'SandS14p1_ibcao_4320x56160.bin';
dirz.plotBathy = ['/data5/glwagner/Numerics/nestedModelMaker/bathymetry/' bathyName ];

% Call user-defined functions - - - - - - - - - - - - - - - - - - - - - - - - - 
% Specify properties of the parent model.
[dirz, parent] = specifyParentProperties(dirz);
[dirz, child] = specifyChildProperties(dirz, child);

checkDirectories(dirz)

% Zoom-factor between child- and parent-grid resolution.
child.zoom = child.res / parent.res;

% Get open boundary conditions and grid info  - - - - - - - - - - - - - - - - - 
% Parse parent data structure for open boundary information.
parentObij = parseOpenBoundaries(child);
parentObij = getOpenBoundaryHorizontalGrid(dirz.parentGlobalGrids, parent, parentObij);
parentObij = getOpenBoundaryVerticalGrid_aste(dirz.parentGlobalGrids, parent, parentObij);
parentObuv = getParentOpenBoundaryConditions(dirz, parent, child, parentObij);

% Get boundary indices for child grid.
childObij = transcribeOpenBoundary(child.zoom, parentObij);
childObij = getOpenBoundaryHorizontalGrid(dirz.childGlobalGrids, child, childObij);

% Messy treatment of vertical grid for now.
load(dirz.childZGrid, 'zGrid')
childObij = getOpenBoundaryVerticalGrid_child(dirz.childBathy, child, ...
                childObij, zGrid);

childObuv = getChildOpenBoundaryConditions(childObij, parentObij, parentObuv);

% Extract tidal amplitudes and phases at open boundaries (using parent model
% date information -- make sure the child model is started at that time!).
%childObTides = getTidalData(childObij, datenum(child.tspan.years(1), ...
%    child.tspan.months(1), 1));

% Generate the child domain - - - - - - - - - - - - - - - - - - - - - - - - - - 
child = initializeDomain(child);
child = snapDomainToSuperGrid(child, child.nSuperGrid);
child = getDomainBathymetry(dirz.childBathy, child);
child = modifyBathymetry(child);
child = discardUnconnectedOcean(child);

[childObij, childObuv] = snapOpenBoundaryToSuperGrid(childObij, childObuv, child);

childObij = getOpenBoundaryHorizontalGrid(dirz.childGlobalGrids, child, childObij);

parent = getDomainGrid(dirz.parentGlobalGrids, parent);
child = getDomainGrid(dirz.childGlobalGrids, child);

% Load z-grids.
child.zGrid = getfield(load(dirz.childZGrid, 'zGrid'), 'zGrid');
child.nz = length(child.zGrid.zC);

parent.zGrid = getfield(load(dirz.parentZGrid, 'zGrid'), 'zGrid');
parent.nz = length(parent.zGrid.zC);

% Generate initial conditions - - - - - - - - - - - - - - - - - - - - - - - - - 
extractAndSaveInitialConditions(dirz, parent, child);

% Save things to file
saveGrid(child);
saveBathymetry(child);
saveObuv(child, childObij, childObuv);
saveObTides(child, childObij, childObTides);

% print tiling information
tiling(child);

% print obcs setup
obcsSetup(child, childObij);

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
