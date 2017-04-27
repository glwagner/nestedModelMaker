function [rLowCnew,hFacC]=calc_hFacC(rLowC,hFacMin,hFacMinDr,drF,rF)

%----------
%function [rLowCnew,hFacC]=calc_hFacC(rLowC,hFacMin,hFacMinDr,drF,rF)
%
% Input:
%   rLowC : [nx ny] negative (read in rLowC, or take negative of Depth.data)
%   [hFacMin,hFacMinDr] ( = [.2,5])
%   drF   : positive [nz] (from rdmds)
%   rF    : negative [nz+1], from rdmds
%
% Output:
%   hFacC : [nx ny nz] , 1 for ocean, 0 for land
%   rLowCnew: new Depth based on hFacC, NEGATIVE (same sign with input rLowC)
%
% Note: 1. if read in original bathymetry in real*8 and calc rLowCnew and hFacC,
%       hFacC is IDENTICAL to output from MITgcm, and rLowCnew is within 
%       10^-13 from Depth.data
%       2. if read in Depth.data in real*8 and calc rLowCnew and hFacC,
%       hFacC is within 10^-11 to output from MITgcm, and rLowCnew is within
%       10^-13 from Depth.data (which is the input)
%----------

hFacInf=0.1;
hFacSup=5.;
recip_drF=1./drF;

sz=size(rLowC);
nz=length(drF);

hFacC=zeros(sz(1),sz(2),nz);
for k=1:nz
  hFacMnSz=max( hFacMin, min(hFacMinDr*recip_drF(k),1.0) );
%      o Non-dimensional distance between grid bound. and domain lower_R bound.
  hFacCtmp = (rF(k).*ones(size(rLowC))-rLowC)*recip_drF(k);
%      o Select between, closed, open or partial (0,1,0-1)
  hFacCtmp=min( max( hFacCtmp, 0.0) , 1.0);

%      o Impose minimum fraction and/or size (dimensional)
  temp=zeros(size(rLowC));
  clear ii;ii=find(hFacCtmp<hFacMnSz);
  clear ij;ij=find(hFacCtmp>=hFacMnSz);
  if (length(ii)>0);
    clear jj; jj=find(hFacCtmp(ii)<(hFacMnSz*0.5));
    clear kk; kk=find(hFacCtmp(ii)>(hFacMnSz*0.5));
    if (length(jj)>0);temp(ii(jj))=0;end;
    if (length(kk)>0);temp(ii(kk))=hFacMnSz;end;
  end;
  if(length(ij)>0);
    temp(ij)=hFacCtmp(ij);
  end
  hFacC(:,:,k)=temp;
end;

% get rLowCnew
rLowCnew=ones(size(rLowC)).*rF(1);
for k=nz:-1:1
  rLowCnew = rLowCnew - drF(k).*hFacC(:,:,k);
end;

hFacC=squeeze(hFacC);

%C--   hFacW and hFacS (at U and V points)
%%  for k=1:nz
%    hFacW(k)=min(hFacC(i,j,k),hFacC(i-1,j,k));
%    hFacS(i,j,k,bi,bj)=min(hFacC(i,j,k),hFacC(i,j-1,k));
%  end
return
