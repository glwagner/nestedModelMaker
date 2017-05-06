function [uc,vc]=centering_llcuv(uI,vI,nfx,nfy);
%----
%function [uc,vc]=centering_llcuv(uI,vI,nfx,nfy);
%assume that hfac[W,S] have already been applied
%[uI,vI]: in compact format
%[uc,vc]: 5 faces

%%%if not global, then will put into global face first
%----

%assume global, can readjust later to accomodate aste
sz=size(uI);if(length(sz)==2);sz=[sz 1];end;
nx=sz(1);ny=sz(2);nz=sz(3);
%nfy0_sum=[0,nfy0(1),nfy0(2),nfy0(3),nfx0(4),nfx0(5)];

%nfx=[nx,nx,nx,3*nx,3*nx];
%nfy=[3*nx,3*nx,nx,nx,nx];
nfy_sum=[0 nfy(1) nfy(2) nfy(3) nfx(4) nfx(5)];
%iskip=[0,3,6,7,10,13];

  for iface=1:5;
%define size
    u{iface}=zeros(nfx(iface)+1,nfy(iface),nz);
    v{iface}=zeros(nfx(iface),nfy(iface)+1,nz);
    uc{iface}=zeros(nfx(iface),nfy(iface),nz);
    vc{iface}=zeros(nfx(iface),nfy(iface),nz);
  end;

nfxp=nfx;nfyp=nfy;nfxq=nfx;nfyq=nfy;
up=u;uq=u;vp=v;vq=v;
  for iface=1:5;
    if(nfx(iface)==0);
          if(iface==2);
            up{iface}=nan.*v{1};vp{iface}=nan.*u{1};  nfxp(2)=nfxp(1);nfyp(2)=nfyp(1);	%for exchange
            uq{iface}=nan.*reshape(u{4}(1:nfx(4),1:nfy(4),:),nfy(4),nfx(4),nz);
            vq{iface}=nan.*reshape(v{4}(1:nfx(4),1:nfy(4),:),nfy(4),nfx(4),nz);
            nfxq(2)=nfyq(4);nfyq(2)=nfxq(4);	%for exchange
      elseif(iface==4);
            up{iface}=nan.*u{5};vq{iface}=nan.*v{5};  nfxp(4)=nfxp(5);nfyp(4)=nfyp(5);	%for exchange
            uq{iface}=nan.*reshape(v{2}(1:nfx(2),1:nfy(2),:),nfy(2),nfx(2),nz);
            vq{iface}=nan.*reshape(u{2}(1:nfx(2),1:nfy(2),:),nfy(2),nfx(2),nz);
            nfxq(4)=nfyq(2);nfyq(4)=nfxq(2);	%for exchange
      end;
    end;

%now filling in faces:
    i0=sum(nfy_sum(1:iface))+1:sum(nfy_sum(1:iface+1));
    u{iface}(1:nfx(iface),1:nfy(iface),1:nz)=...
         reshape(uI(1:nx,i0,1:nz),nfx(iface),nfy(iface),nz);
         %reshape(uI(1:nx,nx*iskip(iface)+1:nx*(iskip(iface+1)),1:nz),nfx(iface),nfy(iface),nz);
    v{iface}(1:nfx(iface),1:nfy(iface),1:nz)=...
         reshape(vI(1:nx,i0,1:nz),nfx(iface),nfy(iface),nz);
         %reshape(vI(1:nx,nx*iskip(iface)+1:nx*(iskip(iface+1)),1:nz),nfx(iface),nfy(iface),nz);
  end;

%now u edge:
  clear ut;ut=up{2}(1,1:nfyp(2),1:nz);u{1}(nfxp(1)+1,1:nfyp(1),1:nz)=ut;			%face 2 to 1
  clear ut;ut=sym_g_mod(v{4}(1:nfxp(4),1,1:nz),7,0);uq{2}(nfxq(2)+1,1:nfyq(2),1:nz)=ut;		%face 4 to 2
  clear ut;ut=u{4}(1,1:nfyp(4),1:nz);u{3}(nfxp(3)+1,1:nfyp(3),1:nz)=ut;				%face 4 to 3
%will not fill the last cells nx*3+1 for u{4} and u{5} because they're land, so assume zeros

%now v edge: (a bit more complicated that u)
  clear vt;vt=sym_g_mod(u{3}(1,1:nfyp(3),1:nz),5,0);v{1}(1:nfxp(1),nfyp(1)+1,1:nz)=vt;		%face 3 to 1
  clear vt;vt=v{3}(1:nfxp(3),1,1:nz);v{2}(1:nfxp(2),nfyp(2)+1,1:nz)=vt;				%face 3 to 2
  clear vt;vt=sym_g_mod(u{5}(1,1:nfyp(5),1:nz),5,0);v{3}(1:nfxp(3),nfyp(3)+1,1:nz)=vt;		%face 5 to 3
  if(nfx(4)>0);
    nxtemp=min(nfxp(5),nfxp(4));
    clear vt;vt=v{5}(1:nxtemp,1,1:nz);v{4}(1:nxtemp,nfyp(4)+1,1:nz)=vt;				%face 5 to 4**
  end;
  clear vt;vt=sym_g_mod(u{1}(1,1:nfyp(1),1:nz),5,0);v{5}(1:nfxp(5),nfyp(5)+1,1:nz)=vt;		%face 1 to 5


%now centering:
  for iface=1:5;
    uc{iface}=(u{iface}(1:nfx(iface),1:nfy(iface),1:nz)+u{iface}(2:nfx(iface)+1,1:nfy(iface)  ,1:nz))./2;
    vc{iface}=(v{iface}(1:nfx(iface),1:nfy(iface),1:nz)+v{iface}(1:nfx(iface)  ,2:nfy(iface)+1,1:nz))./2;
  end;

return
