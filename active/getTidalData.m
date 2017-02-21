function getTidalData(obij, startdate)

% input:
%   obij      - boundary structure
% *** obij{i} need to have lon_u, lat_u, lon_v, lat_v fields! ***
%   startdate - model start date to match tidal phase (e.g. datenum(2012, 1, 1))
% output
%   Appends to obij the following fields:
%     .am_u - amplitudes of grid-zonal velocities
%     .am_v - amplitudes of grid-meridional velocities
%     .ph_u - phases of grid-zonal velocities
%     .ph_v - phases of grid-meridional velocities
%     .cl_u - constituent list for grid-zonal velocities
%     .cl_v - constituent list for grid-meridional velocities

% add path to Tidal Model Driver v2.03 (http://polaris.esr.org/ptm_index.html)
% ***need to make TMD available to put relative path here***
addpath(genpath('/net/barents/raid16/vocana/llc4320/NA2160x1080/run_template/joernc/tides/tmd_mar_203/TMD2.03'));

% loop over boundaries
for i = 1:length(obij)

  % select normal velocity component depending on face
  switch obij{i}.face
    case 1
      grd_u = '+u';
      grd_v = '+v';
    case 5
      grd_u = '-v';
      grd_v = '+u';
    otherwise
      error('Face number %d is not implemented.', obij{i}.face);
  end

  % extract amplitude, phase, h, constituent list
  [obij{i}.am_u, obij{i}.ph_u, h_u, obij{i}.cl_u] = tmd_extract_HC( ...
      'DATA/Model_tpxo7.2', obij{i}.lat_u, obij{i}.lon_u, grd_u(2));
  [obij{i}.am_v, obij{i}.ph_v, h_v, obij{i}.cl_v] = tmd_extract_HC( ...
      'DATA/Model_tpxo7.2', obij{i}.lat_v, obij{i}.lon_v, grd_v(2));

  % convert to phase referenced to model start date, apply nodal corrections
  [obij{i}.am_u, obij{i}.ph_u] = tidalConversionCorrection(startdate, ...
      obij{i}.am_u, obij{i}.ph_u, obij{i}.cl_u);
  [obij{i}.am_v, obij{i}.ph_v] = tidalConversionCorrection(startdate, ...
      obij{i}.am_v, obij{i}.ph_v, obij{i}.cl_v);

  % adjust sign for rotated grid if necessary
  if grd_u(1) == '-'
    obij{i}.am_u = -obij{i}.am_u;
  end
  if grd_v(1) == '-'
    obij{i}.am_v = -obij{i}.am_v;
  end

  % replace NaNs with zeros in amplitudes
  obij{i}.am_u(isnan(obij{i}.am_u)) = 0;
  obij{i}.am_v(isnan(obij{i}.am_v)) = 0;

  % replace NaNs with zeros in phases
  obij{i}.ph_u(isnan(obij{i}.ph_u)) = 0;
  obij{i}.ph_v(isnan(obij{i}.ph_v)) = 0;

end

end
