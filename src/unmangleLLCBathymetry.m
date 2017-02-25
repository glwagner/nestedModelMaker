function bathy = unmangleLLCBathymetry(bathy, face)

% ----------------------------------------------------------------------------- 
% unmangleLLCBathymetry.m
%
% This function 'unmangles' the bathymetry obtained by extraction from the 
% read_llc_fkij function, modifying the bathymetry data so indexing is 
% consistent with other horizontal grid files (like xC, yC, etc.)
%
% Inputs:
%   bathy   : 2D matrix of bathymetry data for one face on the llc grid.
%   face    : an integer indicating the face on which the bathymetry lives.
%
% Output:
%   bathy   : A bathymetry file with modifications depending on the value of
%             "face". For all faces the convention that bathymetry is 'negative'
%             (thus living on a Cartesian grid in which positive z points 'up').
%             For face 1, 2, and 3, nothing else needs to be done. For 
%             face 4, 5, the rows and columns are exchanged, and then the 
%             direction of column indexing is reversed. 
% ----------------------------------------------------------------------------- 

if face < 1 || face > 5
    error('Check your specification of the bathymetry''s face')
end

% Ensure convention that bathymetry/depth is negative.
bathy = -abs(bathy);

% Unmangle column/row indexing convention.
switch face
    case {1, 2}
        % Do nothing.
    case {4, 5}
        % Exchange column and row.
        bathy = permute(bathy, [2 1]);
        % Reverse column indexing.
        bathy = flipud(bathy);
    case 3
        % Do nothing.
end
