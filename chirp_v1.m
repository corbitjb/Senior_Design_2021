function sig = chirp_v1()
    f1 = 0; % Initialize to 0, final frequency
    B = 0; % Initialize to 0, bandwidth
    prompt1 = 'Choose a starting frequency:'; % prompt for user input
    dlgtitle1 = 'Starting Frequency'; % title of dialogue box
    f0 = str2double(inputdlg(prompt1,dlgtitle1)); % collect starting frequency
    question = 'Would you like to specify final frequency or bandwidth?';
    selection = questdlg(question,'','Final Frequency','Bandwidth','Final Frequency');
    
    % Read response from question, specifying final frequency or bandwidth
    switch selection
        case 'Final Frequency'
            prompt2 = 'Enter final frequency:'; 
            dlgtitle2 = 'Final Frequency';
            f1 = str2double(inputdlg(prompt2,dlgtitle2));
            B = f1-f0; % Bandwidth calculation
        case 'Bandwidth'
            prompt2 = 'Enter bandwidth:';
            dlgtitle2 = 'Bandwidth';
            B = str2double(inputdlg(prompt2,dlgtitle2));
            f1 = f0+B; % final frequency calculation
    end
    
    % generate linear chirp signal
    % Some of this code was borrowed from Dr. Dmitriy Garmatyuk
    fmax = 2*f1; % from Nyquist theorem
    N = 1001; % number of samples to take, odd
    t=linspace(0,(N-1)/2/fmax,N); % timeline
    tfin=t(N); % total duration of signal
    k = B/tfin; % slope
    phi0 = 2*pi*f0; % initial frequency in radians
    sig = sin(phi0.*t+(pi*k).*(t.^2)); % generates signal that is returned to main script
    
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