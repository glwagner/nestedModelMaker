%04Oct2016
%there are a few points right around Bering Strait with abnormally large vertical vel
% here constructing a grid-dependence biharmonic visc that is only applied over that area

clear all;
dirRoot='/nobackupp2/atnguye4/llc1080/aste_1080x450x360/';
dirmatlab=[dirRoot 'matlab/'];
dirOut=[dirRoot 'run_template/'];
%dirGrid=[dirRoot 'GRID_real8_04Oct2016/'];
dirGrid='/nobackupp2/atnguye4/MITgcm_c65x/mysetups/aste_1080x450x360/run_obcs_pk0000006240/GRID_real8_04Oct2016/';

nx=1080;nx1=450;nx2=360;ny=2*nx1+nx+nx2;nz=106;nxstr=num2str(nx);nfx=[nx 0 nx nx2 nx1];nfy=[nx1 0 nx nx nx];
yc=rdmds([dirGrid 'YC']);yc=reshape(yc,nx,ny);yc=get_aste_tracer(yc,nfx,nfy);
xc=rdmds([dirGrid 'XC']);xc=reshape(xc,nx,ny);xc=get_aste_tracer(xc,nfx,nfy);
rac=rdmds([dirGrid 'RAC']);rac=reshape(rac,nx,ny);%rac=get_aste_tracer(rac,nfx,nfy);
rF  = squeeze(rdmds([dirGrid 'RF']));
drF = squeeze(rdmds([dirGrid 'DRF']));
%hf=rdmds([dirGrid 'hFacC']);hf=reshape(hf,nx,ny,nz);

%read in bathy to calc hFac:
bathy=readbin([dirRoot 'run_template/bathy_aste1080x360x450_obcs31Dec2016_v1sm.bin'],[nx ny],1,'real*4');
hFacMin=0.2;
hFacMinDr=5.;
[bathyp,hf]=calc_hFacC(-abs(bathy),hFacMin,hFacMinDr,drF,rF);

hf(find(hf>0))=1;iland=find(hf==0);hf=get_aste_tracer(hf,nfx,nfy);

useAreaViscLength=1;

%get coast
N=4;
icoast=0.*ones(nx,ny,nz);
for k=1:nz;
  temp=locate_aste_coast(hf(:,:,k),N);
  icoast(:,:,k)=aste_tracer2compact(temp,nfx,nfy);
end;
version=1;
if(version==1);gridcoast=1:N;end;
weight_coast=0.*icoast;
for igrid=1:length(gridcoast);
  i=find(icoast==gridcoast(igrid));
  weight_coast(i)=1-igrid./(length(gridcoast)+1);
end;
weight_coast(iland)=1;

%zooming in to Bering Strait Region:
iBE=find((xc<=-158|xc>=158)&yc<68);
weight_BE=0.*xc;
weight_BE(iBE)=1;weight_BE=smooth2a(weight_BE,4);	%smooth to prevent abrupt increase
weight_BE(1820:1920,1600:1630)=0;			%spilling
weight_BE=aste_tracer2compact(weight_BE,nfx,nfy);
%weight_BE=repmat(weight_BE,[1 1 nz]);

%now designing a viscosity field (biharmonic)
if(~useAreaViscLength);
  dxi=1./dx;dyi=1./dy;
  ds=2./(dxi.^2+dyi.^2);	%L2_D
else;
  ds=rac;			%L2_D
end;

%C         deepFac2C(k)= 1. _d 0; set_grid_factors.F
%C         L2_D(i,j,bi,bj) = rA(i,j,bi,bj)	mom_init_fixed.F
%C         L2 = L2_D(i,j,bi,bj)*deepFac2C(k)
%C         L2rdt = 0.25 _d 0*recip_dt*L2
%C         L4rdt_D(i,j,bi,bj) = 1/32*recip_dt*L2_D(i,j,bi,bj)**2;   mom_init_fixed.F
%C         deepFac4 = deepFac2C(k)*deepFac2C(k); mom_calc_visc.F
%C         L4rdt = L4rdt_D(i,j,bi,bj)*deepFac4
deltaT=180;
L2rdt=ds./(4.*deltaT);
L4rdt=(ds.^2)./(32.*deltaT);
Ahgrid=0.105;Ahstr=sprintf('%3.3i',Ahgrid*1000);		%from xcell sheet
B4grid=0.075;B4str=sprintf('%3.3i',B4grid*1000);		%from xcell sheet
A=Ahgrid.*L2rdt;
B=B4grid.*L4rdt;

%A=repmat(A,[1 1 nz]);
%B=repmat(B,[1 1 nz]);

%write out raw viscosity fields
Bc=aste_tracer2compact(B,nfx,nfy);
fid=fopen([dirOut 'viscA4_p' B4str '.bin'],'w','b');for k=1:nz;fwrite(fid,Bc,'real*4');end;fclose(fid);
Ac=aste_tracer2compact(A,nfx,nfy);
fid=fopen([dirOut 'viscAh_p' Ahstr '.bin'],'w','b');for k=1:nz;fwrite(fid,Ac,'real*4');end;fclose(fid);

%now apply geographic restriction
A_BE=A.*weight_BE;
B_BE=B.*weight_BE;
%A_BEc=aste_tracer2compact(A_BE,nfx,nfy);
fid=fopen([dirOut 'viscAh_p' Ahstr '_BE.bin'],'w','b');for k=1:nz;fwrite(fid,A_BE,'real*4');end;fclose(fid);
%B_BEc=aste_tracer2compact(B_BE,nfx,nfy);
fid=fopen([dirOut 'viscA4_p' B4str '_BE.bin'],'w','b');for k=1:nz;fwrite(fid,B_BE,'real*4');end;fclose(fid);

%now applying coast effect:
%A=A.*weight_coast;
%B=B.*weight_coast;
%Ac=aste_tracer2compact(A,nfx,nfy);
%Bc=aste_tracer2compact(B,nfx,nfy);
fid=fopen([dirOut 'viscAh_p' Ahstr '_coast' sprintf('%2.2i',N) '_v' num2str(version) '.bin'],'w','b');
for k=1:nz;temp=A.*weight_coast(:,:,k);fwrite(fid,temp,'real*4');end;fclose(fid);
fid=fopen([dirOut 'viscA4_p' B4str '_coast' sprintf('%2.2i',N) '_v' num2str(version) '.bin'],'w','b');
for k=1:nz;temp=B.*weight_coast(:,:,k);fwrite(fid,temp,'real*4');end;fclose(fid);


%now apply coast + geographic restriction
%A_BE=A.*weight_BE;
%B_BE=B.*weight_BE;
%A_BEc=aste_tracer2compact(A_BE,nfx,nfy);
%B_BEc=aste_tracer2compact(B_BE,nfx,nfy);
fid=fopen([dirOut 'viscAh_p' Ahstr '_BEcoast' sprintf('%2.2i',N) '_v' num2str(version) '.bin'],'w','b');
for k=1:nz;temp=A.*weight_coast(:,:,k).*weight_BE;fwrite(fid,temp,'real*4');end;fclose(fid);
fid=fopen([dirOut 'viscA4_p' B4str '_BEcoast' sprintf('%2.2i',N) '_v' num2str(version) '.bin'],'w','b');
for k=1:nz;temp=B.*weight_coast(:,:,k).*weight_BE;fwrite(fid,temp,'real*4');end;fclose(fid);

