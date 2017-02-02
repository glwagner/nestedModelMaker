function obuv = getOpenBoundaryConditions(dirz, parent, child, obij)

% For the cell array of open boundaries specified in input 'obij', 
% extract scalar fields T, S at first and second wet points, as well as
% normal velocity across open boundary (either U or V).  At the moment, 
% we also store the tangential velocity evaluated at the second wet point.
% 
% Input structures or cell-array-of structures:
%
%	dirz		: structure defining critical directories
%	child		: structure giving properties of the child model
%	parent		: structure giving properties of the parent model
%	obij		: cell array of structures with open boundary conditions properties.
%
% Outputs:
%	obuv				: cell array of structures with boundary fields 
%		.T1				: temperature at first wet point at all times.
%		.T2				: temperature at second wet point at all times.
%		.S1				: salinity at first wet point at all times.
%		.S2				: salinity at second wet point at all times.
%		(.U, and .V)	: velocity fields at either first or second wet point, 
%						  depending on the value of obij.edge
%		.time			: time vector 
%
%	glw, Jan 28 2016 (wagner.greg@gmail.com)
%
% Message.
disp('Extracting boundary conditions...'), t1 = tic;
%----------------------------------------------------------------------------- 

% Check inputs?
checkDirectories(dirz)
%checkOpenBoundaries(parent, obij);
%checkParentModel(parent);

%----------------------------------------------------------------------------- 
% Initialize the files to be loaded for the open boundaries.
tracerFiles = dir([dirz.parent.data.TS parent.model.TSname '.*.data']);
velFiles    = dir([dirz.parent.data.UV parent.model.UVname '.*.data']);

% This is the length of the list; it also specifies how many files to load.
nTracerFiles = length(tracerFiles);

% Get the indices corresponding to the time-stamp within the filename string.
iDot  = find(tracerFiles(1).name=='.');
iSecs = iDot(1)+1:iDot(2)-1;

% This loop gets a vector of length 4 for each time-step to be loaded (LL of them)
timeSteps = zeros(nTracerFiles, 4);
for iFile = 1:nTracerFiles

	% Get the timestamp of the data file in seconds.
  	seconds  = str2num(tracerFiles(iFile).name(iSecs));
	% This appears to convert seconds to a date vec.  One day must taken off
	% To get the time correct
  	dates    = datevec(ts2dte(seconds, parent.model.dt, ...
								parent.model.year0, parent.model.mnth0, 0));	

	% Store the relevant information in fileTimez
  	fileTimez(iFile, 1:3) = dates(1:3);
	fileTimez(iFile, 4)   = seconds;
end

% Fine the index of the file to load first.
iFilez = find(fileTimez(:,1)==parent.model.years(1));
iFile0 = iFilez(1);

% ----------------------------------------------------------------------------- 
% Load bottom / bathymetry information for the parent model; this allows us
% to store the area-averaged velocity, rather than the area-integrated velocity 
% that ASTE outputs.

% Load hFac's.
hFacC = rdmds([dirz.parent.grid 'hFacC']); 
hFacW = rdmds([dirz.parent.grid 'hFacW']); 
hFacS = rdmds([dirz.parent.grid 'hFacS']); 

% Reshape.
hFacC = reshape(hFacC, parent.nx0, parent.ny0, parent.nz);
hFacW = reshape(hFacW, parent.nx0, parent.ny0, parent.nz); 
hFacS = reshape(hFacS, parent.nx0, parent.ny0, parent.nz); 

% Tranform grid properties into the 'aste' format.  
% Output is a cell array of length 5 for each face..
hFacC_aste = get_aste_faces(hFacC, parent.nx, parent.ny);
hFacW_aste = get_aste_faces(hFacC, parent.nx, parent.ny);
hFacS_aste = get_aste_faces(hFacC, parent.nx, parent.ny);

% Find bottom (where hFac=0) for U, V, and T.
iBot.U = find(hFacW(:)==0);
iBot.V = find(hFacS(:)==0);
iBot.T = find(hFacC(:)==0);

% ----------------------------------------------------------------------------- 
% Initialize stuff before the main loop.

% Predefine matrices to reserve memory
disp('    Initializing fields...'), t2 = tic;
for iOb = 1:parent.nOb

	% Number of boundary points
	ni = length(obij{iOb}.ii);
	
	% Initialize boundary fields
	obuv{iOb}.T1 = zeros(ni, parent.nz, parent.model.nMonths);
	obuv{iOb}.T2 = zeros(ni, parent.nz, parent.model.nMonths);
	obuv{iOb}.S1 = zeros(ni, parent.nz, parent.model.nMonths);
	obuv{iOb}.S2 = zeros(ni, parent.nz, parent.model.nMonths);
	obuv{iOb}.U  = zeros(ni, parent.nz, parent.model.nMonths);
	obuv{iOb}.V  = zeros(ni, parent.nz, parent.model.nMonths);

	% Initialize time matrix.
	obuv{iOb}.time = zeros(parent.model.nMonths, 4);

