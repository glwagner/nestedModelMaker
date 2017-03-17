function [aam, aph] = tidalConversionCorrection(time, aam, aph, cl)

% This conversion and correction ensures that the MITgcm will predict the same
% tides as the TMD routine tmd_tide_pred. The MITgcm tidal predictor is:
% amp*cos(2*pi*(t-ph)/period), where amp and phase are the arguments passed via
% input files and t is the time since model start in seconds.
% INPUT:
%   time - model start time in days, e.g. datenum(2012,1,1)
%   aam  - amplitude as obtained from tmd_extract_HC
%   aph  - phase as obtained from tmd_extract_HC
%   cl   - constituent list as obtained from tmd_extract_HC
% OUTPUT:
%   aam  - corrected amplitude
%   aph  - converted and corrected phase, which now is a time lag
% EXAMPLE:
%   [vam,vph,h,cl] = tmd_extract_HC('DATA/Model_tpxo7.2',lat,lon,'v');
%   [vam,vph] = conv_corr(datenum(2012,1,1),vam,vph,cl)

  % get nodal corrections
  [pu, pf] = nodal(time - datenum(1992,1,1) + 48622, cl);
  % loop through constituents
  for i = 1:length(cl)
    % get constituent data
    [ispec, am, ph, omega, alpha, constitNum] = constit(cl(i,:));
    % nodal correction to amplitude (and conversion to m/s)
    aam(i,:) = pf(i)*aam(i,:)/100;
    % phase conversion to time lag and nodal correction
    aph(i,:) = -(ph+pu(i)-aph(i,:)*pi/180)/omega - (time-datenum(1992,1,1))*86400;
  end

end
