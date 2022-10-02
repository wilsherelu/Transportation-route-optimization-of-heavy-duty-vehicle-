Sets
p Provinceset /Shanghai,Zhejiang,Jiangsu,Anhui,Fujian,Jiangxi,Guangdong ,Hunan,Hubei,Henan,Shandong,Guangxi,Guizhou,Chongqing,Shan3xi,Shan1xi,Hebei,Tianjin,Beijing,Liaoning,Jilin,Heilongjiang,Yunnan,Sichuan,Gansu,Ningxia,Neimenggu,Xinjiang,Xizang,Qinghai,Idazhou,Iqinhuangdao,Izhangjiakou,Ibaitoushan,Iliuyuan,Igeermu,Ichifeng,Pqiandaohu,Pdanjiang,Pemei,Ptongren,Pchangbai,Pheyuan,Phonghegu,Pmanasi,Iankang/;
alias(p,pp);

Parameters
DisMatrix(p,pp)
Price(p)
Supply(p)
Demand(p)
Disboundary(p,pp)
Fco2(p)
Loadtopower
/0.0472/
Maxrange
/3000/
Pcarbon
/500/;
$call gdxxrw.exe <route and file name>.xlsx squeeze=n par=DisMatrix dim=2 rng=Distance!A1:AU47
$gdxin ProvincematrixD.gdx
$load DisMatrix
$gdxin
$call gdxxrw.exe <route and file name>.xlsx squeeze=n par=Price dim=1 rng=Price!A1:AT2
$gdxin ProvincematrixD.gdx
$load Price
$gdxin
$call gdxxrw.exe <route and file name>.xlsx squeeze=n par=Supply dim=1 rng=Supply!A1:AT2
$gdxin ProvincematrixD.gdx
$load Supply
$gdxin
$call gdxxrw.exe <route and file name>.xlsx squeeze=n par=Demand dim=1 rng=Demand!A1:AT2
$gdxin ProvincematrixD.gdx
$load Demand
$gdxin
$call gdxxrw.exe <route and file name>.xlsx squeeze=n par=Disboundary dim=2 rng=Boundary!A1:AU47
$gdxin ProvincematrixD.gdx
$load Disboundary
$gdxin
$call gdxxrw.exe <route and file name>.xlsx squeeze=n par=Fco2 dim=1 rng=Carbon!A1:AT2
$gdxin ProvincematrixD.gdx
$load Fco2
$gdxin

Positive Variables

matrixIN(p,pp)
matrixOUT(p,pp)
routechargep(p,pp)
routechargepp(p,pp)
routedischarge(p,pp)
totchargep(p)
totchargepp(p)
storage(p,pp)
usestorage(p,pp)
CO2
Ctot(p);


Variables
totalcost;

Equations
SDbalance
Inoutbalance

Powerconsumption
Supplylimit
Charge
ChargeLB1
ChargeLB2
Storagebalance
Storagelimit1
Storagelimit2
Costep
Costepp
Calcost
Calco2
*Etest
Caltotcha
;

SDbalance(p).. sum(pp,matrixIN(p,pp))+Supply(p)=e=sum(pp,matrixOUT(p,pp))+Demand(p);
Inoutbalance(p,pp)..matrixIN(p,pp)=e=matrixOUT(pp,p);
Powerconsumption(p,pp)..routedischarge(p,pp)=e=matrixOUT(p,pp)*Loadtopower*DisMatrix(p,pp);
Supplylimit(p)..matrixIN(p,p)=e=0;
Charge(p,pp)..usestorage(p,pp)+routechargep(p,pp)+routechargepp(p,pp)-storage(p,pp)=e=routedischarge(p,pp);
ChargeLB1(p,pp)..usestorage(p,pp)+routechargep(p,pp)=g=matrixOUT(p,pp)*Loadtopower*Disboundary(p,pp);
ChargeLB2(p,pp)..usestorage(p,pp)+routechargep(p,pp)=l=matrixOUT(p,pp)*Loadtopower*(Disboundary(p,pp)+Maxrange);
Storagebalance(p)..sum(pp,usestorage(p,pp))=e=sum(pp,storage(pp,p));
Storagelimit1(p,pp)..routechargep(p,pp)=l=matrixOUT(p,pp)*1000;
Storagelimit2(p,pp)..routechargepp(p,pp)=l=matrixOUT(p,pp)*1000;
Costep(p)..totchargep(p)=e=sum(pp,routechargep(p,pp));
Costepp(p)..totchargepp(p)=e=sum(pp,routechargepp(pp,p));
Calcost..totalcost=e=sum( p,(totchargep(p)+totchargepp(p))*Price(p)/0.85  )+CO2*Pcarbon;
Calco2..CO2=e=sum( p,(totchargep(p)+totchargepp(p))*Fco2(p) )/1000;
Caltotcha(p)..Ctot(p)=e=totchargep(p)+totchargepp(p);


matrixIN.lo(p,pp)=0;
matrixOUT.lo(p,pp)=0;
usestorage.lo(p,pp)=0;
routechargep.lo(p,pp)=0;
routechargepp.lo(p,pp)=0;
storage.lo(p,pp)=0;
matrixIN.l(p,pp)=1;
matrixOUT.l(p,pp)=1;
usestorage.l(p,pp)=1;
routechargep.l(p,pp)=1;
routechargepp.l(p,pp)=1;
storage.l(p,pp)=1;
Model electTrans /all/;

Solve electTrans using mip minimizing totalcost;
Display matrixOUT.l,routechargep.l,routechargepp.l,usestorage.l,storage.l,totchargep.l,totchargepp.l,CO2.l;
*execute_unload "results.gdx" matrixOUT.L routechargep.l routechargepp.l Ctot.L totalcost.l CO2.l
*execute 'gdxxrw.exe results.gdx o=<route and file name>.xlsx var=matrixOUT.L squeeze=n rng=Out!A1:AU47'
*execute 'gdxxrw.exe results.gdx o=<route and file name>.xlsx var=routechargep.L squeeze=n rng=Cstart!A1:AU47'
*execute 'gdxxrw.exe results.gdx o=<route and file name>.xlsx var=routechargepp.L squeeze=n rng=Cend!A1:AU47'
*execute 'gdxxrw.exe results.gdx o=<route and file name>.xlsx var=Ctot.L squeeze=n rng=Ctot!A1:AU47'
*execute 'gdxxrw.exe results.gdx o=<route and file name>.xlsx var=totalcost.L squeeze=n rng=result!A1'
*execute 'gdxxrw.exe results.gdx o=<route and file name>.xlsx var=CO2.l squeeze=n rng=result!A2'
