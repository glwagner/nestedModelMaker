clear all;

%----- define size, grid ---------
nx0 = 270;
nx  = 4320; nxstr=num2str(nx);
fac = nx/nx0;
% user input:
ncut2=450; ncut1=360;

%-- define input and output dir
dirRoot=['/nobackupp2/atnguye4/llc' nxstr '/aste_' nxstr 'x' num2str(ncut2) 'x' num2str(ncut1) '/'];
dirOut=[dirRoot 'run_template/input_obcs/'];if(exist(dirOut)==0);mkdir(dirOut);fprintf('mkdir %s\n',dirOut);end;
dirMatlab=[dirRoot 'matlab/'];cd(dirMatlab);

nfx0=[nx0 0 nx0 180   450];   nfy0=[  450 0 nx0 nx0 nx0];
nfx =[nx  0 nx  ncut1 ncut2]; nfy =[ncut2 0 nx  nx  nx];

% "_full" <=> "global"
nfx0_full=[nx0 0 nx0 0 3*nx0]; nfy0_full=[3*nx0 0 nx0 0 nx0];
nfx_full =[nx 0 nx 0 3*nx];    nfy_full =[3*nx 0 nx 0 nx];

%----- define indices of domain ---------
ix1=1:nx;					%global [   1 1080]
iy1=3*nx-ncut2+[1:ncut2];			%global [2791 3240]

ix5=3*nx-[iy1(end):-1:iy1(1)]+1;		%global [   1  450]
iy5=sort(nx-ix1)+1;				%global [   1 1080]

ix4=1:ncut1;					%global [   1  360]
iy4=1:nx;					%global [   1 1080]

ix1_0=ceil(ix1(1)/fac):ix1(end)/fac;		%global [   1  270]
iy1_0=[floor(iy1(1)/fac):ceil(iy1(end)/fac)];	%global [ 697  810]
ix5_0=sort(3*nx0-(iy1_0)+1);			%global [   1  114]
iy5_0=ceil(iy5(1)/fac):iy5(end)/fac;		%global [   1  270]
ix4_0=1:ncut1/fac;				%global [   1   90]
iy4_0=1:nx0;					%global [   1  270]

%------ load grid -------------
fieldstr={'xc','yc','xg','yg','dxg','dyg'};
indfield=[  1    2    6    7    15    16];

dirGrid0='/nobackupp2/atnguye4/llc270/global/run_template_llc270/';
for iface=[1,3,4,5]
      if(iface==1);nxa=nx0;nya=3*nx0;ixa=1:nxa;iya=nya-nfy0(iface)+1:nya;%these indices are from global llc
  elseif(iface==3);nxa=nx0;nya=nx0;  ixa=1:nfx0(iface);iya=1:nya;
  else;            nxa=3*nx0;nya=nx0;ixa=1:nfx0(iface);iya=1:nya;end;
  for ifld=1:size(fieldstr,2);
    clear temp tmp1
    temp=read_slice([dirGrid0 'llc_00' num2str(iface) '_' num2str(nxa) '_' num2str(nya) '.bin'],...
                     nxa+1,nya+1,indfield(ifld),'real*8');		%global
    eval(['mygrid0.' fieldstr{ifld} '{iface}=temp(ixa,iya);']);		%aste
  end;
end;

dirGrid1=['/nobackupp2/atnguye4/llc' nxstr '/aste_' nxstr 'x' num2str(ncut2) 'x' num2str(ncut1) '/run_template/'];
for iface=[1,3,4,5]
      if(iface==1);nxa=nfx(iface);nya=nfy(iface);ixa=1:nxa;iya=1:nya;           %these indices are from cut mitgrid
  elseif(iface==3);nxa=nfx(iface);nya=nfy(iface);ixa=1:nxa;iya=1:nya;
  else;            nxa=nfx(iface);nya=nfy(iface);ixa=1:nxa;iya=1:nya;end;

  for ifld=1:size(fieldstr,2);
    temp=read_slice([dirGrid1 'tile' sprintf('%3.3i',iface) '.mitgrid'],...
                     nfx(iface)+1,nfy(iface)+1,indfield(ifld),'real*8');
    eval(['mygrid1.' fieldstr{ifld} '{iface}=temp(ixa,iya);']);		%regional
  end;
end

