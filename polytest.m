
%Various tests of level set method w/ polygons
clear; close all;
Model.recon = 'ppm'; Model.solver = 'hll';

config = 'nacajet';

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
Model.Bds = [-5 5 -3 3];
Model.Nvec = round( [1024 512]/8 ) + 1;
Init.problem = 'flow';

inP.x0 = 0; inP.y0 = 0; inP.T = 0.15; inP.c = 2;
inP.alpha = 0;
obsPoly.type = 'poly';
[xv yv] = naca(inP,1000); obsPoly.xv = xv'; obsPoly.yv = yv';

obsWedge.type = 'poly'; xv = [0 1 1]; yv = [0 0.2 -0.2]; %[obsWedge.xv obsWedge.yv] = makePoly(xv,yv,0.01);
obsWedge.xv = xv'; obsWedge.yv = yv';
switch lower(config)
    case{'nacajet'}
        Init.Min = 10;
        Init.cent = 0; Init.rad = 1; Init.disc = false;
        
        Model.Bds = [-1 4 -2 2];
        %Boundary conditions
        Model.bcs.ibx = 'injet'; Model.bcs.obx = 'outflow';
        Model.bcs.iby = 'outflow'; Model.bcs.oby = 'outflow';
        Cs = sqrt( (5/3)*Init.P0/Init.rho0 ); Init.vin = Init.Min*Cs;
        
        lvlDef.numObs = 1;
        lvlDef.obsDat{1} = obsPoly;
    case{'nacaflow'}
        Init.DelP = 50;
        Model.Bds = [-1 4 -2 2];
        %Boundary conditions
        Model.bcs.ibx = 'pinflow'; Model.bcs.obx = 'outflow';
        Model.bcs.iby = 'outflow'; Model.bcs.oby = 'outflow';
       
        
        lvlDef.numObs = 1;
        lvlDef.obsDat{1} = obsPoly;      
    case{'wedgejet'}
        Init.Min = 10;
        Init.cent = 0; Init.rad = 1; Init.disc = false;
        
        Model.Bds = [-1 4 -2 2];
        %Boundary conditions
        Model.bcs.ibx = 'injet'; Model.bcs.obx = 'outflow';
        Model.bcs.iby = 'outflow'; Model.bcs.oby = 'outflow';
        Cs = sqrt( (5/3)*Init.P0/Init.rho0 ); Init.vin = Init.Min*Cs;
        
        lvlDef.numObs = 1;
        lvlDef.obsDat{1} = obsWedge;        
    otherwise
        disp('Unknown problem');
end

%Let's roll
Init.lvlDef = lvlDef;
Model.Init = Init; Model.Pic = Pic;
[Grid Gas] = runsim(Model);