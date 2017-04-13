function [SALT, THETA, UVEL, VVEL] = loadInitialParentFields(dirz, parent, child);

% File manipulation and initialization  - - - - - - - - - - - - - - - - - - - - 
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

% Load fields - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
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
