function obij = getOpenBoundaryGrid(gridDir, model, obij)

% Input structures or cell-array-of structures:
%
%	dirz		: structure defining critical directories
%	model		: structure giving open boundary info of the model.
%	obij		: cell array of structures with open boundary conditions properties.
%
% Outputs:
%
%	obij structure with its original fields, plus:
%
% 		.zF		: face z-position 
% 		.zC		: cell centers z-position
% 		.dzF	: face-to-face vertical distance
% 		.dzC	: center-to-center distance
%		.xC1	: cell center x-position of first wet point
%		.xC2	: cell center x-position of second wet point
%		.yC1	: cell center y-position of first wet point
%		.yC2	: cell center y-position of second wet point
%		.xG		: grid corner x-position along open boundary
%		.yG		: grid corner x-position along open boundary
%		.dxG	: grid x-spacing on open boundary (ambiguous on y-boundaries)
%		.dyG	: grid y-spacing on open boundary (ambiguous on x-boundaries)
%
%	glw, Jan 28 2016 (wagner.greg@gmail.com)
%
% ----------------------------------------------------------------------------- 
% Note about the binary file in "gridFileName" and MITgcm's grid structure:
% 	The binary file in "gridFileName" contains grid information about horizontal
% 	discretiation in the "LLC" coordinate system.  Each of the vertical levels
% 	in the binary file correspond to a horizontal field in x,y on one of the 
% 	LLC faces.  The fields have different dimensions: for example, "xC" is 
% 	an array that contains the x-position of the cell cetners, while "xG"
% 	contains the x-position of the cell corners; this means that "xG" is
% 	larger than xC by one point in both x and y.  In the binary file name
% 	"gridFileName", this means that all the files have the dimension of xG.  
% 	In the case that the field being stored is smaller than xG in one or
% 	both dimensions, the final point in the field is set to zero.  Below,
% 	the fields that are smaller than xG (and yG) are trimmed to their actual
% 	actual dimension (thus exCluding the padded zeros on the edges) for 
% 	clarity. 
% -----------------------------------------------------------------------------  
%%% Key for idx:
%		1	xC			5	rA			 9  dyU			13	rAw
%		2	yC			6	xG			10	rAz     	14	rAs
%		3	dxF			7	yG			11	dxC     	15	dxG
%		4	dyF			8	dxV 		12	dyC     	16	dyG
% -----------------------------------------------------------------------------  
%%% From "GRID.h":
%
%   | (3) Views showing nomenclature and indexing
%   |     for grid descriptor variables.
%   |
%   |      Fig 3a. shows the orientation, indexing and
%   |      notation for the grid spacing terms used internally
%   |      for the evaluation of gradient and averaging terms.
%   |      These varaibles are set based on the model input
%   |      parameters which define the model grid in terms of
%   |      spacing in X, Y and Z.
%   |
%   |      Fig 3b. shows the orientation, indexing and
%   |      notation for the variables that are used to define
%   |      the model grid. These varaibles are set directly
%   |      from the model input.
%   |
%   | Figure 3a
%   | =========
%   |       |------------------------------------
%   |       |                       |
%   |"PWY"********************************* etc...
%   |       |                       |
%   |       |                       |
%   |       |                       |
%   |       |                       |
%   |       |                       |
%   |       |                       |
%   |       |                       |
%   |
%   |       .                       .
%   |       .                       .
%   |       .                       .
%   |       e                       e
%   |       t                       t
%   |       c                       c
%   |       |-----------v-----------|-----------v----------|-
%   |       |                       |                      |
%   |       |                       |                      |
%   |       |                       |                      |
%   |       |                       |                      |
%   |       |                       |                      |
%   |       u<--dxF(i=1,j=2,k=1)--->u           t          |
%   |       |/|\       /|\          |                      |
%   |       | |         |           |                      |
%   |       | |         |           |                      |
%   |       | |         |           |                      |
%   |       |dyU(i=1,  dyC(i=1,     |                      |
%   | ---  ---|--j=2,---|--j=2,-----------------v----------|-
%   | /|\   | |  k=1)   |  k=1)     |          /|\         |
%   |  |    | |         |           |          dyF(i=2,    |
%   |  |    | |         |           |           |  j=1,    |
%   |dyG(   |\|/       \|/          |           |  k=1)    |
%   |   i=1,u---        t<---dxC(i=2,j=1,k=1)-->t          |
%   |   j=1,|                       |           |          |
%   |   k=1)|                       |           |          |
%   |  |    |                       |           |          |
%   |  |    |                       |           |          |
%   | \|/   |           |<---dxV(i=2,j=1,k=1)--\|/         |
%   |"SB"++>|___________v___________|___________v__________|_
%   |       <--dxG(i=1,j=1,k=1)----->
%   |      /+\                                              .
%   |       +
%   |       +
%   |     "WB"
%   |
%   |   N, y increasing northwards
%   |  /|\ j increasing northwards
%   |   |
%   |   |
%   |   ======>E, x increasing eastwards
%   |             i increasing eastwards
%   |
%   |    i: East-west index
%   |    j: North-south index
%   |    k: up-down index
%   |    u: x-velocity point
%   |    V: y-velocity point
%   |    t: tracer point
%   | "SB": Southern boundary
%   | "WB": Western boundary
%   |"PWX": Periodic wrap around in X.
%   |"PWY": Periodic wrap around in Y.
% -----------------------------------------------------------------------------  
% Message.
disp('Getting grid information at open boundaries...'), t1 = tic;

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
hFacC = reshape(hFacC, model.nx0, model.ny0, model.nz);
hFacW = reshape(hFacW, model.nx0, model.ny0, model.nz); 
hFacS = reshape(hFacS, model.nx0, model.ny0, model.nz); 
depth = reshape(depth, model.nx0, model.ny0);

