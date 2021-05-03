function new_tscene = addMig(x,y,tscene)
% 
% addMig(x,y,tscene)
% 
% This function adds a Mig25 made up of point targets to an array meant 
% to imitate a target scene for a synthetic aperture radar.
% x and y are the starting coordinates where the mig will be added
% and represent the bottom left corner
% tscene is the array in which the Mig will be added

load mig25.mat; % file containing real MiG image data
migdata=X;
mig_image=abs(fftshift(fft2(migdata)));
mig_image=mig_image/max(max(mig_image)); % normalize mig image to maximum of 1
mig_image = mig_image(15:56,150:390); % crop image
newsize = [16 32]; % this size is arbitrary, but fits well into the target scene
newMig = imresize(mig_image,newsize); % resize image to newsize
newMig = newMig./(max(max(newMig))); % normalize to 1 again
% for i = 1:newsize(1)
%     for ii = 1:newsize(2)
% %         if newMig(i,ii) < 0.1
% %             newMig(i,ii) = 0.03; % adds a background to the rectangular image to simulate a runway
% %         else
%             newMig(i,ii) = newMig(i,ii) + ((newMig(i,ii))/4); % makes the mig more reflective
% %         end
%     end
% end

% these loops add the mig into the target scene
for i = x+1:x+newsize(1)
    for ii = y+1:y+newsize(2)
        tscene(i,ii) = newMig(i-x,ii-y);
    end
end
new_tscene = tscene;