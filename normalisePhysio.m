function data = normalisePhysio(data, columns)
% given a shimmer input data (read from csv), normalises columns
% so that they are centred at 0 and oscillate between
% 1 and -1, using the 1st derivative (difference in movement) and scaled
% using the 0.1% quantile
% for example, to normalise accelerometer data call normaliseAccel(emgData, 2:4)

% columns in emg / gsr Data
% 1: timestamp (ms)
% 2: accel_x
% 3: accel_y
% 4: accel_z

for i = columns
    
    iminus = 1: size(data,1) - 1;
    data(iminus , i) = diff(data(:, i));
    data(iminus , i) = data(iminus , i) / quantile(data(iminus , i), 0.001);  % 0.1% quartile
    
    % cut off everything above 1 and below -1
    biggr = data(iminus, i) > 1;
    smallr = data(iminus, i) < -1;
    data(biggr, i) = 1;
    data(smallr, i) = -1;
    
end

data = removerows(data, size(data,1));

end