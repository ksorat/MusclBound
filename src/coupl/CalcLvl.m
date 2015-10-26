function Grid = CalcLvl(Model,Grid)

%Take data from Model.Obj to generate obstructions via the level
%set method

%See setupModel for format of Model.Obj/Model.Obj.obsDef

%Data to be returned into Grid.lvlSet
%sd = signed distance at each point
%ghost = boolean, true at each point that is an interior ghost
%obj = boolean, true at each point that is an interior solid
%fluid = boolean, true at each point that is a fluid cell (unnecessary)
%Next, we create a list of the ghost cells
%ghost1d = 1d indices of ghost cells
%ghost_sd = 1d signed distances of ghost cells
%gi/gj = 1d i/j coordinates of ghost cells
%nx/ny = normal vector toward boundary for each interior ghost
%vx/vy = velocity vector for each interior ghost
%        THIS IS A LIE, we are assuming rigid motion for now
%ds = grid spacing to use, max{dx,dy}
%dip = probe length

global DEBUG;

Obj = Model.Obj;

Nx = Grid.Nx; Ny = Grid.Ny;
numObj = Obj.numObj;

lvlSet.ds = max(Grid.dx,Grid.dy);
lvlSet.ds_min = min(Grid.dx,Grid.dy);


sd = inf(Nx,Ny);
Vx = zeros(Nx,Ny);
Vy = zeros(Nx,Ny);
Nvecx = zeros(Nx,Ny);
Nvecy = zeros(Nx,Ny);

Propel = false(Nx,Ny);

%Create embiggen'ed arrays
[yy xx] = meshgrid(Grid.yc,Grid.xc);
[jj ii] = meshgrid(1:Ny,1:Nx);

for n=1:numObj
    objDef = Obj.objDef{n};
    
    %In this loop update sd, nx/ny, and vx/vy
    %Trap for mobility
       
    switch lower(objDef.type)
        
        case{'circle'}
            disp('Deprecated circle option');
            pause;
        case{'poly'}

            aLvl = lvlPoly(objDef,Grid);
        otherwise
            disp('Unsupported object type');
            pause;
    end
    
    %aLvl has been created
    Ind = (aLvl.sd < sd); %Where is the object the closest thing
    sd(Ind) = aLvl.sd(Ind);
    Nvecx(Ind) = aLvl.nx(Ind);
    Nvecy(Ind) = aLvl.ny(Ind);
    
    Vx(Ind) = aLvl.vx(Ind);
    Vy(Ind) = aLvl.vy(Ind);
    if (objDef.propel)
        PropN = findPropel(Grid,objDef,sd);
        Propel = Propel | PropN;
    end
        
end

%Calculate things derived from sd/V/N
fluid = (sd > 0);
obj = ( sd < -2*sqrt(2)*lvlSet.ds );
ghost = (~fluid) & (~obj);

%Create 1d arrays w/ extra info about the interior ghosts
ghost1d = find(ghost); lvlSet.ghost1d = ghost1d;
lvlSet.gi = ii(ghost1d);
lvlSet.gj = jj(ghost1d);
lvlSet.ng = length(ghost1d);
lvlSet.ghost_sd = sd(ghost1d);
lvlSet.gVx = Vx(ghost1d); lvlSet.gVy = Vy(ghost1d);
lvlSet.gNx = Nvecx(ghost1d); lvlSet.gNy = Nvecy(ghost1d);
lvlSet.propel = Propel(ghost1d);

lvlSet.dip = 1.75*lvlSet.ds;
lvlSet.sd = sd;
lvlSet.fluid = fluid;
lvlSet.ghost = ghost;
lvlSet.obj = obj;

lvlSet = calcGeom(Grid,lvlSet);

Grid.lvlSet = lvlSet;

if (DEBUG & ( (Grid.t+Grid.dt) <eps) & (numObj == 1) ) %Only do once
    
    plot(objDef.xv,objDef.yv,'r-o'); hold on;
    quiver(xx(ghost1d),yy(ghost1d),lvlSet.gNx,lvlSet.gNy,'k');
    plot(xx(ghost1d),yy(ghost1d),'bx');
    axis equal
    hold off;
    drawnow; %pause
end

    
function PropN = findPropel(Grid,obsDat,sd)

Nx = Grid.Nx; Ny = Grid.Ny;
xc = Grid.xc; yc = Grid.yc;
[yy xx] = meshgrid(yc, xc);
[jj ii] = meshgrid(1:Ny,1:Nx);
ds = max(Grid.dx,Grid.dy);

In = (sd <= 0);

Outlets = find(obsDat.isOutlet);
NumOut = length(Outlets);
Close = false(Nx,Ny);

rp = 2*sqrt(2)*ds;

for n=1:NumOut
    outN = Outlets(n);
    xc = obsDat.xv(outN);
    yc = obsDat.yv(outN);
    
    rr = sqrt( (xx-xc).^2 + (yy-yc).^2 );
    Close = Close | (rr <= rp);
