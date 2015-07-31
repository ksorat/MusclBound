
%Various tests of the level set method

clear; close all;
Model.recon = 'ppm';
Model.solver = 'hll';

config = 'levelmjet';

%Generic data
Pic.view = true;
Pic.val = 'd';
Pic.pg = false;

%Generic initialization values
Init.rho0 = 1.0;
Init.P0 = 1;
Model.Tfin = 50.0;
Model.Bds = [-5 5 -2.5 2.5];
Model.Nvec = round([1024 512]/6);

switch lower(config)
    case{'leveljet'}
               
        Init.DelP = 1; %Pressure ratio
        Init.Min = 10; %Inward Mach #
        
        %Jet structure
        Init.cent = 0.0;
        Init.rad = 0.5;
        Init.disc = false;
        Init.problem = 'flow';
        
        %Boundary conditions
        Model.bcs.ibx = 'injet'; Model.bcs.obx = 'outflow';
        Model.bcs.iby = 'outflow'; Model.bcs.oby = 'outflow';
        Cs = sqrt( (5/3)*Init.P0/Init.rho0 ); Init.vin = Init.Min*Cs;
        
        lvlDef.numObs = 1; lvlDef.obsType{1} = 'circle';
        lvlDef.obsParam = [0 -1 1 -1];

    case{'levelmjet'}
               
        Init.DelP = 1; %Pressure ratio
        Init.Min = 10; %Inward Mach #
        
        %Jet structure
        Init.cent = 0.0;
        Init.rad = 0.5;
        Init.disc = false;
        Init.problem = 'flow';
        
        %Boundary conditions
        Model.bcs.ibx = 'injet'; Model.bcs.obx = 'outflow';
        Model.bcs.iby = 'outflow'; Model.bcs.oby = 'outflow';
        Cs = sqrt( (5/3)*Init.P0/Init.rho0 ); Init.vin = Init.Min*Cs;
        
        lvlDef.numObs = 1; lvlDef.obsType{1} = 'circle';
        lvlDef.obsParam = [0 0 0.25 -1];
        lvlDef.ds = [0.0 0.5];
        lvlDef.tau = 1;
        lvlDef.mobile = true;        
    case{'levelcyl'}
        Init.problem = 'flow';
        Init.DelP = 10;
        Pic.val = 'd';
        %Pic.cax = [0.0 1];
        Model.bcs.ibx = 'pinflow'; Model.bcs.obx = 'outflow';
        Model.bcs.iby = 'periodic'; Model.bcs.oby = 'periodic';
        
        lvlDef.numObs = 1; lvlDef.obsType{1} = 'circle';
        lvlDef.obsParam = [0 0 0.5 -1];
    case{'levelmcyl'}
        %Mobile cylinder
        Init.problem = 'flow';
        
        Pic.val = 'd';
        %Pic.cax = [0.0 1];
        Model.bcs.ibx = 'inflow'; Model.bcs.obx = 'outflow';
        Model.bcs.iby = 'periodic'; Model.bcs.oby = 'periodic';
        Model.bcs.inspeed = 5;
        
        lvlDef.numObs = 1; lvlDef.obsType{1} = 'circle';
        lvlDef.obsParam = [0 0 0.5 -1];    
        lvlDef.ds = [0.0 1.5];
        lvlDef.tau = 5;
        lvlDef.mobile = true;
    otherwise
        disp('Unknown problem');
end
        
%Let's roll!
Init.lvlDef = lvlDef;
Model.Init = Init;
Model.Pic = Pic;
[Grid Gas] = runsim(Model);

