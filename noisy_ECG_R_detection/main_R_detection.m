%%
clear all; clc; close all;

%%
tic

%import all ecg signals
ecg1_A=load('ECG_A_01.mat');
ecg1_B=load('ECG_B_01.mat');
ecg2_A=load('ECG_A_02.mat');
ecg2_B=load('ECG_B_02.mat');
ecg1_A= ecg1_A.sig;
ecg1_B=ecg1_B.sig;
ecg2_A=ecg2_A.sig;
ecg2_B=ecg2_B.sig;

%the given signal was in microV 
ecg1_A = ecg1_A./1000;
ecg1_B = ecg1_B./1000;
ecg2_A = ecg2_A./1000;
ecg2_B = ecg2_B./1000; 

%% R-wave detection + filtering
freq = 1000; %[Hz]
dt = 1/freq; %[sec]

PLFREQ1_A = freq_to_filter(ecg1_A,freq);
PLFREQ1_B = freq_to_filter(ecg1_B,freq);
PLFREQ2_A = freq_to_filter(ecg2_A,freq);
PLFREQ2_B = freq_to_filter(ecg2_B,freq);

%% for "B" signals:

% R detections
R1=Rwave_detection(ecg1_B,PLFREQ1_B);
R2=Rwave_detection(ecg2_B,PLFREQ2_B);

% R-wave detection:
% call function to detect R-waves 
Rwaves.R1 = Rwave_detection(ecg1_B, PLFREQ1_B);%R1 = index of R waves
ecg1_B_fil = Filter_sig(ecg1_B,PLFREQ1_B,freq);
Rwaves.R2 = Rwave_detection(ecg2_B, PLFREQ2_B);%R2 = index of R waves 
ecg2_B_fil = Filter_sig(ecg2_B,PLFREQ2_B,freq);

%time vectors
N1_B = length(ecg1_B)-1;
t1_B = 0:dt:dt*N1_B;
N2_B = length(ecg2_B)-1;
t2_B = 0:dt:dt*N2_B;

% plots:
% ORS - signal
ORS_plots(freq,ecg1_B,ecg1_B_fil,'ecg1-B',t1_B,R1)
ORS_plots(freq,ecg2_B,ecg2_B_fil,'ecg2-B',t2_B,R2)

% HR
HR_1_B = HR_plots(freq,R1,'ecg1-B-fil');
HR_2_B = HR_plots(freq,R2,'ecg2-B-fil');

% Save R-wave detections for "s" signals:
Rwaves.R1=Rwaves.R1;
Rwaves.R2=Rwaves.R2;
save('B.mat','Rwaves');

%% for "A" signals:

% R detections
R1=Rwave_detection(ecg1_A,PLFREQ1_A);
R2=Rwave_detection(ecg2_A,PLFREQ2_A);

% R-wave detection:
% call function to detect R-waves 
Rwaves.R1 = Rwave_detection(ecg1_A, PLFREQ1_A);%R1 = index of R waves
ecg1_A_fil = Filter_sig(ecg1_A,PLFREQ1_A,freq);
Rwaves.R2 = Rwave_detection(ecg2_A, PLFREQ2_A);%R2 = index of R waves
ecg2_A_fil = Filter_sig(ecg2_A,PLFREQ2_A,freq);

%time vectors
N1_A = length(ecg1_A)-1;
t1_A = 0:dt:dt*N1_A;
N2_A = length(ecg2_A)-1;
t2_A = 0:dt:dt*N2_A;

% plots:
% ORS - signal
ORS_plots(freq,ecg1_A,ecg1_A_fil,'ecg1-A',t1_A,R1)
ORS_plots(freq,ecg2_A,ecg2_A_fil,'ecg2-A',t2_A,R2)

%
HR_1_y = HR_plots(freq,R1,'ecg1-A-fil');
HR_2_y = HR_plots(freq,R2,'ecg2-A-fil');

% Save R-wave detections for "y" signals:
Rwaves.R1=Rwaves.R1;
Rwaves.R2=Rwaves.R2;
save('A.mat','Rwaves');

toc

%% plotting the filters

f1 = 2.1667; %breathing frequency
f2 = PLFREQ2_A; %powerline x
fs=1000; %sampling frequency

%% IIR notch filter (Respiratory Frequency)
w1 = f1/(fs/2);  bw1 = w1/10;
[num1,den1] = iirnotch(w1,bw1); %notch filter
fvtool(num1,den1);
fvtool(num1,den1,'phase')
zplane(num1,den1)
title("poles and zeros map for IIR notch filter (Respiratory Frequency)")
grid


%% IIR notch filter (x Frequency)
w2 = 2*f2/(fs);  bw2 = w2/10;
[num2,den2] = iirnotch(w2,bw2); %notch filter
fvtool(num2,den2);
fvtool(num2,den2,'phase')
zplane(num2,den2)
title("poles and zeros map for IIR notch filter (x Frequency)")
grid

%% Band-Pass (ECG Frequency range)
bpFilt = designfilt('bandpassfir','FilterOrder',1000,...
    'CutoffFrequency1',0.65,'CutoffFrequency2',50,'SampleRate',1000); %BPF
fvtool(bpFilt);
fvtool(num2,den2,'phase');
zplane(bpFilt)
title("poles and zeros map for FIR Band-Pass (ECG Frequency range)")
grid


%% Function for PLFREQ (freq_to_filter)

function [PLFREQ] = freq_to_filter(signal,freq)
    L = length(signal);
    FFT_abs = abs(fft(signal));
    f = linspace(0,freq,L); %[Hz]
    idx_30 = find(f>=30 & f<=70, 1);
    idx_70 = find(f>=30 & f<=70, 1, 'last');
    [~,max_idx] = max(FFT_abs(idx_30:idx_70));
    PLFREQ = f(max_idx+idx_30); %[Hz]
end

%% Functions for plots 

function ORS_plots(freq,noisy_signal,denoised_signal,signal_name,time,R_vec)
    %noisy signal
    figure()
    subplot(2,1,1)
    plot(time,noisy_signal)
    xlabel('Time [sec]')
    ylabel('Amplitude [mV]')
    xlim([30 38])
    title1=sprintf("ECG noisy signal %s",signal_name);
    title(title1)
    %denoised signal
    subplot(2,1,2)
    plot(time,denoised_signal,time(R_vec),denoised_signal(R_vec),'o')
    xlabel('Time [sec]')
    ylabel('Amplitude [mV]')
    xlim([30 38])
    title2=sprintf("ECG denoised signal %s",signal_name);
    title(title2)
end

function [avg_HR]=HR_plots(freq,R_detections,signal_name)
    time_R = R_detections./freq;
    HR_values = 1./(diff(time_R));
    figure()
    scatter(time_R(1:end-1),HR_values);
    xlabel('Time [sec]');
    ylabel('Heart Rate [beats/sec]');
    title3=sprintf("Heart Rate for the signal: %s",signal_name);
    title(title3);
    avg_HR=mean(HR_values);
end

