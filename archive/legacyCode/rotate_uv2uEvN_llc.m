function [uE,vN]=rotate_uv2uEvN_llc(u,v,AngleCS,AngleSN,nx,ny,nz)
%-------------------
%[uE,vN]=rotate_uv2uEvN_llc(u,v,AngleCS,AngleSN,nx,ny,nz)
%input:
%  [u,v]        : original compact format
%  Angle[CS,SN] : Angle[CS,SN], in compact format
%  [nx,ny,nz]   : size of [u,v]
%output:
%  [uE,vN]      : compact format size [nx ny nz]
%-------------------

%centering
[uc,vc]=centering_llcuv(u,v,nx,ny,nz);

%put from faces into compact, overwriting [u,v]
u=cat(2,uc{1},uc{2},uc{3},reshape(uc{4},nx,3*nx,nz),reshape(uc{5},nx,3*nx,nz));
v=cat(2,vc{1},vc{2},vc{3},reshape(vc{4},nx,3*nx,nz),reshape(vc{5},nx,3*nx,nz));

%rotate
u=reshape(u,nx*ny,nz);
v=reshape(v,nx*ny,nz);
for k=1:nz
  uE(:,k)=AngleCS(:).*u(:,k)-AngleSN(:).*v(:,k);
  vN(:,k)=AngleSN(:).*u(:,k)+AngleCS(:).*v(:,k);
end;

uE=reshape(uE,nx,ny,nz);
vN=reshape(vN,nx,ny,nz);

return

