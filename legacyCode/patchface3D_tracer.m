function [array_out,faces]=patchface3D_tracer(nx,ny,nz,array_in,direction)
% ------------------------------------------------------------------
% function [array_out,faces]=patchface3D(nx,ny,nz,array_in,direction)
%
% input: nx, e.g., 540    or 540*4
%        ny, e.g., 540*13 or 540*4 (nx*13 or nx*4)
%        nz: e.g., 50 levels 
%        array_in : (a) [nx*4 nx*4 nz] (worldmap) or (b) [nx nx*13 nz] (compact)
%                or (c) [nx nx*13 nz] (individual 5 faces put together)
%                   (c) is done as: array_in=[f1,f2,f3,f4',f5'] NOTE PRIME on f4-f5
%                   f[1-5] are exactly as read in from individual 5 face files
%                   e.g., f4=readbin('llc_004_288_96.bin',[289 97 1],1,'real*8');f4=f4(1:3*nx,1:nx)';
%
%        direction: 0 : worldmap array [nx*4 nx*4] to MITgcm compact array [nx nx*13 nz]
%				1 : individual faces [nx nx*13 nz] or {1}-{5} to MITgcm compact form [nx nx*13 nz]
%                   2 : MITgcm compact array [nx nx*13 nz] to world map view [nx*4 nx*4 nz], 
%                   3 : individual faces [nx nx*13 nz] or {1}-{5} to worldmap array [nx*4 nx*4 nz]
%                   
% output: array_out 
%         if direction = 0: size [nx 13*nx nz]
%				   = 1: size [nx 13*nx nz]
%                      = 2: size [nx*4 nx*4 nz]; = [2160 2160 nz] for nx = 540
%                      = 3: size [nx*4 nx*4 nz]; = [2160 2160 nz] for nx = 540
%         faces: face 1 - 5, same orientation as if read in from individual face files
% ------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%% to world map %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%---------------------- 5 faces to world map --------------------------------------
if (direction==2|direction==3);

  if(direction==3);					% [3] from 5 individual faces
    temp=whos('array_in');
    if(strcmp(temp.class,'double'));
      ix=1:nx;iy=1:3*nx;			f{1}=array_in(ix,iy,:);
      ix=1:nx;iy=3*nx+1:6*nx;		f{2}=array_in(ix,iy,:);
      ix=1:nx;iy=6*nx+1:7*nx;		f{3}=array_in(ix,iy,:);
      ix=1:nx;iy=7*nx+1:10*nx;	f{4}=permute(array_in(ix,iy,:),[2,1,3]);
      ix=1:nx;iy=10*nx+1:13*nx;	f{5}=permute(array_in(ix,iy,:),[2,1,3]);
    elseif(strcmp(temp.class,'cell'));
      f=array_in;
    end;
%---------------------- compact array to world map --------------------------------
  elseif(direction==2);				% [2] from MITgcm compact array 
    ix=1:nx;iy=1:3*nx;			f{1}=array_in(ix,iy,:);
    ix=1:nx;iy=3*nx+1:6*nx;		f{2}=array_in(ix,iy,:);
    ix=1:nx;iy=6*nx+1:7*nx;		f{3}=array_in(ix,iy,:);	% arctic: [nx nx]
    ix=1:nx;iy=7*nx+1:10*nx;		f{4}=reshape(array_in(ix,iy,:),3*nx,nx,nz);
    ix=1:nx;iy=10*nx+1:13*nx;		f{5}=reshape(array_in(ix,iy,:),3*nx,nx,nz);
  end;

  array_out=zeros(4*nx,4*nx,nz);
  array_out(1:4*nx,1:3*nx,:)=cat(1,f{1},f{2},sym_g_mod(f{4},7,0),sym_g_mod(f{5},7,0));
  array_out(1:nx,3*nx+1:4*nx,:)=sym_g_mod(f{3},5,0);
  array_out(2*nx+1:3*nx,3*nx+1:4*nx,:)=sym_g_mod(f{3},7,0);
  array_out(3*nx+1:4*nx,3*nx+1:4*nx,:)=sym_g_mod(f{3},6,0);
  faces=f;

%%%%%%%%%%%%%%%%%%%%%%%%%% to MITgcm compact form %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif(direction==0|direction==1); 

%---------------------- 5 faces to compact form --------------------------------------
  if(direction==1);					% [1] from 5 individual faces  [f1,f2,f3,f4',f5']
    temp=whos('array_in');
    if(strcmp(temp.class,'double'));
      ix=1:nx;
      iy=1:3*nx;			f{1}=array_in(ix,iy,:);
      iy=3*nx+1:6*nx;		f{2}=array_in(ix,iy,:);
      iy=6*nx+1:7*nx;		f{3}=array_in(ix,iy,:);
      iy=7*nx+1:10*nx;		f{4}=permute(array_in(ix,iy,:),[2,1,3]);
      iy=10*nx+1:13*nx;		f{5}=permute(array_in(ix,iy,:),[2,1,3]);
    elseif(strcmp(temp.class,'cell'));
      f=array_in;
    end;

%---------------------- world map to compact form ------------------------------------
  elseif(direction==0);				% [0] from worldmap array

    nx=nx/4;
    ix=1:nx;       iy=1:3*nx;	f{1}=array_in(ix,iy,:);			
    ix=nx+1:2*nx;  iy=1:3*nx;	f{2}=array_in(ix,iy,:);		
    ix=2*nx+1:3*nx;iy=1:3*nx; f{4}=sym_g_mod(array_in(ix,iy,:),5,0);
    ix=3*nx+1:4*nx;iy=1:3*nx; f{5}=sym_g_mod(array_in(ix,iy,:),5,0);
    ix=1:nx;iy=3*nx+1:4*nx;   f{3}=sym_g_mod(array_in(ix,iy,:),7,0);
  end;

  array_out=zeros(nx,13*nx,nz);
  array_out=cat(2,f{1},f{2},f{3},reshape(f{4},nx,3*nx,nz),reshape(f{5},nx,3*nx,nz));
  faces=f;	

end;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

return