%-------- MANUAL PART: define for EACH ob ------------------
obcstype=['NSEW'];
for iobcs=1:4;
if(iobcs==1);
%5deg Atlantic
  fieldIn0.obcsstr='S';
  fieldIn0.obcstype=find(obcstype==fieldIn0.obcsstr);
  fieldIn0.face=1;
  fieldIn0.nx=nx0;							% 270
  fieldIn0.nfx=nfx0;							% [270 0 270 180 450]
  fieldIn0.nfy=nfy0;							% [450 0 270 270 270]
  fieldIn0.sshiftx=(nfx0_full(fieldIn0.face)-nfx0(fieldIn0.face));	% 0
  fieldIn0.sshifty=(nfy0_full(fieldIn0.face)-nfy0(fieldIn0.face));	% 360
  fieldIn0.ix=[1:nx0]+fieldIn0.sshiftx;					% [1:270] global (eyeballing)


  fieldIn0.jy=(iy1_0(1)+1).*ones(size(fieldIn0.ix));	% [338] aste, [698]  global (1st wet pt)

  eval(['ix=ix' num2str(fieldIn0.face) ';']);
  eval(['iy=iy' num2str(fieldIn0.face) ';']);
  fieldIn.obcsstr=fieldIn0.obcsstr;
  fieldIn.obcstype=fieldIn0.obcstype;
  fieldIn.face=fieldIn0.face;
  fieldIn.nx=nx;							% 1080
  fieldIn.nfx=nfx;							% [1080 0 1080  360  450]
  fieldIn.nfy=nfy;							% [ 450 0 1080 1080 1080]
  fieldIn.sshiftx=ix(1)-1;						% 0
  fieldIn.sshifty=iy(1)-1;						% 3*1080-1200=2040, or 2041-1=2040
  fieldIn.ix=(fieldIn0.ix(1)-1)*fac+1:fieldIn0.ix(end)*fac;		% global [1 1080]
  if(fieldIn0.obcsstr=='N');
    fieldIn.jy=((fieldIn0.jy(1)-1)*fac+1).*ones(size(fieldIn.ix));
  elseif(fieldIn0.obcsstr=='S');
    fieldIn.jy=(fieldIn0.jy(1)*fac).*ones(size(fieldIn.ix));		% global 2792, (1st wet pt)
  end
  fieldIn.flag_case=0;

elseif(iobcs==2);
% Pacific
  fieldIn0.obcsstr='E';
  fieldIn0.obcstype=find(obcstype==fieldIn0.obcsstr);
  fieldIn0.face=4;
  fieldIn0.nx=nx0;
  fieldIn0.nfx=nfx0;
  fieldIn0.nfy=nfy0;
  fieldIn0.sshiftx=0;
  fieldIn0.sshifty=0;
  fieldIn0.jy=[ 1:270]+fieldIn0.sshifty;                        %global
  fieldIn0.ix=ceil(ncut1/fac)*ones(size(fieldIn0.jy))+fieldIn0.sshiftx; %global (1st wet pt)    %90

  eval(['ix=ix' num2str(fieldIn0.face) ';']);
  eval(['iy=iy' num2str(fieldIn0.face) ';']);
  fieldIn.obcsstr=fieldIn0.obcsstr;
  fieldIn.face=fieldIn0.face;
  fieldIn.obcstype=fieldIn0.obcstype;
  fieldIn.nx=nx;
  fieldIn.nfx=nfx;
  fieldIn.nfy=nfy;
  fieldIn.sshiftx=ix(1)-1;
  fieldIn.sshifty=iy(1)-1;                                      % 1080-1080=0, or 361-361=0
  fieldIn.jy=(fieldIn0.jy(1)-1)*fac+1:fieldIn0.jy(end)*fac;     % [  1 1080] global
  if(fieldIn0.obcsstr=='E');
    fieldIn.ix=((fieldIn0.ix(1)-1)*fac+1).*ones(size(fieldIn.jy)); % [357], global (1st wet pt)
  elseif(fieldIn0.obcsstr=='W');
    fieldIn.ix=(fieldIn0.ix(1)*fac).*ones(size(fieldIn.jy));
  end;
  fieldIn.flag_case=0;

elseif(iobcs==3);
%52deg in Atlantic
  fieldIn0.obcsstr='E';
  fieldIn0.obcstype=find(obcstype==fieldIn0.obcsstr);
  fieldIn0.face=5;
  fieldIn0.nx=nx0;
  fieldIn0.nfx=nfx0;
  fieldIn0.nfy=nfy0;
  fieldIn0.sshiftx=0;
  fieldIn0.sshifty=0;
  fieldIn0.jy=[ 1:270]+fieldIn0.sshifty;			%global
  fieldIn0.ix=ceil(ncut2/fac)*ones(size(fieldIn0.jy))+fieldIn0.sshiftx;	%global (1st wet pt)	%113

  eval(['ix=ix' num2str(fieldIn0.face) ';']);
  eval(['iy=iy' num2str(fieldIn0.face) ';']);
  fieldIn.obcsstr=fieldIn0.obcsstr;
  fieldIn.face=fieldIn0.face;
  fieldIn.obcstype=fieldIn0.obcstype;
  fieldIn.nx=nx;
  fieldIn.nfx=nfx;
  fieldIn.nfy=nfy;
  fieldIn.sshiftx=ix(1)-1;
  fieldIn.sshifty=iy(1)-1;					% 1080-1080=0, or 361-361=0
  fieldIn.jy=(fieldIn0.jy(1)-1)*fac+1:fieldIn0.jy(end)*fac;     % [  1 1080] global
  if(fieldIn0.obcsstr=='E');
    fieldIn.ix=((fieldIn0.ix(1)-1)*fac+1).*ones(size(fieldIn.jy)); % [449], global (1st wet pt)
  elseif(fieldIn0.obcsstr=='W');
    fieldIn.ix=(fieldIn0.ix(1)*fac).*ones(size(fieldIn.jy));
  end;
  fieldIn.flag_case=0;

end;

% Where the magic happens:
[fieldOut, fieldOut0] = get_obcsNSEW(fieldIn0, fieldIn, ...
							mygrid0, mygrid1, 0, fieldIn.flag_case);

  obcs0{iobcs}=fieldOut0;
  obcs{iobcs} =fieldOut;
end;

datestamp='31Dec2016';%datestamp=date;datestamp(find(datestamp=='-'))='';
fsave=[dirOut 'step0_obcs_' datestamp '.mat'];save(fsave,'obcs0','obcs');fprintf('%s\n',fsave);
