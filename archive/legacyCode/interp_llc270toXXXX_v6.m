function [fieldOut]=interp_llc270toXXXX_v6(fieldIn,flagXX,flagNZ,flaghFac,nx,drF0,drF1)

%------------
% function [fieldout]=interp_llc270toXXXX_v6(fieldIn,flagXX,flagNZ,flagFac,nx,drF0,drF1)
% fieldIn:  [nx ny nz nt] or [nx 1 nz nt] or [nx ny 1 nt] or [nx 1 1 1]
% dimXX = [1 1] or [1 0] or [0 1] for interp in x/y or x or y dir, [0 0]=no interp horiz
% flagNZ = [1]=yes z-interp in 3rd dim, else [0]=no,
% flaghFac = [0]=normal mapping, [1]=deal with partial cell
% nx: 540,1080,2160,4320
%          rr = nx_new/270
% fieldOut: [sz(1)*rr  sz(2)*rr (106)] or [sz(1)*rr+1 sz(1)*rr+1 (106)]
%------------

% Expect on the incoming that the dimension is already 3 or 4 dim?
% However, if the 2nd dim is equal to nz0, will add a 2nd dim of 1
% and slide everything down the line to 3rd and 4th dim

if(length(flagXX)~=2);error('need size flagXX to be 2x1, eg [1 1]');end;

nz=106;nz0=50;

%horizontal interp:
%first check size and make everything 4 dim: [nx ny nz nt]
sz0=size(fieldIn);L=length(sz0);
if(L==2);
  sz0=[sz0 1 1];
elseif(L==3);
  sz0=[sz0 1];
end;

%find which one is z-dir:
iz=find(sz0==nz0);
if(iz==2);
  if(sz0(3)>1);	%assume if this is the case, then sz0(3) is nt
    fieldIn=permute(fieldIn,[1 4 2 3]);
  else;
    fieldIn=permute(fieldIn,[1 3 2 4]);
  end;
  sz0=size(fieldIn);
  if(length(sz0)==3);sz0=[sz0 1];end;
end;

if(sum(flagXX)>0);
  fac=nx/270;
  if(flagXX(1)==1);nx=sz0(1)*fac;else;nx=sz0(1);end;
  if(flagXX(2)==1);ny=sz0(2)*fac;else;ny=sz0(2);end;
  newF=zeros(nx,ny,sz0(3),sz0(4));
  for j=1:ny/sz0(2);
    for i=1:nx/sz0(1);
      newF(i:nx/sz0(1):nx,j:ny/sz0(2):ny,:,:)=fieldIn;
    end;
  end;
else;
  newF=fieldIn;
end;

if(flagNZ==1);
    clear tempk temp1 temp3 temp4 temp5
    %vertical interp:
    sz=size(newF);if(length(sz)==2);sz=[sz 1 1];elseif(length(sz)==3);sz=[sz 1];end;
    iz=find(sz==nz0);
    if(length(iz)==0);error('wrong size in 3rd dimension');end;

    temp4=zeros(sz(1),sz(2),nz,sz(4));

%top 10 cells; we're not dealing with correct partial cells yet.
%even though the first 10 cells in v5 adds to the first 2 lev, this is ok for now:
    for k=1:7; temp4(:,:,k,:)=newF(:,:,1,:);end;	%new 106 to old 50: lev 1:7 maps to 1
    for k=8:10;temp4(:,:,k,:)=newF(:,:,2,:);end;	%new 106 to old 50: lev 8:10 maps to 2

%starting here we allow partial cells
%get proper ratio instead of assuming 0.5 0.5:
    for k=3:50
        k_u=(k+2)*2+1;
        k_l=(k+3)*2;
        if (flaghFac==0)					 % 11:106 to 3:50
            temp4(:,:,k_u,:)=newF(:,:,k,:);
            temp4(:,:,k_l,:)=newF(:,:,k,:);
        elseif ( flaghFac==1)
%if hfac=.4 , i.e., 40%water = 60% land
%even cell has to be land, the odd cell 80% water
%if hfac = .6, i.e.,
%  for hFacW: 1 is water , 0 is no water(land), 0.4 is 40% water.
            r_u=drF1(2*k+5)/drF0(k);
            r_l=drF1(2*k+6)/drF0(k);
            temp4(:,:,k_u,:)=newF(:,:,k,:);
            temp4(:,:,k_l,:)=newF(:,:,k,:);

            temp=newF(:,:,k,:);
            temp4_u=temp4(:,:,k_u,:);
            temp4_l=temp4(:,:,k_l,:);
            clear ii;ii=find(temp(:)<=r_u & temp(:)>0);
            if(length(ii)>0);
                temp4_u(ii)=temp(ii)./r_u;			%This cell is partial cell
                temp4_l(ii)=0;					%This cell is whole land
                temp4(:,:,k_u,:)=temp4_u;
                temp4(:,:,k_l,:)=temp4_l;
            end;

            temp4_u=temp4(:,:,k_u,:);
            temp4_l=temp4(:,:,k_l,:);
            clear ij;ij=find(temp(:)>r_u & temp(:)<1);
            if(length(ij)>0);
                temp4_u(ij)=1;
                temp4_l(ij)=(temp(ij)-r_u)/r_l;;
                temp4(:,:,k_u,:)=temp4_u;
                temp4(:,:,k_l,:)=temp4_l;
            end;
        end;
        %fprintf('%i ',k);
    end;
    %fprintf('\n');
    fieldOut=temp4;
else
    fieldOut=newF;
end;

%squeezing out extra dimensions:
fieldOut=squeeze(fieldOut);

%szN=size(fieldOut);if(length(szN)==2);szN=[szN 1];end;

%%incase of vector field, trimming here
%%if(szN(1)==(nx0+1) & flagUV>0);
%if(szN(1)==(sz0(1)+1) & flagUV>0);
%    tempFF=fieldOut;clear fieldOut;
%    fieldOut=nan(nx+1,ny+1,szN(3));
%    if(flagUV==1);%U: face5,
%        fieldOut(1:nx+1,1:ny,:)=tempFF(1:nx+1,1:ny,:);
%    elseif(flagUV==2);%V:
%        fieldOut(1:nx,1:ny+1,:) = tempFF(1:nx,1:ny+1,:);
%    end;
%end;
return
