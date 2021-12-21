function [R_detections]=Rwave_detection(signal)
    % 1) square:   
    sqr_signal = (signal).^2;
    
    % 2) normalize:
    norm_signal(1:length(sqr_signal)) = (((sqr_signal(1:end)-min(sqr_signal)))./(max(sqr_signal)-min(sqr_signal))); 
    
    % 3) moving averge filter:
    avg_signal = movmean(norm_signal,5); %filter's window size = 5
    
    % 4) first derivative- first threshold:
    first_derivative = [0 abs(avg_signal(2:end)-avg_signal(1:end-1))]; 
    QRS_detections = []; %saving the QRS detections in a vector
    % 4.1) dividing the signal into windows of 5000 samples each:
    window_length = 5000; 
    num=floor(length(first_derivative)/window_length);
    for i=0:num-1
        window = first_derivative((i*window_length)+1:(i*window_length)+window_length);
        % 4.2) using first threshold- set in zero all values under 350% of the average value in the
        % window:
        window(window < 3.5*mean(window)) = 0;
        locs=find(islocalmax(window, 'MinSeparation', 300)); 
        QRS_detections = [QRS_detections,(i*window_length)+locs];
    end
    %applying the same operations on the samples in the last window:
    window_end = first_derivative((num*window_length)+1:end);
    window_end(window_end < 3.5*mean(window_end)) = 0;
    locs_end=find(islocalmax(window_end, 'MinSeparation', 300)); 
    QRS_detections = [QRS_detections,(num*window_length)+locs_end];
    
    % 5) derivative of the locations- second threshold:
    location_derivative= [0 abs(QRS_detections(2:end)-QRS_detections(1:end-1))];
    % 5.1) using second threshold-  picking only the values above 65% of the average value to remove close peaks:
    detect_final = QRS_detections((location_derivative>round(0.65*mean(location_derivative)))==1);
    
    % 6) detecting R waves:
    R_detections=[];
    % 6.1) dividing the signal into windows of 100 samples each: 
    small_window = 100;
    % 6.2) the maximum value in each window is determined as the R wave:
    for i=1:length(detect_final)
        locs = 0;
        if detect_final(i)+(small_window/2)<length(signal) && detect_final(i)-(small_window/2)>1
            [~,locs]=max(signal((detect_final(i)-(small_window/2)):(detect_final(i)+(small_window/2))));
            R_detections(i) = locs - 1 + detect_final(i)-(small_window/2);
        elseif detect_final(i)-(small_window/2)<=1
            [~,locs]=max(signal(1:detect_final(i)+(small_window/2)));
            R_detections(i) = locs - 1 + QRS_detections(i)-(small_window/2);
        elseif detect_final(i)+(small_window/2)>=length(signal)
            [~,locs]=max(signal(detect_final(i)-(small_window/2):end));
            R_detections(i) = locs - 1 + QRS_detections(i)-(small_window/2);
        end
    end
end