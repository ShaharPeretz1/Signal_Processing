function [fil_signal] = Filter_sig(signal,PLFREQ,fs)

    f1 = 2.1667; %breathing frequency
    f2 = PLFREQ; %powerline x

    w1 = f1/(fs/2);  bw1 = w1/10;
    [num1,den1] = iirnotch(w1,bw1); %notch filter
    fil_signal_1 = filter(num1,den1,signal);
    
    %IIR notch filter (x Freq)
    w2 = f2/(fs/2);  bw2 = w2/20;
    [num2,den2] = iirnotch(w2,bw2); %notch filter
    fil_signal_2 = filter(num2,den2,fil_signal_1);
    
    % FIR 
    bpFilt = designfilt('bandpassfir','FilterOrder',1000,...
        'CutoffFrequency1',0.65,'CutoffFrequency2',160,'SampleRate',1000);  
    fil_signal = filtfilt(bpFilt,fil_signal_2) ; % Filter the signal using filtfilt

end

