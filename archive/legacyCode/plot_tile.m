clear all;
nx=1080;nxstr=num2str(nx);nx1=450;nx2=360;ny=2*nx1+nx2+nx;nfx=[nx 0 nx nx2 nx1];nfy=[nx1 0 nx nx nx];
dirGrid=['/nobackupp2/atnguye4/llc' nxstr '/aste_' nxstr 'x' num2str(nx1) 'x' num2str(nx2) '/run_template/'];
%a=readbin([dirGrid 'bathy_aste2160x' num2str(nx1) 'x' num2str(nx2) '.bin'],[nx ny]);
strbathy='_v1';%'';%strbathy=_fix1obcs20Sep2016_0m';
a=readbin([dirGrid 'bathy_aste' nxstr 'x' num2str(nx1) 'x' num2str(nx2) strbathy '.bin'],[nx ny]);
hf=ones(size(a));hf(find(a==0))=0;
[hf1,hf]=get_aste_tracer(hf,nfx,nfy);%clear hf

%face4: blank out corners:
hf{4}(200:end,1:300)=0;
hf{4}(220:end,990:end)=0;
hf{1}(990:end,1:90)=0;
hf{5}(360:end,1:90)=0;

%hf=readbin([dirGrid 'hFacC.data'],[nx ny]);
%yc=readbin([dirGrid 'YC.data'],[nx ny]);yc(find(yc==0))=nan;[yc,yc1]=get_aste_tracer(yc,nfx,nfy);   clear yc

%%try to trim to 1008 x 1200:
%nx1=1080;%nx1=1224;
%hf{1}=hf1{1}(1:nx,1800-nx1+1:1800);hf{2}=[];hf{3}=hf1{3};hf{4}=hf1{4};hf{5}=hf1{5}(1:nx1,1:nx);
%yc{1}=yc1{1}(1:nx,1800-nx1+1:1800);yc{2}=[];yc{3}=yc1{3};yc{4}=yc1{4};yc{5}=yc1{5}(1:nx1,1:nx);

factor(nx)      %2 2 2 3 3 3 5
factor(nx1)	%2     3 3   5 5
factor(nx2)	%2     3 3 3 5
for icase=1:5;                                       %+org               v0     v0      v1
  if(icase==1);dtilex=90;dtiley=90;	%total 312,   220 non-blank	; 214;	197;	207
  elseif(icase==2);dtilex=45;dtiley=45;	%total 1248,  794 non-blank	; 769;	736;	760
  elseif(icase==3);dtilex=30;dtiley=30;	%total 2808, 1711 non-blnk	; 1645;	1600;  1644
  elseif(icase==4);dtilex=30;dtiley=45;	%total 1872, 1165 non-blnk	; 1129;	1087;  1120
  elseif(icase==5);dtilex=45;dtiley=30;	%total 1872, 1163 non-blnk	; 1128;	1089;  1120
  end;
print_fig=1;
nx=nx;ny=2*nx1+nx2+nx;nfx=[nx 0 nx nx2 nx1];nfy=[nx1 0 nx nx nx];

%dirRoot='/nobackupp2/atnguye4/MITgcm_c65q/mysetups/aste_270x450x180/';%run_c65q_20022013_it0001_pk0000000003/';
%dirRoot='/nobackupp2/atnguye4/llc270/aste_270x450x180/';%run_c65q_20022013_it0001_pk0000000003/';
%dirGrid=[dirRoot 'GRID/'];
%dirGrid='/nobackupp6/atnguye4/MITgcm_c65q/mysetups/aste_270x450x180/run_c65q_20022013_it0001_pk0000000003_norescaling_smooth/';

%precIn='real*4';
%temp=dir([dirGrid 'hFacC.data']);
%aa=temp.bytes/nx/ny/nz/4;if(aa==2);precIn='real*8';end;
%
%a=readbin([dirGrid 'hFacC.data'],[nx ny],1,precIn);
%[a,hf]=get_aste_tracer(a,nfx,nfy);

cc=0;cc1=0;
for iface=[1,3:5]
  msk{iface}=0.*hf{iface};
end;

fOut=[dirGrid 'exch2_tile' sprintf('%2.2i',dtilex) 'x' sprintf('%2.2i',dtiley) '.txt'];
fid=fopen(fOut,'w');

for iface=[1,3:5];
  clear temp 
  temp=hf{iface};
  temp1=0.*temp;
  nnx=nfx(iface)/dtilex;
  nny=nfy(iface)/dtiley;

  for j=1:nny
    jy=(j-1)*dtiley+1:j*dtiley;
    for i=1:nnx
      cc1=cc1+1;
      ix=(i-1)*dtilex+1:i*dtilex;
      b=sum(sum(temp(ix,jy))); 
      if(b>0);
        cc=cc+1;
        lx(cc)=ix(floor(dtilex/2));
        ly(cc)=jy(floor(dtiley/2));
        ll(cc)=cc;
        temp1(ix,jy)=1;
      else;
        fprintf(fid,'%i,\n',cc1);
      end;
    end
  end
  msk{iface}=temp1;
end;
fclose(fid);

cc=0;
for iface=[1,3:5];
  temp=msk{iface};
  figure(iface);clf;colormap(gray(3));
  imagescnan(msk{iface}');axis xy;caxis([-1,2]);
  %temp1=yc{iface};title(['yc: [' num2str(nanmin(temp1(:)),3) ' ' num2str(nanmax(temp1(:)),3) ']']);
  set(gca,'Xtick',0:dtilex:nfx(iface),'Ytick',0:dtiley:nfy(iface));grid;
  hold on;[aa,bb]=contour(1:nfx(iface),1:nfy(iface),hf{iface}',[1 1]);hold off;
  set(bb,'color',.7.*[1,1,1],'linewidth',2);
  nnx=nfx(iface)/dtilex;
  nny=nfy(iface)/dtiley;
  for j=1:nny;
    jy=(j-1)*dtiley+1:j*dtiley;
    for i=1:nnx
      ix=(i-1)*dtilex+1:i*dtilex;
      if(sum(sum(temp(ix,jy)))>0);
        cc=cc+1;
        text(lx(cc),ly(cc),num2str(ll(cc)),'HorizontalAlignment','center');
      end;
    end;
  end;
  if(print_fig==1);
  if(iface==1);set(gcf,'paperunit','inches','paperposition',[0 0 14 10]);
  elseif(iface==3);set(gcf,'paperunit','inches','paperposition',[0 0 10 10]);
  elseif(iface==4);set(gcf,'paperunit','inches','paperposition',[0 0 8 10]);
  else;            set(gcf,'paperunit','inches','paperposition',[0 0 10 14]);end;
  figure(iface);fpr=[dirGrid 'Face' num2str(iface) '_tile' sprintf('%2.2i',dtilex) 'x' sprintf('%2.2i',dtiley) '.png'];
  print(fpr,'-dpng');fprintf('%s\n',fpr);
  end;
end;
  fprintf('tilex,num_tile,total_tile: [%i %i %i]\n',[dtilex,cc,nx*ny/dtilex/dtiley]);
keyboard
end;
