%Sets internal ghost zones for the level set method

function Gas = Lvl2Ghost(Model,Grid,Gas)

if (~Model.Obj.present)
    %How did you even get here?
    disp('How did you even get here?  <Lvl2Ghost>');
end

lvlSet = Grid.lvlSet;

%Loop through interior ghost zones
for n=1:lvlSet.ng
    %i/j indices of this ghost zone
    ig = lvlSet.gi(n);
    jg = lvlSet.gj(n);
    
    %x/y point of this ghost zone (centered)
    xg = Grid.xc(ig);
    yg = Grid.yc(jg);
    
    %Signed distance/normals of this ghost zone from boundary
    sdn = lvlSet.ghost_sd(n);
    nx = lvlSet.gNx(n);
    ny = lvlSet.gNy(n);
    
    %Distance from ghost zone center to image point
    L = abs(sdn) + lvlSet.dip;
    xip = xg + L*nx;
    yip = yg + L*ny;
    
    %Calculate interpolated gas quantities at probe
    [Dip Vxip Vyip Pip] = ProbeAt(xip,yip,Grid,Gas);

    scl = L/(L - abs(sdn) );
    
    %Velocity values of the wall
    VxW = lvlSet.gVx(n);
    VyW = lvlSet.gVy(n);
    
    %Set ghost values
    %----------------
    %Set ghost value of density, assuming neuman bc w/ normal deriv=0 at
    %boundary
    Dgc = Dip;
    
    %Set ghost value of pressure
    %If neuman bc, w/ normal deriv=0
    Pgc = Pip;
    %Otherwise, use wall temperature boundary condition
    %Tw = Temperature of wall
    %Tfw = Temperature of fluid at wall, equal to Tw if Knud=0
    
    %Tgc = Tip - scl*( Tip - Tfw)
    %Pgc = Temp2Pressure(Dgc,Tgc)
    
    
    %Now set velocity values
    %If Knud=0, Vf = Vw (fluid velocity @ wall = wall velocity)
    if (~Model.doKnud)
        Vxfw = VxW;
        Vyfw = VyW;
    else
        %Knudsen number is non-zero
        %Need an extra image point (iip) & Vx/Vy @ iip
        xiip = xip + lvlSet.dip*nx;
        yiip = yip + lvlSet.dip*ny;
        [Diip Vxiip Vyiip Piip] = ProbeAt(xiip,yiip,Grid,Gas);

        %Map Vip/Viip/VW -> new coordinate system (Vn,Vt), normal/tangential to
        %wall
        [VnW VtW] = xy2nt(VxW,VyW,nx,ny);
        [Vnip Vtip] = xy2nt(Vxip,Vyip,nx,ny);
        [Vniip Vtiip] = xy2nt(Vxiip,Vyiip,nx,ny);
        
        %Calculate derivative along normal in tangential velocity
        dUtdn = (Vtiip - Vtip)/lvlSet.dip;
        
        %Calculate velocities of fluid at wall
        %Vnfw = VnW, normal velocities of wall/fluid at wall agree
        Vnfw = VnW;
        Vtfw = VtW + Model.Knud.alpha_u*Model.Knud.lam_mfp*dUtdn;
        
        %Now map back to cartesian coordinates
        [Vxfw Vyfw] = nt2xy(Vnfw,Vtfw,nx,ny);
        
    end
    
    Vxgc = Vxip - scl*( Vxip - Vxfw );
    Vygc = Vyip - scl*( Vyip - Vyfw );
    
    Gas.D(ig,jg) = Dgc;
    Gas.P(ig,jg) = Pgc;
    
    Gas.Vx(ig,jg) = Vxgc;
    Gas.Vy(ig,jg) = Vygc;
    

    if (lvlSet.propel(n))
        
        Gas.D(ig,jg) = Model.Init.rho0;
        Gas.P(ig,jg) = Model.Init.P0;
        Vmag = Model.Init.Vmag_Propel;
        Gas.Vx(ig,jg) = Vmag*nx;
        Gas.Vy(ig,jg) = Vmag*ny;   
    end
    

