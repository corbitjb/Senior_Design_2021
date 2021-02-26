function new_tscene = addTank(x,y,tscene)
%
% addTank(x,y,tscene) adds a tank to the target scene
% at coordinates (x,y).
% tscene is the array that contains the target scene

s = [32,16];
tank_image = zeros(s);
% these loops generate the body of the tank
% Note: all of the lines that include the statement randn() can be
% commented out for faster run times and lexx complexity
for i = 1:18 % 18 pixels long
    for ii = 1:12 % 12 pixels wide
        if (i < 2 || ii < 2) || (i > 17 || ii > 9)
            tank_image(i,ii) = 0.7; % make edges of tank 70 % reflective
            tank_image(i,ii) = tank_image(i,ii)-0.01*abs(randn(1)); % add imperfections to surface of tank
        else
            tank_image(i,ii) = 0.9; % make body of tank 90% reflective
            tank_image(i,ii) = tank_image(i,ii)-0.01*abs(randn(1)); % add imperfections to surface of tank
        end
    end
end
% these loops generate the barrel of the tank
for i = 18:26 % 8 pixels long
    for ii = 6:7 % 2 pixels wide
        if ii == 5 || i == 18
            tank_image(i,ii) = 0.9;
            tank_image(i,ii) = tank_image(i,ii)-0.01*abs(randn(1));
        else
            tank_image(i,ii) = 0.8;
            tank_image(i,ii) = tank_image(i,ii)-0.01*abs(randn(1));
        end
    end
end
% Add the tank to the target scene
for i = x+1:x+s(1)
    for ii = y+1:y+s(2)
        tscene(i,ii) = tank_image(i-x,ii-y);
    end
end
new_tscene = tscene; % update target scene to pass back to original script