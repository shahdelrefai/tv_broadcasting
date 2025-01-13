% Parameters
fs = 10000;                % Sampling frequency in Hz
video_carrier_freq = 1e6;  % Video carrier frequency in Hz (1 MHz)
cutoff_freq = 1000;         % Cutoff frequency for VSB in Hz
video_file = 'C:\Users\USER\Downloads\videoplayback.mp4';  % Replace with your video file path
output_file = 'reconstructed_video.avi'; % Output file path

% Read the video file
video = VideoReader(video_file);

% Get video properties
video_width = video.Width;
video_height = video.Height;
video_fps = video.FrameRate;
num_frames = floor(video.Duration * video_fps);

% Create video writer object
writer = VideoWriter(output_file, 'Uncompressed AVI');
writer.FrameRate = video_fps;
open(writer);

% Process and plot each frame
frame_idx = 1;
while hasFrame(video)
    frame = readFrame(video);
    
    % Convert the frame to individual R, G, B signals
    b_channel = double(frame(:, :, 1));
    g_channel = double(frame(:, :, 2));
    r_channel = double(frame(:, :, 3));
    
    % Flatten each channel to 1D signals
    b_signal = b_channel(:);
    g_signal = g_channel(:);
    r_signal = r_channel(:);
    
    % Apply VSB modulation to each channel
    b_vsb_signal = vsb_modulate(b_signal, video_carrier_freq, fs, cutoff_freq, length(b_signal));
    g_vsb_signal = vsb_modulate(g_signal, video_carrier_freq, fs, cutoff_freq, length(g_signal));
    r_vsb_signal = vsb_modulate(r_signal, video_carrier_freq, fs, cutoff_freq, length(r_signal));
    
    % Apply inverse VSB modulation to each channel (demodulation)
    b_demod_signal = vsb_demodulate(b_vsb_signal, video_carrier_freq, fs, cutoff_freq, length(b_signal));
    g_demod_signal = vsb_demodulate(g_vsb_signal, video_carrier_freq, fs, cutoff_freq, length(g_signal));
    r_demod_signal = vsb_demodulate(r_vsb_signal, video_carrier_freq, fs, cutoff_freq, length(r_signal));
    
    % Reshape the signals back into image format
    b_channel_reconstructed = reshape(b_demod_signal, [video_height, video_width]);
    g_channel_reconstructed = reshape(g_demod_signal, [video_height, video_width]);
    r_channel_reconstructed = reshape(r_demod_signal, [video_height, video_width]);
    
    % Combine the channels into one frame
    reconstructed_frame = cat(3, uint8(b_channel_reconstructed), uint8(g_channel_reconstructed), uint8(r_channel_reconstructed));
    
    % Write the frame to the video file
    writeVideo(writer, reconstructed_frame);
    
    % Plot the signals for the first frame
    if frame_idx == 1
        % Original signals
        figure;
        
        subplot(3,3,1);
        plot(b_signal(1:200), 'b');
        title('Original Blue Channel Signal');
        xlabel('Sample Index');
        ylabel('Amplitude');
        
        subplot(3,3,2);
        plot(g_signal(1:200), 'g');
        title('Original Green Channel Signal');
        xlabel('Sample Index');
        ylabel('Amplitude');
        
        subplot(3,3,3);
        plot(r_signal(1:200), 'r');
        title('Original Red Channel Signal');
        xlabel('Sample Index');
        ylabel('Amplitude');
        
        % FFT for each channel
        b_fft = fft(b_signal);
        g_fft = fft(g_signal);
        r_fft = fft(r_signal);
        
        % Frequency axis scaling
        len_b = length(b_fft);
        freq_axis_b = (-len_b/2:len_b/2-1) * (fs / len_b);

        len_g = length(g_fft);
        freq_axis_g = (-len_g/2:len_g/2-1) * (fs / len_g);

        len_r = length(r_fft);
        freq_axis_r = (-len_r/2:len_r/2-1) * (fs / len_r);
        
        subplot(3,3,4);
        plot(freq_axis_b, fftshift(abs(b_fft)), 'b');
        title('FFT of Blue Channel Signal');
        xlabel('Frequency (Hz)');
        ylabel('Magnitude');
        grid on;
        
        subplot(3,3,5);
        plot(freq_axis_g, fftshift(abs(g_fft)), 'g');
        title('FFT of Green Channel Signal');
        xlabel('Frequency (Hz)');
        ylabel('Magnitude');
        grid on;
        
        subplot(3,3,6);
        plot(freq_axis_r, fftshift(abs(r_fft)), 'r');
        title('FFT of Red Channel Signal');
        xlabel('Frequency (Hz)');
        ylabel('Magnitude');
        grid on;
        
        % Modulated signals
        subplot(3,3,7);
        plot(b_vsb_signal(1:200), 'b');
        title('VSB Modulated Blue Channel Signal');
        xlabel('Sample Index');
        ylabel('Amplitude');
        
        subplot(3,3,8);
        plot(g_vsb_signal(1:200), 'g');
        title('VSB Modulated Green Channel Signal');
        xlabel('Sample Index');
        ylabel('Amplitude');
        
        subplot(3,3,9);
        plot(r_vsb_signal(1:200), 'r');
        title('VSB Modulated Red Channel Signal');
        xlabel('Sample Index');
        ylabel('Amplitude');
        
        % FFT for VSB modulated signals
        len_b_f = length(b_vsb_signal);
        freq_axis_b_f = (-len_b_f/2:len_b_f/2-1) * (fs / len_b_f);

        len_g_f = length(g_vsb_signal);
        freq_axis_g_f = (-len_g_f/2:len_g_f/2-1) * (fs / len_g_f);

        len_r_f = length(r_vsb_signal);
        freq_axis_r_f = (-len_r_f/2:len_r_f/2-1) * (fs / len_r_f);

        figure;
        subplot(3,1,1);
        plot(freq_axis_b_f, fftshift(abs(fft(b_vsb_signal))), 'b');
        title('FFT of VSB Modulated Blue Channel Signal');
        xlabel('Frequency (Hz)');
        ylabel('Magnitude');
        grid on;
        
        subplot(3,1,2);
        plot(freq_axis_g_f, fftshift(abs(fft(g_vsb_signal))), 'g');
        title('FFT of VSB Modulated Green Channel Signal');
        xlabel('Frequency (Hz)');
        ylabel('Magnitude');
        grid on;
        
        subplot(3,1,3);
        plot(freq_axis_r_f, fftshift(abs(fft(r_vsb_signal))), 'r');
        title('FFT of VSB Modulated Red Channel Signal');
        xlabel('Frequency (Hz)');
        ylabel('Magnitude');
        grid on;
        
        % Save the plot
        saveas(gcf, 'modulation_and_fft_plots.png');
    end
    
    frame_idx = frame_idx + 1;
