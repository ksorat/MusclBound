
%Various tests of level set method w/ static polygons
clear; close all;

config = 'nacajet';
%config = 'wedgejet';
%Generic initialization
Model.Tfin = 10;
Model.Bds = [-5 5 -3 3];
Model.Nvec = round( [1024 512]/8 ) + 1;
Init.problem = 'flow';

%Create NACA foil
inP.x0 = 0; inP.y0 = 0; inP.T = 0.15; inP.c = 2; inP.alpha = 0; obsPoly.type = 'poly';
[xv yv] = makeNACA(inP,1000); obsPoly.xv = xv'; obsPoly.yv = yv';

%Create wedge
obsWedge.type = 'poly'; xv = [0 1 1]; yv = [0 0.2 -0.2]; [obsWedge.xv obsWedge.yv] = makePoly(xv,yv,0.01);
obsWedge.xv = xv'; obsWedge.yv = yv';

Model.bcs.obx = 'outflow'; Model.bcs.iby = 'outflow'; Model.bcs.oby = 'outflow'; 
switch lower(config)
    case{'nacajet'}
        Init.Min = 5;
        Init.jet_cent = 0; Init.rad = 1; Init.disc = false;
        
        Model.Bds = [-1 4 -2 2];
        %Boundary conditions
        Model.bcs.ibx = 'injet'; 
        
        lvlDef.numObs = 1;
        lvlDef.obsDat{1} = obsPoly;
    case{'nacaflow'}
        Init.DelP = 50;
        Model.Bds = [-1 4 -2 2];
        %Boundary conditions
        Model.bcs.ibx = 'pinflow'; 
                
        lvlDef.numObs = 1;
        lvlDef.obsDat{1} = obsPoly;      
    case{'wedgejet'}
        Init.Min = 10;
        Init.jet_cent = 0; Init.rad = 1; Init.disc = false;
        
        Model.Bds = [-1 4 -2 2];
        %Boundary conditions
        Model.bcs.ibx = 'injet'; 
        
        lvlDef.numObs = 1;
        lvlDef.obsDat{1} = obsWedge;        
    otherwise
        disp('Unknown problem');
end

%Let's roll
Init.lvlDef = lvlDef;
Model.Init = Init; 
[Grid Gas] = runsim(Model);