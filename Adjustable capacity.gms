Sets
p Provinceset /Shanghai,Zhejiang,Jiangsu,Anhui,Fujian,Jiangxi,Guangdong ,Hunan,Hubei,Henan,Shandong,Guangxi,Guizhou,Chongqing,Shan3xi,Shan1xi,Hebei,Tianjin,Beijing,Liaoning,Jilin,Heilongjiang,Yunnan,Sichuan,Gansu,Ningxia,Neimenggu,Xinjiang,Xizang,Qinghai,Idazhou,Iqinhuangdao,Izhangjiakou,Ibaitoushan,Iliuyuan,Igeermu,Ichifeng,Pqiandaohu,Pdanjiang,Pemei,Ptongren,Pchangbai,Pheyuan,Phonghegu,Pmanasi,Iankang/
i Time /2020*2060/
* 2020 represents 0%decarbonization  2060 represents 80% decarbonization
j Careff /1*101/
;
alias(p,pp);

Scalar
x
y;

Parameters
DisMatrix(p,pp)
Price(p)
Supply(p)
Demand(p)
Disboundary(p,pp)
Fco2(p)
RPCO2(i)
LTPlist(j)
MapCO2(i,j)
Ctot(i,j)
Maxrange
/200/
Pcarbon
/250/
Caplim
RedCO2
/1/
Loadtopower
/0.2/
;
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
$call gdxxrw.exe <route and file name>.xlsx squeeze=n par=RPCO2 dim=1 rng=time!A1:AO2
$gdxin senana.gdx
$load RPCO2
$gdxin
$call gdxxrw.exe <route and file name>.xlsx squeeze=n par=LTPlist dim=1 rng=Capacity!A1:CW2
$gdxin senana.gdx
$load LTPlist
$gdxin

display RPCO2,LTPlist;
MapCO2(i,j)=1;
Ctot(i,j)=1;


Positive Variables
test(p,pp)
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
;


Variables
totalcost
VPC(p);

Equations
SDbalance
PDbalance
limitup
limitlo
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
*Caltotcha
*Etest
;

SDbalance(p).. sum(pp,matrixIN(p,pp))+Supply(p)+VPC(p)=e=sum(pp,matrixOUT(p,pp))+Demand(p);
PDbalance.. sum(p,Supply(p)+VPC(p))=e=sum(p,Supply(p));
limitup(p).. VPC(p)=l=Supply(p)*Caplim;
limitlo(p).. VPC(p)=g=-Supply(p)*Caplim;
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
Calco2..CO2=e=sum( p,(totchargep(p)+totchargepp(p))*Fco2(p) )/1000*RedCO2;
*ton
*Caltotcha(p)..Ctot(p)=e=totchargep(p)+totchargepp(p);
*Etest(p,pp)..test(p,pp)=e= matrixOUT(p,pp)*Loadtopower*Disboundary(p,pp);

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
VPC.l(p)=0;
*VPC.up(p)=1.1;
*VPC.lo(p)=0.9;
CO2.l=1e9;
CO2.lo=1e7;
totalcost.l=1e11
Model electTrans /all/;
*option mip=BARON;
*Option ResLim = 864000;
*Option IterLim = 100000000;
for (x = 1 to 41,
        for (y=1 to 101,
                 RedCO2=sum(i$(ord(i)=x),RPCO2(i));
                 Caplim=sum(j$(ord(j)=y),LTPlist(j));

                 Solve electTrans using mip minimizing totalcost;
                 Solve electTrans using mip minimizing totalcost;
                 MAPCO2(i,j)$(ord(i)=x and ord(j)=y)=CO2.l;
                 Ctot(i,j)$(ord(i)=x and ord(j)=y)=totalcost.l;

);
);
display MAPCO2,Ctot,RPCO2,LTPlist
*execute_unload "resultsSA.gdx" Ctot MAPCO2

*execute 'gdxxrw.exe resultsSA.gdx o=<route and file name>.xlsx par=Ctot squeeze=n rng=cost!'
*execute 'gdxxrw.exe resultsSA.gdx o=<route and file name>.xlsx par=MAPCO2 squeeze=n rng=CO2!'
