clear all


% Define the name of the model.
child.name = 'BrazilBasin_LLC1080';


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
% Initialize the script by copying code to active directory and adding the path.
if exist('./active') == 7, eval('!rm ./active/*')
else,                      mkdir('./active'),       end

eval( '!cp ./src/*.m ./active/')
eval(['!cp ./models/' child.name '/*.m ./active/'])

addpath('./active/')


% Initialization  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
[dirz, parent] = specifyParentProperties();
[dirz, child] = specifyChildProperties(dirz, child);
[dirz, parent, child] = checkAndProcessInput(dirz, parent, child);

% Get open boundary conditions and grid info  - - - - - - - - - - - - - - - - - 

% Parse parent data structure for open boundary information.
parentObij = parseOpenBoundaries(child);
parentObij = getOpenBoundaryHorizontalGrid(dirz.parentGlobalGrids, parent, ...
    parentObij);
parentObij = getOpenBoundaryVerticalGrid_aste(dirz.parentGlobalGrids, parent, ...
    parentObij);
parentObuv = getParentOpenBoundaryConditions(dirz, parent, child, parentObij);

% Get boundary indices for child grid.
childObij = transcribeOpenBoundary(child.zoom, parentObij);
childObij = getOpenBoundaryHorizontalGrid(dirz.childGlobalGrids, child, childObij);

% Messy treatment of vertical grid for now.
load(dirz.childZGrid, 'zGrid')
childObij = getOpenBoundaryVerticalGrid_child(dirz.childBathy, child, ...
                childObij, zGrid);

childObuv = getChildOpenBoundaryConditions(childObij, parentObij, parentObuv);

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

% Extract tidal amplitudes and phases at open boundaries (using parent model
% date information -- make sure the child model is started at that time!).
childObTides = getTidalData(childObij, datenum(child.tspan.years(1), ...
    child.tspan.months(1), 1));

% Generate initial conditions - - - - - - - - - - - - - - - - - - - - - - - - - 

%extractAndSaveInitialConditions(dirz, parent, child);

% Save things to file
saveGrid(dirz, child);
saveBathymetry(dirz, child);
saveObuv(dirz, child, childObij, childObuv);
saveObTides(dirz, child, childObij, childObTides);

% print tiling information
tiling(child);

% print obcs setup
obcsSetup(child, childObij);
