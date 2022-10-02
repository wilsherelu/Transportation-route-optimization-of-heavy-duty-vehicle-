Sets
p Provinceset /Shanghai,Zhejiang,Jiangsu,Anhui,Fujian,Jiangxi,Guangdong ,Hunan,Hubei,Henan,Shandong,Guangxi,Guizhou,Chongqing,Shan3xi,Shan1xi,Hebei,Tianjin,Beijing,Liaoning,Jilin,Heilongjiang,Yunnan,Sichuan,Gansu,Ningxia,Neimenggu,Xinjiang,Xizang,Qinghai,Idazhou,Iqinhuangdao,Izhangjiakou,Ibaitoushan,Iliuyuan,Igeermu,Ichifeng,Pqiandaohu,Pdanjiang,Pemei,Ptongren,Pchangbai,Pheyuan,Phonghegu,Pmanasi,Iankang/;
*set name may vary from the ones in the paper
alias(p,pp);

Parameters
DisMatrix(p,pp)
*Transport distance between two provinces(locations)   [km]
Disboundary(p,pp)
*Transport distance from provincial capital city of p to the province boudary toward pp   [km]
Price(p)
*Electricity price of each province     [CNY/kWh]
Supply(p)
*Cargo supply in a province     [MT]
Demand(p)
*Cargo demand in a province     [MT]

Fco2(p)
*Emission factor of electricity  [kg CO2/ kWh]
Loadtopower
/0.2/
*Energy efficicy of transportation [kWh/(MT*km)]
Maxrange
/200/
*Maximum milerange    [km]
Pcarbon
/500/
*Carbon pirce    [CNY/kg CO2]
;
*data input based on excel file
$call gdxxrw.exe <route and file name>.xlsx squeeze=n par=DisMatrix dim=2 rng=Distance!A1:AU47
$gdxin Provincematrix.gdx
$load DisMatrix
$gdxin
$call gdxxrw.exe <route and file name>.xlsx squeeze=n par=Price dim=1 rng=Price!A1:AT2
$gdxin Provincematrix.gdx
$load Price
$gdxin
$call gdxxrw.exe <route and file name>.xlsx squeeze=n par=Supply dim=1 rng=Supply!A1:AT2
$gdxin Provincematrix.gdx
$load Supply
$gdxin
$call gdxxrw.exe <route and file name>.xlsx squeeze=n par=Demand dim=1 rng=Demand!A1:AT2
$gdxin Provincematrix.gdx
$load Demand
$gdxin
$call gdxxrw.exe <route and file name>.xlsx squeeze=n par=Disboundary dim=2 rng=Boundary!A1:AU47
$gdxin Provincematrix.gdx
$load Disboundary
$gdxin
$call gdxxrw.exe <route and file name>.xlsx squeeze=n par=Fco2 dim=1 rng=Carbon!A1:AT2
$gdxin Provincematrix.gdx
$load Fco2
$gdxin

Positive Variables

matrixIN(p,pp)
*cargo input from pp to p
matrixOUT(p,pp)
*cargo output from p to pp
routechargep(p,pp)
*Charge of transport from p to pp at p
routechargepp(p,pp)
*Charge of transport from p to pp at pp
routedischarge(p,pp)
*Consumed electricity of transport from p to pp at pp
totchargep(p)
*sum of routechargep for pp
totchargepp(p)
*sum of routechargep for p
storage(p,pp)
*Storage of      unused electricity from p to pp at pp
usestorage(p,pp)
*Use electricity storage   at p for the transport  from p to pp
CO2
*Total CO2 emission [MT]
Ctot(p);
*Total electricity charge in a province: totchargep+totchargepp

Variables
totalcost;
*Minimize the total transport cost
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
Calcost..totalcost=e=sum( p,(totchargep(p)+totchargepp(p))*Price(p)  )+CO2*Pcarbon;
Calco2..CO2=e=sum( p,(totchargep(p)+totchargepp(p))*Fco2(p) )/1000;
*ton
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
*Result output into a targeted excel file
*execute_unload "results.gdx" matrixOUT.L routechargep.l routechargepp.l Ctot.L totalcost.l CO2.l
*execute 'gdxxrw.exe results.gdx o=<route and file name>.xlsx var=matrixOUT.L squeeze=n rng=Out!A1:AU47'
*execute 'gdxxrw.exe results.gdx o=<route and file name>.xlsx var=routechargep.L squeeze=n rng=Cstart!A1:AU47'
*execute 'gdxxrw.exe results.gdx o=<route and file name>.xlsx var=routechargepp.L squeeze=n rng=Cend!A1:AU47'
*execute 'gdxxrw.exe results.gdx o=<route and file name>.xlsx var=Ctot.L squeeze=n rng=Ctot!A1:AU47'
*execute 'gdxxrw.exe results.gdx o=<route and file name>.xlsx var=totalcost.L squeeze=n rng=result!A1'
*execute 'gdxxrw.exe results.gdx o=<route and file name>.xlsx var=CO2.l squeeze=n rng=result!A2'
