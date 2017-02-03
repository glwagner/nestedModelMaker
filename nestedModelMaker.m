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
eval( 'cp ./src/*.m ./active/')
eval(['cp ./models/' modelName '/*.m ./active/'])

% Enter active directory active directory to path
cd('./active/')

% Enter parameters of the parent model.
[dirz, parent] = specifyParentModelAndDirectories(parent, child);

% Check to make sure all's ok.
checkDirectories(dirz)
% checkParentModel(parent) 				% This function must be written.
% checkOpenBoundaries(parent, obij) 	% This function must be written.

% Specify boundaries (should be automated).
parentObij = specifyOpenBoundaries(parent); parent.nOb = length(obij);

% Get grid info along boundary and then extract obcs from full 3d parent fields.
parentObij = getOpenBoundaryGrid(gridDir, parent, parentObij);
parentObuv = getOpenBoundaryConditions(dirz, parent, child, parentObij);

% Check-point open boundary files.
save([dirz.child.obcs 'obij_parent.mat'], 'obij')
save([dirz.child.obcs 'obuv_parent.mat'], 'obuv')

% ----------------------------------------------------------------------------- 

% Hack the 'initial' child open boundaries together.
child.zoom = 16;
child.nOb = parent.nOb;

% Get boundary indices for child grid.
for iOb = 1:child.nOb
	childObij{iOb} = transcribeOpenBoundaryParentToChild(parentObij{iOb}, child.zoom)
end




% Plot.
for iOb = 1:parent.nOb

	[ii, jj] = getOpenBoundaryIndices(obij{iOb}, 'local', parent.offset);

	% Plot bathymetry on the LLC grid with open boundary marked.
	visualizeOpenBoundary(dirz, obij{iOb})

	% Make a quick movie
	quickOpenBoundaryMovie(parent, obuv{iOb}, obij{iOb})

end

% Copy user-defined functions into model directory when script is complete.
eval(['!cp -r ' pwd '/user ' dirz.child.home])
