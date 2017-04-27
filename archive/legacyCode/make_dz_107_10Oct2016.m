%atn 13.Sep.2016
%Chen Chen contrib:  note that we need to output drF as real*8, otherwise
%there is leakage
clear all;
%dirOut='/net/nares/raid8/ecco-shared/llc2160/aste_2160x1800x1008/GRID/';if(exist(dirOut)==0);mkdir(dirOut);end;
version=3;vstr=['v' num2str(version)];
%dirOut=['/workspace/ecco-shared/llc1080/aste_1080x450x360/GRID_real8_' vstr '/'];if(exist(dirOut)==0);mkdir(dirOut);end;
% change this
dirOut= pwd;
%rf1=readbin('/net/nares/raid8/ecco-shared/llc270/aste_270x450x180/GRID_real8/RF.data',[1 51],1,'real*8');rf1=abs(rf1);
%rF=readbin('/net/nares/raid8/ecco-shared/llc2160/global/GRID/RF.data',[1 91]);rF=abs(rF);
 delR = [...
     10.000000000000000000000000, 10.000000000000000000000000, 10.000000000000000000000000, 10.000000000000000000000000,...
     10.000000000000000000000000, 10.000000000000000000000000, 10.000000000000000000000000, 10.010000000000000000000000,...
     10.030000000000000000000000, 10.110000000000000000000000, 10.320000000000000000000000, 10.800000000000000000000000,...
     11.760000000000000000000000, 13.420000000000000000000000, 16.040000000000000000000000, 19.820000000000000000000000,...
     24.850000000000000000000000, 31.100000000000000000000000, 38.420000000000000000000000, 46.500000000000000000000000,...
     55.000000000000000000000000, 63.500000000000000000000000, 71.580000000000000000000000, 78.900000000000000000000000,...
     85.150000000000000000000000, 90.180000000000000000000000, 93.960000000000000000000000, 96.580000000000000000000000,...
     98.250000000000000000000000, 99.250000000000000000000000,100.010000000000000000000000,101.330000000000000000000000,...
    104.560000000000000000000000,111.330000000000000000000000,122.830000000000000000000000,139.090000000000000000000000,...
    158.940000000000000000000000,180.830000000000000000000000,203.550000000000000000000000,226.500000000000000000000000,...
    249.500000000000000000000000,272.500000000000000000000000,295.500000000000000000000000,318.500000000000000000000000,...
    341.500000000000000000000000,364.500000000000000000000000,387.500000000000000000000000,410.500000000000000000000000,...
    433.500000000000000000000000,456.500000000000000000000000];
%delR=ceil(delR);
if(version==2);
  rf1=[0 cumsum(delR)];
  N=107;il=[1 8 11:2:N];ik=[1:51];clear temp1 temp2;temp1=rf1(ik);temp2=spline(il,temp1,1:N);
  delR106=diff(temp2);temp3=[0 cumsum(delR106)];
%linear interp is BAD, do not use
%N=107;il=[1 8 11:2:N];ik=[1:51];clear temp1 temp2;temp1=rf1(ik);temp2p=interp1(il,temp1,1:N,'linear');
%atn: CAN NOT round, otherwise introduce error
%delR106=diff(temp2);delR106=round(delR106*100)/100;temp3=[0 cumsum(delR106)];
%now make delR106 to be monotonically increasing:
  delR106p=delR106;
  delR106p(1:4)=[delR106(3), delR106(2), delR106(4), delR106(1)];
  delR106p(3)=delR106p(3)+.03;
  delR106p(4)=delR106p(4)-.03;
  datestmp='13Sep2016';
elseif(version==3|version==5);
  if(version==3);
    rf1=[-10 0 cumsum(delR)];
    N=107;il=[-7 1 8 11:2:N];ik=[1:52];clear temp1 temp2;temp1=rf1(ik);temp2=spline(il,temp1,1:N);
%trying a slightly different function to reduce the sharp gradient from 10 to 11:
    clear temp tempp;temp=interp1([-10 1  8 11 12 13 14 15 16 17 18 19],...
                                  [-20 0 10 20 25 30 35 40 45 50 45 40],[1:20],'spline')
  elseif(version==5);
    rf1=[-10 0 cumsum(delR)];
    N=107;il=[-7 1 8 11:2:N];ik=[1:52];clear temp1 temp2;temp1=rf1(ik);temp2=spline(il,temp1,1:N);
%trying a slightly different function to reduce the sharp gradient from 10 to 11:
    clear temp tempp;temp=interp1([-10 1 11 13 15 17 19],[-20 0 20 30 40 50 40],[1:11],'spline')
  end;
  tempp=diff(temp);
  delR106=diff(temp2);delR106(1:10)=tempp(1:10);delR106(11:20)=5;temp3=[0 cumsum(delR106)];
  delR106p=delR106;
