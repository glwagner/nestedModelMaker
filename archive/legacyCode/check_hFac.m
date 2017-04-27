clear all

dirRoot270='/nobackupp2/atnguye4/MITgcm_c65q/mysetups/aste_270x450x180/';
Run270='run_c65q_20022013noRstar_mp03latp30_v7imdimSnow_A2v3coast08_it0013_pk0000000002_badpfespeed';
dir270=[dirRoot270 Run270 '/'];dirGrid270=[dirRoot270 'GRID_real8/'];
nx0=270;nx1_0=450;nx2_0=180;ny0=2*nx1_0+nx0+nx2_0;nz0=50;nfx0=[nx0 0 nx0 nx2_0 nx1_0];nfy0=[nx1_0 0 nx0 nx0 nx0];

nx=1080;nx1=450;nx2=360;ny=2*nx1+nx+nx2;nz=106;nfx=[nx 0 nx nx2 nx1];nfy=[nx1 0 nx nx nx];nxstr=num2str(nx);
dirRoot=['/nobackupp2/atnguye4/MITgcm_c65x/mysetups/aste_' nxstr 'x' num2str(nx1) 'x' num2str(nx2) '/'];
%dirGrid=[dirRoot 'GRID_real8_fix1obcs02Oct2016_0m/'];
%dirGrid=[dirRoot 'run_obcs_1tsbathy270r8_pk0000000000_hFacMinp2Dr4p9/'];
%dirGrid=[dirRoot 'run_obcs_1tsbathy270r8_pk0000000000_hFacMin0Dr4p9/'];
dirGrid=[dirRoot 'run_obcs_1tsbathy270r8_pk0000000000/'];

rr=nx/nx0;

hfC0=rdmds([dirGrid270 'hFacC']);hfC0=reshape(hfC0,nx0,ny0,nz0);
fC0{1}=hfC0(:,1:nfy0(1),:);
fC0{3}=hfC0(:,nfy0(1)+1:nfy0(1)+nfy0(3),:);
fC0{4}=reshape(hfC0(:,nfy0(1)+nfy0(3)+1:nfy0(1)+nfy0(3)+nfx0(4),:),nfx0(4),nfy0(4),nz0);
fC0{5}=reshape(hfC0(:,nfy0(1)+nfy0(3)+nfx0(4)+1:end,:),nfx0(5),nfy0(5),nz0);

hfW0=rdmds([dirGrid270 'hFacW']);hfW0=reshape(hfW0,nx0,ny0,nz0);
fW0{1}=hfW0(:,1:nfy0(1),:);
fW0{3}=hfW0(:,nfy0(1)+1:nfy0(1)+nfy0(3),:);
fW0{4}=reshape(hfW0(:,nfy0(1)+nfy0(3)+1:nfy0(1)+nfy0(3)+nfx0(4),:),nfx0(4),nfy0(4),nz0);
fW0{5}=reshape(hfW0(:,nfy0(1)+nfy0(3)+nfx0(4)+1:end,:),nfx0(5),nfy0(5),nz0);

hfS0=rdmds([dirGrid270 'hFacS']);hfS0=reshape(hfS0,nx0,ny0,nz0);
fS0{1}=hfS0(:,1:nfy0(1),:);
fS0{3}=hfS0(:,nfy0(1)+1:nfy0(1)+nfy0(3),:);
fS0{4}=reshape(hfS0(:,nfy0(1)+nfy0(3)+1:nfy0(1)+nfy0(3)+nfx0(4),:),nfx0(4),nfy0(4),nz0);
fS0{5}=reshape(hfS0(:,nfy0(1)+nfy0(3)+nfx0(4)+1:end,:),nfx0(5),nfy0(5),nz0);

%checking some indices (not used):
i1=1:nfx0(1);j1=[nx1-floor(nx1/rr):nx1];%338:450, length(113)
i3=1:nfx0(3);j3=1:nfy0(3);
i4=1:ceil(nx2/rr);j4=1:nfy0(4);	    %1:90
i5=1:ceil(nx1/rr);j5=1:nfy0(5);	    %1:113

%from step1_extract_llc270tsuv:
%[f1_Soffset,f1_SoffsetV,f4_Eoffset,f5_Eoffset] %[338 339 90 113]
%from this, need to match identically: face1: j=339; face4: i=90; face5: i=113;
f1_Soffset_0=338;f1_SoffsetV_0=339;f4_Eoffset_0=90;f5_Eoffset_0=113;

%from step1b_interpllc270_llc1080grid:
%[f1_Soffset,f1_SoffsetV,f4_Eoffset,f5_Eoffset] %[2 3 357 449] 		%line 115,163,208
%so need to match 3, 357, 449
f1_Soffset_1=2;f1_SoffsetV_1=3;f4_Eoffset_1=357;f5_Eoffset_1=449;