end
disp(['    ... done. (time = ' num2str(toc(t2), '%6.3f') ' s)'])

% Get the precision for T, S, U, V from their associated .meta files.
precision.TS = get_precision([dirz.parent.data.TS, ...
						 		tracerFiles(1).name(1:end-4) 'meta']);
precision.UV = get_precision([dirz.parent.data.UV, ...
						 		velFiles(1).name(1:end-4) 'meta']);


% Loop through all time-points.
disp('    Loading and cutting fields...')
for iit = 1:parent.model.nMonths

	% Set timer.
	clear t2, t2 = tic;

	% Set the file index.
	iFile = iFile0 + iit - 1;

	% File names.
  	loadFile.TS = [dirz.parent.data.TS tracerFiles(iFile).name]; 
  	loadFile.UV = [dirz.parent.data.UV velFiles(iFile).name]; 

	% -------------------------------------------------------------------------  
	% Load entire parent fields.  The function "get_aste_faces" outputs
	% a cell array of length five corresponding to each of the faces.
	% We are assuming, unfortunately, that the data is in the 'ASTE' format.
	% -------------------------------------------------------------------------  

	% Get avg(T).
  	field = read_slice(loadFile.TS, parent.nx0, parent.ny0, ...
						1:parent.nz, precision.TS);     
	field(iBot.T) = NaN;
	THETA = get_aste_faces(field, parent.nx, parent.ny);

	% Get avg(S).
  	field = read_slice(loadFile.TS, parent.nx0, parent.ny0, ...
						[1:parent.nz]+parent.nz, precision.TS);
	field(iBot.T) = NaN;
	SALT = get_aste_faces(field, parent.nx, parent.ny);

	% Get avg(U*hFac)
  	field = read_slice(loadFile.UV, parent.nx0, parent.ny0, ...
						1:parent.nz, precision.UV);     
	% NaN-out bottom regions before getting the area-averaged velocity.
	field(iBot.U) = NaN;
	% Compute U* = avg(U*hFac)/hFac0
	field = field./hFacW;
	UVEL = get_aste_faces(field, parent.nx, parent.ny);

	% Get avg(V*hFac)
  	field = read_slice(loadFile.UV, parent.nx0, parent.ny0, ...
						[1:parent.nz]+parent.nz, precision.UV);

	% NaN-out bottom regions before getting the area-averaged velocity.
	field(iBot.V) = NaN;
	% Compute V* = avg(V*hFac)/hFac0.
	field = field./hFacS;
	VVEL = get_aste_faces(field, parent.nx, parent.ny);

	% Write a message.
	year  = fileTimez(iFile, 1);
	month = fileTimez(iFile, 2);
	day   = fileTimez(iFile, 3) + 1;  % I am not sure we should add 1, but it seems right.

	disp(['        Loaded 3D parent model fields from ' datestr([year month day 0 0 0]), ...
			' (time = ' num2str(toc(t2), '%6.3f'), ' s)']), 
  
	% For each time point, cut out all open boundary conditions.
	for iOb = 1:parent.nOb

		% ii and jj are *local* indices on the *parent* grid.  
		[ii, jj] = getOpenBoundaryIndices(obij{iOb}, 'local', parent.offset);
		
		% Pull out face index for convenience.
		face = obij{iOb}.face;

		% obuv{iOb}.(T, S, U, V) have been initialized. Now extract from 3D ASTE fields.
		obuv{iOb}.T1(:, :, iit) = squeeze(THETA{face}(ii.T1, jj.T1, :));
		obuv{iOb}.T2(:, :, iit) = squeeze(THETA{face}(ii.T2, jj.T2, :));

		obuv{iOb}.S1(:, :, iit) = squeeze(SALT {face}(ii.T1, jj.T1, :));
		obuv{iOb}.S2(:, :, iit) = squeeze(SALT {face}(ii.T2, jj.T2, :));

		obuv{iOb}.U (:, :, iit) = squeeze(UVEL{face} (ii.U,  jj.U,  :));
		obuv{iOb}.V (:, :, iit) = squeeze(VVEL{face} (ii.V,  jj.V,  :));

		% Store the time at which the time-step was taken.
		obuv{iOb}.time(iit, :) = fileTimez(iFile, :);
	end
end

% Final message.
disp(['   ... done extracting boundary conditions. (time = ' num2str(toc(t1), '%6.3f') ' s)'])
