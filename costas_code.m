function [sig,t,long_t] = costas_code(length,f0,f1,plotFlag,acfFlag)
% This function creates a costas coded sinusoid with 1001 samples.
% Future inputs could be starting frequency and frequency step size.
costas_length = length;
if costas_length == 10
    frequency_idx = [10 9 7 3 6 1 2 4 8 5];
else % default to 8
    costas_length = 8;
    frequency_idx = [2 6 3 8 7 5 1 4];
end

f_step = (f1-f0)/costas_length;
fmax = f0 + costas_length*f_step;
N = 1001;
t=linspace(0,(N-1)/2/fmax,N); % timeline
long_t = linspace(0,(N-1)*(2*fmax),N*4); % needed later for demodulation
tfin=t(N); % total duration of signal
timestep = round(N/costas_length);
sig = zeros(1,N); % pre-allocate memory for signal
index = linspace(costas_length,1,costas_length);
for i = 1:costas_length
    frequency = f0 + frequency_idx(i)*f_step;
    time_subset = t(N-(index(i)*timestep):N-(index(i)*timestep)+timestep);
    sig(N-(index(i)*timestep):N-(index(i)*timestep)+timestep) = sin(2*pi*frequency.*time_subset);
end

if(acfFlag == 1)
    % plot autocorrelation function, normalized to 1
    [c,xcor] = xcorr(sig,'normalize');
    figure();
    plot(xcor,abs(c));
    title("Costas ACF");
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
    title("Costas Signal, Length " + costas_length);
    xlabel('Time (s)');
    ylabel('Amplitude');
end  
end