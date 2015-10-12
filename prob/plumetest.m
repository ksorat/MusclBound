%Propulsion test

clear; close all;
config = 'jet';
%config = 'blast';
Init.Vmag_Propel = 5;

Init.problem = 'flow';
        Model.bcs.ibx = 'outflow'; Model.bcs.obx = 'outflow';
        Model.bcs.iby = 'outflow'; Model.bcs.oby = 'outflow';

        Model.Pic.val = 'd';
        Model.Pic.cax = [0 2.5];
      
%Generic initialization
Model.Tfin = 20;
Model.Bds = [-20 20 -20 20];
Model.Nvec = round( [1024 1024]/0.5 );

Nc = 100; 

[xv yv propel] = makeShip([],Nc);
obsSh.xv = xv; obsSh.yv = yv; 
obsSh.type = 'poly'; obsSh.M = 2.5; 
obsSh.mobile = true; obsSh.v0 = [0 0]; obsSh.propel = true;
obsSh.isOutlet = propel; 

InP1.alpha = -55;
InP1.delx = -12.5; InP1.dely = -12.5;

InP2.alpha = 30;
InP2.delx = 7.5; InP2.dely = -7.5;

obsSh1 = RotateTranslate(obsSh,InP1);
obsSh2 = RotateTranslate(obsSh,InP2);


lvlDef.obsDat{1} = obsSh1;
lvlDef.obsDat{2} = obsSh2;
lvlDef.numObs = 2;

Init.lvlDef = lvlDef;
Model.Init = Init; 
[Grid Gas] = runsim(Model);
