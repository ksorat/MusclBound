
%Propulsion test

clear; close all;
Model.recon = 'ppm'; Model.solver = 'hll';

%Generic output
Pic.view = true;
Pic.val = 'd';
Pic.pg = false;
Pic.dovid = false;
Pic.cax = [0 3];

%Generic initialization
Init.rho0 = 1.0;
Init.P0 = 1;
Init.DelP = 1;
Model.Tfin = 10;
%Model.Bds = [-5 5 -8 8];
Model.Bds = [-10 20 -10 30];
Model.Nvec = round( [1024 1024]/1);

Init.problem = 'flow';
Nc = 100; InP = true;
[xv yv propel] = makeShip(InP,Nc);
obsSh.xv = xv; obsSh.yv = yv; 
obsSh.type = 'poly'; obsSh.M = 2.5; 
obsSh.mobile = true; obsSh.v0 = [0 0]; obsSh.propel = true;
obsSh.doProp = propel; 

Init.Min = 5.0;
Init.cent = 12.5; Init.rad = 2; Init.disc = false;

Model.bcs.ibx = 'injet'; Model.bcs.obx = 'outflow';
Model.bcs.iby = 'outflow'; Model.bcs.oby = 'outflow';
Cs = sqrt( (5/3)*Init.P0/Init.rho0 ); Init.vin = Init.Min*Cs;

lvlDef.numObs = 1; lvlDef.obsDat{1} = obsSh;

Init.lvlDef = lvlDef;
Model.Init = Init; Model.Pic = Pic;
[Grid Gas] = runsim(Model);
