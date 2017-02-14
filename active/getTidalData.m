function cl = getTidalData(faces, startdate)

% input:
%   faces       - structure containing faces of the child domain
%     .facenumber - face number (1-5)
%     .lonN       - longitudes of northern boundary points
%     .latN       - latitudes of northern boundary points
%     .lonS       - longitudes of southern boundary points
%     .latS       - latitudes of southern boundary points
%     .lonE       - longitudes of eastern boundary points
%     .latE       - latitudes of eastern boundary points
%     .lonW       - longitudes of western boundary points
%     .latW       - latitudes of western boundary points
%   startdate   - model start date to match tidal phase (e.g. datenum(2012, 1, 1))
% output
%   Appends to faces the following fields:
%     .amN - amplitudes of normal velocity at northern boundary
%     .amS - amplitudes of normal velocity at southern boundary
%     .amE - amplitudes of normal velocity at eastern boundary
%     .amW - amplitudes of normal velocity at western boundary
%     .phN - phases of normal velocity at northern boundary
%     .phS - phases of normal velocity at southern boundary
%     .phE - phases of normal velocity at eastern boundary
%     .phW - phases of normal velocity at western boundary
%   All of these contain information on the tital constituents at all boundary points.
%   cl   - tidal constituent list

% add path to Tidal Model Driver v2.03 (http://polaris.esr.org/ptm_index.html)
% ***need to make TMD available to put relative path here***
addpath(genpath('/net/barents/raid16/vocana/llc4320/NA2160x1080/run_template/joernc/tides/tmd_mar_203/TMD2.03'));

% add MITgcm MATLAB utils path
addpath(genpath('/data4/joernc/MITgcm/utils/matlab'))

% loop over faces
for face = faces

  % select normal velocity component depending on face
  switch face.number
    case 1
      vel_EW = 'u'
      vel_NS = 'v'
      sgn_EW = 1
      sgn_NS = -1
    case 5
      vel_EW = 'v'
      vel_NS = 'u'
      sgn_EW = 1
      sgn_NS = -1
    otherwise
      error('Face number %d is not implemented.', face.number)
  end

  % extract amplitude, phase, h, constituent list
  [amN, phN, hN, clN] = tmd_extract_HC('DATA/Model_tpxo7.2', face.latN, face.lonN, vel_NS);
  [amS, phS, hS, clS] = tmd_extract_HC('DATA/Model_tpxo7.2', face.latS, face.lonS, vel_NS);
  [amE, phE, hE, clE] = tmd_extract_HC('DATA/Model_tpxo7.2', face.latE, face.lonE, vel_EW);
  [amW, phW, hW, clW] = tmd_extract_HC('DATA/Model_tpxo7.2', face.latW, face.lonW, vel_EW);

  % convert to phase referenced to model start date, apply nodal corrections
  [amN, phN] = tidalConversionCorrection(startdate, amN, phN, clN);
  [amS, phS] = tidalConversionCorrection(startdate, amS, phS, clS);
  [amE, phE] = tidalConversionCorrection(startdate, amE, phE, clE);
  [amW, phW] = tidalConversionCorrection(startdate, amW, phW, clW);

  % adjust sign for rotated grid if necessary
  amN *= sgn_NS;
  amS *= sgn_NS;
  amE *= sgn_EW;
  amW *= sgn_EW;

  % replace NaNs with zeros in amplitudes
  amN(isnan(amN)) = 0;
  amS(isnan(amS)) = 0;
  amE(isnan(amE)) = 0;
  amW(isnan(amW)) = 0;

  % replace NaNs with zeros in phases
  phN(isnan(phN)) = 0;
  phS(isnan(phS)) = 0;
  phE(isnan(phE)) = 0;
  phW(isnan(phW)) = 0;

  % save amplitudes to structure
  face.amN = amN;
  face.amS = amS;
  face.amE = amE;
  face.amW = amW;

  % save phases to structure
  face.phN = phN;
  face.phS = phS;
  face.phE = phE;
  face.phW = phW;

end

% output constituent list
cl = clN

end
