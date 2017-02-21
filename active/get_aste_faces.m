function [ff]=get_aste_faces(F,nfx,nfy)
%=========================================
% function [ff]=get_aste_faces(F,nfx,nfy)
% ATN 14-Sep-2012
% function to get 5faces of ASTE domain for tracers
% Input:
% 	F: compact form, obtained from S=readbin(fileinS,[nx ny nz],1,'real*8');
%        A) If already in aste compact size, for llc270 it's [270 1350 50]
%              e.g., for aste_270x450x180, [nx,ny,nz]=[270 1350 50]
%	    B) If in global size, it's [270 270*13 50]
%              e.g., for global, [nx,ny,nz]=[270 3510 50]
%
%    nfx:	     actual x-size of aste faces: [270 0 270 180 450]
%    nfy:		actual y-size of aste faces: [450 0 270 270 270]
%    
% Output:
%   ff    : 5 faces {1}(nx 450 nz) {2}(0 0 nz) {3}(nx nx nz)
%                   {4}(180 nx nz) {5}(450 nx nz)
%===========================================================

[nx,ny,nz]=size(F);

%-------- order stored in compact format ---------------
nfx1=[nfx(1) nfx(2) nfx(3) nfy(4) nfy(5)];
nfy1=[nfy(1) nfy(2) nfy(3) nfx(4) nfx(5)];

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
  ff=[];
  fprintf('Wrong size for F: [nx ny nz]=[%i %i %i]\n',[nx ny nz]);
  fprintf('Need F [%i %i %i](aste) or [%i %i %i](global)\n',...
          [nfx(1) sum(nfy1) nz nfx(1) 13*nfx(1) nz]);
  error('wrong size for F');
end;

return

