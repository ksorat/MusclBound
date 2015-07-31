function makeFig(Model,Grid,Gas)

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

switch lower(Model.Pic.val)
    case{'d'}
        Z = Gas.D;
        varS = 'Density';
    case{'p'}
        Z = Gas.P;
        varS = 'Pressure';
    case{'vx'}
        Z = Gas.Vx;
        varS = 'X-Velocity';
    case{'vy'}
        Z = Gas.Vy;
        varS = 'Y-Velocity';
    case{'spd'}
        Z = sqrt( Gas.Vx.^2 + Gas.Vy.^2);
        varS = 'Speed';
    case{'k'}
        Z = 0.5*Gas.D.*( Gas.Vx.^2 + Gas.Vy.^2);
        varS = 'Kinetic Energy';
    case{'ma','mach'}
        Spd = sqrt( Gas.Vx.^2 + Gas.Vy.^2);
        Cs = Prim2Cs(Gas.D,Gas.Vx,Gas.Vy,Gas.P,Model);
        Z = Spd./Cs;
        varS = 'Mach Number';
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

if (Model.lvlset.present)
    sd = Grid.lvlSet.sd(is:ie,js:je);
    hold on;
    
    if (Model.Pic.pg)
        %Only do outline
        contour(x,y,sd',[0 0],'w'); %Does outline
    else        
    %Fill region
        C = contourc(x,y,sd',[0 0]);
        xobs = C(1,2:end);
        yobs = C(2,2:end);
        fill(xobs,yobs,'w');
    end
    
    hold off;
end

caxis(cAx);
xlabel('X'); ylabel('Y');
titS = sprintf('%s @ t=%3.2f', varS, Grid.t);
title(titS);

% 
% if (Model.ib.present)
%     hold on;
%     for n=1:Grid.ib.numObs
%         obs = Grid.ib.obs{n};
%         fill(obs.x,obs.y,'w');
%         
%     end
%    hold off;
% end

drawnow;

