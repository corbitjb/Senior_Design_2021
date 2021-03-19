function [sig,t,long_t] = bpsk_mod(code_length,fc,plotFlag,acfFlag)
% This function modulates a Barker Code uaing Binary Phase Shift Keying
% (BPSK)
% The output function will be a vector in the form sin(wt + phase)
% Input fc is the carrier frequency.
% code_length is the length of the desired barker code

if code_length == 2
    BC = [1 -1];
elseif code_length == 3
    BC = [1 1 -1];
elseif code_length == 4
    BC = [1 1 -1 1];
elseif code_length == 5
    BC = [1 1 1 -1 1];
elseif code_length == 7
    BC = [1 1 1 -1 -1 1 -1];
elseif code_length == 11
    BC = [1 1 1 -1 -1 -1 1 -1 -1 1 -1];
elseif code_length == 13
    BC = [ 1 1 1 1 1 -1 -1 1 1 -1 1 -1 1];
end

sampling = 50; % controls number of samples to take per bit duration
wc = 2*pi*fc; % convert carrier to radians
N = length(BC); % number of periods used, use 1 period for each bit
tfin = N/fc; % total period of signal
Ns = sampling*N+1; % Number of samples to take, must be odd
t = linspace(0,tfin,Ns); % construct timeline
long_t = linspace(0,4*tfin,4*Ns);
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

if(acfFlag == 1)
    % plot autocorrelation function, normalized to 1
    [c,xcor] = xcorr(sig,'normalize');
    figure();
    plot(xcor,abs(c));
    title("Barker " + code_length + " ACF");
end

if(plotFlag == 1)
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
end
end % end of function