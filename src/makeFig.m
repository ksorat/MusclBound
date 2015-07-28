function makeFig(Model,Grid,Gas)

Gam = Model.Init.Gam;
%Set bounds
if (~Model.Pic.pg)
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
set(gcf,'units','normalized','outerposition',[0 0 0.5 0.75]);
%axis equal;
if isfield(Model.Pic,'cax')
    caxis(Model.Pic.cax);
else
    nStd = 1;
    zM = mean(Zp(:));
    zStd = std(Zp(:));
    cAx = [ (zM-nStd*zStd) (zM+nStd*zStd) ];
end

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