end

% Close the video writer
close(writer);

% Function for VSB modulation with padding/truncation
function vsb_signal = vsb_modulate(signal, carrier_freq, fs, cutoff_freq, original_length)
    % Time vector based on the signal length and sampling rate
    t = (0:length(signal)-1) / fs;

    % Generate carrier signal for modulation
    carrier = cos(2 * pi * carrier_freq * t);

    % Modulate the signal with the carrier
    modulated_signal = signal .* carrier';

    % Apply a lowpass filter to perform VSB filtering
    [b, a] = butter(5, cutoff_freq / (fs / 2), 'low');
    vsb_signal = filter(b, a, modulated_signal);

    % Pad or truncate to ensure the output signal matches the original length
    if length(vsb_signal) > original_length
        vsb_signal = vsb_signal(1:original_length);
    elseif length(vsb_signal) < original_length
        vsb_signal = [vsb_signal; zeros(original_length - length(vsb_signal), 1)];
    end
end

% Function for VSB demodulation (inversing the modulation)
function demod_signal = vsb_demodulate(vsb_signal, carrier_freq, fs, cutoff_freq, original_length)
    % Time vector based on the signal length and sampling rate
    t = (0:length(vsb_signal)-1) / fs;

    % Generate carrier signal for demodulation
    carrier = cos(2 * pi * carrier_freq * t);

    % Demodulate the signal by multiplying with the carrier
    demodulated_signal = vsb_signal .* carrier';

    % Apply a lowpass filter to recover the original signal
    [b, a] = butter(5, cutoff_freq / (fs / 2), 'low');
    demod_signal = filter(b, a, demodulated_signal);

    % Pad or truncate to ensure the output signal matches the original length
    if length(demod_signal) > original_length
        demod_signal = demod_signal(1:original_length);
    elseif length(demod_signal) < original_length
        demod_signal = [demod_signal; zeros(original_length - length(demod_signal), 1)];
    end
end
