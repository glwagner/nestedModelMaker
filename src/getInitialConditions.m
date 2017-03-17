function initialCondition = getInitialConditions(dirz, parent, child)

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
% Load model fields - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
fprintf('Loading parent model fields for interpolation... ')
clear t0, t0 = tic;

% Initialize the files to be loaded for the open boundaries.
tracerFiles = dir([dirz.parentTSdata parent.model.TSname '.*.data']);
velFiles    = dir([dirz.parentUVdata parent.model.UVname '.*.data']);

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

% Load bottom / bathymetry information for the parent model; this allows us
% to store the area-averaged velocity, rather than the area-integrated velocity 
% that ASTE outputs.

% Load hFac's.
hFacC = rdmds([dirz.parentGrid 'hFacC']); 
hFacW = rdmds([dirz.parentGrid 'hFacW']); 
hFacS = rdmds([dirz.parentGrid 'hFacS']); 

% Reshape.
hFacC = reshape(hFacC, parent.nii_asteFormat, parent.njj_asteFormat, parent.nz);
hFacW = reshape(hFacW, parent.nii_asteFormat, parent.njj_asteFormat, parent.nz); 
hFacS = reshape(hFacS, parent.nii_asteFormat, parent.njj_asteFormat, parent.nz); 

% Tranform grid properties into the 'aste' format.  
% Output is a cell array of length 5 for each face..
hFacC_aste = get_aste_faces(hFacC, parent.nii, parent.njj);
hFacW_aste = get_aste_faces(hFacC, parent.nii, parent.njj);
hFacS_aste = get_aste_faces(hFacC, parent.nii, parent.njj);

% Find bottom (where hFac=0) for U, V, and T.
iBot.U = find(hFacW(:)==0);
iBot.V = find(hFacS(:)==0);
iBot.T = find(hFacC(:)==0);

% Get the precision for T, S, U, V from their associated .meta files.
precision.TS = get_precision([dirz.parentTSdata, ...
						 		tracerFiles(1).name(1:end-4) 'meta']);
precision.UV = get_precision([dirz.parentUVdata, ...
						 		velFiles(1).name(1:end-4) 'meta']);

% Set the file index.
iFile = iFile0 - 1 ...
            + 12*(child.tspan.years(1)-parent.model.year0) ...
            + child.tspan.months(1)-parent.model.mnth0;

% File names.
loadFile.TS = [dirz.parentTSdata tracerFiles(iFile).name]; 
loadFile.UV = [dirz.parentUVdata velFiles(iFile).name]; 

% Load entire parent fields.  The function "get_aste_faces" outputs
% a cell array of length five corresponding to each of the faces.

% Get avg(T).
field = read_slice(loadFile.TS, parent.nii_asteFormat, parent.njj_asteFormat, ...
                    1:parent.nz, precision.TS);     
field(iBot.T) = NaN;
THETA = get_aste_faces(field, parent.nii, parent.njj);

% Get avg(S).
field = read_slice(loadFile.TS, parent.nii_asteFormat, parent.njj_asteFormat, ...
                    [1:parent.nz]+parent.nz, precision.TS);
field(iBot.T) = NaN;
SALT = get_aste_faces(field, parent.nii, parent.njj);

% Get avg(U*hFac)
field = read_slice(loadFile.UV, parent.nii_asteFormat, parent.njj_asteFormat, ...
                    1:parent.nz, precision.UV);     
field(iBot.U) = NaN;

% Compute U* = avg(U*hFac)/hFac0
field = field./hFacW;
UVEL = get_aste_faces(field, parent.nii, parent.njj);

% Get avg(V*hFac)
field = read_slice(loadFile.UV, parent.nii_asteFormat, parent.njj_asteFormat, ...
                    [1:parent.nz]+parent.nz, precision.UV);
field(iBot.V) = NaN;

% Compute V* = avg(V*hFac)/hFac0.
field = field./hFacS;
VVEL = get_aste_faces(field, parent.nii, parent.njj);

fprintf('done. (time = %0.3f s)\n', toc(t0))
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
% Interpolation - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
fprintf('Inpaint-NaNs-ing the parent model fields for face '), t0=tic;

% Use inpaint_nans to continue model data into land regions
for face = 1:5
    fprintf('%d... ', face), t1=tic;

    SALT{face}  = inpaint_nans(SALT{face});
    THETA{face} = inpaint_nans(THETA{face});
    UVEL{face}  = inpaint_nans(UVEL{face});
    VVEL{face}  = inpaint_nans(VVEL{face});

    if face ~= 5
        fprintf('(t = %0.3f s), face ', toc(t1))
    end
end
fprintf('(t = %0.3f s).', toc(t1))


% Interpolate.
for face = 1:5
    % Interpolate in z first
    if child.nii(face) ~= 0
        SALT_zInterp{face}  = interp1( parent.zGrid.zC, ...
                                       permute(SALT{face}, [3 1 2]), ...
                                       child.zGrid.zC );

        THETA_zInterp{face} = interp1( parent.zGrid.zC, ...
                                       permute(THETA{face}, [3 1 2]), ...
                                       child.zGrid.zC );

        UVEL_zInterp{face}  = interp1( parent.zGrid.zC, ...
                                       permute(UVEL{face}, [3 1 2]), ...
                                       child.zGrid.zC );

        VVEL_zInterp{face}  = interp1( parent.zGrid.zC, ...
                                       permute(VVEL{face}, [3 1 2]), ...
                                       child.zGrid.zC );

        % Return matrices to indexing form (x, y, z)
        SALT_zInterp{face}  = permute(SALT_zInterp{face},  [2 3 1]);
        THETA_zInterp{face} = permute(THETA_zInterp{face}, [2 3 1]);
        UVEL_zInterp{face}  = permute(UVEL_zInterp{face},  [2 3 1]);
        VVEL_zInterp{face}  = permute(VVEL_zInterp{face},  [2 3 1]);
    end

end

% Memory tricks. 

size(SALT{1})
size(SALT_zInterp{1})

input('Press enter to continue')

% Initialize.
%initialCondition = zeros(child.nii, child.njj, 
        

%{
%% Set initial condition.
for face = 1:5
    % Loop over 'meridional' index, which depends on the face.
    switch face
        % Meridional is index 2.
        case {'1', '2'}
        case {'3', '4' ,'5'}
    end
end

%}


%disp(['        Loaded 3D parent fields for averaging period ending ', ...
%         datestr([year month day 0 0 0]), ...
%        ' (time = ' num2str(toc(t2), '%6.3f'), ' s)']), 
