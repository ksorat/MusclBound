

%Fragmentation test

%Various tests of level set method w/ polygons
clear; close all;
Model.recon = 'ppm'; Model.solver = 'hll';

%Generic output
Pic.view = true;
Pic.val = 'd';
Pic.pg = false;
Pic.dovid = false;
Pic.cax = [0 4];

%generic initialization
Init.rho0 = 1.0;
Init.P0 = 1;
Init.DelP = 1;
Model.Tfin = 10;
Model.Bds = [-1 5 -2.5 2.5];
Model.Nvec = round( [1024 512]/4 );
Init.problem = 'flow';
Nc = 11;
InP.R = [0.5 1]; InP.Theta = [-30 30]; 
[xv yv] = makeCrescent(InP,Nc);

InP1 = InP; InP2 = InP;
InP1.Theta = [-30 0]; InP2.Theta = [0 30];

obsCr.type = 'poly'; obsCr.xv = xv; obsCr.yv = yv;
obsCr1 = obsCr; obsCr2 = obsCr;
[obsCr1.xv obsCr1.yv] = makeCrescent(InP1,Nc);
[obsCr2.xv obsCr2.yv] = makeCrescent(InP2,Nc);
obsCr1.mobile = true; obsCr1.v0 = [0 -0.5];
obsCr2.mobile = true; obsCr2.v0 = [0 0.5];


Init.Min = 10;
Init.cent = -0.25; Init.rad = 0.5; Init.disc = false;

Model.bcs.ibx = 'injet'; Model.bcs.obx = 'outflow';
Model.bcs.iby = 'outflow'; Model.bcs.oby = 'outflow';
Cs = sqrt( (5/3)*Init.P0/Init.rho0 ); Init.vin = Init.Min*Cs;

lvlDef.numObs = 2;
lvlDef.obsDat{1} = obsCr1;
lvlDef.obsDat{2} = obsCr2;

Init.lvlDef = lvlDef;
Model.Init = Init; Model.Pic = Pic;
[Grid Gas] = runsim(Model);