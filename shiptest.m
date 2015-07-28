%Runs various models that include a "ship" obstruction

clear; close all;
scl = 0.1; %Scl for ship
x0 = 0.0; y0 = 0.0;

Model.recon = 'ppm';
config = 'shipblast';
config = 'shipflow';

Model.Tfin = 5.0;
Model.Bds = [-0.5 1.5 -1 1];
Model.Nvec = 1+[1024 512]/8;

Init.Gam = 5/3;

%Graphical data
Pic.view = true; %Print pic
Pic.val = 'P'; %Which quantity to print
Pic.pg = 'false'; %Print ghosts

switch lower(config)
    case{'shipflow'}
        sim = 'flow';
        Init.Gam = 5/3;
        Init.rho0 = 1.0;
        Init.P0 = 0.1;
        Init.DelP = 100;
        %MachIn = 5;
        
        %Cs = sqrt(Init.Gam*Init.P0/Init.rho0);
        
        Model.bcs.ibx = 'inflow'; Model.bcs.obx = 'outflow';
        Model.bcs.ibx = 'pinflow'; Model.bcs.obx = 'poutflow';
        Model.bcs.iby = 'reflect'; Model.bcs.oby = 'reflect';
        Pic.val = 'spd';
        Pic.cax = [0 2];
        %Model.bcs.inspeed = MachIn*Cs;
        %Pic.cax = [0 5];
        
    case{'shipblast'}
        sim = 'blast';
        Init.rho0 = 1.0;
        Init.rad = 0.1;
        Init.P0 = 0.1;
        Init.DelP = 100; %Pressure ratio for in versus out
        a = 0.2;
        %Init.cent = [-a 2*a];
        Init.cent = [0.5 0.5];
        %Pic.cax = [Init.P0 Init.P0*Init.DelP/7.5];
        Pic.cax = [0 1.5];
    otherwise('Unknown simulation')
        pause
end

%Define obstruction
obsDef.numObs = 4;
obsDef.obsType = {'block','block','trix','trix'};
obsDef.View = true;
obsDef.obsParam = zeros(obsDef.numObs,4);

obsDef.obsParam(1,:) = [ (x0+3*scl) (x0+10*scl) (-1*scl) (1*scl) ]; 
obsDef.obsParam(2,:) = [ (x0+5*scl) (x0+6*scl) (-2*scl) (2*scl) ];
obsDef.obsParam(3,:) = [x0 y0 (x0+3*scl) (y0+2*scl)];
obsDef.obsParam(4,:) = [(x0+7*scl) y0 (x0+9*scl) (y0+4*scl)];

Init.obsDef = obsDef;

Init.problem = sim;
Model.Init = Init;
Model.Pic = Pic;

[Grid Gas] = runsim(Model);

        





