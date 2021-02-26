% Adapted from: ECE 430 Final Project
% Created May 10, 2020
% Edited for Senior Design Project
% Edited Fall 2020 - Spring 2021

clear all;clc;
%% Generate Target Scene
tscene = zeros(256,256); % creates a 256 x 256 grid
tscene_size = size(tscene); % 1st val is x, 2nd val is y
% Loops add a road/runway to target scene
% for xx = 1:tscene_size(1) % for all x values of tscene
%     for yy = 170:250 % 80 pixels wide
%         tscene(xx,yy) = 0.03; % 3% reflective, 1 is highest value
%     end
% end
% The following functions populate the target scene with objects
% tscene = addMig(10,210,tscene); % adds a MiG at 10,210
tscene = addMig(50,193,tscene);
% tscene = addMig(90,210,tscene);
tscene = addMig(130,193,tscene);
% tscene = addMig(170,210,tscene);
tscene = addTank(200,50,tscene); % adds a tank at 200,50
% tscene = addTank(190,70,tscene);
tscene = addTank(130,30,tscene);
tscene = tscene'; % transpose the target scene for readability
figure; colormap(hot);pcolor(tscene); shading flat; % generate image of target scene
title('Target Scene');

%% Rest of the code
fc = 1e9; % initialize to 0
prompt_fc = 'Choose a carrier frequency:'; % prompt for user input
dlgtitle_fc = 'Carrier Frequency'; % title of dialogue box
fc = str2double(inputdlg(prompt_fc,dlgtitle_fc)); % collect starting frequency

c = 3e8; % approx. speed of light
% tsig = chirp_v1; % call the function chirp_v1 to generate a chirp signal

BC = [1 1 1 -1 -1 1 -1]; % barker code 7
% BC = [ 1 1 1 1 1 -1 -1 1 1 -1 1 -1 1]; % barker code 13
tsig = bpsk_mod(BC,fc); % Generate Barker Code as transmitted signal

Ns = length(tsig);N=4*Ns;
tline=linspace(0,4e-6,N); % timeline
captures = 20; % number of "pictures" taken by radar
uk = linspace(10,length(tscene),captures); % locations of reception, captures are taken linearly along the x-axis
count = 1; % used for counting the number of pixels that have a reflectivity
noise_level = 1; % adjust the level of noise in the signal (0 = no noise)
for i = 1:tscene_size(1) % use these loops to set up vectors of point targets 
    for ii = 1:tscene_size(2)
        if tscene(i,ii) > 0 % if pixel is reflective
            uT(count) = ii; % x-value of coordinate of point target
            yT(count) = i; % x-value of coordinate of point target
            ref(count) = tscene(i,ii); % value of each point determines reflectivity
            count = count+1;
        end
    end
end

td = zeros(length(uk),length(uT)); % time delay
tidx = zeros(length(uk),length(uT)); % index will be used later
rxsig = randn(length(uk),length(tline)).*noise_level; % received signal, initialize with noise

SNR = sum(tsig.^2)/(sum(rxsig(1,1:length(tsig)).^2)); % right now, rxsig is only noise
SNR_dB = 10*log10(SNR); % convert SNR into decibels

figure(); % create figure for results of match filtering
MF_plot = zeros(length(uk),N); % initialize to zero
for i = 1:length(uk)
    for k = 1:length(uT)
        td(i,k)=2*sqrt((uT(k)-uk(i))^2+yT(k)^2)/c; % find time delay from Pythagorean theorem
        % The following line and if statement removes aliasing if two time
        % delays are identical. It prevents errors in the code
        alias=find(abs(tline-td(i,k))==min(abs(tline-td(i,k))));
        if length(alias) > 1
            tidx(i,k) = alias(1);
        else
            tidx(i,k) = alias;
        end
        rxsig(i,:)=rxsig(i,:) + [zeros(1,tidx(i,k)-1) ref(k).*tsig zeros(1,N-tidx(i,k)-(Ns-1))]; % construct received signal
    end
    MF=xcorr(rxsig(i,:),tsig); % cross-correlate received signal with transmitted signal
    MF_plot(i,:)=abs(MF(N:2*N-1)); % store vlaues for plotting
    subplot(length(uk),1,i);plot(tline,MF_plot(i,:));%grid;
    xlabel('Time, s');ylabel('|MF|');
end
        
td_uk = zeros(size(tscene)); % for storing the time delays
intensity = zeros(size(tscene)); % this will ultimately be the reconstructed image
A = linspace(1,captures,captures); % A will add up the matched filtered values

% Image Reconstruction
for x = 1:tscene_size(1)
    for y = 1:tscene_size(2)
        for z = 1:length(A)
            td_uk(x,y,z) = 2*sqrt((x-uk(z))^2+y^2)/3e8; % calculate round-trip travel time for signal
            count = 1;
            while tline(count) < td_uk(x,y,z) % used to find time delay of signal
                count = count+1; % index while less than time delay
            end
            A(z) = (MF_plot(z,count)+MF_plot(z,count-1))/2; 
        end
        intensity(y,x) = sum(A); % intensity of pixel is sum of amplitudes
%         if intensity(y,x) < 5000 % simple thresholding to remove ghosting
%             intensity(y,x) = 0;
%         end
    end
end
% Plot Reconstructed Image
figure();
pcolor(intensity);shading flat;grid off;
title("Reconstructed Image via Backprojection, SNR = " + SNR_dB);
xlabel("Cross-Range (m)");
ylabel("Range (m)");
