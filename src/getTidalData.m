function obij = getTidalData(obij, startdate)

% input:
%   obij      - boundary structure
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
addpath('/net/barents/raid16/vocana/llc4320/NA2160x1080/run_template/joernc/tides/tmd_mar_203/TMD2.03');

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

  % get coordinates of boundary velocity points
  switch obij{i}.edge
    case 'north'
      x_u = obij{i}.xC1;
      y_u = obij{i}.yC1;
      x_v = obij{i}.xG;
      y_v = obij{i}.yG;
    case 'south'
      x_u = obij{i}.xC2;
      y_u = obij{i}.yC2;
      x_v = obij{i}.xG;
      y_v = obij{i}.yG;
    case 'east'
      x_u = obij{i}.xG;
      y_u = obij{i}.yG;
      x_v = obij{i}.xC2;
      y_v = obij{i}.yC2;
    case 'west'
      x_u = obij{i}.xG;
      y_u = obij{i}.yG;
      x_v = obij{i}.xC1;
      y_v = obij{i}.yC1;
  end

  % extract amplitude, phase, h, constituent list
  [obij{i}.am_u, obij{i}.ph_u, h_u, obij{i}.cl_u] = tmd_extract_HC( ...
      'DATA/Model_tpxo7.2', y_u, x_u, grd_u(2));
  [obij{i}.am_v, obij{i}.ph_v, h_v, obij{i}.cl_v] = tmd_extract_HC( ...
      'DATA/Model_tpxo7.2', y_v, x_v, grd_v(2));

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
