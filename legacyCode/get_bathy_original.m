%20.Sep.2016
%spent a lot of time fixing bathy for llc2160, so let's use that for now:
dirRoot='/nobackupp2/atnguye4/';
%use llc2160x1800x1008, then will trim
nx0=2160;nx1p=1800;nx2p=1008;ny0=nx1p+nx0+nx2p+nx1p;nfx0=[nx0 0 nx0 nx2p nx1p];nfy0=[nx1p 0 nx0 nx0 nx0];
nx=nx0/2;nx1=450;nx2=360;ny=nx1+nx+nx2+nx1;nfx=[nx 0 nx nx2 nx1];nfy=[nx1 0 nx nx nx];
dirIn =[dirRoot 'llc' num2str(nx0) '/aste_' num2str(nx0) 'x' num2str(nfy0(1)) 'x' num2str(nfx0(4)) '/run_template/'];
dirOut=[dirRoot 'llc' num2str(nx) '/aste_' num2str(nx) 'x' num2str(nfy(1)) 'x' num2str(nfx(4)) '/run_template/'];

strbathyIn='_fix1obcs20Jun2014_5m_mod1_36';
fIn =[dirIn  'bathy_aste' num2str(nx0) 'x' num2str(nx1p) 'x' num2str(nx2p) strbathyIn '.bin'];
fOut=[dirOut 'bathy_aste' num2str(nx)  'x' num2str(nx1)  'x' num2str(nx2)  '.bin'];
temp=dir(fIn);precIn='real*4';if(temp.bytes/nx0/ny0/4==2);precIn='real*8';end;

b0=readbin(fIn,[nx0 ny0],1,precIn);
b=interp_llc2160to1080(b0,nfx0,nfy0);

%now trimming:
[bp,bpf]=get_aste_tracer(b,nfx0/2,nfy0/2);

for iface=[1,3,4,5];
  sz0=size(bpf{iface});
  if(iface==1);
    bf{iface}=bpf{iface}(:,sz0(2)-nx1+1:sz0(2));
  elseif(iface==3);
    bf{iface}=bpf{iface};
  else;
    bf{iface}=bpf{iface}(1:nfx(iface),:);
  end;
end;
for iface=[1,3:5];clf;subplot(121);mypcolor(bpf{iface}');thincolorbar;subplot(122);mypcolor(bf{iface}');thincolorbar;title(iface);pause;end;

%blanking out face4:
ix=243:360;iy=732:1007;bf{4}(ix,iy)=0;	%Alaskan Stream
ix=230:288;iy=146:273; bf{4}(ix,iy)=0;	%Okhost Sea
ix=229:360;iy=1:239;   bf{4}(ix,iy)=0;	%Okhost Sea

%now put back into compact format:
b1=cat(2,bf{1},bf{3},reshape(bf{4},nfy(4),nfx(4)),reshape(bf{5},nfy(5),nfx(5)));
writebin(fOut,b1,1,precIn);

%plotting
bp=get_aste_tracer(b1,nfx,nfy);
msk=zeros(size(bp));msk(find(bp==0))=1;msk(1:780,600:end)=1;msk(1:552,300:600)=1;msk(750:1100,1500:end)=1;
clf;mypcolor(-bp'.*(1-msk)');colorbar;grid;
shadeland(1:2*nx,1:nx1+nx+nx2,msk',[.7 .7 .7]);
set(gcf,'paperunits','inches','paperposition',[0 0 12 8]);
fpr=[dirOut 'bathy_aste' num2str(nx)  'x' num2str(nx1)  'x' num2str(nx2)  '.png'];print(fpr,'-dpng');fprintf('%s\n',fpr);