% Tranform grid properties into the 'aste' format.  
% Output is a cell array of length 5 for each face..
hFacC_aste = get_aste_faces(hFacC, model.nx, model.ny);
hFacW_aste = get_aste_faces(hFacC, model.nx, model.ny);
hFacS_aste = get_aste_faces(hFacC, model.nx, model.ny);
depth_aste = get_aste_faces(depth, model.nx, model.ny);

% Store grid properties for each open boundary condition.

for iOb = 1:model.nOb

	%%%% something like: "getOpenBoundaryVerticalGrid.m"
	%%%% This could change from parent to child.

	% Get the local indices of ii and jj on the model grid.
	[ii, jj] = getOpenBoundaryIndices(obij{iOb}, 'local', model.offset);
		
	% Length of open boundary.
	obij{iOb}.nn  = length(obij{iOb}.ii);

	% Pull out face index for convenience.
	face = obij{iOb}.face;

	% hFac on first and second wet point.
	obij{iOb}.hFac.T1 = squeeze(hFacC_aste{face}(ii.T1, jj.T1, :));
	obij{iOb}.hFac.T2 = squeeze(hFacC_aste{face}(ii.T2, jj.T2, :));

	% Depth at first and second wet point (which is the depth of the cell used to make volume flux measurement?)
	obij{iOb}.depth1 = squeeze(depth_aste{face}(ii.T1, jj.T1));
	obij{iOb}.depth2 = squeeze(depth_aste{face}(ii.T2, jj.T2));

	% hFac corresponding to each velocity.
	obij{iOb}.hFac.U = squeeze(hFacW_aste{face}(ii.U, jj.U, :));
	obij{iOb}.hFac.V = squeeze(hFacS_aste{face}(ii.V, jj.V, :));

	% Vertical grid.
	obij{iOb}.zF  = zF;
	obij{iOb}.zC  = zC;
	obij{iOb}.dzF = dzF;
	obij{iOb}.dzC = dzC;

	%%%% something like: "obij = getOpenBoundaryHorizontalGrid(gridDir, model, obij)"
	%%%% This should not change from parent to child.

	% Load and cut the global llc grid at model-grid resolution.
	gridFileName = [gridDir 'llc_00' int2str(face) '_', ...
					int2str(model.llc.nx(face)) '_', ...
					int2str(model.llc.ny(face)) '.bin'];

	% Number of cell faces ("grid faces"?) in the x- and y-direction.
	nxG = model.llc.nx(face)+1;
	nyG = model.llc.ny(face)+1;

	% Load fields of interest from the global grid (see key above).
	idx =  1; xC  = read_slice(gridFileName, nxG, nyG, idx, 'real*8');	
	idx =  2; yC  = read_slice(gridFileName, nxG, nyG, idx, 'real*8');	

	idx =  6; xG  = read_slice(gridFileName, nxG, nyG, idx, 'real*8');	
	idx =  7; yG  = read_slice(gridFileName, nxG, nyG, idx, 'real*8');	

	idx = 15; dxG = read_slice(gridFileName, nxG, nyG, idx, 'real*8');	
	idx = 16; dyG = read_slice(gridFileName, nxG, nyG, idx, 'real*8');	

	% Trim xC, yC, dxG, and dyG to eliminate any possible ambiguity.
	xC = xC(1:end-1, 1:end-1);
	yC = yC(1:end-1, 1:end-1);
	
	dxG = dxG(1:end-1, :);
	dyG = dyG(:, 1:end-1);

	% Get the boundary indices on the llc grid.
	[iillc, jjllc] = getOpenBoundaryIndices(obij{iOb}, 'llc');

	% Store grid corner and grid length information.
	obij{iOb}.xG  = xG (iillc.xG,  jjllc.xG );
	obij{iOb}.yG  = yG (iillc.yG,  jjllc.yG );
	obij{iOb}.dxG = dxG(iillc.dxG, jjllc.dxG);
	obij{iOb}.dyG = dyG(iillc.dyG, jjllc.dyG);

	% Cell center x-positions of first and second wet point.
	obij{iOb}.xC1 = xC (iillc.T1, jjllc.T1); 
	obij{iOb}.xC2 = xC (iillc.T2, jjllc.T2); 

	% Cell center y-positions of first and second wet point.
	obij{iOb}.yC1 = yC (iillc.T1, jjllc.T1); 
	obij{iOb}.yC2 = yC (iillc.T2, jjllc.T2); 
	
end

%----------------------------------------------------------------------------- 
disp(['   ... done extracting grid on open boundary. (time = ' num2str(toc(t1), '%6.3f') ' s)'])



