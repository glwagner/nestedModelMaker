clear all

%read in dz to find out where the cutoff for hFacMinDr is
 hFacMin=0;
 hFacMinDr=0;

dirRoot270='/nobackupp2/atnguye4/MITgcm_c65q/mysetups/aste_270x450x180/';
Run270='run_c65q_20022013noRstar_mp03latp30_v7imdimSnow_A2v3coast08_it0013_pk0000000002_badpfespeed';
dir270=[dirRoot270 Run270 '/'];dirGrid270=[dirRoot270 'GRID_real8/'];
nx0=270;nx1_0=450;nx2_0=180;ny0=2*nx1_0+nx0+nx2_0;nz0=50;nfx0=[nx0 0 nx0 nx2_0 nx1_0];nfy0=[nx1_0 0 nx0 nx0 nx0];

nx=1080;nx1=450;nx2=360;ny=2*nx1+nx+nx2;nz=106;nfx=[nx 0 nx nx2 nx1];nfy=[nx1 0 nx nx nx];nxstr=num2str(nx);
dirRoot=['/nobackupp2/atnguye4/MITgcm_c65x/mysetups/aste_' nxstr 'x' num2str(nx1) 'x' num2str(nx2) '/'];
dirGrid=[dirRoot 'run_obcs_1tsbathy270r8_pk0000000000/'];

drf=rdmds([dirGrid 'DRF']);drf=abs(squeeze(drf));
rf =rdmds([dirGrid 'RF']);rf=squeeze(rf);
drc=rdmds([dirGrid 'DRC']);drc=abs(squeeze(drc));
de=rdmds([dirGrid 'Depth']);de=reshape(de,nx,ny);def{1}=de(:,1:nfy(1));
rl=rdmds([dirGrid 'rLowC']); rl=reshape(rl,nx,ny);rl=abs(rl);rlf{1}=rl(:,1:nfy(1));
b =readbin([dirGrid 'bathy_fromllc270_r8.bin'],[nx ny],1,'real*8');b=abs(b);bf{1}=b(:,1:nfy(1));

hFacC_calc=calc_hFacC(-abs(rlf{1}),hFacMin,hFacMinDr,drf,rf);

ix=1:700;iy=1:450;
figure(1);clf;colormap(jet(21));
subplot(231);mypcolor(ix,iy,bf{1}(ix,iy)');thincolorbar;grid;title('bathy_fromllc270_r8.bin','interpreter','none');
subplot(232);mypcolor(ix,iy,def{1}(ix,iy)');thincolorbar;grid;title('Depth; hFacMin=0., hFacMinDr=0');
subplot(233);mypcolor(ix,iy,bf{1}(ix,iy)'-def{1}(ix,iy)');thincolorbar;grid;title('bathy from llc270 r8 minus Depth');
subplot(234);mypcolor(ix,iy,bf{1}(ix,iy)');thincolorbar;grid;title('bathy_fromllc270_r8.bin','interpreter','none');
subplot(235);mypcolor(ix,iy,rlf{1}(ix,iy)');thincolorbar;grid;title('rLowC; hFacMin=0., hFacMinDr=0');
subplot(236);mypcolor(ix,iy,bf{1}(ix,iy)'-rlf{1}(ix,iy)');thincolorbar;grid;title('bathy from llc270 r8 minus Depth');
set(gcf,'paperunits','inches','paperposition',[0 0 16 8]);
fpr=[dirGrid 'bathy_Depth_rLowC.png'];print(fpr,'-dpng');

rr=nx/nx0;

%llc270
hfC0=rdmds([dirGrid270 'hFacC']);hfC0=reshape(hfC0,nx0,ny0,nz0);
fC0{1}=hfC0(:,1:nfy0(1),:);
fC0_1{1}=interp_llc270to1080_face5_v2(fC0{1},1,0,1);
fC0_1{1}=fC0_1{1}(1:nx,nfy0(1)*rr-nfy(1)+1:nfy0(1)*rr,:);

%now read in llc1080 hfac to match
hfC1=rdmds([dirGrid 'hFacC']);hfC1=reshape(hfC1,nx,ny,nz);
fC1{1}=hfC1(:,1:nfy(1),:);

for k=1:nz;
ix=1:700;iy=1:450;
figure(1);clf;colormap(jet(21));
subplot(231);mypcolor(ix,iy,fC0_1{1}(ix,iy,k)');thincolorbar;grid;title('hFacC interp from llc270');
subplot(232);mypcolor(ix,iy,hFacC_calc(ix,iy,k)');thincolorbar;grid;title(['hFacC calc offline, k=' num2str(k)]);
subplot(233);mypcolor(ix,iy,fC0_1{1}(ix,iy,k)'-hFacC_calc(ix,iy,k)');thincolorbar;grid;
             title(['interp minus calc offline; sum:' num2str(sum(sum(fC0_1{1}(ix,iy,k)-hFacC_calc(ix,iy,k))))]);
subplot(234);mypcolor(ix,iy,fC0_1{1}(ix,iy,k)'-fC1{1}(ix,iy,k)');thincolorbar;grid;title('interp minus model output');
             title(['interp minus model output; sum:' num2str(sum(sum(fC0_1{1}(ix,iy,k)-fC1{1}(ix,iy,k))))]);
subplot(235);mypcolor(ix,iy,fC1{1}(ix,iy,k)');thincolorbar;grid;title('model output');
subplot(236);mypcolor(ix,iy,fC1{1}(ix,iy,k)'-hFacC_calc(ix,iy,k)');thincolorbar;grid;
             title(['model output minus calc offline; sum:' num2str(sum(sum(fC1{1}(ix,iy,k)-hFacC_calc(ix,iy,k))))]);
  set(gcf,'paperunits','inches','paperposition',[0 0 16 8]);
  fpr=[dirGrid 'hFacC_calcoffline_interp_modeloutput_k' sprintf('%3.3i',k) '.png'];print(fpr,'-dpng');
pause;
end;


%from step1_extract_llc270tsuv:
%[f1_Soffset,f1_SoffsetV,f4_Eoffset,f5_Eoffset] %[338 339 90 113]
%from this, need to match identically: face1: j=339; face4: i=90; face5: i=113;
f1_Soffset_0=338;f1_SoffsetV_0=339;f4_Eoffset_0=90;f5_Eoffset_0=113;

%from step1b_interpllc270_llc1080grid:
%[f1_Soffset,f1_SoffsetV,f4_Eoffset,f5_Eoffset] %[2 3 357 449] 		%line 115,163,208
%so need to match 3, 357, 449
f1_Soffset_1=2;f1_SoffsetV_1=3;f4_Eoffset_1=357;f5_Eoffset_1=449;

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
