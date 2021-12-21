clc; clear all; close all;

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

freq=1000; %[Hz] - sampling rate
dt=1/freq; %[sec]

%% for "B" signals:
% R-wave detection:
%call function to detect R-waves 
Rwaves.R1 = Rwave_detection(ecg1_B) ;%R1 = index of R waves 
Rwaves.R2 = Rwave_detection(ecg2_B) ;%R2 = index of R waves 

% Plots:
% Add required plots:
% ECG 1_B 
ORS_plots(freq,ecg1_B,Rwaves.R1,"B1")
average_HR_1_B=HR_plots(freq,Rwaves.R1,"B1")

% Save R-wave detections for "s" signals:
Rwaves.R1=Rwaves.R1;
Rwaves.R2=Rwaves.R2;
save('B.mat','Rwaves');

%% for "A" signals:
% R-wave detection
%call function to detect R-waves
Rwaves.R1 = Rwave_detection(ecg1_A) ;%R3 = index of R waves 
Rwaves.R2 = Rwave_detection(ecg2_A) ;%R4 = index of R waves 

% Plots:
% Add required plots:
% ECG 2_A
ORS_plots(freq,ecg2_A,Rwaves.R2,"A2")
average_HR_2_A=HR_plots(freq,Rwaves.R2,"A2")

% Save R-wave detections for "A" signals:
Rwaves.R1=Rwaves.R1;
Rwaves.R2=Rwaves.R2;
save('A.mat','Rwaves');

toc

%% functions for the plots

function [avg_HR]=HR_plots(freq,R_detections,signal_name)
    time = R_detections./freq;
    HR_values = 1./(diff(time));
    figure()
    scatter(time(1:end-1),HR_values);
    xlabel('Time [sec]');
    ylabel('Heart Rate [beats/sec]');
    title(sprintf("Heart Rate for the signal: %s",signal_name));
    avg_HR=mean(HR_values);
end

function ORS_plots(freq,signal,R_detections,signal_name)
    %time
    dt=1/freq;
    end_time = length(signal)-1;
    time = 0:dt:dt*end_time;
    %signal [15 20]
    figure();
    plot(time,signal,time(R_detections),signal(R_detections),'o');
    xlabel('Time [sec]');
    ylabel('Amplitude [mV]');
    xlim([15 20]);
    title(sprintf("ECG signal %s",signal_name));
    ylim([-200 2500]);
    
    %signal with R-detections [23 28]
    figure();
    plot(time,signal,time(R_detections),signal(R_detections),'o')
    xlabel('Time [sec]')
    ylabel('Amplitude [mV]')
    xlim([23 28])
    title(sprintf("ECG Signal %s with R-Peak Detections",signal_name))
    ylim([-200 2500])
end