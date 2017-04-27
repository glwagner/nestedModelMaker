%load in step1 llc270aste output, expand and interp to 106k
clear all;

%set generic indices + constants
%nx0=270; ny0=1350; nz0=50; nfx0=[nx0 0 nx0 180 450];nfy0=[450 0 nx0 nx0 nx0];
%sum_nfac0=nfy0(1)+nfy0(2)+nfy0(3)+nfx0(4)+nfx0(5);

nx=1080; ncut1=360;ncut2=450; nxstr=num2str(nx);
%nfx=[ncut1 0 ncut1 0 ncut2];nfy=[ncut2 0 ncut1 0 ncut1];

%set directory
dirRoot=['/nobackupp2/atnguye4/llc' nxstr '/aste_' nxstr 'x' num2str(ncut2) 'x' num2str(ncut1) '/'];
dirIn = [dirRoot 'run_template/input_obcs/'];dirOut = dirIn;
dirMatlab=[dirRoot 'matlab/'];cd(dirMatlab);

%dirGrid0=['/nobackupp2/atnguye4/MITgcm_c65q/mysetups/aste_270x450x180/GRID_real8/'];
dirGrid0=['/nobackupp2/atnguye4/MITgcm_c65q/mysetups/aste_270x450x180/GRID_real8_fill9iU42Ef_noStLA/'];
dirGrid =['/nobackupp2/atnguye4/llc1080/NA1080x1200/GRID_real8_v3/'];	%this is hardcoded, to get drF

% load drF
rF0  =   (squeeze(rdmds([dirGrid0 'RF'])));
rF   =   (squeeze(rdmds([dirGrid  'RF'])));
drF0 =   (squeeze(rdmds([dirGrid0 'DRF'])));  nz0=length(drF0);
drF  =   (squeeze(rdmds([dirGrid  'DRF'])));  nz =length(drF);

% load step 0 obcs structures
datestamp='31Dec2016';
fIn=[dirIn 'step0_obcs_' datestamp '.mat'];load(fIn,'obcs');
fIn=[dirIn 'step1_obcs_' datestamp '.mat'];load(fIn,'obcs0','T0','S0','U0','V0');

nt=size(T0{1},3);
fsave=[dirOut 'step2_obcs_' datestamp '.mat'];

%if(exist(fsave)==0);
%initialize
for iobcs=1:size(obcs,2);	%8
  iface=obcs{iobcs}.face;
  ix=unique(obcs{iobcs}.iC1(2,:));Lix=length(ix);
  jy=unique(obcs{iobcs}.jC1(2,:));Ljy=length(jy);
  iv=unique(obcs{iobcs}.ivel(2,:));
  jv=unique(obcs{iobcs}.jvel(2,:));

  if(iv~=0 & jv==0);                  %either E or W
    T{iobcs}=zeros(Ljy,nz,nt);
  elseif(jv~=0 & iv==0);              %either N or S
    T{iobcs}=zeros(Lix,nz,nt);
  end;
  S{iobcs}=T{iobcs};
  U{iobcs}=T{iobcs};
  V{iobcs}=T{iobcs};
end;

%now do first round of interpolation
flagXX=[1 0];flagNZ=1;flaghFac=0;
varstr={'T','S','U','V'};
for iobcs=1:size(obcs,2);
  for ivar=1:size(varstr,2);
    eval(['tmp0=' varstr{ivar} '0{iobcs};']);
    tmp=interp_llc270toXXXX_v6(tmp0,flagXX,flagNZ,flaghFac,nx,drF0,drF);
    eval([varstr{ivar} '{iobcs}=tmp;']);
  end;
end;

