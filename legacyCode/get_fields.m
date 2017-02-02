clear all;

nx0=270;ny0=1350;nz0=50;
nfx0=[nx0 0 nx0 180 450];nfy0=[450 0 nx0 nx0 nx0];
dirIn='/nobackupp2/atnguye4/llc270/aste_270x450x180/run_template/';

nx=1080;nx1=450;nx2=360;ny=2*nx1+nx+nx2;nz=106;nxstr=num2str(nx);
nfx=[nx 0 nx nx2 nx1];nfy=[nx1 0 nx nx nx];
dirOut=['/nobackupp2/atnguye4/llc' nxstr '/aste_' nxstr 'x' num2str(nx1) 'x' num2str(nx2) '/run_template/'];
ext=['_llc' nxstr];

fac=nx/nx0;
nfxa=ceil([nx0 0 nx0 nfx(4)/fac nfx(5)/fac]);nfya=ceil([nfy(1)/fac 0 nx0 nx0 nx0]);

flist={'WOA09v2_T_llc270_JAN.bin','WOA09v2_S_llc270_JAN.bin',...
       'diffkr_basin_v1m9EfC.bin','AREAaste_Jan2002_270x1350.bin',...
       'HEFFaste_Jan2002_270x1350.bin','HSNOWaste_Jan2002_270x1350.bin'};%'Diffkr_basin_v1m9EfB_Method2.bin',

for ifile=1:size(flist,2);

  fIn=[flist{ifile}];idot=find(fIn=='.');idash=find(fIn=='_');
  if(length(strfind(fIn,'llc'))>0);
    fOut=[dirOut fIn(1:idash(2)-1) ext fIn(idash(3):end)];
  elseif(length(strfind(fIn,'270x1350'))>0);
    fOut=[dirOut fIn(1:idash(2)) nxstr 'x' num2str(ny) fIn(idot:end)];
  else;
    fOut=[dirOut fIn(1:idot-1) ext '.bin'];
  end;

  if(exist(fOut)==0);

  clear FF
  temp=dir([dirIn fIn]);nz0=temp.bytes/nx0/ny0/8;
  FF=readbin([dirIn fIn],[nx0 ny0 nz0],1,'real*8');
  FF=get_aste_tracer(FF,nfx0,nfy0);			%[540 900 50]
  FF=FF(:,nfy0(1)-nfya(1)+1:sum(nfy0(1:3))+nfxa(4),:);	%[1:540,333:486,1:50]
  FFp=FF;
  FF(find(FF==0))=nan;
  for k0=1:nz0;
    clear temp mintemp maxtemp
    temp=FF(:,:,k0);mintemp=nanmin(temp(:));maxtemp=nanmax(temp(:));    temp=inpaint_nans(temp);
    temp(find(temp<mintemp))=mintemp;temp(find(temp>maxtemp))=maxtemp;  FFp(:,:,k0)=temp;
    fprintf('%i ',k0);
  end;fprintf('\n');
  if(nz0==1);
    FF_new=interp_llc270toXXXX(FFp,0,0,nx1,nx2,nx);fprintf('\n');
  elseif(nz0==50);
    FF_new=interp_llc270toXXXX(FFp,1,0,nx1,nx2,nx);fprintf('\n');
  end;
%trimming
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
  Fc=nan(nx,ny,size(FF_new,3));
  for k=1:size(FF_new,3);clear temp;temp=aste_tracer2compact(FF_new(:,:,k),nfx,nfy);Fc(:,:,k)=temp;fprintf('%i ',k);end;
  fprintf('\n');
  writebin(fOut,Fc,1,'real*4');
  clear FF_new Fc temp

  end;%exist(fOut)

end;
