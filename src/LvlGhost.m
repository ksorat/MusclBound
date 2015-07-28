%Sets internal ghost zones for the level set method

function Gas = LvlGhost(Model,Grid,Gas)

if (~Model.lvlset.present)
    %How did you even get here?
    disp('You shouldn''t be in LvlGhost');
end

lvlSet = Grid.lvlSet;

