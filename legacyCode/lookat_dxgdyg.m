%21.Sep.2016
nx=1080;nxstr=num2str(nx);nx1=450;nx2=360;ny=nx1+nx+nx2+nx1;nfx=[nx 0 nx nx2 nx1];nfy=[nx1 0 nx nx nx];
dirRoot=['/nobackupp2/atnguye4/llc' nxstr '/'];
dirglobal=[dirRoot 'global/GRID/'];
dirOut=[dirRoot 'aste_' nxstr 'x' num2str(nfy(1)) 'x' num2str(nfx(4)) '/run_template/'];

b=readbin([dirOut 'bathy_aste' nxstr 'x' num2str(nfy(1)) 'x' num2str(nfx(4)) '.bin'],[nx ny]);b=get_aste_tracer(b,nfx,nfy);
msk=zeros(size(b));msk(find(b==0))=1;msk(1:780,600:end)=1;msk(1:552,300:600)=1;msk(750:1100,1500:end)=1;

dxg=rdmds([dirglobal 'DXG']);dxg=reshape(dxg,nx,13*nx);
dyg=rdmds([dirglobal 'DYG']);dyg=reshape(dyg,nx,13*nx);
[dxg,dyg]=get_aste_vector(dxg,dyg,nfx,nfy,0);
%dxg=get_aste_tracer(dxg,nfx,nfy);
%dyg=get_aste_tracer(dyg,nfx,nfy);
dxg=dxg(1:end-1,1:end-1);
dyg=dyg(1:end-1,1:end-1);

%plotting
temp=cat(3,dxg,dyg);
clf;colormap(jet(11));
subplot(121);mypcolor(min(temp,[],3)'./1e3.*(1-msk)');thincolorbar;grid;
shadeland(1:2*nx,1:nx1+nx+nx2,msk',[.7 .7 .7]);title('min(dxg,dyg)');
subplot(122);mypcolor(max(temp,[],3)'./1e3.*(1-msk)');thincolorbar;grid;
shadeland(1:2*nx,1:nx1+nx+nx2,msk',[.7 .7 .7]);title('max(dxg,dyg)');
set(gcf,'paperunits','inches','paperposition',[0 0 14 8]);
fpr=[dirOut 'dxgdyg_aste' num2str(nx)  'x' num2str(nx1)  'x' num2str(nx2)  '.png'];print(fpr,'-dpng');fprintf('%s\n',fpr);
