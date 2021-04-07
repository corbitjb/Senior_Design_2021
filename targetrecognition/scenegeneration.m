tscene = zeros(256,256); % creates a 256 x 256 grid
tscene_size = size(tscene); % 1st val is x, 2nd val is y
% Loops add a road/runway to target scene
for xx = 1:tscene_size(1) % for all x values of tscene
    for yy = 170:250 % 80 pixels wide
        tscene(xx,yy) = 0.03; % 3% reflective, 1 is highest value
    end
end
% The following functions populate the target scene with objects
% tscene = addMig(10,210,tscene); % adds a MiG at 10,210
tscene = addMig(200,40,tscene);
tscene = addMig(230,50,tscene);
% tscene = addMig(130,193,tscene);
% tscene = addMig(170,210,tscene);
tscene = addTank(20,20,tscene); % adds a tank at 200,50
tscene = addTank(50,70,tscene);
tscene = addTank(20,120,tscene);
tscene = addTank(50,170,tscene);
tscene = addTank(20,220,tscene);
% tscene = addTank(50,130,tscene);
% tscene = addTank(50,130,tscene);

tscene = tscene'; % transpose the target scene for readability
figure
imshow(tscene)