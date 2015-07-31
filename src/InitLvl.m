
function Grid = InitLvl(Model,Grid)

%Take data from Model.Init.lvlDef to generate an obstruction via the level
%set method

%Note, for now this is implemented only for a single circle
%lvlDef contains
%numObs = number of obstruction
%lvlDef.obsType(1:numObs) = type of each obstruction
%lvlDef.obsParam(1:numObs,1:4) = details for each, requires 4 numbers
%block-type, the 4 numbers are [xmin xmax ymin ymax] 
%wedge-type, the 4 numbers are [x0 y0 theta r] 
%circle-type, the 4 numbers are [xc yc rad xx?] 

%This method needs to return several things all located in Grid.lvlset
%lvlset contains
%sd = signed distance at each point
%ghost = boolean, true at each point that is a level set ghost cell
%obj = boolean, true at each point that is entirely contained in obs
%fluid = boolean, true when neither of the previous 2 are (unnecessary)
%Fx_sol/Fy_sol = 1 on "good" interfaces, 0 on "bad"
%Bad interfaces = object<->object, object<->ghost

lvlDef = Model.Init.lvlDef;

%Trap things that aren't yet implemented

if (lvlDef.numObs>1)
    disp('Multiple objects in the level set method isn''t implemented');
    pause;
end



lvlDef = Model.Init.lvlDef;
numObs = lvlDef.numObs;
obsType = lvlDef.obsType;
obsParam = lvlDef.obsParam;

for i=1:numObs
    switch lower(obsType{i})
        
        case{'circle'}
            %Do circle type
            parami = obsParam(i,:);
            lvlSeti = lvlCircle(Grid,parami);
        otherwise
            disp('Non-circle objects not yet implemented in level set method');
            
    end
    %Merge lvlseti into lvlset
    %Don't bother for now, since numObs==1
    lvlSet = lvlSeti;
end

%Send it back
Grid.lvlSet = lvlSet;

function lvlSet = lvlCircle(Grid,param)

Nx = Grid.Nx; Ny = Grid.Ny;
xc = Grid.xc; yc = Grid.yc;
[yy xx] = meshgrid(yc, xc);
[jj ii] = meshgrid(1:Ny,1:Nx);


x0 = param(1);
y0 = param(2);
rad = param(3);

rr = sqrt( (xx - x0).^2  + (yy - y0).^2 ) ;
In =  rr <= rad;

sd = zeros(Nx,Ny);
sd = rr-rad;

ds = max(Grid.dx,Grid.dy);
fluid = (sd > 0);
obj = (sd < -2*sqrt(2)*ds );
ghost = (~fluid) & (~obj);

%Create 1d arrays w/ extra info about the ghost cells
ghost1d = find(ghost);
gi = ii(ghost1d);
gj = jj(ghost1d);
ng = length(ghost1d);
ghost_sd = sd(ghost1d);

%Create normal vector of ghost cells
nx = zeros(1,ng); ny = nx;
for n=1:ng
    x = xc(gi(n));
    y = yc(gj(n));
    
    vx = x-x0; vy = y-y0;
    nvec = sqrt(vx^2 + vy^2);
    nx(n) = vx/nvec; ny(n) = vy/nvec;
end

lvlSet.sd = sd;
lvlSet.fluid = fluid; lvlSet.obj = obj; lvlSet.ghost = ghost;
lvlSet.ghost1d = ghost1d; lvlSet.gi = gi; lvlSet.gj = gj;
lvlSet.ng = ng; lvlSet.ghost_sd = ghost_sd;
lvlSet.ds = ds;
lvlSet.dip = 1.75*ds; %1.75 as in the paper, avoids recursive interpolation
lvlSet.nx = nx; lvlSet.ny = ny;


%look upon my creation
%plot(xc(gi),yc(gj),'ro'); hold on; quiver(xc(gi),yc(gj),nx,ny); hold off;



    