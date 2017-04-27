function [Fnew,ff]=get_aste_tracer(F,nfx,nfy)
%=========================================
% function [Fnew,ff]=get_aste_tracer(F,nfx,nfy)
% ATN 14-Sep-2012
% function to get 1 big ASTE domain for tracers
% Input:
% 	F: (A) compact form, obtained from S=readbin(fileinS,[nx ny nz],1,'real*8');
%        A1) If already in aste compact size, for llc270 it's [270 1350 50]
%              e.g., for aste_270x450x180, [nx,ny,nz]=[270 1350 50]
%	 A2) If in global size, it's [270 270*13 50]
%              e.g., for global, [nx,ny,nz]=[270 3510 50]
%
%          (B) 5 faces from ASTE domain
%    nfx:	     actual x-size of aste faces: [270 0 270 180 450]
%    nfy:		actual y-size of aste faces: [450 0 270 270 270]
%    
% Output:
%   [Fnew]: size [2*270 450+270+180]
%   ff    : 5 faces {1}(nx 450 nz) {2}(0 0 nz) {3}(nx nx nz)
%                   {4}(180 nx nz) {5}(450 nx nz)
%===========================================================

%HORIZONTAL extent of face5 to mid-left, smaller = more CAA is included
fac1=13/18;%fac=15/18;%fac=7/9;%fac=2/3;
%VERTICAL extent of face5 to mid-left, higher = more CAA is included
fac2=16/18;%16/18 is good. 17/18 is too much, 15/18 is not enough

%-------- order stored in compact format ---------------
nfx1=[nfx(1) nfx(2) nfx(3) nfy(4) nfy(5)];
nfy1=[nfy(1) nfy(2) nfy(3) nfx(4) nfx(5)];

%test class
aa=whos('F');
bb=strmatch(aa.class,'double');
if(bb==1);

[nx,ny,nz]=size(F);
%-------- put compact form into faces: -----------------
if(sum(nfy1)==ny);				%already in aste geometry
  ff{1}=F(1:nfx1(1),1:nfy1(1),: );
  ff{3}=F(1:nfx1(3),sum(nfy1(1:2))+1:sum(nfy1(1:3)),: );
  ff{4}=reshape( F(1:nfx1(4),sum(nfy1(1:3))+1:sum(nfy1(1:4)),: ) , nfx(4),nfy(4),nz );
  ff{5}=reshape( F(1:nfx1(5),sum(nfy1(1:4))+1:sum(nfy1(1:5)),: ) , nfx(5),nfy(5),nz );
elseif(ny/nx==13);					%from global llc
  ff{1}=F( :,3*nx-nfy1(1)+1:3*nx,: );
  ff{3}=F( :,6*nx+1:7*nx,: );
  ff{4}=reshape( F( :, 7*nx+1:10*nx,: ) ,3*nx,nx,nz );ff{4}=ff{4}(1:nfy1(4),:,:);
  ff{5}=reshape( F( :,10*nx+1:13*nx,: ) ,3*nx,nx,nz );ff{5}=ff{5}(1:nfy1(5),:,:);
else
  fprintf('Wrong size for F: [nx ny nz]=[%i %i %i]\n',[nx ny nz]);
  fprintf('Need F [%i %i %i](aste) or [%i %i %i](global)\n',...
          [nfx(1) sum(nfy1) nz nfx(1) 13*nfx(1) nz]);
  error('wrong size for F');
end;
else;
  nx=0;nz=0;
  for k=1:5;
    ff{k}=F{k};
    sz=size(ff{k});if(length(sz)==2);sz=[sz 1];end;
    nx=max(nx,sz(1));
    nz=max(nz,sz(3));
  end;
end;

%================================================================ 
%================================================================ 
%================================================================ 
%============= putting all on 1 big matrix ======================


Fnew=nan(nfy(5)+nfx(1),nfy(1)+nfx(3)+nfx(4),nz);

%lower right corner: face 1
Fnew(nfy(5)+1:nfy(5)+nfx(1),1:nfy(1),1:nz) = ff{1};

%for k=1:nz
% lower left corner, face 5, rotated 90deg clockwise (use Gael's sym_g)
  Fnew(1:nfy(5),1:nfx(5),:)= sym_g_mod(ff{5},7,0);

  if(size(ff{3},1)>0&size(ff{3},2)>0);
% mid left: face 3, rot 180deg
  Fnew(1:nfx(3),nfx(5)+1:nfx(5)+nfy(3),:)=sym_g_mod(ff{3},6,0);

  clear temp iaste jaste iface jface
  temp=sym_g_mod(ff{5},6,0);
  iaste=round([nfy(5)*fac1+1,nfy(5)]);jaste=round([nfx(5)+(1-fac2)*nfy(5)-4,nfx(5)+nfy(5)]);
  iface=round([nfx(5)-nfy(5)*(1-fac1)+1,nfx(5)]);jface=round([(1-fac2)*nfy(5)-4,nfy(5)]);

  Fnew(iaste(1):iaste(2),jaste(1):jaste(2),:)=...
	temp(iface(1):iface(2),jface(1):jface(2),:);

% mid right: face 3, rot 90deg ccw
  Fnew(nfy(5)+1:nfy(5)+nfx(1),nfy(1)+1:nfy(1)+nfx(3),:)=sym_g_mod(ff{3},5,0);

% upper right corner, face 4 (Bering Strait), rot 90deg ccw:
  if(size(ff{4},1)>0&size(ff{4},2)>0);
    Fnew(nfy(5)+1:nfy(5)+nfx(1),nfy(1)+nfx(3)+1:nfy(1)+nfx(3)+nfx(4),:)=sym_g_mod(ff{4},5,0);
  end;
  end;

%end;

return

