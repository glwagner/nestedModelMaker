clear all;

nx0=270;ny0=1350;nz0=50;
nfx0=[nx0 0 nx0 180 450];nfy0=[450 0 nx0 nx0 nx0];
%dirIn='/nobackupp8/atnguye4/llc270/aste_270x450x180/run_template/+pickup/';
dirIn='/nobackupp2/atnguye4/MITgcm_c65q/mysetups/aste_270x450x180/';
RunStrIn='run_c65q_20022013noRstar_mp03latp30_v7imdimSnow_A2v3coast08_it0013_pk0000000002_badpfespeed';RunStrShort='iter0013';
ts0='0000026280';
fIn=[dirIn RunStrIn '/' 'pickup' '.' ts0 '.data'];

nx=1080;nxstr=num2str(nx);nx1=450;nx2=360;ny=2*nx1+nx+nx2;nz=106;
nfx=[nx 0 nx nx2 nx1];nfy=[nx1 0 nx nx nx];
dirOut=['/nobackupp2/atnguye4/llc' nxstr '/aste_' nxstr 'x' num2str(nx1) 'x' num2str(nx2) '/run_template/'];
if(exist(dirOut)==0);error('missing run_template dir');end;
ts='0000000001';

fac=nx/nx0;
nfxa=ceil([nx0 0 nx0 nfx(4)/fac nfx(5)/fac]);nfya=ceil([nfy(1)/fac 0 nx0 nx0 nx0]);

fOut=[dirOut 'pickup_' RunStrShort '.' ts '.data'];

%---------Vector pairs-------------
for ifield=[1,3,4,5,7,8,9];
  if(ifield==1|ifield==5);
    clear FFu FFv FFup FFvp
    FFu=read_slice(fIn,nx0,ny0,(ifield-1)*nz0+1:ifield*nz0,'real*8');
    FFv=read_slice(fIn,nx0,ny0,ifield*nz0+1:(ifield+1)*nz0,'real*8');
%put to aste
    [FFu,FFv]=get_aste_vector(FFu,FFv,nfx0,nfy0,1);	%[541 901]
%shrinking:
    FFu=FFu(:,nfy0(1)-nfya(1)+1:sum(nfy0(1:3))+nfxa(4)+1,:);	%[1:541,316:810+1,1:50]
    FFv=FFv(:,nfy0(1)-nfya(1)+1:sum(nfy0(1:3))+nfxa(4)+1,:);	%[1:541,316:810+1,1:50]
    FFup=FFu;FFvp=FFv;
    FFu(find(FFu==0))=nan;FFv(find(FFv==0))=nan;

  fprintf('begin UV interp: ');
%fill in nans:
    for k0=1:nz0;
      clear temp mintemp maxtemp
      temp=FFu(:,:,k0);mintemp=nanmin(temp(:));maxtemp=nanmax(temp(:));    temp=inpaint_nans(temp);
      temp(find(temp<mintemp))=mintemp;temp(find(temp>maxtemp))=maxtemp;   FFup(:,:,k0)=temp;
      clear temp mintemp maxtemp
      temp=FFv(:,:,k0);mintemp=nanmin(temp(:));maxtemp=nanmax(temp(:));    temp=inpaint_nans(temp);
      temp(find(temp<mintemp))=mintemp;temp(find(temp>maxtemp))=maxtemp;   FFvp(:,:,k0)=temp;
      fprintf('%i ',k0);
    end;fprintf('\n');
    clear FFu FFv temp

%now interp to llc2160 grid: 
% [fieldOut]=interp_llc270to2160(fieldIn,flagNZ,flagUV)
    FFu_new=interp_llc270toXXXX(FFup,1,1,nx1,nx2,nx);fprintf('\n');
    FFv_new=interp_llc270toXXXX(FFvp,1,2,nx1,nx2,nx);fprintf('\n');
    clear FFup FFvp

%trimming:
    NN=size(FFu_new,2)-(nx1+nx+nx2);
    if(NN>0 & floor(NN/2)*2==NN)
      FFu_new=FFu_new(:,NN/2+1:end-NN/2,:);
    elseif(NN~=0);
      error('need to figure out the size to trim!');
    end
    NN=size(FFu_new,1)-(2*nx);
    if(NN>0 & floor(NN/2)*2==NN)
      FFu_new=FFu_new(NN/2+1:end-NN/2,:,:);
    elseif(NN~=0);
      error('need to figure out the size to trim!');
    end
    NN=size(FFv_new,2)-(nx1+nx+nx2);
    if(NN>0 & floor(NN/2)*2==NN)
      FFv_new=FFv_new(:,NN/2+1:end-NN/2,:);
    elseif(NN~=0)
      error('need to figure out the size to trim!');
    end
    NN=size(FFv_new,1)-(2*nx);
    if(NN>0 & floor(NN/2)*2==NN)
      FFv_new=FFv_new(NN/2+1:end-NN/2,:,:);
    elseif(NN~=0);
      error('need to figure out the size to trim!');
    end
