
%Various tests of level set method
clear; close all;
Model.recon = 'ppm'; Model.solver = 'hll';

config = 'counterjet';

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
Model.Tfin = 4;
Model.Bds = [-5 5 -3 3];
Model.Nvec = round( [1024 512]/8 );
Init.problem = 'flow';

%Couple of basic types
obsCirc.type = 'circle'; obsCirc.center = [0 0]; obsCirc.radius = 0.3;
obsCirc.mobile = true; obsCirc.dx = 2; obsCirc.tau = 2; obsCirc.func = [1 0];

obsCirc1 = obsCirc;
obsCirc1.dx = 1; obsCirc1.tau = -2; obsCirc1.radius = 0.15;


switch lower(config)
    case{'counterjet'}
        Init.Min = 5;
        Init.cent = 0; Init.rad = 0.5; Init.disc = false;
        
        
        %Boundary conditions
        Model.bcs.ibx = 'injet'; Model.bcs.obx = 'outflow';
        Model.bcs.iby = 'outflow'; Model.bcs.oby = 'outflow';
        Cs = sqrt( (5/3)*Init.P0/Init.rho0 ); Init.vin = Init.Min*Cs;
        
        lvlDef.numObs = 2;
        lvlDef.obsDat{1} = obsCirc;
        lvlDef.obsDat{2} = obsCirc1;
    case{'bobjet'}
        Init.Min = 10;
        %Boundary conditions
        Model.bcs.ibx = 'injet'; Model.bcs.obx = 'outflow';
        Model.bcs.iby = 'outflow'; Model.bcs.oby = 'outflow';
        Cs = sqrt( (5/3)*Init.P0/Init.rho0 ); Init.vin = Init.Min*Cs;
        lvlDef.numObs = 1;
        obsCirc.center = [0 0]; obsCirc.radius = 0.25;
        obsCirc.dx = [0 1]; obsCirc.tau = 2; obsCirc.func = [0 0];
        lvlDef.obsDat{1} = obsCirc;
    otherwise
        disp('Unknown problem');
end

%Let's roll
Init.lvlDef = lvlDef;
Model.Init = Init; Model.Pic = Pic;
[Grid Gas] = runsim(Model);
