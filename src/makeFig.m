function makeFig(Model,Grid,Gas)

global Nfig;



Gam = Model.Init.Gam;
%Set bounds
if (Model.Pic.pg)
    %Print ghosts
    is = Grid.isd;
    ie = Grid.ied;
    js = Grid.jsd;
    je = Grid.jed;
else
    %Don't print ghosts
    is = Grid.is;
    ie = Grid.ie;
    js = Grid.js;
    je = Grid.je;
end

x = Grid.xc(is:ie);
y = Grid.yc(js:je);

Pos = false; %Is this a positive definite quantity?

switch lower(Model.Pic.val)
    case{'d'}
        Z = Gas.D;
        varS = 'Density';
        Pos = true;
    case{'p'}
        Z = Gas.P;
        varS = 'Pressure';
        Pos = true;
    case{'logp'}
        Z = log10(Gas.P);
        varS = 'Log Pressure';
    case{'vx'}
        Z = Gas.Vx;
        varS = 'X-Velocity';
    case{'vy'}
        Z = Gas.Vy;
        varS = 'Y-Velocity';
    case{'spd'}
        Z = sqrt( Gas.Vx.^2 + Gas.Vy.^2);
        varS = 'Speed';
        Pos = true;
    case{'k'}
        Z = 0.5*Gas.D.*( Gas.Vx.^2 + Gas.Vy.^2);
        varS = 'Kinetic Energy';
        Pos = true;
    case{'ma','mach'}
        Spd = sqrt( Gas.Vx.^2 + Gas.Vy.^2);
        Cs = Prim2Cs(Gas.D,Gas.Vx,Gas.Vy,Gas.P,Model);
        Z = Spd./Cs;
        varS = 'Mach Number';
        Pos = true;
    otherwise
        disp('Unknown diagnostic');
        pause;
end
if (Model.solid.present)
    Z(Grid.solid.In) = nan;
end

Zp = Z(is:ie,js:je);
kcolor(x,y,Zp'); %axis equal;
%set(gcf,'units','normalized','outerposition',[0 0 0.5 0.75]);
Xdom = Grid.xi(end)-Grid.xi(1);
Ydom = Grid.yi(end)-Grid.yi(1);
aspRat = Xdom/Ydom;
FixIn = 18;
set(gcf,'units','inches','outerposition', [ 0 0 FixIn FixIn/aspRat]); 

%axis equal;
if isfield(Model.Pic,'cax')
    %caxis(Model.Pic.cax);
    cAx = Model.Pic.cax;
else
    nStd = 3;
    zM = mean(Zp(:));
    zStd = std(Zp(:));
    cAx = [ (zM-nStd*zStd) (zM+nStd*zStd) ];
end
if (Pos)
    cAx(1) = 0.0;
end

if (Model.lvlSet.present)
    sd = Grid.lvlSet.sd(is:ie,js:je);
    hold on;
    
    if (Model.Pic.pg)
        %Only do outline
        contour(x,y,sd',[0 0],'w'); %Does outline
    else        
    %Fill region
        if (Model.lvlSet.allpoly)
            for n=1:Model.Init.lvlDef.numObs
                obsDat = Model.Init.lvlDef.obsDat{n};
                fill(obsDat.xv,obsDat.yv,'w');
            end
        else
            FillPolys(x,y,sd);
        end
    end
    
    hold off;
end

caxis(cAx);
xlabel('X'); ylabel('Y');
titS = sprintf('%s @ t=%3.3f', varS, Grid.t);
title(titS);

drawnow;
if (Model.Pic.dovid)
    Figfile = sprintf('%s/Vid.%04d.png', Model.Pic.vid_dir,Nfig);
    export_fig(Figfile);
end
Nfig = Nfig+1;

function FillPolys(x,y,sd)

C = contourc(x,y,sd',[0 0]);

N = length(C);
ic = 1;
while (ic < N)
    icp = ic+1;
    num = C(2,ic); %How many elements are in this
    xobs = C(1,icp:icp+num-1);
    yobs = C(2,icp:icp+num-1);
    ic = icp+num;
    fill(xobs,yobs,'w');
end