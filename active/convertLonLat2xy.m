function [xx, yy] = convertLonLat2xy(lon, lat)

% ----------------------------------------------------------------------------- 
% Convert latitude and longitude coordinates to tangent plane 
% Cartesian coordinates.
%
%	Inputs:
%       lon : nlat x nlon matrix of longitudes in degs
%       lat : nlat x nlon matrix of latitudes in degs
%
%   Outputs:
%       xx  : nlat x nlon matrix of east-west coordinates in meters.
%       yy  : nlat x nlon matrix of south-north coordinates in meters.
%
% ----------------------------------------------------------------------------- 

% Size of arrays.
[nx, ny] = size(lon);

% This scaling from wikipedia converts Latitude and Longitude to meters.
lat2meters = 111132.92 - 559.82*cosd(2*lat) - 93.5*cosd(3*lat);
lon2meters = 111412.84*cosd(lat) - 93.5*cosd(3*lat) - 0.118*cosd(5*lat);

% Calculate matrices of the grid spacing in lat,lon.
dlon = lon(:, 2:end) - lon(:, 1:end-1);
dlat = lat(2:end, :) - lat(1:end-1, :);

% Convert grid-spacing matrices from lat,lon to x,y.
dx = dlon * 1/2*( lon2meters(:, 1:end-1) + lon2meters(:, 2:end) );
dy = dlat * 1/2*( lat2meters(1:end-1, :) + lat2meters(2:end, :) );

% Convert grid spacing to coordinates, with zeros at the corners.
xx = cat(2, zeros(ny, 1), cumsum(dx, 2));
yy = cat(1, zeros(1, nx), cumsum(dy, 1));
