
%Propulsion test

clear; close all;
config = 'jet';
%config = 'blast';
Init.Vmag_Propel = 10;

switch lower(config)
    case{'blast'}
        Init.problem = 'blast';
        Init.DelP = 500;
        Init.cent = [10 10];
        Init.rad = 2;
        Model.bcs.ibx = 'outflow'; Model.bcs.obx = 'outflow';
        Model.bcs.iby = 'outflow'; Model.bcs.oby = 'outflow';
        
    case{'jet'}
        Init.problem = 'flow';
        Init.Min = 10.0;
        Init.jet_cent = 12.5; Init.rad = 2; Init.disc = false;
        Model.bcs.ibx = 'injet'; Model.bcs.obx = 'outflow';
        Model.bcs.iby = 'outflow'; Model.bcs.oby = 'outflow';
                
end
Model.Pic.val = 'd';
Model.Pic.cax = [0 2.5];
Model.Pic.dovid = false;
%Generic initialization
Model.Tfin = 20;
Model.Bds = [-10 20 -10 30];
Model.Nvec = round( [1024 1024]/1 );

Nc = 100; 
InP = [];
[xv yv propel] = makeShip(InP,Nc);
obsSh.xv = xv; obsSh.yv = yv; 
obsSh.type = 'poly'; obsSh.M = 2.5; 
obsSh.mobile = true; obsSh.v0 = [0 0]; obsSh.propel = true;
obsSh.isOutlet = propel; 
lvlDef.numObs = 1; lvlDef.obsDat{1} = obsSh;

Init.lvlDef = lvlDef;
Model.Init = Init; 
[Grid Gas] = runsim(Model);

