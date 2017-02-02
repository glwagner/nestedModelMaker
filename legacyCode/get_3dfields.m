%20.Sep.2016
%spent a lot of time fixing bathy for llc2160, so let's use that for now:
dirRoot='/nobackupp2/atnguye4/';
nz=106;
nx0=2160;nx1p=900;nx2p=540;ny0=nx1p+nx0+nx2p+nx1p;nfx0=[nx0 0 nx0 nx2p nx1p];nfy0=[nx1p 0 nx0 nx0 nx0];
nx=nx0/2;ny=ny0/2;nx1=nx1p/2;nx2=nx2p/2;nfx=nfx0/2;nfy=nfy0/2;
dirIn =[dirRoot 'llc' num2str(nx0) '/aste_' num2str(nx0) 'x' num2str(nfy0(1)) 'x' num2str(nfx0(4)) '/run_template/'];
dirOut=[dirRoot 'llc' num2str(nx) '/aste_' num2str(nx) 'x' num2str(nfy(1)) 'x' num2str(nfx(4)) '/run_template/'];

strIn= {'WOA09v2_S_llc2160_JAN','WOA09v2_T_llc2160_JAN','Diffkr_basin_v1m9EfB_Method2_llc2160'};
strOut={'WOA09v2_S_llc1080_JAN','WOA09v2_T_llc1080_JAN','Diffkr_basin_v1m9EfB_Method2_llc1080'};
for ifile=1:size(strIn,2);
  clear fIn fOut temp f0 f
  fIn =[dirIn  strIn{ifile} '.bin'];
  fOut=[dirOut strOut{ifile} '.bin'];
  temp=dir(fIn);precIn='real*4';if(temp.bytes/nx0/ny0/nz/4==2);precIn='real*8';end;

  f0=readbin(fIn,[nx0 ny0 nz],1,precIn);
  f=interp_llc2160to1080(f0,nfx0,nfy0);
  writebin(fOut,f,1,precIn);fprintf('%s\n',fOut);
end;