%check obcs:
fnames=fieldnames(obcs0{1});
for iobcs=1:size(obcs0,2);
  clear sz szp iz ix tmp tmp0
  sz=size(T0{iobcs});					%[nx0 nz0 nt]

  for ifld=1:size(fnames,1);
    clear fnamep iz ix szp tmp
    fnamep=char(fnames(ifld));

    if(isfield(obcs{iobcs},fnamep)==0);			%if field does not exist in obcs
      eval(['tmp0=obcs0{iobcs}.' fnamep ';']);
      szp=size(tmp0);
      iz=find(szp==sz(2));	%nz0
      ix=find(szp==sz(1));	%nx0

      if(ix==1);
        if(isempty(iz)==1);
          tmp=interp_llc270toXXXX_v6(tmp0,flagXX,0,0,nx,drF0,drF);

        elseif(iz==2);
          if(length(strfind(lower(fnamep),'hf'))>0);
            tmp=interp_llc270toXXXX_v6(tmp0,flagXX,flagNZ,1,nx,drF0,drF);
          else;
            tmp=interp_llc270toXXXX_v6(tmp0,flagXX,flagNZ,0,nx,drF0,drF);
          end;
        end; %iz
        eval(['obcs{iobcs}.' fnamep '=tmp;']);

      end;   %ix
    end;     %isfield
  end;       %ifld
end;         %iobcs

%fix special case Gibraltar strait
for iobcs=1:size(obcs,2);
  if(obcs{iobcs}.flag_case==1);
    Lx=length(obcs{iobcs}.ix);
    str={'D1','D2','hfC1','hfC2','hfW','hfS'};
    for istr=1:size(str,2);
      if(isfield(obcs{iobcs},str{istr})==1);
        eval(['obcs{iobcs}.' str{istr} '=obcs{iobcs}.' str{istr} '(1:Lx,:);']);
      end;
    end;
    str={'T','S','U','V'};
    for istr=1:size(str,2);
      eval([str{istr} '{iobcs}=' str{istr} '{iobcs}(1:Lx,:,:);']);
    end;
  end;
end;

%calculating hFac using updated bathy:
hFacMin=0.2;
hFacMinDr=5.;

%define last obcs:
obcs2=obcs;
obcsstr='NSEW';
obcstype=[1 2 3 4];
obcsvelstr={'V','V','U','U'};
obcshfstr ={'S','S','W','W'};
obcsdsstr ={'x','x','y','y'};
obcsvelnulstr={'U','U','V','V'};

for iobcs=1:size(obcs,2);

  itype=find(obcsstr==obcs{iobcs}.obcsstr);
  velstr=obcsvelstr{itype};
  hfstr =obcshfstr{itype};
  dsstr =obcsdsstr{itype};
  velnulstr=obcsvelnulstr{itype};

%first, test that we can reproduce hf in obcs0:
  bathyo=obcs0{iobcs}.D1;  hfo    =obcs0{iobcs}.hfC1;
  [bathyop,hfop]=calc_hFacC(-abs(bathyo),hFacMin,hFacMinDr,drF0,rF0);		%1=ocean, 0=land
  tmp=bathyo-abs(bathyop);[sum(tmp) mean(tmp)]	%[-6.477e-11  -2.4e-13]

%old bathy and hfacC
%1st/2nd wet pt
  for istr=1:2;istrp=num2str(istr);
  eval(['bathyo' istrp ' = obcs{iobcs}.D'   istrp ';']);
  eval(['hfo'    istrp ' = obcs{iobcs}.hfC' istrp ';']);
  eval(['[bathyo' istrp 'p,hf' istrp ']=calc_hFacC(-abs(bathyo' istrp '),hFacMin,hFacMinDr,drF,rF);']);%1=ocean, 0=land
  eval(['bathyn' istrp ' = remove_extra_ocean_hFacC(abs(bathyo' istrp 'p),hfo' istrp ',hf' istrp ',hFacMin,hFacMinDr,drF,abs(rF));']);
  eval(['[bathyn' istrp 'p,hfa' istrp ']=calc_hFacC(-abs(bathyn' istrp '),hFacMin,hFacMinDr,drF,rF);']);%1=ocean, 0=land
  end;
  [iz,ix]=meshgrid(1:size(hfa1,2),1:size(hfa1,1));
  tmp=hf1-hfo1;
  ii=find(tmp(:)>0 & hfo1(:)==0);					%point of "new" ocean
  jj=find(tmp(:)>0 & hfo1(:)>0);					%point where new drF yields more fraction
  kk=find(tmp(:)<0 & hfo1(:)>=0);					%point where new drF yeilds less fraction, OK
  tmp=hfa1-hfo1;
  ll=find(tmp(:)>0 & hfo1(:)==0);					%point of "new" ocean
  mm=find(tmp(:)>0 & hfo1(:)>0);					%point where new drF yields more fraction
  nn=find(tmp(:)<0 & hfo1(:)>=0);					%point where new drF yields more fraction

