function Grid = InitLvl(Model,Grid)
%Take data from Model.Init.lvlDef to generate obstructions via the level
%set method

%This has been changed from the previous method.  Now is based on polygons

%lvlDef contains
%numObs = number of obstructions
%obsDat{i} = data for each obstruction
%obsDat{i}.type = circle/poly
%circle type
%       .radius
%       .center = xc/yc
%poly type
%       .xv = x vertices
%       .yv = y vertices

%For all types
%obsDat{i}.mobile = true/false, is this object moving
%obsDat{i}.veldat = data about velocity of this object

%Data to be returned into Grid.lvlSet
%sd = signed distance at each point
%ghost = boolean, true at each point that is an interior ghost
%obj = boolean, true at each point that is an interior solid
%fluid = boolean, true at each point that is a fluid cell (unnecessary)
%ghost1d = 1d indices of ghost cells
%ghost_sd = 1d signed distances of ghost cells
%gi/gj = 1d i/j coordinates of ghost cells
%nx/ny = normal vector toward boundary for each interior ghost
%vx/vy = velocity vector for each interior ghost
%        THIS IS A LIE, we are assuming rigid motion for now
%ds = grid spacing to use, max{dx,dy}
%dip = probe length

global SMALL_NUM;
%Nwin = 4; %Smoothing window, number of cells
lvlDef = Model.Init.lvlDef;
Nx = Grid.Nx; Ny = Grid.Ny;
numObs =lvlDef.numObs;

lvlSet.ds = max(Grid.dx,Grid.dy);
lvlSet.ds_min = min(Grid.dx,Grid.dy);


sd = inf(Nx,Ny);
Vx = zeros(Nx,Ny);
Vy = zeros(Nx,Ny);
Nvecx = zeros(Nx,Ny);
Nvecy = zeros(Nx,Ny);

%Create embiggen'ed arrays
[yy xx] = meshgrid(Grid.yc,Grid.xc);
[jj ii] = meshgrid(1:Ny,1:Nx);

for n=1:numObs
    obsDat = lvlDef.obsDat{n};
    %In this loop update sd, nx/ny, and vx/vy
    %Trap for mobility
    if  (obsDat.mobile)
        [delx dely vx vy] = moveObj(obsDat,Grid.t);
        if (Grid.t < eps)
            vx = 0; vy = 0;
        end
    else
        delx = 0; dely = 0;
        vx = 0; vy = 0;
    end
    
    switch lower(obsDat.type)
        
        case{'circle'}
            %Convert circle to polygon
            x0 = obsDat.center(1) + delx;
            y0 = obsDat.center(2) + dely;
            rad = obsDat.radius;
            aLvl = lvlCircle(Grid,x0,y0,rad);            
        case{'poly'}
            disp('Polygons don''t work yet'); pause;
            xv = obsDat.xv;
            yv = obsDat.yv;
            
        otherwise
            disp('Unsupported object type');
    end
    
    %aLvl has been created
    Ind = (aLvl.sd < sd); %Where is the object the closest thing
    sd(Ind) = aLvl.sd(Ind);
    Nvecx(Ind) = aLvl.nx(Ind);
    Nvecy(Ind) = aLvl.ny(Ind);
    
    Vx(Ind) = vx; Vy(Ind) = vy;

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

lvlSet.dip = 1.75*lvlSet.ds;
lvlSet.sd = sd;
Grid.lvlSet = lvlSet;

%Visualize if you wanna
%kcolor(xx,yy,sd); hold on; quiver(xx(ghost1d),yy(ghost1d),lvlSet.gNx,lvlSet.gNy,'w'); hold off;
%pause


function aLvl = lvlCircle(Grid,x0,y0,rad)

Nx = Grid.Nx; Ny = Grid.Ny;
xc = Grid.xc; yc = Grid.yc;
[yy xx] = meshgrid(yc, xc);
[jj ii] = meshgrid(1:Ny,1:Nx);

rr = sqrt( (xx - x0).^2  + (yy - y0).^2 ) ;
In =  rr <= rad;

sd = (rr-rad);
Px = (xx-x0); Py = (yy-y0);
nvec = sqrt(Px.^2 + Py.^2);

aLvl.sd = sd;
aLvl.nx = Px./nvec;
aLvl.ny = Py./nvec;


%Calculates relevant values to move object
%Displacement from center, velocity of boundary

%if obsDat.mobile = true, then
%obsDat.dx (1/2 elements)
%obsDat.tau (1/2 elements)
%obsDat.func (1/2 elements, 0 = sin, 1 = sin)

%x = x0 + dx*func(2*pi*t/tau_x)
%y = ...
%delx = x-x0
function [delx dely vx vy] = moveObj(obsDat,t)

dx = obsDat.dx(1);
if (length(obsDat.dx) > 1)
    dy = obsDat.dx(2);
else
    dy = dx;
end

taux = obsDat.tau(1);
if (length(obsDat.tau) > 1)
    tauy = obsDat.tau(2);
else
    tauy = taux;
end

func = obsDat.func;
fx = obsDat.func(1);
if (length(func) > 1)
    fy = func(2);
else
    fy = fx;
end

[delx vx] = moveDir(dx,taux,fx,t);
[dely vy] = moveDir(dy,tauy,fy,t);


function [del v] = moveDir(ds,taus,fs,t)

if (fs == 0)
    del = ds*sin(2*pi*t/taus);
    v = (2*pi/taus)*ds*cos(2*pi*t/taus);
elseif (fs == 1)
    del = ds*cos(2*pi*t/taus);
    v = -1*(2*pi/taus)*ds*sin(2*pi*t/taus);
else
    disp('Unknown functional form');
    pause;
end
    


    