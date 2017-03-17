function obij = getOpenBoundaryVerticalGrid_aste(gridDir, model, obij)

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
fprintf('Getting vertical grid information at open boundaries... '), t1 = tic;

% Load 1D vertical grid information.
zF  = squeeze(rdmds([gridDir 'RF' ]));
zC  = squeeze(rdmds([gridDir 'RC' ]));
dzF = squeeze(rdmds([gridDir 'DRF']));
dzC = squeeze(rdmds([gridDir 'DRC']));

% Load 3D bottom / bathymetry information for the model.

% Load hFac's.
hFacC = rdmds([gridDir 'hFacC']); 
hFacW = rdmds([gridDir 'hFacW']); 
hFacS = rdmds([gridDir 'hFacS']); 
depth = rdmds([gridDir 'Depth']); 

% Reshape.
hFacC = reshape(hFacC, model.nii_asteFormat, model.njj_asteFormat, model.nz);
hFacW = reshape(hFacW, model.nii_asteFormat, model.njj_asteFormat, model.nz); 
hFacS = reshape(hFacS, model.nii_asteFormat, model.njj_asteFormat, model.nz); 
depth = reshape(depth, model.nii_asteFormat, model.njj_asteFormat);

% Tranform grid properties into the 'aste' format.  
% Output is a cell array of length 5 for each face..
hFacC_aste = get_aste_faces(hFacC, model.nii, model.njj);
hFacW_aste = get_aste_faces(hFacC, model.nii, model.njj);
hFacS_aste = get_aste_faces(hFacC, model.nii, model.njj);
depth_aste = get_aste_faces(depth, model.nii, model.njj);

% Store grid properties for each open boundary condition.
for iOb = 1:length(obij)

	% Get the local indices of ii and jj on the model grid.
	[ii, jj] = getOpenBoundaryIndices(obij{iOb}, 'local', model.offset);
		
	% Pull out face index for convenience.
	face = obij{iOb}.face;

	% hFac on first and second wet point.
	obij{iOb}.hFac.T1 = squeeze(hFacC_aste{face}(ii.T1, jj.T1, :));
	obij{iOb}.hFac.T2 = squeeze(hFacC_aste{face}(ii.T2, jj.T2, :));

	% Depth at first and second wet point (which is the depth of the cell used to make volume flux measurement?)
	obij{iOb}.depth1 = -squeeze(depth_aste{face}(ii.T1, jj.T1));
	obij{iOb}.depth2 = -squeeze(depth_aste{face}(ii.T2, jj.T2));

	% hFac corresponding to each velocity.
	obij{iOb}.hFac.U = squeeze(hFacW_aste{face}(ii.U, jj.U, :));
	obij{iOb}.hFac.V = squeeze(hFacS_aste{face}(ii.V, jj.V, :));

	% Vertical grid.
	obij{iOb}.zF  = zF;
	obij{iOb}.zC  = zC;
	obij{iOb}.dzF = dzF;
	obij{iOb}.dzC = dzC;

	% Number of vertical grid points.
    obij{iOb}.nz = length(obij{iOb}.zC);
	
end

fprintf('done. (time = %6.3f s)\n', toc(t1))