%
    FFv_new=cat(1,FFv_new,FFv_new(end,:,:));
    FFv_new=cat(2,FFv_new,FFv_new(:,end,:));
    FFu_new=cat(1,FFu_new,FFu_new(end,:,:));
    FFu_new=cat(2,FFu_new,FFu_new(:,end,:));

%put back to compact format:
    FUc=nan(nx,ny,nz);FVc=FUc;
    for k=1:nz
      clear tempU tempV
      [tempU,tempV]=aste_vector2compact(FFu_new(:,:,k),FFv_new(:,:,k),nfx,nfy,1);
      FUc(:,:,k)=tempU; FVc(:,:,k)=tempV;
      fprintf('%i ',k);
    end;
    fprintf('\n');
    clear tempU tempV

    iskip=ifield-1;
    writebin(fOut,FUc,1,'real*8',iskip); 
    writebin(fOut,FVc,1,'real*8',iskip+1);

    clear FFu_new FFv_new FUc FVc

  elseif(ifield==3|ifield==4);%T/S
    clear FF
    FF=read_slice(fIn,nx0,ny0,(ifield-1)*nz0+1:ifield*nz0,'real*8');
    FF=get_aste_tracer(FF,nfx0,nfy0);					%[540 900 50]
    FF=FF(:,nfy0(1)-nfya(1)+1:sum(nfy0(1:3))+nfxa(4),:);	%[1:540,226:486,1:50]
    FFp=FF;
    FF(find(FF==0))=nan;
    for k0=1:nz0;
      clear temp mintemp maxtemp
      temp=FF(:,:,k0);mintemp=nanmin(temp(:));maxtemp=nanmax(temp(:));    temp=inpaint_nans(temp);
      temp(find(temp<mintemp))=mintemp;temp(find(temp>maxtemp))=maxtemp;  FFp(:,:,k0)=temp;
      fprintf('%i ',k0);
    end;fprintf('\n');
    FF_new=interp_llc270toXXXX(FFp,1,0,nx1,nx2,nx);fprintf('\n');
%trimming:
    NN=size(FF_new,2)-(nx1+nx+nx2);
    if(NN>0&floor(NN/2)*2==NN)
      FF_new=FF_new(:,NN/2+1:end-NN/2,:);
    elseif(NN~=0);
      error('need to figure out the size to trim!');
    end
    NN=size(FF_new,1)-(2*nx);
    if(NN>0&floor(NN/2)*2==NN)
      FF_new=FF_new(NN/2+1:end-NN/2,:,:);
    elseif(NN~=0);
      error('need to figure out the size to trim!');
    end

    clear FF FFp temp
    Fc=nan(nx,ny,nz);
    for k=1:nz;clear temp;temp=aste_tracer2compact(FF_new(:,:,k),nfx,nfy);Fc(:,:,k)=temp;fprintf('%i ',k);end;
    fprintf('\n');
    iskip=ifield-1;
    writebin(fOut,Fc,1,'real*8',iskip);
    clear FF_new Fc temp

  elseif(ifield>6);%scalar field on surface
    clear FF temp mintemp maxtemp
    FF=read_slice(fIn,nx0,ny0,6*nz0+(ifield-6),'real*8');
    FF=get_aste_tracer(FF,nfx0,nfy0);					%[540 900 1]
    FF=FF(:,nfy0(1)-nfya(1)+1:sum(nfy0(1:3))+nfxa(4),:);	%[1:540,226:486,1]
    FFp=FF;
    FF(find(FF==0))=nan;
    temp=FF;mintemp=nanmin(temp(:));maxtemp=nanmax(temp(:));    		  temp=inpaint_nans(temp);
    temp(find(temp<mintemp))=mintemp;temp(find(temp>maxtemp))=maxtemp;  FFp=temp;
    FF_new=interp_llc270toXXXX(FFp,0,0,nx1,nx2,nx);
%trimming:
    NN=size(FF_new,2)-(nx1+nx+nx2);
    if(NN>0&floor(NN/2)*2==NN)
      FF_new=FF_new(:,NN/2+1:end-NN/2,:);
    elseif(NN~=0);
      error('need to figure out the size to trim!');
    end
    NN=size(FF_new,1)-(2*nx);
    if(NN>0&floor(NN/2)*2==NN)
      FF_new=FF_new(NN/2+1:end-NN/2,:,:);
    elseif(NN~=0);
      error('need to figure out the size to trim!');
    end

    clear FF FFp temp mintemp maxtemp
    Fc=aste_tracer2compact(FF_new,nfx,nfy);
    iskip=6*nz+(ifield-7);
    writebin(fOut,Fc,1,'real*8',iskip);
    clear Fc FF_new
  end;

end;
