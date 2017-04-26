zGrid.zF  = -abs(zgrid.zf);
zGrid.zC  = 1/2*(zGrid.zF(2:end) + zGrid.zF(1:end-1))';
zGrid.dzF = zgrid.delz';
zGrid.dzC = zGrid.zC(2:end)-zGrid.zC(1:end-1);

zGrid.dzDzF = zgrid.dzdelz;

zGrid.name = zgrid.name;