%rounding off!!
  fac=1e2;
  temp=round(delR106p.*fac);
  temp50=delR.*fac;
  if(version==3);
    temp(7)=temp50(1)-sum(temp(1:6));
    temp(10)=temp50(2)-sum(temp(8:9));
    datestmp='11Oct2016';
  elseif(version==5);
    temp(10)=sum(temp50(1:2))-sum(temp(1:9));
    for k=3:50;temp(k*2+6)=temp50(k)-temp(k*2+5);end;
    datestmp='10Oct2016';
  end;
  delR106p=temp./fac;
end;

%delR106p=diff(temp2p);
temp3p=[0 cumsum(delR106p)];
%delR106:
for k=1:11;ii=[(k-1)*10+1:k*10];
 if(ii(end)>(N-1));jj=find(ii<=(N-1));ii=ii(jj);end;fprintf('%8.2f',delR106(ii));fprintf('\n');end;
for k=1:11;ii=[(k-1)*10+1:k*10];
 if(ii(end)>(N-1));jj=find(ii<=(N-1));ii=ii(jj);end;fprintf('%8.2f',delR106p(ii));fprintf('\n');end;
%version2:
%    1.13    1.17    1.23    1.31    1.38    1.68    2.10    2.64    3.29    4.06
%    4.84    5.16    5.04    4.96    4.99    5.01    5.00    5.00    5.00    5.00
%    5.00    5.01    5.01    5.02    5.04    5.07    5.12    5.20    5.31    5.49
%    5.72    6.04    6.45    6.97    7.62    8.42    9.36   10.46   11.72   13.13
%   14.70   16.40   18.24   20.18   22.21   24.29   26.43   28.57   30.71   32.79
%   34.82   36.76   38.60   40.30   41.87   43.28   44.54   45.64   46.58   47.38
%   48.03   48.55   48.96   49.29   49.53   49.72   49.90   50.11   50.41   50.92
%   51.69   52.87   54.54   56.79   59.67   63.16   67.26   71.83   76.83   82.11
%   87.61   93.22   98.91  104.64  110.38  116.12  121.87  127.63  133.38  139.12
%  144.87  150.63  156.38  162.12  167.87  173.63  179.38  185.12  190.87  196.63
%  202.38  208.12  213.87  219.63  225.38  231.12
%version3:
%    0.93    1.01    1.14    1.32    1.56    1.85    2.19    2.61    3.25    4.14
%    5.00    5.00    5.00    5.00    5.00    5.00    5.00    5.00    5.00    5.00
%    5.00    5.01    5.01    5.02    5.04    5.07    5.12    5.20    5.31    5.49
%    5.72    6.04    6.45    6.97    7.62    8.42    9.36   10.46   11.72   13.13
%   14.70   16.40   18.24   20.18   22.21   24.29   26.43   28.57   30.71   32.79
%   34.82   36.76   38.60   40.30   41.87   43.28   44.54   45.64   46.58   47.38
%   48.03   48.55   48.96   49.29   49.53   49.72   49.90   50.11   50.41   50.92
%   51.69   52.87   54.54   56.79   59.67   63.16   67.26   71.83   76.83   82.11
%   87.61   93.22   98.91  104.64  110.38  116.12  121.87  127.63  133.38  139.12
%  144.87  150.63  156.38  162.12  167.87  173.63  179.38  185.12  190.87  196.63
%  202.38  208.12  213.87  219.63  225.38  231.12
%version5:
%    0.60    0.71    0.90    1.16    1.50    1.91    2.39    2.95    3.58    4.29
%    5.00    5.00    5.00    5.00    5.00    5.00    5.00    5.00    5.00    5.00
%    5.00    5.01    5.01    5.02    5.04    5.07    5.12    5.20    5.31    5.49
%    5.72    6.04    6.45    6.97    7.62    8.42    9.36   10.46   11.72   13.13
%   14.70   16.40   18.24   20.18   22.21   24.29   26.43   28.57   30.71   32.79
%   34.82   36.76   38.60   40.30   41.87   43.28   44.54   45.64   46.58   47.38
%   48.03   48.55   48.97   49.28   49.53   49.72   49.90   50.11   50.41   50.92
%   51.69   52.87   54.54   56.79   59.67   63.16   67.26   71.83   76.83   82.11
%   87.61   93.22   98.91  104.64  110.38  116.12  121.87  127.63  133.38  139.12
%  144.88  150.62  156.38  162.12  167.88  173.62  179.38  185.12  190.88  196.62
%  202.38  208.12  213.88  219.62  225.38  231.12

if(version==2);ii=1:51;else;ii=2:52;end;
figure(2);clf;
subplot(411);plot(il,temp1,'ks-',1:N,temp3,'r.-',1:N,temp3p,'b^-');grid;
  ylabel('abs(rF) [m]');xlabel('klev');axis([0.5 108 -5 7200]);legend('50lev','106lev-spline','106lev-monotonic',2);
