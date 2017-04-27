function [fcompact,faces]=aste_tracer2compact(aste,nfx,nfy);
%------------
%function [fcompact,faces]=aste_tracer2compact(aste,nfx,nfy);
% In:
% nfx: [270 0 270 180 450]
% nfy: [450 0 270 270 270]
% aste: aste domain size [nx*2 nfy(1)+nfy(3)+nfx(4)+nfx(5),nz]
%
% Out:
% compact format [270 1350 nz]
% ATN 19-Feb-2013 ------------

nx=nfx(3);
if(nx==0);nx=nfx(1);end;
[tempx tempy nz]=size(aste);
if((nfy(1)+nfy(3)+nfx(4))~=tempy);
  error('inconsistent nfx or nfy versus size aste');
  return
else;

%initialize:
  f{1}=nan(nfx(1),nfy(1),nz);f{2}=[];f{3}=nan(nx,nx,nz);
  f{4}=nan(nfx(4),nfy(4),nz);f{5}=nan(nfx(5),nfy(5),nz);

%filling
  f{1}=aste(nx+1:2*nx,1:nfy(1),:);
  for k=1:nz;
    if(nfx(3)>0);
    clear temp;temp=sym_g_mod(aste(nx+1:2*nx,nfy(1)+1:nfy(1)+nfx(3)+nfx(4),k),7,0);
    f{3}(:,:,k)=temp(1:nfx(3),1:nfy(3));
    f{4}(:,:,k)=temp(nx+1:nx+nfx(4),1:nfy(4));
    else;
     f{3}=[];
     f{4}=[];
    end;
    clear temp;temp=sym_g_mod(aste(1:nx,1:nfx(5),k),5,0);f{5}(:,:,k)=temp;
  end;

  if(nfx(3)>0);
  fcompact=[f{1},f{3},reshape(f{4},nfy(4),nfx(4),nz),reshape(f{5},nfy(5),nfx(5),nz)];
  else;
  fcompact=[f{1},reshape(f{5},nfy(5),nfx(5),nz)];
  end;
  faces=f;
  
end;

return

