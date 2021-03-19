% Adapted from: ECE 430 Final Project
% Created May 10, 2020
% Edited for Senior Design Project
% Edited Fall 2020 - Spring 2021

%%%%%%%%%% THIS VERSION USES A MATLAB GUI APP %%%%%%%%%%%%%

% Custom functions called in this script:
% chirp_v4
% bpsk_mod
% costas_code
% getMult
% addMig
% addTank
% SignalStudio.mlapp

clear all;clc;

%% Call app and wait
app = SignalStudio;
waitfor(app.execution,'Value') % wait for simulate button to be pressed

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
% tscene = addMig(50,193,tscene);
% tscene = addMig(90,210,tscene);
tscene = addMig(130,193,tscene);
% tscene = addMig(170,210,tscene);
tscene = addTank(200,50,tscene); % adds a tank at 200,50
% tscene = addTank(190,70,tscene);
tscene = addTank(130,30,tscene);
tscene = tscene'; % transpose the target scene for readability
figure; colormap(gray);pcolor(tscene); shading flat; % generate image of target scene
title('Target Scene');

%% Setup carrier frequency
fc_base = app.CarrierFrequencyEditField.Value;
fc_mult = getMult(app.CarrierUnits.Value);
fc = fc_base*fc_mult;

%% Other parameters that remain constant
captures = round(app.CrossRangeStopsSlider.Value); % number of "pictures" taken by radar
noise_level = 1; % adjust the level of noise in the signal (0 = no noise)
c = 3e8; % approx. speed of light (m/s)
plotFlag = app.PlotSignalsCheckBox.Value;
acfFlag = app.PlotACFCheckBox.Value;

%% Code to simulate signal 1
% Generate signal 1
if(strcmp(app.Signal1.Value,'Chirp (LFM)'))
    f0_sig1 = app.StartFrequencyField1.Value;
    f0_mult1 = getMult(app.StartFreqUnits1.Value); % multiplier from drop-down list
    f0_sig1 = f0_sig1*f0_mult1;
    f1_sig1 = app.StopFrequencyField1.Value;
    f1_mult1 = getMult(app.StopFreqUnits1.Value); % multiplier from drop-down list
    f1_sig1 = f1_sig1*f1_mult1;
    [tsig,t,long_t] = chirp_v4(f0_sig1,f1_sig1,plotFlag,acfFlag);
elseif(strcmp(app.Signal1.Value,'Barker Code'))
    barker_length1 = str2double(app.BarkerLength1.Value);
    bcf1 = app.BarkerFreq1.Value; % barker code frequency
    bcf_mult1 = getMult(app.BarkerUnits1.Value);
    bcf1 = bcf1*bcf_mult1;    
    [tsig,t,long_t] = bpsk_mod(barker_length1,bcf1,plotFlag,acfFlag);
elseif(strcmp(app.Signal1.Value,'Costas Code'))
    c_length1 = str2double(app.CostasLength1.Value);
    f0_sig1 = app.StartFrequencyField1.Value;
    f0_mult1 = getMult(app.StartFreqUnits1.Value); % multiplier from drop-down list
    f0_sig1 = f0_sig1*f0_mult1;
    f1_sig1 = app.StopFrequencyField1.Value;
    f1_mult1 = getMult(app.StopFreqUnits1.Value); % multiplier from drop-down list
    f1_sig1 = f1_sig1*f1_mult1;
    [tsig,t,long_t] = costas_code(c_length1,f0_sig1,f1_sig1,plotFlag,acfFlag);
end

% Modulate and execute
Ns = length(tsig);N=4*Ns;
carrier_sig = cos(2*pi*fc.*t);
long_carrier_sig = cos(2*pi*fc.*long_t);
tsig_mod = tsig.*carrier_sig;
tline=linspace(0,4e-6,N); % timeline

uk = linspace(10,length(tscene),captures); % locations of reception, captures are taken linearly along the x-axis
count = 1; % used for counting the number of pixels that have a reflectivity
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
rxsig_demod = zeros(length(uk),length(tline)); % demodulated recieved signal

SNR = sum(tsig.^2)/(sum(rxsig(1,1:length(tsig)).^2)); % right now, rxsig is only noise
SNR_dB = 10*log10(SNR); % convert SNR into decibels
if(app.PlotMatchedFilteringCheckBox.Value == 1)
    figure(); % create figure for results of match filtering
end
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
        rxsig(i,:)=rxsig(i,:) + [zeros(1,tidx(i,k)-1) ref(k).*tsig zeros(1,N-tidx(i,k)-(Ns-1))]; %construct received signal
        rxsig_demod(i,:) = rxsig(i,:)./long_carrier_sig;
    end
    MF=xcorr(rxsig(i,:),tsig); % cross-correlate received signal with transmitted signal
    MF_plot(i,:)=abs(MF(N:2*N-1)); % store vlaues for plotting
    if(app.PlotMatchedFilteringCheckBox.Value == 1)
        subplot(length(uk),1,i);plot(tline,MF_plot(i,:));%grid;
        xlabel('Time, s');ylabel('|MF|');
    end
