%mom_calc_visc.F
%C         L2 = L2_D(i,j,bi,bj)*deepFac2C(k)
%C         L2rdt = 0.25 _d 0*recip_dt*L2
%C       viscAh = +0.25*L**2*viscAhGrid/deltaT
clear all;
dirRoot='/nobackupp2/atnguye4/llc1080/aste_1080x450x360/';
%dirGridnb=[dirRoot 'GRID/'];
dirGrid=['/nobackupp2/atnguye4/llc1080/aste_1080x450x360/GRID/'];
dirVisc=[dirRoot 'run_template/input_viscosity/'];if(exist(dirVisc)==0);mkdir(dirVisc);end;

nx=1080;ncut1=360;ncut2=450;ny=2*ncut2+ncut1+nx;nz=106;nfx=[nx 0 nx ncut1 ncut2];nfy=[ncut2 0 nx nx nx];

%deltaT0=60;deltaT1=120;deltaT2=180;deltaT3=150;deltaT4=240;
deltaT=[60,120,180,150,240];
useAreaViscLength=1;

list_fields2={'XC','YC','DXF','DYF','RAC','XG','YG','DXV','DYU','RAZ',...
    'DXC','DYC','RAW','RAS','DXG','DYG'};
files=dir([dirRoot 'run_template/tile00*.mitgrid']);
for k=[1,3:5];
  temp=read_slice([dirRoot 'run_template/tile00' num2str(k) '.mitgrid'],nfx(k)+1,nfy(k)+1,3:5,'real*8');
  dxf{k}=temp(1:nfx(k),1:nfy(k),1);
  dyf{k}=temp(1:nfx(k),1:nfy(k),2);
  racf{k}=temp(1:nfx(k),1:nfy(k),3);
end;

%put to compact:
rac=cat(2,racf{1},racf{3},reshape(racf{4},nfy(4),nfx(4)),reshape(racf{5},nfy(5),nfx(5)));
dx=cat(2,dxf{1},dxf{3},reshape(dxf{4},nfy(4),nfx(4)),reshape(dxf{5},nfy(5),nfx(5)));
dy=cat(2,dyf{1},dyf{3},reshape(dyf{4},nfy(4),nfx(4)),reshape(dyf{5},nfy(5),nfx(5)));

%%read in visc for Ahgrid=0.005 as output from model:
%vp003=readbin([dirVisc 'visc_3d_set1_A2p003.0000002232.data'],[nx ny]);
%vp003(find(vp003==0))=nan;

%hf=readbin([dirGrid 'hFacC.data'],[nx ny]);hf(find(hf>0))=1;hf(find(hf==0))=nan;
%dx=readbin([dirGridnb 'DXF.data'],[nx ny]);dy=readbin([dirGridnb 'DYF.data'],[nx ny]);
%rac=readbin([dirGridnb 'RAC.data'],[nx ny]);
%dx=readbin([dirGrid 'DXG.data'],[nx ny]);dy=readbin([dirGrid 'DYG.data'],[nx ny]);
%rac=readbin([dirGrid 'RAC.data'],[nx ny]);

rF  = squeeze(rdmds([dirGrid 'RF']));
drF = squeeze(rdmds([dirGrid 'DRF']));
%hf=rdmds([dirGrid 'hFacC']);hf=reshape(hf,nx,ny,nz);

%read in latest bathy to calc hFac:
bathystr='_obcs31Dec2016_v1Asm';%'_obcs31Dec2016_v1sm';
bathy=readbin([dirRoot 'run_template/bathy_aste1080x450x360' bathystr '.bin'],[nx ny],1,'real*4');
hFacMin=0.2;
hFacMinDr=5.;
[bathyp,hf]=calc_hFacC(-abs(bathy),hFacMin,hFacMinDr,drF,rF);

hf(find(hf>0))=1;iland=find(hf==0);hf(iland)=nan;%hfp=get_aste_tracer(hf,nfx,nfy);

%ds method1
if(~useAreaViscLength);
  dxi=1./dx;dyi=1./dy;
  ds=2./(dxi.^2+dyi.^2);
else;
  ds=rac;
end;

%C         deepFac2C(k)= 1. _d 0; set_grid_factors.F
%C         L2 = L2_D(i,j,bi,bj)*deepFac2C(k)
%C         L2rdt = 0.25 _d 0*recip_dt*L2
Ahgrid=1.0;%0.5;%0.4;%0.1;%0.02;%0.005;%0.001;0.0002;
A=zeros(nx,ny,length(deltaT));
Ap=zeros(2*nx,nfy(1)+nfy(3)+nfx(4));
for k=1:length(deltaT);
  L2rdt=ds./(4.*deltaT(k));
  A(:,:,k)=Ahgrid.*L2rdt;
end;

%A0=Ahgrid.*L2rdt0;
%A0p=get_aste_tracer(A0,nfx,nfy);

Ap=get_aste_tracer(A,nfx,nfy);

hfp=get_aste_tracer(hf,nfx,nfy);

figure(1);clf;colormap(jet(21));
subplot(141);mypcolor(Ap(:,:,1)'.*hfp(:,:,1)');thincolorbar;grid;
subplot(142);mypcolor(Ap(:,:,2)'.*hfp(:,:,1)');thincolorbar;grid;
subplot(143);mypcolor(Ap(:,:,3)'.*hfp(:,:,1)');thincolorbar;grid;
subplot(144);mypcolor(Ap(:,:,5)'.*hfp(:,:,1)');thincolorbar;grid;

strA=num2str(Ahgrid);idot=find(strA=='.');
  if(length(idot)>0);
    strA=[strA(1:idot-1) 'p' strA(idot+1:end)];
  else;
    strA=[strA 'p0'];
  end;

for k=1:length(deltaT);
  strT=sprintf('%4.4i',deltaT(k));
  fOut=[dirVisc 'ViscAh_' strA '_dT' strT '.bin'];
  writebin(fOut,A(:,:,k),1,'real*4');
end;

%now apply to coast line:
hf1=1-isnan(hfp);
Ncoast=4;gridcoast=1:Ncoast;
icoast=locate_coast(hf1,Ncoast);
weight_coast=zeros(size(icoast));

for igrid=1:length(gridcoast);
  i=find(icoast==gridcoast(igrid));
  weight_coast(i)=1-igrid./(length(gridcoast)+1);
end;

iland=find(hf1==0);weight_coast(iland)=1;

for iT=1:length(deltaT);
  clear Aq Aqc

  Aq=zeros(size(icoast));
  Aqc=zeros(nx,ny,nz);
  for k=1:nz;
    Aq(:,:,k)=Ap(:,:,iT).*weight_coast(:,:,k);
  end;

  Aqc=aste_tracer2compact(Aq,nfx,nfy);

  strT=sprintf('%4.4i',deltaT(iT));
  %fOut=[dirVisc 'ViscAh_' strA '_dT' strT '_v1smc4.bin'];
  fOut=[dirVisc 'ViscAh_' strA '_dT' strT '_v1Asmc4.bin'];
  writebin(fOut,Aqc,1,'real*4');fprintf('%s\n',fOut);
end;
