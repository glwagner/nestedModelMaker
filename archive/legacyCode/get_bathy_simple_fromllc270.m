clear all
nx0=270;nx1_0=450;nx2_0=180;ny0=2*nx1_0+nx0+nx2_0;nfx0=[nx0 0 nx0 nx2_0 nx1_0];nfy0=[nx1_0 0 nx0 nx0 nx0];
dirIn0='/nobackupp2/atnguye4/llc270/aste_270x450x180/run_template/';
b0=readbin([dirIn0 'bathy_fill9iU42Ef_noStLA.bin'],[nx0 ny0],1,'real*8');

bf0{1}=b0(:,1:nfy0(1));
bf0{3}=b0(:,nfy0(1)+1:nfy0(1)+nfy0(3));
bf0{4}=reshape(b0(:,nfy0(1)+nfy0(3)+1:nfy0(1)+nfy0(3)+nfx0(4)),nx2_0,nx0);
bf0{5}=reshape(b0(:,nfy0(1)+nfy0(3)+nfx0(4)+1:nfy0(1)+nfy0(3)+nfx0(4)+nfx0(5)),nx1_0,nx0);

nx=1080;nx1=450;nx2=360;ny=2*nx1+nx+nx2;nfx=[nx 0 nx nx2 nx1];nfy=[nx1 0 nx nx nx];
rr=nx/nx0;

temp=interp_llc270to1080_face5_v2(bf0{1},0,0,0);
bf{1}=temp(:,nx1_0*rr-nx1+1:nx1_0*rr);

temp=interp_llc270to1080_face5_v2(bf0{3},0,0,0);
bf{3}=temp;

temp=interp_llc270to1080_face5_v2(bf0{4},0,0,0);
bf{4}=temp(1:nx2,:);

temp=interp_llc270to1080_face5_v2(bf0{5},0,0,0);
bf{5}=temp(1:nx1,:);

b=cat(2,bf{1},bf{3},reshape(bf{4},nx,nx2),reshape(bf{5},nx,nx1));

dirOut=['/nobackupp2/atnguye4/llc' num2str(nx) '/aste_' num2str(nx) 'x' num2str(nx1) 'x' num2str(nx2) '/run_template/'];
writebin([dirOut 'bathy_fromllc270_r8.bin'],b,1,'real*8');
writebin([dirOut 'bathy_fromllc270_r4.bin'],b,1,'real*4');
