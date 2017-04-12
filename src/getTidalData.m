function childObTides = getTidalData(childObij, startdate)

% input:
%   childObij - boundary structure
%   startdate - model start date to match tidal phase (e.g. datenum(2012, 1, 1))
% output
%   Appends to childObij the following fields:
%     .am_u - amplitudes of grid-zonal velocities
%     .am_v - amplitudes of grid-meridional velocities
%     .ph_u - phases of grid-zonal velocities
%     .ph_v - phases of grid-meridional velocities
%     .cl_u - constituent list for grid-zonal velocities
%     .cl_v - constituent list for grid-meridional velocities

% Test whether this is doing the right thing:
%   % what is done in this function
%   [vam,vph,h,cl] = tmd_extract_HC('DATA/Model_tpxo7.2',35,-60,'z');
%   [vam,vph] = conv_corr(datenum(2012,1,1),vam,vph,cl);
%   % predict M2 tide at 35N/60W at 6am on 2012-01-01 using TMD
%   tmd_tide_pred('DATA/Model_tpxo7.2',datenum(2012,1,1)+6/24,35,-60,'z',[1])
%   % predict tide as in MITgcm
%   [ispec,am,ph,omega,alpha,constitNum] = constit(cl(1,:));
%   vam(1)*cos(omega*(6*3600-vph(1)))*100
%   % predict K1 tide at 35N/60W at 6am on 2012-01-01 using TMD
%   tmd_tide_pred('DATA/Model_tpxo7.2',datenum(2012,1,1)+6/24,35,-60,'z',[5])
%   % predict tide as in MITgcm
%   [ispec,am,ph,omega,alpha,constitNum] = constit(cl(5,:));
%   vam(5)*cos(omega*(6*3600-vph(5)))*100

% add path to Tidal Model Driver v2.03 (http://polaris.esr.org/ptm_index.html)
% ***need to make TMD available to put relative path here***
addpath(genpath('/net/barents/raid16/vocana/llc4320/NA2160x1080/run_template/joernc/tides/tmd_mar_203/TMD2.03'));

% loop over boundaries
for i = 1:length(childObij)

  % select normal velocity component depending on face
  switch childObij{i}.face
    case 1
      grd_u = '+u';
      grd_v = '+v';
    case 5
      grd_u = '-v';
      grd_v = '+u';
    otherwise
      error('Face number %d is not implemented.', childObij{i}.face);
  end

  % get coordinates of boundary velocity points (tangential velocities are
  % prescribed at the first wet point)
  % Check whether these are the right coordinates!!!
  switch childObij{i}.edge
    case {'north', 'south'}
      switch childObij{i}.face
        case 1
          x_u = childObij{i}.xG(1:end-1);
          y_u = childObij{i}.yC1;
          x_v = childObij{i}.xC1;
          y_v = childObij{i}.yG(1:end-1);
        case 5
          x_u = childObij{i}.xC1;
          y_u = childObij{i}.yG(1:end-1);
          x_v = childObij{i}.xG(1:end-1);
          y_v = childObij{i}.yC1;
        otherwise
          error('Face number %d is not implemented.', childObij{i}.face);
      end
    case {'east', 'west'}
      switch childObij{i}.face
        case 1
          x_u = childObij{i}.xG(1:end-1);
          y_u = childObij{i}.yC1;
          x_v = childObij{i}.xC1;
          y_v = childObij{i}.yG(1:end-1);
        case 5
          x_u = childObij{i}.xC1;
          y_u = childObij{i}.yG(1:end-1);
          x_v = childObij{i}.xG(1:end-1);
          y_v = childObij{i}.yC1;
        otherwise
          error('Face number %d is not implemented.', childObij{i}.face);
      end
  end

  % extract amplitude, phase, h, constituent list
  [childObTides{i}.am_u, childObTides{i}.ph_u, h_u, childObTides{i}.cl_u] = ...
      tmd_extract_HC('DATA/Model_tpxo7.2', y_u, x_u, grd_u(2));
  [childObTides{i}.am_v, childObTides{i}.ph_v, h_v, childObTides{i}.cl_v] = ...
      tmd_extract_HC('DATA/Model_tpxo7.2', y_v, x_v, grd_v(2));

  % convert to phase referenced to model start date, apply nodal corrections
  [childObTides{i}.am_u, childObTides{i}.ph_u] = tidalConversionCorrection( ...
      startdate, childObTides{i}.am_u, childObTides{i}.ph_u, ...
      childObTides{i}.cl_u);
  [childObTides{i}.am_v, childObTides{i}.ph_v] = tidalConversionCorrection( ...
      startdate, childObTides{i}.am_v, childObTides{i}.ph_v, ...
      childObTides{i}.cl_v);

  % adjust sign for rotated grid if necessary
  if grd_u(1) == '-'
    childObTides{i}.am_u = -childObTides{i}.am_u;
  end
  if grd_v(1) == '-'
    childObTides{i}.am_v = -childObTides{i}.am_v;
  end

  % replace NaNs with zeros in amplitudes
  childObTides{i}.am_u(isnan(childObTides{i}.am_u)) = 0;
  childObTides{i}.am_v(isnan(childObTides{i}.am_v)) = 0;

  % replace NaNs with zeros in phases
  childObTides{i}.ph_u(isnan(childObTides{i}.ph_u)) = 0;
  childObTides{i}.ph_v(isnan(childObTides{i}.ph_v)) = 0;

end

end
