function [sig,t,long_t] = golay2(f0,length,plotFlag,acfFlag)
% This function generates a Golay signal modulated using QPSK.
% The signal is modulated at frequency f0
% The length of a Golay signal can be 32, 64, or 128
% plotFlag can be 0 (no plots shown) or 1 (plot time and frequency domains)
% acfFlag can be 0 (no plots shown) or 1 (plot time and frequency domains)

f0 = 2*pi*f0;
[Ga,Gb] = wlanGolaySequence(length); % generate binary golay string
% setup as row vectors instead of column vectors
Ga = Ga';
Gb = Gb';
samples = 50; % number of samples
fmax = 2*f0; % from Nyquist theorem
N = length*samples/2+1; % number of samples to take, odd
t=linspace(0,(N-1)/2/fmax,N); % timeline
long_t = linspace(0,(N-1)*(2*fmax),N*4); % needed later

% Quadrature Phase Shift Keying (QPSK)
% [1 1] = 45  degrees
% [1 -1] = 315 degrees
% [-1 1] = 135 degrees
% [-1 -1] = 225 degrees
sig1 = zeros(1,length*samples/2); % pre-allocate vector for signal
sig2 = zeros(1,length*samples/2);
% divide by two because two bits are transmitted at the same time
for i = 1:2:length-1
    phase_idx1 = [Ga(i) Ga(i+1)];
    if(phase_idx1 == [-1 -1])
        phase_shift1 = 225*pi/180;
    elseif(phase_idx1 == [-1 1])
        phase_shift1 = 135*pi/180;
    elseif(phase_idx1 == [1 -1])
        phase_shift1 = 315*pi/180;
    elseif(phase_idx1 == [1 1])
        phase_shift1 = 45*pi/180;
    end
    current_idx = (i+1)/2;
    sampling_idx = current_idx*samples-samples+1;
    sig1(sampling_idx:(sampling_idx + samples)) = sin(f0.*t(sampling_idx:(sampling_idx + samples)) + phase_shift1);
    
    phase_idx2 = [Gb(i) Gb(i+1)];
    if(phase_idx2 == [-1 -1])
        phase_shift2 = 225*pi/180;
    elseif(phase_idx2 == [-1 1])
        phase_shift2 = 135*pi/180;
    elseif(phase_idx2 == [1 -1])
        phase_shift2 = 315*pi/180;
    elseif(phase_idx2 == [1 1])
        phase_shift2 = 45*pi/180;
    end
    sig2(sampling_idx:(sampling_idx + samples)) = sin(f0.*t(sampling_idx:(sampling_idx + samples)) + phase_shift2);
end
sig = sig1+sig2;
if(acfFlag == 1)
    % plot autocorrelation function, normalized to 1
    [c,xcor] = xcorr(sig,'normalize');
    figure();
    plot(xcor,abs(c));
    title("Golay ACF");
end
if(plotFlag == 1)
    % setup frequency spectrum
    j = sqrt(-1); % not necessary, but prevents warning messages
    fs=abs(1/(t(2)-t(1))); % <-- Sampling frequency, fs
    fn=linspace(-fs*(N-1)/(2*N),fs*(N-1)/(2*N),N);
    signalsp=(1/fs*fft(sig1)); % <-- Regular FFT
    % create plot of signal
    figure()
    subplot(1,2,2)
    plot(fn,abs(fftshift(signalsp)));grid; % plot frequency spectrum of signal
    title('Frequency Spectrum');
    xlabel('Frequency (Hz)');
    subplot(1,2,1)
    plot(t,sig1);grid; % plot time domain signal
    title('Golay Signal');
    xlabel('Time (s)');
    ylabel('Amplitude');
end
end