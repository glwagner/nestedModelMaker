function Fout=compute_gate_transport(vel,ds,dz,hfac)

%-------------
%function Fout=compute_gate_transport(vel,ds,dz,hfac)
%
% Input:
%    vel  [ns nz nt]
%    ds   [ns 1]
%    dz   [1  nz]
%    hfac [ns nz]

% Fout: vol transport m^3/s = vel*ds*dz*hfac
%-------------

L1=length(ds);
L2=length(dz);
if(size(hfac,1)==L2 & size(hfac,2)==L1);
  hfac=hfac';
end;

if(size(hfac,1)~=L1 & size(hfac,2)~=L2);
  error('wrong size hfac');
end

sz=size(vel);
if(sz(2)==L1 & sz(1)==L2);
  vel=permute(vel,[2 1 3]);
end;
if(size(vel,1)~=L1&size(vel,2)~=L2);
  error('wrong size vel');
end;

if(size(ds,2)==L1);ds=ds';end;
if(size(dz,1)==L2);dz=dz';end;

inan=find(isnan(hfac(:))==1);
if(length(inan)>0);hfac(inan)=0;end;

nt=size(vel,3);
[dzp,dsp]=meshgrid(dz,ds);
dzp=repmat(dzp,[1 1 nt]);
dsp=repmat(dsp,[1 1 nt]);
hfac=repmat(hfac,[1 1 nt]);

%check nan
inan=find(isnan(vel(:))==1);
if(length(inan)>0);vel(inan)=0;end;

transp=vel.*dzp.*dsp.*hfac;
Fout=reshape(transp,L1*L2,nt);
Fout=sum(Fout,1);

return