%now compare old and new hf[W,S] to make sure there is no "new" ocean hole
  hfveln1=cat(3,hfa1,hfa2);hfveln1=min(hfveln1,[],3);
  eval(['hfvel1=obcs{iobcs}.hf' hfstr ';']);
  tmp=hfveln1-hfvel1;
  oo=find(tmp(:)>0 & hfvel1(:)==0);					%points of "new" ocean, need plug
  pp=find(tmp(:)>0 & hfvel1(:)>0);					%points of new more fraction, OK
  qq=find(tmp(:)<0 & hfvel1(:)>=0);					%points of new less fraction, OK
  [length(ii) length(ll) length(oo) length(jj) length(mm) length(pp) length(kk) length(nn) length(qq)]	%[0 0 0 196 236 212 140 128 148]

  if(length(oo)>0);
    fprintf('there is new ocean in hf %s ',obcs{iobcs}.obcsstr);
  end;

  figure(1);clf;colormap(jet(20));
    subplot(331);mypcolor(hfo1');thincolorbar;grid;title('hfo1 - interp from llc270');
    subplot(332);mypcolor(hf1');thincolorbar;grid;title('hf1 - get from new drF');
    subplot(333);mypcolor(hf1'-hfo1');thincolorbar;grid;title('hf1-hfo1');
       hold on;plot(ix(ii),iz(ii),'b.');plot(ix(jj),iz(jj),'.','color',.7.*[1 1 1]);plot(ix(kk),iz(kk),'k.');hold off;
    subplot(334);mypcolor(hfa1');thincolorbar;grid;title('hfa1; new hfa to remove new ocean');
    subplot(336);mypcolor(hfa1'-hfo1');thincolorbar;grid;title('hfa1-hfo1, expect <=0');
       hold on;plot(ix(ll),iz(ll),'b.');plot(ix(mm),iz(mm),'.','color',.7.*[1 1 1]);plot(ix(nn),iz(nn),'k.');hold off;
    subplot(337);mypcolor(hfvel1');thincolorbar;grid;title('original hf[S,W]');
    subplot(338);mypcolor(hfveln1');thincolorbar;grid;title('new hf[S,W]');
    subplot(339);mypcolor(hfveln1'-hfvel1');grid;thincolorbar;title('new minus old, want to be <0');
       hold on;plot(ix(oo),iz(oo),'m.');plot(ix(pp),iz(pp),'.','color',.7.*[1 1 1]);plot(ix(qq),iz(qq),'k.');hold off;

%compute transport:
  eval(['hfvelo=obcs0{iobcs}.hf' hfstr ';']);
  eval(['ds0=obcs0{iobcs}.d' dsstr 'g;']);
  eval(['ds =obcs{iobcs}.d' dsstr 'g;']);
  eval(['vel0=' velstr '0{iobcs};']);
  eval(['vel=' velstr '{iobcs};']);
  eval(['scale0=obcs2{iobcs}.scale' upper(dsstr) ';']);			%size [1 nx]
  sz=size(vel);
  scale0=repmat(scale0',[1 sz(2) sz(3)]);

  tr0=compute_gate_transport(vel0,ds0,drF0,hfvelo);
  tr1=compute_gate_transport(vel.*scale0 ,ds ,drF ,hfvel1);
  tr1p=compute_gate_transport(vel.*scale0,ds ,drF ,hfveln1);

%take ratio
  sscale=tr1./tr1p;	%size [1 nt]
  eval(['tmp=obcs2{iobcs}.scale' upper(dsstr) ';']);			%size [1 nx]
  sz=size(tmp);if(sz(1)==1&sz(2)==size(vel,1));tmp=tmp';end;
  sscale=tmp*sscale;							%size [nx nt]
  sscale=repmat(sscale,[1 1 nz]);sscale=permute(sscale,[1 3 2]);	%size [nx nz nt]
  eval(['obcs2{iobcs}.scale' obcs{iobcs}.obcsstr '=sscale;']);
  eval(['obcs2{iobcs}.' velstr '=vel.*sscale;']);
  eval(['obcs2{iobcs}.' velnulstr '=0.*obcs2{iobcs}.' velstr ';']);
  obcs2{iobcs}.T =T{iobcs};
  obcs2{iobcs}.S =S{iobcs};
  obcs2{iobcs}.D1=bathyn1;
  obcs2{iobcs}.D2=bathyn2;
  obcs2{iobcs}.hfC1=hfa1;
  obcs2{iobcs}.hfC2=hfa2;
  eval(['obcs2{iobcs}.hf' hfstr '=hfveln1;']);

%now compute the last transport, make sure it matches with tr0:
  eval(['vel2=obcs2{iobcs}.' velstr ';']);
  eval(['hf  =obcs2{iobcs}.hf' hfstr ';']);
  tr2=compute_gate_transport(vel2,ds,drF,hf);

  figure(2);clf;
  a=tr1 -tr0;subplot(311);plot(a,'-');title([num2str(sum(a)) ',' num2str(mean(a))]);ylabel('tr\_expand - tr270');grid;
  a=tr1p-tr0;subplot(312);plot(a,'-');title([num2str(sum(a)) ',' num2str(mean(a))]);ylabel('tr\_expand\_fixed - tr270');grid;
  a=tr2 -tr0;subplot(313);plot(a,'-');title([num2str(sum(a)) ',' num2str(mean(a))]);ylabel('tr\_exapnd\_fixed\_scaled) - tr270');grid;

end;

save(fsave,'obcs2','-v7.3');fprintf('%s\n',fsave);
%else;
%  load(fsave,'obcs2');
%end;

%arrange into East, West, North South
nTpad=2;
nfx=obcs2{1}.nfx;
nfy=obcs2{1}.nfy;
sz=size(obcs2{1}.T);
LEast=sum(nfy);
LWest=LEast;
LNorth=sum(nfx);
LSouth=sum(nfx);

obcsstr={'N','S','E','W'};
obcsstrlong={'North','South','East','West'};
yshift=cumsum([0 nfy]);
xshift=cumsum([0 nfx]);
varstr={'T','S','U','V'};

get_field=1; %<-- make 0 to get indices for data.obcs
%initialize
for iloop=1:size(obcsstr,2);
  if(get_field==1);
  for ivar=1:size(varstr,2);
    eval([obcsstrlong{iloop} '.' varstr{ivar} '=zeros(L' obcsstrlong{iloop} ',sz(2),sz(3)+nTpad);']);
  end;
  end;
  eval([obcsstrlong{iloop} '.ind=zeros(L' obcsstrlong{iloop} ',1);']);		%keep track of indices for data.obcs
end;

for iloop=2:3;%size(obcsstr,2);		%NSEW
  for iobcs=1:size(obcs2,2);		%1-8
    if(obcs2{iobcs}.obcsstr==obcsstr{iloop});
      iface=obcs2{iobcs}.face;
      ix=unique(obcs2{iobcs}.iC1(2,:));
      jy=unique(obcs2{iobcs}.jC1(2,:));
      for ivar=1:size(varstr,2);	%TSUV
        clear inan tmp
        if(obcs2{iobcs}.obcsstr=='N'|obcs2{iobcs}.obcsstr=='S');	%N,S
          if(get_field==1);
            eval(['sz=size(obcs2{iobcs}.' varstr{ivar} ');']);
            tmp=zeros(sz(1),sz(2),sz(3)+nTpad);				%add padding +2
            eval(['tmp(:,:,2:end-1)=obcs2{iobcs}.' varstr{ivar} ';']);
            tmp(:,:,1)=tmp(:,:,2);tmp(:,:,end)=tmp(:,:,end-1);
            inan=find(isnan(tmp(:))==1);if(length(inan)>0);tmp(inan)=0;end;		%get rid of nan
            eval([obcsstrlong{iloop} '.' varstr{ivar} '(ix+xshift(iface),:,:)=tmp;']);
          end;
          if(ivar==1);eval([obcsstrlong{iloop} '.ind(ix+xshift(iface))=jy;']);end;
        else;
          if(get_field==1);
            eval(['sz=size(obcs2{iobcs}.' varstr{ivar} ');']);
            tmp=zeros(sz(1),sz(2),sz(3)+nTpad);
            eval(['tmp(:,:,2:end-1)=obcs2{iobcs}.' varstr{ivar} ';']);
            tmp(:,:,1)=tmp(:,:,2);tmp(:,:,end)=tmp(:,:,end-1);
            inan=find(isnan(tmp(:))==1);if(length(inan)>0);tmp(inan)=0;end;               %get rid of nan
            eval([obcsstrlong{iloop} '.' varstr{ivar} '(jy+yshift(iface),:,:)=tmp;']);
          end;
          if(ivar==1);eval([obcsstrlong{iloop} '.ind(jy+yshift(iface))=ix;']);end;
        end;
      end;	%ivar
    end		%
  end;		%iobcs
end;		%iloop

%write out
write_files=1;
if(write_files==1);
nzstr=num2str(sz(2));
ntstr=num2str(sz(3)+nTpad);
for iloop=2:3;%size(obcsstr,2);	S,E
  eval(['L=L' obcsstrlong{iloop} ';']);
  str=[sprintf('%4.4i',L) 'x' nzstr 'x' ntstr];
  for ivar=1:size(varstr,2);
    clear tmp fOut
    fOut=[dirOut 'OB' obcsstr{iloop} lower(varstr{ivar}) '_' str '_' datestamp '.bin'];
    eval(['tmp=' obcsstrlong{iloop} '.' varstr{ivar} ';']);
    writebin(fOut,tmp,1,'real*4');fprintf('%s\n',fOut);
  end;
end;
end;

%getting indices:
%South
iy=unique(South.ind);iy=iy(find(iy>0));
for i=1:length(iy);
  ix=find(South.ind==iy(i));
  fprintf('[ix_start ix_end length(ix) iy]=%i %i %i %i\n',...
           [ix(1) ix(end) ix(end)-ix(1)+1 iy(i)]);
end;
%[ix_start ix_end length(ix) iy]=1 1080 1080 2
%OB_Jsouth = 1080*2, 1890*0

%East
ix=unique(East.ind);ix=ix(find(ix>0));
for i=1:length(ix);
  iy=find(East.ind==ix(i));
  fprintf('[iy_start iy_end length(iy) ix]=%i %i %i %i\n',...
           [iy(1) iy(end) iy(end)-iy(1)+1 ix(i)]);
end;
%%%%[iy_start iy_end length(iy) ix]=440 443 4 383
%[iy_start iy_end length(iy) ix]=1531 2610 1080 357
%[iy_start iy_end length(iy) ix]=2611 3690 1080 449
%%%%OB_Ieast = 439*0, 4*383, 1087*0, 1080*357, 1080*449
%OB_Ieast = 450*0, 1080*0, 1080*357, 1080*449

%West
%ix=unique(West.ind);ix=ix(find(ix>0));
%for i=1:length(ix);
%  iy=find(West.ind==ix(i));
%  fprintf('[iy_start iy_end length(iy) ix]=%i %i %i %i\n',...
%           [iy(1) iy(end) iy(end)-iy(1)+1 ix(i)]);
%end;