end
        
td_uk = zeros(tscene_size); % for storing the time delays
intensity1 = zeros(tscene_size); % this will ultimately be the reconstructed image
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
        intensity1(y,x) = sum(A); % intensity of pixel is sum of amplitudes
    end
end
if(app.FilterOutputCheckBox.Value == 1)
    intensity1 = joel_filters(intensity1,0.5);
end
% Plot Reconstructed Image 1
reconstructed_image = figure();
title("Reconstructed Image via Backprojection");
subplot(1,2,1);
pcolor(intensity1);shading flat;grid off;
xlabel("Cross-Range");
ylabel("Range");

%% Code to simulate signal 2
% Generate signal 2
if(strcmp(app.Signal2.Value,'Chirp (LFM)'))
    f0_sig2 = app.StartFrequencyField2.Value;
    f0_mult2 = getMult(app.StartFreqUnits2.Value); % multiplier from drop-down list
    f0_sig2 = f0_sig2*f0_mult2;
    f1_sig2 = app.StopFrequencyField2.Value;
    f1_mult2 = getMult(app.StopFreqUnits2.Value); % multiplier from drop-down list
    f1_sig2 = f1_sig2*f1_mult2;
    [tsig,t,long_t] = chirp_v4(f0_sig2,f1_sig2,plotFlag,acfFlag);
elseif(strcmp(app.Signal2.Value,'Barker Code'))
    barker_length2 = str2double(app.BarkerLength2.Value);
    bcf2 = app.BarkerFreq2.Value; % barker code frequency
    bcf_mult2 = getMult(app.BarkerUnits2.Value);
    bcf2 = bcf2*bcf_mult2;
    [tsig,t,long_t] = bpsk_mod(barker_length2,bcf2,plotFlag,acfFlag);
elseif(strcmp(app.Signal2.Value,'Costas Code'))
    c_length2 = str2double(app.CostasLength2.Value);
    f0_sig2 = app.StartFrequencyField2.Value;
    f0_mult2 = getMult(app.StartFreqUnits2.Value); % multiplier from drop-down list
    f0_sig2 = f0_sig2*f0_mult2;
    f1_sig2 = app.StopFrequencyField2.Value;
    f1_mult2 = getMult(app.StopFreqUnits2.Value); % multiplier from drop-down list
    f1_sig2 = f1_sig2*f1_mult2;
    [tsig,t,long_t] = costas_code(c_length2,f0_sig2,f1_sig2,plotFlag,acfFlag);
end

% Modulate and execute
Ns = length(tsig);N=4*Ns;
carrier_sig = cos(2*pi*fc.*t);
long_carrier_sig = cos(2*pi*fc.*long_t);
tsig_mod = tsig.*carrier_sig;
tline=linspace(0,4e-6,N); % timeline

uk = linspace(10,length(tscene),captures); % locations of reception, captures are taken linearly along the x-axis
count = 1; % used for counting the number of pixels that have a reflectivity
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
rxsig_demod = zeros(length(uk),length(tline)); % demodulated recieved signal

SNR = sum(tsig.^2)/(sum(rxsig(1,1:length(tsig)).^2)); % right now, rxsig is only noise
SNR_dB = 10*log10(SNR); % convert SNR into decibels
if(app.PlotMatchedFilteringCheckBox.Value == 1)
    figure(); % create figure for results of match filtering
end
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
        rxsig_demod(i,:) = rxsig(i,:)./long_carrier_sig;
    end
    MF=xcorr(rxsig(i,:),tsig); % cross-correlate received signal with transmitted signal
    MF_plot(i,:)=abs(MF(N:2*N-1)); % store vlaues for plotting
    if(app.PlotMatchedFilteringCheckBox.Value == 1)
        subplot(length(uk),1,i);plot(tline,MF_plot(i,:));%grid;
        xlabel('Time, s');ylabel('|MF|');
    end
end
        
td_uk = zeros(tscene_size); % for storing the time delays
intensity2 = zeros(tscene_size); % this will ultimately be the reconstructed image
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
        intensity2(y,x) = sum(A); % intensity of pixel is sum of amplitudes
    end
end
if(app.FilterOutputCheckBox.Value == 1)
    intensity2 = joel_filters(intensity2,0.5);
end
% Plot Reconstructed Image 1
figure(reconstructed_image);
subplot(1,2,2);
pcolor(intensity2);shading flat;grid off;
xlabel("Cross-Range");
ylabel("Range");