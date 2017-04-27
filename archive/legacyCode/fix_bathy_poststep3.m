%09.Jan.2017
%modify Western Arctic shelf to reduce vertical instability
clear all;
nx=1080;ncut1=360;ncut2=450;ny=2*ncut2+ncut1+nx;nz=106;nfx=[nx 0 nx ncut1 ncut2];nfy=[ncut2 0 nx nx nx];
dirRoot='/nobackupp2/atnguye4/MITgcm_c65x/mysetups/aste_1080x450x360/';
b=readbin([dirRoot 'run_template/bathy_aste1080x450x360_obcs31Dec2016_v1sm.bin'],[nx,ny]);
b=abs(get_aste_tracer(b,nfx,nfy));
b0=b;

figure(12);clf;mypcolor(b');caxis([0 1e2]);colorbar;grid;

%need to make shallower:
%Diomede: grid-scaled jumps:
ix=1577;iy=1692;b(ix,iy)=(b(ix,iy-1)+b(ix,iy+1))/2;
ix=1577;iy=1694;b(ix,iy)=(b(ix,iy-1)+b(ix,iy+1))/2;
ix=1578;iy=1692:1695;for i=1:length(iy);b(ix,iy(i))=b(ix,iy(1)-1);end;
ix=1579;iy=1692:1695;for i=1:length(iy);b(ix,iy(i))=b(ix,iy(1)-1);end;

%Coast of Alaska:
ix=1566;iy=1701;b(ix,iy)=b(ix,iy+1);
ix=1566;iy=1700;b(ix,iy)=(b(ix,iy-1)+b(ix,iy+1))/2;
ix=1565;iy=1701;b(ix,iy)=(b(ix-1,iy)+b(ix+1,iy))/2;
ix=1565;iy=1700;b(ix,iy)=(b(ix,iy-1)+b(ix,iy+1))/2;

%Barrow Canyon:
ix=1449;iy=1514;b(ix,iy)=(b(ix-1,iy)+b(ix+1,iy))/2;
ix=1450;iy=1516;b(ix,iy)=(b(ix+1,iy)+b(ix,iy+1))/2;
ix=1450;iy=1515;b(ix,iy)=(b(ix,iy-1)+b(ix,iy+1))/2;
ix=1449;iy=1515;b(ix,iy)=(b(ix-1,iy)+b(ix+1,iy))/2;
ix=1449;iy=1516;b(ix,iy)=(b(ix-1,iy)+b(ix+1,iy))/2;

bc=aste_tracer2compact(-abs(b),nfx,nfy);
fOut=[dirRoot 'run_template/bathy_aste1080x450x360_obcs31Dec2016_v1Asm.bin'];
writebin(fOut,bc,1,'real*4');fprintf('%s\n',fOut);

figure(13);clf;mypcolor(b');caxis([0 1e2]);colorbar;grid;
