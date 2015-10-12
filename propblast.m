
%Propulsion test

clear; close all;
Model.recon = 'plm'; Model.solver = 'hll';

%Generic output
Pic.view = true;
Pic.val = 'd';
Pic.pg = false;
Pic.dovid = true;
Pic.cax = [0 3];

%Generic initialization
Init.rho0 = 1.0;
Init.P0 = 1;
Init.DelP = 500;
Init.cent = [10 10];
Init.rad = 2;
Model.Tfin = 50;
%Model.Bds = [-5 5 -8 8];
Model.Bds = [-10 20 -10 30];
Model.Nvec = round( [1024 1024]/2);

%Model.bcs.ibx = 'outflow'; Model.bcs.obx = 'outflow';
%Model.bcs.iby = 'outflow'; Model.bcs.oby = 'outflow';

Init.problem = 'blast';
Nc = 100; InP = true;
[xv yv propel] = makeShip(InP,Nc);
obsSh.xv = xv; obsSh.yv = yv; 
obsSh.type = 'poly'; obsSh.M = 2.5; 
obsSh.mobile = true; obsSh.v0 = [0 0]; obsSh.propel = true;
obsSh.doProp = propel; 

lvlDef.numObs = 1; lvlDef.obsDat{1} = obsSh;

Init.lvlDef = lvlDef;
Model.Init = Init; Model.Pic = Pic;
[Grid Gas] = runsim(Model);
