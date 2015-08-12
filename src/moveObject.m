
%Moves the objects defined in Model.lvlDef
function Model = moveObject(Model,Grid,Gas)

%Useful grabs
lvlDef = Model.Init.lvlDef;
Nx = Grid.Nx; Ny = Grid.Ny;
numObs =lvlDef.numObs;

lvlSet.ds = max(Grid.dx,Grid.dy);
lvlSet.ds_min = min(Grid.dx,Grid.dy);
dt = Grid.dt;

for n=1:numObs
    
    obsDat = lvlDef.obsDat{n};
    
    obsDat.xv = obsDat.xv + dt*obsDat.vx;
    obsDat.yv = obsDat.yv + dt*obsDat.vy;
    lvlDef.obsDat{n} = obsDat;
end

Model.Init.lvlDef = lvlDef;