function [sig,t,long_t] = chirp_v4(f0,f1,plotFlag,acfFlag)
% generate linear chirp signal
% Some of this code was borrowed from Dr. Dmitriy Garmatyuk
% this version is intended to be used with the SAR GUI
B = f1-f0;
fmax = 2*f1; % from Nyquist theorem
N = 1001; % number of samples to take, odd
t=linspace(0,(N-1)/2/fmax,N); % timeline
long_t = linspace(0,(N-1)*(2*fmax),N*4); % needed later
tfin=t(N); % total duration of signal
k = B/tfin; % slope
phi0 = 2*pi*f0; % initial frequency in radians
sig = sin(phi0.*t+(pi*k).*(t.^2)); % generates signal that is returned to main script

if(acfFlag == 1)
    % plot autocorrelation function, normalized to 1
    [c,xcor] = xcorr(sig,'normalize');
    figure();
    plot(xcor,abs(c));
    title("LFM ACF");
end

if(plotFlag == 1)
    % setup frequency spectrum
    j = sqrt(-1); % not necessary, but prevents warning messages
    fs=abs(1/(t(2)-t(1))); % <-- Sampling frequency, fs
    fn=linspace(-fs*(N-1)/(2*N),fs*(N-1)/(2*N),N);
    signalsp=(1/fs*fft(sig)); % <-- Regular FFT
    % create plot of signal
    figure()
    subplot(1,2,2)
    plot(fn,abs(fftshift(signalsp)));grid; % plot frequency spectrum of signal
    title('Frequency Spectrum');
    xlabel('Frequency (Hz)');
    subplot(1,2,1)
    plot(t,sig);grid; % plot time domain signal
    title('Signal Preview');
    xlabel('Time (s)');
    ylabel('Amplitude');
end
end