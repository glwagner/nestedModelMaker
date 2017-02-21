function [Unew,Vnew]=get_aste_vector(U,V,nfx,nfy,sign_switch)
%=========================================
% function [Unew,Vnew]=get_aste_vector(U,V,nfx,nfy,sign_switch)
% ATN 14-Sep-2012
% function to get 1 big ASTE domain for vectors
% Input:
% 	U: compact form, obtained from U=readbin(fileinU,[nx ny nz],1,'real*8');
% 	V: compact form, obtained from V=readbin(fileinV,[nx ny nz],1,'real*8');
%        A) If already in aste compact size, for llc270 it's [270 1350 50]
%              e.g., for aste_270x450x180, [nx,ny,nz]=[270 1350 50]
%        B) If in global size, it's [270 270*13 50]
%              e.g., for global, [nx,ny,nz]=[270 3510 50]
%        C) also allows in faces (4.Jan.2017)
%
%    nfx:	     actual x-size of aste faces: [270 0 270 180 450]
%    nfy:		actual y-size of aste faces: [450 0 270 270 270]
%    sign_switch: 1 for U/V fields, 0 for DX,DY fields
%    
% [Unew,Vnew]: size [2*270+1 450+270+180+1] = [541 901]
%===========================================================

%HORIZONTAL extent of face5 to mid-left, smaller = more CAA is included
fac1=13/18;%fac=15/18;%fac=7/9;%fac=2/3;
%VERTICAL extent of face5 to mid-left, higher = more CAA is included
fac2=16/18;%16/18 is good. 17/18 is too much, 15/18 is not enough

%check type
temp=whos('U');
if(strcmp(temp.class,'double')==1);
[nx,ny,nz]=size(U);

%-------- order stored in compact format ---------------
nfx1=[nfx(1) nfx(2) nfx(3) nfy(4) nfy(5)];
nfy1=[nfy(1) nfy(2) nfy(3) nfx(4) nfx(5)];

%-------- put compact form into faces: -----------------
if(sum(nfy1)==ny);                 %already in aste geometry
  ffu{1}=U( :,1:nfy1(1),: );
  if(nfx(3)>0);
  ffu{3}=U( :,sum(nfy1(1:2))+1:sum(nfy1(1:3)),: );
  end;
  if(nfx(4)>0);
  ffu{4}=reshape( U( :,sum(nfy1(1:3))+1:sum(nfy1(1:4)),: ) , nfx(4),nfy(4),nz );
  end;
  ffu{5}=reshape( U( :,sum(nfy1(1:4))+1:sum(nfy1(1:5)),: ) , nfx(5),nfy(5),nz );

  ffv{1}=V( :,1:nfy1(1),: );
  if(nfx(3)>0);
  ffv{3}=V( :,sum(nfy1(1:2))+1:sum(nfy1(1:3)),: );
  end;
  if(nfx(4)>0);
  ffv{4}=reshape( V( :,sum(nfy1(1:3))+1:sum(nfy1(1:4)),: ) , nfx(4),nfy(4),nz );
  end;
  ffv{5}=reshape( V( :,sum(nfy1(1:4))+1:sum(nfy1(1:5)),: ) , nfx(5),nfy(5),nz );
elseif(ny/nx==13);                      %from global llc
  ffu{1}=U( :,3*nx-nfy1(1)+1:3*nx,: );
  ffu{3}=U( :,6*nx+1:7*nx,: );
  ffu{4}=reshape( U( :, 7*nx+1:10*nx,: ) ,3*nx,nx,nz );ffu{4}=ffu{4}(1:nfy1(4),:,:);
  ffu{5}=reshape( U( :,10*nx+1:13*nx,: ) ,3*nx,nx,nz );ffu{5}=ffu{5}(1:nfy1(5),:,:);

  ffv{1}=V( :,3*nx-nfy1(1)+1:3*nx,: );
  ffv{3}=V( :,6*nx+1:7*nx,: );
  ffv{4}=reshape( V( :, 7*nx+1:10*nx,: ) ,3*nx,nx,nz );ffv{4}=ffv{4}(1:nfy1(4),:,:);
  ffv{5}=reshape( V( :,10*nx+1:13*nx,: ) ,3*nx,nx,nz );ffv{5}=ffv{5}(1:nfy1(5),:,:);
else
  fprintf('Wrong size for U: [nx ny nz]=[%i %i %i]\n',[nx ny nz]);
  fprintf('Need U [%i %i %i](aste) or [%i %i %i](global)\n',...
          [nfx(1) sum(nfy1) nz nfx(1) 13*nfx(1) nz]);
  error('wrong size for U');
end;
else;%cell
  %just assign the faces:
  nz=0;nx=0;
  for iface=1:5;
    ffu{iface}=U{iface};
    ffv{iface}=V{iface};
    nz=max(nz,size(U{iface},3));
    if(iface<4);nx=max(nx,size(U{iface},1));end;
  end;
end;

%================================================================ 
%================================================================ 
%================================================================ 
%================== putting all on 1 big matrix =================

Unew=nan(nfy(5)+nfx(1),nfy(1)+nfx(3)+nfx(4),nz);
Vnew=nan(nfy(5)+nfx(1),nfy(1)+nfx(3)+nfx(4),nz);

%lower right corner: face 1
Unew(nfy(5)+1:nfy(5)+nfx(1),1:nfy(1),1:nz) = ffu{1};
Vnew(nfy(5)+1:nfy(5)+nfx(1),1:nfy(1),1:nz) = ffv{1};

