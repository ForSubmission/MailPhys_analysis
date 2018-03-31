classdef Params < handle
    % Contains all parameters that are shared between functions for later
    % reference.
    
    properties (Constant)
        
        %% directories
        basedir = ['~' filesep 'MATLAB'];  % for all matlab files
        outdir = [Params.basedir filesep 'MailPhys'];  % specific to MailPhys
        edatemp = [Params.outdir filesep 'eda_temp'];  % specific to EDA preprocess
        edaduplicate = [Params.edatemp filesep 'duplicate'];  % specific to EDA preprocess duplicates
        
        %% formats
        sfo_p = '%02d';  % string format for participants 01, 02 ...
        
        %% other parameters
        minPeakDistance = 0.10;  % minimum distance between peaks
        
        %% shimmer
        shimmer_srate = 51.2;
        csvStart = 3;  % indicate which row contains the first same of valid data in Shimmer csv files

        % indices for EMG in Shimmer csv files
        iTimestamp = 1;
        iaccX = 2;
        iaccY = 3;
        iaccZ = 4;
        iCorr = 6;
        iZygo = 7;

        % indices for GSR in Shimmer csv files
        % 1 to 4 = identical to EMG
        iGSR = 6;
        
        %% time verification threshold (ms)
        timeThresh = 50;  % amount of milliseconds within which we consider a sample to be valid
        % if its number of samples and time difference are off by at most
        % this amount
        
    end
    
end