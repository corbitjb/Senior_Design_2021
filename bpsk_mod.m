function sig = bpsk_mod(BC,fc)
% This function modulates a Barker Code uaing Binary Phase Shift Keying
% (BPSK)
% The output function will be a vector in the form sin(wt + phase)
% Input fc is the carrier frequency.
% Input BC is the vector containing the desired barker code elements.

% Uncomment these lines to run code without calling as a function
% BC = [ 1 1 1 1 1 -1 -1 1 1 -1 1 -1 1]; % barker code 13
% fc = 1e9; % 1 GHz carrier frequency

sampling = 50; % controls number of samples to take per bit duration
wc = 2*pi*fc; % convert carrier to radians
N = length(BC); % number of periods used, use 1 period for each bit
tfin = N/fc; % total period of signal
Ns = sampling*N+1; % Number of samples to take, must be odd
t = linspace(0,tfin,Ns); % construct timeline
% The following loop constructs the modulated signal
sig = zeros(1,Ns); % initialize output signal to 0
for i = 1:N
    phase = 0;
    if BC(i) == 1 % 180 (pi) degree offset
        phase = pi; % Matlab operates in radians 
    end
    start_idx = sampling*i - sampling + 1; % starting index for each element of barker code
    fin_idx = start_idx + sampling - 1; % final index of section of sinusoid
    sig(start_idx:fin_idx) = sin(wc.*t(start_idx:fin_idx)+phase); % construct signal
end

j = sqrt(-1); % not necessary, but prevents warning messages
fs=abs(1/(t(2)-t(1))); % <-- Sampling frequency, fs
fn=linspace(-fs*(Ns-1)/(2*Ns),fs*(Ns-1)/(2*Ns),Ns);
signalsp=(1/fs*fft(sig)); % <-- Regular FFT

% Plot Results side-by-side
figure();
subplot(1,2,1);
plot(t,sig)
xlabel('Time (s)');
title('Barker Code Modulated with Binary Phase Shift Keying');
subplot(1,2,2);
plot(fn,abs(fftshift(signalsp)));grid; % plot frequency spectrum of signal
title('Frequency Spectrum');
xlabel('Frequency (Hz)');
end % end of function