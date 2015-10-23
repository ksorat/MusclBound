
%Various tests of level set method w/ mobile polygons
clear; close all;


%config_fluid = 'flow';
%config_fluid = 'blast';
config_fluid = 'blastflow';

config_solid = 'square';
%config_solid = '2moon';
%config_solid = 'circle';

Model.Tfin = 3;
Model.Bds = [-1 5 -2.5 2.5];
Model.Nvec = round( [1024 512]/8);

Init.Min = 10;
Init.jet_cent = -0.25; Init.rad = 0.5; Init.disc = false;

Model.bcs.ibx = 'injet'; Model.bcs.obx = 'outflow';
Model.bcs.iby = 'outflow'; Model.bcs.oby = 'outflow';

switch lower(config_fluid)
    case{'flow'}
        Init.problem = 'flow';
    case{'blast'}
        Init.problem = 'blast';
        Init.DelP = 1000;
        Init.cent = [2 -1]; Init.rad = 0.25;
        Model.bcs.ibx = 'outflow';
    case{'blastflow'}
        Init.problem = 'blast';
        Init.DelP = 1000;
        Init.cent = [2 -1]; Init.rad = 0.25;        
end

switch lower(config_solid)
    case{'2moon'}
        %Make crescents
        Nc = 100;
        InP.R = [0.5 1]; InP.Theta = [-30 30]; [xv yv] = makeCrescent(InP,Nc);
        InP1 = InP; InP2 = InP; InP1.Theta = [-30 -4.5]; InP2.Theta = [4.5 30];
        obsCr.type = 'poly'; obsCr.xv = xv; obsCr.yv = yv;
        obsCr1 = obsCr; obsCr2 = obsCr;
        [obsCr1.xv obsCr1.yv] = makeCrescent(InP1,Nc);
        [obsCr2.xv obsCr2.yv] = makeCrescent(InP2,Nc);
        obsCr1.mobile = true;
        obsCr2.mobile = true;
        lvlDef.obsDat{1} = obsCr1;
        lvlDef.obsDat{2} = obsCr2;
        
    case{'square'}
        %Make square
        obsSq.type = 'poly'; obsSq.xv = [0.5 0.5 1 1 0.5]; obsSq.yv = [-0.5 0.5 0.5 -0.5 -0.5];
        obsSq.mobile = true; obsSq.v0 = [-0.5 0.5];
        lvlDef.obsDat{1} = obsSq;
        
    case{'circle'}
        %Make circle
        InPc.R = 0.5; InPc.C = [0.51 0];
        obsCirc.type = 'poly'; [obsCirc.xv obsCirc.yv] = makeCircle(InPc,Nc);
        obsCirc.mobile = true;
        lvlDef.obsDat{1} = obsCirc;
end


lvlDef.numObs = length(lvlDef.obsDat);

Init.lvlDef = lvlDef;
Model.Init = Init; 
[Grid Gas] = runsim(Model);