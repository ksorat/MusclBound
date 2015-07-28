
%Various tests of the level set method

clear; close all;
Model.recon = 'ppm';
Model.solver = 'hll';

config = 'leveljet';

%Generic data
Pic.view = true;
Pic.val = 'd';
Pic.pg = true;


switch lower(config)
    case{'leveljet'}
        Model.Tfin = 50.0;
        Model.Bds = [-5 5 -5 5];
        Model.Nvec = [1024 1024]/4;
        
        
        Init.rho0 = 1.0;
        Init.P0 = 1;
        Init.DelP = 100; %Pressure ratio
        Init.Min = 10; %Inward Mach #
        
        %Jet structure
        Init.cent = 0.0;
        Init.rad = 0.5;
        Init.disc = true;
        Init.problem = 'flow';
        
        %Boundary conditions
        Model.bcs.ibx = 'injet'; Model.bcs.obx = 'outflow';
        Model.bcs.iby = 'outflow'; Model.bcs.oby = 'outflow';
        Cs = sqrt( (5/3)*Init.P0/Init.rho0 ); Init.vin = Init.Min*Cs;
        
        lvlDef.numObs = 1; lvlDef.obsType{1} = 'circle';
        lvlDef.obsParam = [2 1 1 -1];
        
        Init.lvlDef = lvlDef;
    otherwise
        disp('Unknown problem');
end
        
%Let's roll!

Model.Init = Init;
Model.Pic = Pic;
[Grid Gas] = runsim(Model);

