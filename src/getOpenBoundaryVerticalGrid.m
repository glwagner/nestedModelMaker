function obij = getOpenBoundaryVerticalGrid(gridDir, model, obij)

% ----------------------------------------------------------------------------- 
% Input structures or cell-array-of structures:
%
%	gridDir     : A string that points to the directory of the ASTE grid info.
%	model		: Structure giving open boundary info of the model.
%	obij		: Cell array of structures with open boundary conditions 
%                 properties.
%
% Outputs:
%
%	obij structure with its original fields, plus:
%
% 		.zF		: Face z-position 
% 		.zC		: Cell centers z-position
% 		.dzF	: Face-to-face vertical distance
% 		.dzC	: Center-to-center distance
%       .hFac   : Structure with fields .T, .S, .U, .V which give the hFac
%                 for each field.
%
%	glw, Jan 28 2016 (wagner.greg@gmail.com)
%
% ----------------------------------------------------------------------------- 

% Message.
disp('Getting vertical grid information at open boundaries...'), t1 = tic;

% Load 1D vertical grid information.
zF  = squeeze(rdmds([gridDir 'RF' ]));
zC  = squeeze(rdmds([gridDir 'RC' ]));
dzF = squeeze(rdmds([gridDir 'DRF']));
dzC = squeeze(rdmds([gridDir 'DRC']));

% Store grid properties for each open boundary condition.
for iOb = 1:model.nOb

	% Store properties of the vertical grid.
	obij{iOb}.zF  = zF;
	obij{iOb}.zC  = zC;
	obij{iOb}.dzF = dzF;
	obij{iOb}.dzC = dzC;

end

%----------------------------------------------------------------------------- 
disp(['   ... done extracting vertical grid on open boundary. ', ...
        '(time = ' num2str(toc(t1), '%6.3f') ' s)'])