end
PropN = Close & In;


function aLvl = lvlPoly(obsDat,Grid)

Nx = Grid.Nx; Ny = Grid.Ny;
xc = Grid.xc; yc = Grid.yc;
[yy xx] = meshgrid(yc, xc);
[jj ii] = meshgrid(1:Ny,1:Nx);
ds = max(Grid.dx,Grid.dy);


xv = obsDat.xv;
yv = obsDat.yv;
%Close polygon if necessary
if ((xv(1) ~= xv(end)) || (yv(1) ~= yv(end))) %Maybe change to eps comparison?
    xv = [xv ; xv(1)];
    yv = [yv ; yv(1)];
end
Nv = length(xv);
%Construct quick bounding circle
xcm = sum(xv(1:Nv-1))/(Nv-1);
ycm = sum(yv(1:Nv-1))/(Nv-1);
Rcm = sqrt( (xv-xcm).^2 + (yv-ycm).^2 );
Rcm = max(Rcm(:)); %Find maximum distance from center to a vertex

Rcm = Rcm + (Grid.ng+1)*ds; %Add some breathing room

%Create necessary arrays
sd = zeros(Nx,Ny);
nx = sd; ny = sd;
xb = sd; yb = sd;
Vx = sd; Vy = sd;

rr = sqrt( (xx-xcm).^2 + (yy-ycm).^2 ); %Distance from poly-center
InBd = rr<=Rcm;

%Only calculate information for stuff in "In"
%For each point in In, calculate
%Signed distance, closest point on polygon (may be yourself), normal toward
%closest point

Inbd1d = find(InBd);
x1d = xx(Inbd1d); y1d = yy(Inbd1d);

[sd1d xb1d yb1d Nx1d Ny1d] = sd_poly(x1d,y1d,xv,yv,Grid);

sdM = 2*max(sd1d);
sd(InBd) = sd1d;

sd(~InBd) = sdM;

nx(InBd) = Nx1d;
ny(InBd) = Ny1d;

%For each point, (xb,yb) is the closest point on the boundary
aLvl.xb = xb1d;
aLvl.yb = yb1d;

%Grab velocities of each vertex
Vxv = obsDat.vx;
Vyv = obsDat.vy;

%Find Vx/Vy of each boundary point using velocities of vertices
Vxi = BoundaryInterp(xb1d,yb1d,xv,yv,Vxv); 
Vyi = BoundaryInterp(xb1d,yb1d,xv,yv,Vyv);

Vx(InBd) = Vxi;
Vy(InBd) = Vyi;

%Store values and get outta here
aLvl.sd = sd;
aLvl.nx = nx;
aLvl.ny = ny;
aLvl.vx = Vx;
aLvl.vy = Vy;

%Calculates interface geometries from lvlSet data
%Returns lvlSet.(Dir)
%Marks fluid cells that are adjacent to ghosts

%West Fluid->Ghost, Flu(i,j) & Gh(i+1,j)
%East Ghost->Fluid, Flu(i,j) & Gh(i-1,j)
%North Ghost->Fluid Flu(i,j) & Gh(i,j-1)

%Also calculate "fake" interfaces
%A fake interface is anything connected to an object cell
%These interfaces will zero out flux
%Fx_obj(i,j) refers to the interface connecting cell (i,j) -> (i-1,j)
function lvlSet = calcGeom(Grid,lvlSet)
Gh = lvlSet.ghost;
Flu = lvlSet.fluid;

gh1d = lvlSet.ghost1d;

Nx = Grid.Nx; Ny = Grid.Ny;
Nxi = Nx+1; Nyi = Ny+1;

Fx_obj = false(Nxi,Ny);
Fy_obj = false(Nx,Nyi);
[jj ii] = meshgrid(1:Ny,1:Nx);

%Could easily make these sparse
West = false(Nx,Ny); East = West; North = West; South = West;

Ngh = length(gh1d);

%Loop through ghost cells
for n=1:Ngh
    i = lvlSet.gi(n);
    j = lvlSet.gj(n);
    %Check neighbors
    if Flu(i+1,j)
        East(i+1,j) = true;
    end
    if Flu(i-1,j)
        West(i-1,j) = true;
    end
    if Flu(i,j+1)
        North(i,j+1) = true;
    end
    if Flu(i,j-1)
        South(i,j-1) = true;
    end
        
end

%Loop through object cells
Obj = lvlSet.obj;
obj1d = find(Obj);
Nob = length(obj1d);
obji = ii(obj1d); objj = jj(obj1d);
for n=1:Nob
    i = obji(n); j = objj(n);
    Fx_obj(i,j) = true;
    Fx_obj(i+1,j) = true;
    Fy_obj(i,j) = true;
    Fy_obj(i,j+1) = true;
end

lvlSet.East  = East;
lvlSet.West  = West;
lvlSet.North = North;
lvlSet.South = South;

lvlSet.Fx_obj = Fx_obj;
lvlSet.Fy_obj = Fy_obj;


