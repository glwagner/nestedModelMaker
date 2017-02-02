clear all;

nx0=270;ny0=1350;nz0=50;
nfx0=[nx0 0 nx0 180 450];nfy0=[450 0 nx0 nx0 nx0];
dirIn='/nobackupp2/atnguye4/llc270/aste_270x450x180/run_template/';

nx=1080;nx1=450;nx2=360ny=nx+2*nx1+nx2;nz=106;nxstr=num2str(nx);
nfx=[nx 0 nx nx2 nx1];nfy=[nx1 0 nx nx nx];
dirOut=['/nobackupp2/atnguye4/llc' nxstr '/aste_' nxstr 'x' num2str(nx1) 'x' num2str(nx2) '/run_template/'];
ext=['_llc' nxstr];

fac=nx/nx0;
nfxa=ceil([nx0 0 nx0 nfx(4)/fac nfx(5)/fac]);nfya=ceil([nfy(1)/fac 0 nx0 nx0 nx0]);

dirIn='/nobackupp8/atnguye4/llc2160/aste_2160x1800x1008/run_template/';
dirGrid='/nobackupp8/atnguye4/llc2160/aste_2160x1800x1008/GRID/';
dirOut=dirIn;
RunStr='run00xxB_19922011_0000026352';

hF=readbin([dirGrid 'hFacC.data'],[nx ny nz]);hF(find(hF<1))=0;
yc=readbin([dirGrid 'YC.data'],[nx ny]);ilowlat=find(yc(:)<60);

fIn=[dirIn 'pickup_run00xxB_19922011.0000026352.data'];
fIn_ice=[dirIn 'pickup_seaice_run00xxB_19922011.0000026352.data'];

clear FF;FF=read_slice(fIn,nx,ny,2*nz+1:3*nz,precIn).*hF;writebin([dirOut 'T_' RunStr '.bin'],FF,1,precOut);
clear FF;FF=read_slice(fIn,nx,ny,3*nz+1:4*nz,precIn).*hF;writebin([dirOut 'S_' RunStr '.bin'],FF,1,precOut);

%restricting SIarea:
clear FF;FF=read_slice(fIn_ice,nx,ny,8,precIn).*hF(:,:,1);
FF(find(FF<0.15))=0;FF(ilowlat)=0;
writebini[dirOut 'SIarea_' RunStr '.bin'],FF,1,precOut);

%restricting SIheff:
clear FF;FF=read_slice(fIn_ice,nx,ny,9,precIn).*hF(:,:,1);
FF(find(FF<0.01))=0;FF(ilowlat)=0;FF(find(FF>2))=2;
writebin([dirOut 'SIheff_' RunStr '.bin'],FF,1,precOut);

%31.jan.2015: smooth fields:
clear all;
dirIn='/nobackupp8/atnguye4/llc2160/aste_2160x1800x1008/run_template/';
dirOut=dirIn;
nx=2160;ny=nx+2*1800+1008;precIn='real*4';precOut='real*4';
RunStr='run00xxB_19922011_0000026352';
fldStr={'S','T','SIarea','SIheff'};
nz=[106,106,1,1];
for ifld=1:4;
  fIn=[dirIn fldStr{ifld} '_' RunStr '.bin'];fprintf('%s\n',fIn);
  fOut=[dirOut fldStr{ifld} 'smooth_' RunStr '.bin'];
  s=readbin(fIn,[nx ny nz(ifld)]);
  sq=zeros(nx,ny,nz(ifld));
  for k=1:nz(ifld);  
    temp=get_aste_tracer(s(:,:,k),nfx,nfy);
    temp=smooth2a(temp,4);
    sq(:,:,k)=aste_tracer2compact(temp,nfx,nfy); 
    fprintf('%i ',k);
  end;
  writebin(fOut,sq);
  fprintf('\n');fprintf('%s\n',fOut);
end;
