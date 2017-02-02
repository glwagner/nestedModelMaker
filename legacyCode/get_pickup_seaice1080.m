clear all;

SEAICE_multDim=7;	%from data.seaice
nx0=270;ny0=1350;nz0=1;
nfx0=[nx0 0 nx0 180 450];nfy0=[450 0 nx0 nx0 nx0];
%dirIn='/nobackupp2/atnguye4/llc270/aste_270x450x180/run_template/+pickup/';
dirIn='/nobackupp2/atnguye4/MITgcm_c65q/mysetups/aste_270x450x180/';
RunStrIn='run_c65q_20022013noRstar_mp03latp30_v7imdimSnow_A2v3coast08_it0013_pk0000000002_badpfespeed';RunStrShort='it0013';
ts0='0000026280';
fIn=[dirIn RunStrIn '/' 'pickup_seaice'  '.' ts0 '.data'];

nx1=450;nx2=360;
nx=1080;nxstr=num2str(1080);ny=2*nx1+nx+nx2;nz=1;
nfx=[nx 0 nx nx2 nx1];nfy=[nx1 0 nx nx nx];
dirOut=['/nobackupp2/atnguye4/llc' nxstr '/aste_' nxstr 'x' num2str(nx1) 'x' num2str(nx2) '/run_template/'];
if(exist(dirOut)==0);error('run_template dir is missing');end;
ts='0000000001';

fac=nx/nx0;
nfxa=ceil([nx0 0 nx0 nfx(4)/fac nfx(5)/fac]);nfya=ceil([nfy(1)/fac 0 nx0 nx0 nx0]);

fOut=[dirOut 'pickup_seaice_' RunStrShort '.' ts '.data'];

%---------Vector pairs-------------
for ifield=1:6
  if(ifield==6);
    clear FFu FFv FFup FFvp
    FFu=read_slice(fIn,nx0,ny0,ifield,'real*8');
    FFv=read_slice(fIn,nx0,ny0,ifield+1,'real*8');
%put to aste
    [FFu,FFv]=get_aste_vector(FFu,FFv,nfx0,nfy0,1);	%[541 901,1]
%shrinking:
    FFu=FFu(:,nfy0(1)-nfya(1)+1:sum(nfy0(1:3))+nfxa(4)+1,:);	%[1:541,316:810+1,1]
    FFv=FFv(:,nfy0(1)-nfya(1)+1:sum(nfy0(1:3))+nfxa(4)+1,:);	%[1:541,316:810+1,1]
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

%now interp to llc1080 grid: 
% [fieldOut]=interp_llc270to2160(fieldIn,flagNZ,flagUV)
    FFu_new=interp_llc270toXXXX(FFup,0,1,nx1,nx2,nx);fprintf('\n');
    FFv_new=interp_llc270toXXXX(FFvp,0,2,nx1,nx2,nx);fprintf('\n');
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

    clear FFup FFvp

%put back to compact format:
    FUc=nan(nx,ny,nz);FVc=FUc;
    for k=1:nz;
      clear tempU tempV
      [tempU,tempV]=aste_vector2compact(FFu_new(:,:,k),FFv_new(:,:,k),nfx,nfy,1);
      FUc(:,:,k)=tempU; FVc(:,:,k)=tempV;
      fprintf('%i ',k);
    end;
    fprintf('\n');
    clear tempU tempV

    iskip=(ifield-1)+(SEAICE_multDim-1);
    writebin(fOut,FUc,1,'real*8',iskip); 
    writebin(fOut,FVc,1,'real*8',iskip+1);
    fprintf('[iskip iskip+1] %i %i\n',[iskip iskip+1]);
    clear FFu_new FFv_new FUc FVc

  else
    clear FF temp mintemp maxtemp
    FF=read_slice(fIn,nx0,ny0,ifield,'real*8');
    FF=get_aste_tracer(FF,nfx0,nfy0);				%[540 900 1]
    FF=FF(:,nfy0(1)-nfya(1)+1:sum(nfy0(1:3))+nfxa(4),:);	%[1:540,226:486,1]
    FFp=FF;
    FF(find(FF==0))=nan;
    if(ifield==1);FF(find(FF==273.15))=nan;end;
    temp=FF;mintemp=nanmin(temp(:));maxtemp=nanmax(temp(:));  temp=inpaint_nans(temp);
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
    if(ifield==1);
      for iskip=(ifield-1):(SEAICE_multDim-1);			%write out 7 times
        writebin(fOut,Fc,1,'real*8',iskip);
        fprintf('iskip: %i ',iskip);
      end;
    else;
      iskip=(ifield-1)+(SEAICE_multDim-1);
      writebin(fOut,Fc,1,'real*8',iskip);
      fprintf('iskip: %i ',iskip);
    end;
    clear Fc FF_new
  end;

end;