subplot(412);plot(1.5:(N-0.5),diff(temp3),'r.-',1.5:(N-0.5),diff(temp3p),'b^-',ii(1)+.5:ii(end)-.5,diff(rf1(ii)),'k.-');grid;
  ylabel('diff(rF)');xlabel('klev');axis([0.5 108 -15 257]);
subplot(413);plot(2:(N-1),diff(diff(temp3)),'r.-',2:(N-1),diff(diff(temp3p)),'b^-',ii(2:end-1),diff(diff(rf1(ii))),'k.-');grid;
  ylabel('diff(diff(rF))');xlabel('klev');axis([0.5 108 -1 6.5]);
subplot(414);plot(temp3(2:(N-1)),diff(diff(temp3)),'r.-',temp3(2:(N-1)),diff(diff(temp3p)),'b^-',...
                  rf1(ii(2:end-1)),diff(diff(rf1(ii))),'k.-');grid;
  ylabel('diff(diff(rF))');xlabel('rF');%axis([0.5 108 -1 6.5]);

fpr=[dirOut 'RF_DRF_' myint2str(N,3) '_v' num2str(version) '_' datestmp '.png'];print(fpr,'-dpng');fprintf('%s\n',fpr);


if(version==5|version==3);
  delR106qq=delR106p;
  strround='round1em2';
elseif(version==2);

  fOut=[dirOut 'RF_' myint2str(N,3) '_' datestmp '.data'];writebin(fOut,-temp3p,1,'real*8');fprintf('%s\n',fOut);
  fOut=[dirOut 'DRF_' myint2str(N-1,3) '_' datestmp '.data'];writebin(fOut,delR106p,1,'real*8');fprintf('%s\n',fOut);

  fac=1e6;
  strround='round1em6';
%still issues with rounding off of 10^-15 when running MITgcm, so now will round off delR106p

  delR106q=round(delR106p*fac)/fac;temp3q=[0 cumsum(delR106q)];

  tempq=[sum(delR106q(1:7)) sum(delR106q(8:10))];
  for i=3:50;
    tempq=[tempq sum(delR106q([(i-1)*2+1:i*2]+6))];
  end;

  i50=find((tempq-delR)~=0);
  i107=(i50-1)*2+1+6
  tempqq=(tempq-delR);
  delR106qq=delR106q;
  delR106qq(i107)=delR106q(i107)-tempqq(i50)/2;

  tempr=[sum(delR106qq(1:7)) sum(delR106qq(8:10))];
  for i=3:50;
    tempr=[tempr sum(delR106qq([(i-1)*2+1:i*2]+6))];
  end;

  R106qq=[0 cumsum(delR106qq)];

  figure(2);clf;
  subplot(311);plot(il,temp1,'ks-',1:N,temp3p,'r.-',1:N,R106qq,'b^-');grid;
    ylabel('abs(rF) [m]');xlabel('klev');axis([0.5 108 -5 7200]);legend('50lev','106lev-monotonic','106lev-mono-round',2);
  subplot(312);plot(1.5:(N-0.5),diff(temp3p),'r.-',1.5:(N-0.5),diff(R106qq),'b^-',1.5:50.5,diff(rf1),'k.-');grid;
    ylabel('diff(rF)');xlabel('klev');axis([0.5 108 -15 257]);
  subplot(313);plot(2:(N-1),diff(diff(temp3p)),'r.-',2:(N-1),diff(diff(R106qq)),'b^-',2:50,diff(diff(rf1)),'k.-');grid;
    ylabel('diff(diff(rF))');xlabel('klev');axis([0.5 108 -1 6.5]);
  
  fpr=[dirOut 'RF_DRF_' myint2str(N,3) '_' strround '_' datestmp '.png'];print(fpr,'-dpng');fprintf('%s\n',fpr);
  
  fOut=[dirOut 'RF_' myint2str(N,3) '_' strround '_' datestmp '.data'];writebin(fOut,-R106qq,1,'real*8');fprintf('%s\n',fOut);
  fOut=[dirOut 'DRF_' myint2str(N-1,3) '_' strround '_' datestmp '.data'];writebin(fOut,delR106qq,1,'real*8');fprintf('%s\n',fOut);
end;

ftext=[dirOut 'DRF_' myint2str(N-1,3) '_' strround '_v' num2str(version) '_' datestmp '.txt'];
fid=fopen(ftext,'w');fprintf('%s\n',ftext);

for k=1:22;
  ii=[(k-1)*5+1:k*5];
  if(ii(end)>(N-1));
    jj=find(ii<=(N-1));
    ii=ii(jj);
  end;
  fprintf(fid,'%12.6f,',delR106qq(ii));fprintf(fid,'\n');
end;
fclose(fid);