%now interp to llc1080
%for face1, need to match only hfacS
fC0_1{1}=interp_llc270to1080_face5_v2(fC0{1},1,0,1);
fS0_1{1}=interp_llc270to1080_face5_v2(fS0{1},1,0,1);
%trimming:
fC0_1{1}=fC0_1{1}(1:nx,nfy0(1)*rr-nfy(1)+1:nfy0(1)*rr,:);
fS0_1{1}=fS0_1{1}(1:nx,nfy0(1)*rr-nfy(1)+1:nfy0(1)*rr,:);

%for face4 & face5: need to match hfacW
fW0_1{4}=interp_llc270to1080_face5_v2(fW0{4},1,0,1);
fW0_1{5}=interp_llc270to1080_face5_v2(fW0{5},1,0,1);

%now read in llc1080 hfac to match
hfC1=rdmds([dirGrid 'hFacC']);hfC1=reshape(hfC1,nx,ny,nz);
fC1{1}=hfC1(:,1:nfy(1),:);
fC1{4}=reshape(hfC1(:,nfy(1)+nfy(3)+1:nfy(1)+nfy(3)+nfx(4),:),nfx(4),nfy(4),nz);
fC1{5}=reshape(hfC1(:,nfy(1)+nfy(3)+nfx(4)+1:end,:),nfx(5),nfy(5),nz);

hfW1=rdmds([dirGrid 'hFacW']);hfW1=reshape(hfW1,nx,ny,nz);
%fW1{1}=hfW1(:,1:nfy(1),:);
%fW1{3}=hfW1(:,nfy(1)+1:nfy(1)+nfy(3),:);
fW1{4}=reshape(hfW1(:,nfy(1)+nfy(3)+1:nfy(1)+nfy(3)+nfx(4),:),nfx(4),nfy(4),nz);
fW1{5}=reshape(hfW1(:,nfy(1)+nfy(3)+nfx(4)+1:end,:),nfx(5),nfy(5),nz);

hfS1=rdmds([dirGrid 'hFacS']);hfS1=reshape(hfS1,nx,ny,nz);
fS1{1}=hfS1(:,1:nfy(1),:);
%fS1{3}=hfS1(:,nfy(1)+1:nfy(1)+nfy(3),:);
%fS1{4}=reshape(hfS1(:,nfy(1)+nfy(3)+1:nfy(1)+nfy(3)+nfx(4),:),nfx(4),nfy(4),nz);
%fS1{5}=reshape(hfS1(:,nfy(1)+nfy(3)+nfx(4)+1:end,:),nfx(5),nfy(5),nz);

%read in dz to find out where the cutoff for hFacMinDr is
% hFacMin=.2;
 hFacMin=0;
 hFacMinDr=4.9; %<-- need this number to clear level 11 but not clearing dz(12), otherwise will still
% have binary cutoff of 1/0 at level 12 whereas we're already starting to get hFac in llc270_50lev:
drf=rdmds([dirGrid 'DRF']);drf=abs(squeeze(drf));
drc=rdmds([dirGrid 'DRC']);drc=abs(squeeze(drc));

%plotting ratio:
 a=squeeze(fC0_1{1}(1:nx,f1_Soffset_1,1:nz));
 b=squeeze(fC1{1}(1:nx,f1_Soffset_1,1:nz));
figure(1);clf;colormap(jet(10));
 subplot(231);mypcolor(squeeze(fC0{1}(:,f1_Soffset_0,:))');thincolorbar;title('hfacC{1}llc270');grid;
 subplot(232);mypcolor(a');thincolorbar;title('hfacC{1}interpfromllc270');grid;
 subplot(233);mypcolor(b');thincolorbar;title('hfacC{1}llc1080');grid;
 subplot(235);mypcolor(b'./a');thincolorbar;title('ratio hfacC{1}llc1080 to hfacC{1}interpfromllc270');grid;
 subplot(236);mypcolor(a'./b');thincolorbar;title('ratio hfacC{1}interpfromllc270 to hfacC{1}llc1080');grid;
 subplot(234);plot(11:25,drf(11:25),'rs-',11:25,drc(11:25),'bo-');
   hold on;plot([11 25],[hFacMinDr hFacMinDr],'k-');hold off;grid;

%inspection of subplot(234) above shows that hFacMinDr >! 4.9 and not 5, otherwise levels 13-14,18-19 are below

 a=squeeze(fS0_1{1}(1:nx,f1_SoffsetV_1,1:nz));
 b=squeeze(fS1{1}(1:nx,f1_SoffsetV_1,1:nz));
figure(1);clf;colormap(jet(10));
 subplot(231);mypcolor(squeeze(fS0{1}(:,f1_SoffsetV_0,:))');thincolorbar;title('hfacW{1}llc270');grid;
 subplot(232);mypcolor(a');thincolorbar;title('hfacW{1}interpfromllc270');grid;
 subplot(233);mypcolor(b');thincolorbar;title('hfacW{1}llc1080');grid;
 subplot(235);mypcolor(b'./a');thincolorbar;title('ratio hfacW{1}llc1080 to hfacW{1}interpfromllc270');grid;
 subplot(236);mypcolor(a'./b');thincolorbar;title('ratio hfacW{1}interpfromllc270 to hfacW{1}llc1080');grid;

