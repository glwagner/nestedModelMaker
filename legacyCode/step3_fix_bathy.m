clear all;

nx=1080; ncut1=360;ncut2=450; nxstr=num2str(nx); 
nfx=[nx 0 nx ncut1 ncut2];nfy=[ncut2 0 nx nx nx];
nxp=nx;ny=2*ncut2+ncut1+nx;

%set directory
dirRoot=['/nobackupp2/atnguye4/llc' nxstr '/aste_' nxstr 'x' num2str(ncut2) 'x' num2str(ncut1) '/'];
dirIn = [dirRoot 'run_template/input_obcs/'];dirOut = dirIn;
dirMatlab=[dirRoot 'matlab/'];cd(dirMatlab);

dirGrid0=['/nobackupp2/atnguye4/MITgcm_c65q/mysetups/aste_270x450x180/GRID_real8_fill9iU42Ef_noStLA/'];
dirGrid =['/nobackupp2/atnguye4/llc1080/NA1080x1200/GRID_real8_v3/'];

datestamp='31Dec2016';
fIn=[dirOut 'step2_obcs_' datestamp '.mat'];load(fIn,'obcs2');

%fBathy=[dirRoot 'run_template/bathy_aste' nxstr 'x' num2str(ncut2) 'x' num2str(ncut1) '_fix1obcs02Oct2016_0m.bin'];
fBathy=[dirRoot 'run_template/bathy_aste' nxstr 'x' num2str(ncut2) 'x' num2str(ncut1) '_v1.bin'];
tmp=dir(fBathy);precIn='real*4';if(tmp.bytes/nxp/ny/4==2);precIn='real*8';end;
bathy=abs(readbin(fBathy,[nxp ny],1,precIn));
bathy=get_aste_faces(bathy,nfx,nfy);
bathy0=bathy;
ind=zeros(nxp,ny);ind=get_aste_faces(ind,nfx,nfy);

for iobcs=1:size(obcs2,2);
  iface=obcs2{iobcs}.face;
  ix1=unique(obcs2{iobcs}.iC1(2,:));
  ix2=unique(obcs2{iobcs}.iC2(2,:));
  jy1=unique(obcs2{iobcs}.jC1(2,:));
  jy2=unique(obcs2{iobcs}.jC2(2,:));

  if(obcs2{iobcs}.obcsstr=='N'|obcs2{iobcs}.obcsstr=='S');	%N or S
    bathy{iface}(ix1,jy1)=obcs2{iobcs}.D1;
    bathy{iface}(ix1,jy2)=obcs2{iobcs}.D2;
    clear ij;tmp=ind{iface}(ix1,jy1);ij=find(tmp(:)>=0);tmp(ij)=tmp(ij)+1;ind{iface}(ix1,jy1)=tmp;
    clear ij;tmp=ind{iface}(ix1,jy2);ij=find(tmp(:)>=0);tmp(ij)=tmp(ij)+1;ind{iface}(ix1,jy2)=tmp;
    if(obcs2{iobcs}.obcsstr=='N');
      bathy{iface}(ix1,jy1+1:nfy(iface))=0;
      ind{iface}(ix1,jy1+1:nfy(iface))=-1;
    else;
      bathy{iface}(ix1,1:jy1-1)=0;
      ind{iface}(ix1,1:jy1-1)=-1;
    end;
  else;
    bathy{iface}(ix1,jy1)=obcs2{iobcs}.D1;
    bathy{iface}(ix2,jy1)=obcs2{iobcs}.D2;
    clear ij;tmp=ind{iface}(ix1,jy1);ij=find(tmp(:)>=0);tmp(ij)=tmp(ij)+1;ind{iface}(ix1,jy1)=tmp;
    clear ij;tmp=ind{iface}(ix2,jy1);ij=find(tmp(:)>=0);tmp(ij)=tmp(ij)+1;ind{iface}(ix2,jy1)=tmp;
    if(obcs2{iobcs}.obcsstr=='E');
      bathy{iface}(ix1+1:nfx(iface),jy1)=0;
      ind{iface}(ix1+1:nfx(iface),jy1)=-1;
    else;
      bathy{iface}(1:ix1-1,jy1)=0;
      ind{iface}(1:ix1-1,jy1)=-1;
    end;
  end;