%for k=1:nz
% lower left corner, face 5, rotated 90deg clockwise (use Gael's sym_g)
% v -> new_u, -u -> new_v
  Unew(1:nfy(5),1:nfx(5),:)= sym_g_mod(ffv{5},7,0);
  Vnew(1:nfy(5),1:nfx(5),:)=-sym_g_mod(ffu{5},7,0);

% mid left: face 3, rot 180deg
% -u -> new_u, -v -> new_v
  if(sum(size(ffu{3}))>0);
  Unew(1:nfx(3),nfx(5)+1:nfx(5)+nfy(3),:)=-sym_g_mod(ffu{3},6,0);
  Vnew(1:nfx(3),nfx(5)+1:nfx(5)+nfy(3),:)=-sym_g_mod(ffv{3},6,0);

  clear tempu tempv iaste jaste iface jface
  tempu=-sym_g_mod(ffu{5},6,0); tempv=-sym_g_mod(ffv{5},6,0);
  iaste=round([nfy(5)*fac1+1,nfy(5)]);jaste=round([nfx(5)+(1-fac2)*nfy(5)-4,nfx(5)+nfy(5)]);
  iface=round([nfx(5)-nfy(5)*(1-fac1)+1,nfx(5)]);jface=round([(1-fac2)*nfy(5)-4,nfy(5)]);

  Unew(iaste(1):iaste(2),jaste(1):jaste(2),:)=...
	tempu(iface(1):iface(2),jface(1):jface(2),:);
  Vnew(iaste(1):iaste(2),jaste(1):jaste(2),:)=...
	tempv(iface(1):iface(2),jface(1):jface(2),:);

% mid right: face 3, rot 90deg ccw
% u -> new_v, -v -> new_u
  Unew(nfy(5)+1:nfy(5)+nfx(1),nfy(1)+1:nfy(1)+nfx(3),:)=-sym_g_mod(ffv{3},5,0);
  Vnew(nfy(5)+1:nfy(5)+nfx(1),nfy(1)+1:nfy(1)+nfx(3),:)= sym_g_mod(ffu{3},5,0);

% upper right corner, face 4 (Bering Strait), rot 90deg ccw:
% u -> new_v, -v -> new_u
  if(sum(size(ffu{4}))>0);
  Unew(nfy(5)+1:nfy(5)+nfx(1),nfy(1)+nfx(3)+1:nfy(1)+nfx(3)+nfx(4),:)=-sym_g_mod(ffv{4},5,0);
  Vnew(nfy(5)+1:nfy(5)+nfx(1),nfy(1)+nfx(3)+1:nfy(1)+nfx(3)+nfx(4),:)= sym_g_mod(ffu{4},5,0);
  end;
  end;
%end;

if(sign_switch==0);	%if no need to flip sign, as in case of [DX,DY]
  Unew=abs(Unew);
  Vnew=abs(Vnew);
end;

%13-Mar-2013: need to shift 1 grid pt in some faces due to c-grid:
% uq=nan(size(up));						% vq=nan(size(vp));                       
% uq(1:540,1:450)=up(1:540,1:450);           % vq(271:540,1:900)=vp(271:540,1:900);
% uq(1:224,451:720)=up(2:225,451:720);       % vq(1:270,2:451)=vp(1:270,1:450);
% uq(226:540,451:720)=up(225:539,451:720);   % vq(1:225,452:721)=vp(1:225,451:720);
% uq(272:540,721:900)=up(271:539,721:900);   % vq(226:270,452:721)=vp(226:270,451:720);
                                             
up=Unew;sz=size(up);if(length(sz)<3);sz=[sz 1];end;			%[540 900 nz]
uq=nan(sz(1)+1,sz(2)+1,sz(3));							%[541,901 nz]
%keep everything in y-dir from 1-450, ix goes from 1:540, ignore 541
uq(1:nx*2,1:nfy(1),:)=up(1:nx*2,1:nfy(1),:);
%for y-dir 450, what was called ix=1 should now be reassigned ix=2 
%shift everything 1 grid to the right
uq(2:nx*2+1,nfy(1)+1:sz(2),:)=up(1:nx*2,nfy(1)+1:sz(2),:);

%uq(1:fac*nx-1,nfy(1)+1:nfy(1)+nfx(3),:)=up(2:fac*nx,nfy(1)+1:nfy(1)+nfx(3),:);
%uq(fac*nx+2:2*nx,nfy(1)+1:nfy(1)+nfx(3),:)=up(fac*nx+1:2*nx-1,nfy(1)+1:nfy(1)+nfx(3),:);
%uq(nx+2:2*nx,nfy(1)+nfx(3)+1:nfy(1)+nfx(3)+nfx(4),:)=up(nx+1:2*nx-1,nfy(1)+nfx(3)+1:nfy(1)+nfx(3)+nfx(4),:);

vp=Vnew;												%[540 900 nz]
vq=nan(sz(1)+1,sz(2)+1,sz(3));							%[541 901 nz]
%keep everything from ix=271:540, ignore 901
vq(nx+1:2*nx,1:nfy(1)+nfx(3)+nfx(4),:)=vp(nx+1:2*nx,1:nfy(1)+nfx(3)+nfx(4),:);
%shift everything from ix=1:270 1 grid up
vq(1:nx,2:sz(2)+1,:)=vp(1:nx,1:sz(2),:);

%vq(1:nx,2:nfy(1)+1,:)=vp(1:nx,1:nfy(1),:);
%vq(1:fac*nx,nfy(1)+2:nfy(1)+nfx(3)+1,:)=vp(1:fac*nx,nfy(1)+1:nfy(1)+nfx(3),:);
%vq(fac*nx+1:nx,nfy(1)+2:nfy(1)+nfx(3)+1,:)=vp(fac*nx+1:nx,nfy(1)+1:nfy(1)+nfx(3),:);

Unew=uq;%;(1:sz(1),:);
Vnew=vq;%(:,1:sz(2));

return