end

%Take vector in x/y system -> n/t system
%Wolog, assume direction for T

function [Vn Vt] = xy2nt(Vx,Vy,Nx,Ny)
Tx = -Ny;
Ty = Nx; %Guarantees dot(N,T) = 0

Vn = Vx*Nx + Vy*Ny;
Vt = Vx*Tx + Vy*Ty;

function [Vx Vy] = nt2xy(Vn,Vt,Nx,Ny)
%Note, this must be same direction assumption as above or things will be
%bad

%V = Vx x^ + Vy y^ = Vn N^ + Vt T^
%  = Vn (Nx x^ + Ny y^) + Vt ( Tx x^ + Ty y^)
%  = x^ ( Vn*Nx  + Vt*Tx ) + y^ ( Vn*Ny + Vt*Ty)
Tx = -Ny;
Ty = Nx;

Vx = Vn*Nx + Vt*Tx;
Vy = Vn*Ny + Vt*Ty;

%Find interpolated values of primitive variables at probe points xp/yp
function [Dp Vxp Vyp Pp] = ProbeAt(xp,yp,Grid,Gas)
    
%Find 4 closest cells to probe point
Img = conImage(xp,yp,Grid);

%Now that we have info about the 4 closest cells, do the bilinear
%interpolation to get primitive variables at probe
if (Img.g2g) %Ghost 2 ghost, ie this ghost's outward normal hits another ghost
    disp('\tWarning, ghost to ghost contact');
end

Dp = calcInterp(Img,Gas.D,Grid);
Pp = calcInterp(Img,Gas.P,Grid);
Vxp = calcInterp(Img,Gas.Vx,Grid);
Vyp = calcInterp(Img,Gas.Vy,Grid);    
    
%Calculates value of Z @ image point given 4 data points
function Zip = calcInterp(Img,Z,Grid)

%Create helpers
i1 = min(Img.i); i2 = max(Img.i);
j1 = min(Img.j); j2 = max(Img.j);

x1 = Grid.xc(i1); x2 = Grid.xc(i2);
y1 = Grid.yc(j1); y2 = Grid.yc(j2);

z11 = Z(i1,j1);
z12 = Z(i1,j2);
z21 = Z(i2,j1);
z22 = Z(i2,j2);


%Calculate interpolated value at x/y
x = Img.xip; y = Img.yip;
scli = (x2-x1)*(y2-y1);
scl = 1/scli;

Zip = scl* ( z11*(x2-x)*(y2-y) + z21*(x-x1)*(y2-y) + z12*(x2-x)*(y-y1) + z22*(x-x1)*(y-y1) );


%Creates Img data structure, includes
%Img.i = 4 values of i for the 4 closest cells
%Img.j = same, but with j
%Img.x = same, but with x values of cell centers
%Img.y = same, but with y values of cell centers

function Img = conImage(xip,yip,Grid)

%Image point is in cell i/j
i = find(xip>=Grid.xi,1,'last');
j = find(yip>=Grid.yi,1,'last');

x = Grid.xc(i); y = Grid.yc(j);

if (xip >= x)
    %look to i+1
    i1 = i+1;
else
    i1 = i;
    i = i-1;
end

if (yip >= y)
    j1 = j+1;
else
    j1 = j;
    j = j-1;
end

Img.i = [i i i1 i1];
Img.j = [j j1 j j1];

Img.x = Grid.xc(Img.i);
Img.y = Grid.yc(Img.j);

Img.xip = xip; Img.yip = yip;

%Check for ghost 2 ghost contact
g2g = false;
for n=1:4
    if Grid.lvlSet.ghost(Img.i(n),Img.j(n))
        g2g = true;
    end
end

Img.g2g = g2g;