%treat special case of Gibraltar Strait
  if(obcs2{iobcs}.flag_case==1);
    bathy{iface}(ix1,jy1(1)-20:jy1(1)-1)=0;
    bathy{iface}(ix1,jy1(end)+1:jy1(end)+20)=0;
    bathy{iface}(ix1+1:nfx(iface),jy1(1)-20:jy1(end)+20)=0;
    ind{iface}(ix1,jy1(1)-20:jy1(1)-1)=-1;
    ind{iface}(ix1,jy1(end)+1:jy1(end)+20)=-1;
    ind{iface}(ix1+1:nfx(iface),jy1(1)-20:jy1(end)+20)=-1;
  end;
end;

for iface=[1,3,4,5];
  sz=size(bathy0{iface});
  [iy,ix]=meshgrid(1:sz(2),1:sz(1));
  tmp=ind{iface};
  ii=find(tmp(:)>0);
  ij=find(tmp(:)<0);

  figure(1);clf;
  subplot(131);mypcolor(bathy0{iface}');caxis([0 1e3]);thincolorbar;title(['bathy0, ' num2str(iface)]);
               hold on;plot(ix(ii),iy(ii),'k.',ix(ij),iy(ij),'m.');hold off;
  subplot(132);mypcolor(bathy{iface}');caxis([0 1e3]);thincolorbar;
               hold on;plot(ix(ii),iy(ii),'k.',ix(ij),iy(ij),'m.');hold off;
  subplot(133);mypcolor(bathy0{iface}'-bathy{iface}');caxis([-1e2 1e3]);thincolorbar;grid;title('bathy0-bathy');
               hold on;plot(ix(ii),iy(ii),'k.',ix(ij),iy(ij),'m.');hold off;
  pause;
end;

%get rid of points due to overlapping obcs:
for iface=[1,3,4,5];
  clear ii tmp1 tmp2
  tmp1=ind{iface};
  tmp2=bathy{iface};
  ii=find(tmp1<0);tmp2(ii)=0;bathy{iface}=tmp2;
end;
%looks sort of ok, just skip the blending for now
%fOut=[dirRoot 'run_template/bathy_aste' nxstr 'x' num2str(ncut2) 'x' num2str(ncut1) '_obcs' datestamp '.bin'];
fOut=[dirRoot 'run_template/bathy_aste' nxstr 'x' num2str(ncut2) 'x' num2str(ncut1) '_obcs' datestamp '_v1.bin'];
bcompact=get_aste_tracer(bathy,nfx,nfy);

figure(1);clf;mypcolor(bcompact');caxis([0 1e2]);colorbar;grid;
%%quick inspection, remove a few places:
ix=1175:1420;iy=1886:1887;bcompact(ix,iy)=0;
ix=1980:2*1080;iy=1886:1887;bcompact(ix,iy)=0;

bcompact=aste_tracer2compact(bcompact,nfx,nfy);
bcompact=-abs(bcompact);
writebin(fOut,bcompact,1,'real*4');

%now blend iymerge inside the domain, this is VERY SPECIFIC to ASTE
%merge 20 grid points in
temp=get_aste_tracer(bcompact,nfx,nfy);

%face1 & face5
iobcs=1;
jy=obcs2{iobcs}.jC2(2,1);

ix=1:2*nx;
iymerge=jy+1:jy+20;
Liy=length(iymerge);

for k=1:Liy;
  w1=k/Liy;w0=1-w1;	%[1/20 19/20]
  temp(ix,iymerge(k))=w1.*temp(ix,iymerge(end)+1)+w0.*temp(ix,jy);
  %fprintf('%i %f %f\n',[k w1 w0]);
end;

%face4:
jy=1886;
ix=nx+1:2*nx;
iymerge=jy-1:-1:jy-20;
Liy=length(iymerge);

for k=1:Liy;
  w1=k/Liy;w0=1-w1;
  temp(ix,iymerge(k))=w1.*temp(ix,iymerge(end)-1)+w0.*temp(ix,jy);
end;

bcompact1=aste_tracer2compact(temp,nfx,nfy);bcompact1=-abs(bcompact1);
fOut=[dirRoot 'run_template/bathy_aste' nxstr 'x' num2str(ncut2) 'x' num2str(ncut1) '_obcs' datestamp '_v1sm.bin'];
writebin(fOut,bcompact1,1,'real*4');
