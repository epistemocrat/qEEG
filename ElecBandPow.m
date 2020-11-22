function [absPow, relPow] = ElecBandPow(subject, segNum, freqRange)
%ELECBANDPOW    Get the absolute & relative band power within a specified
%   			frequency range (i.e. band) for each row of ps (i.e. electrodes).
%
% INPUTS:   subject = Handle; Current subject
%           segNum = Index; Segment number for which to calculate the band power
%           ps = Array; nElecs * nFreqSamples
%           freqRange = 1x2 Array; [lowerFreq upperFreq]
% OUTPUTS:  absPow = Array of doubles (nElecs * 1); Absolute Power (uV^2) within the specified range
%           relPow = Array of doubles (nElecs * 1); Relative Power (%); absolute power within the
%           specified frequency range divided by absolute power across all
%           frequencies in ps
%
% Author: Kevin McEvoy
% Last Updated: */*/*

% This function could be used for either individual electrode power values or regions power
% values (i.e. groups of electrodes). As is, 4 separate functions will have to be written for getting
% the power values for (1) each elec for each seg, (2) each region for each seg, (3) each elec for the 
% avg of all segs, and (4) each region for the avg of all segs
%
% Since 4 functions need to be written anyway, this should be rewritten to output power values for
% all segs so the initial vars calculated below don't need to be recalculated for every call to
% ElecBandPow.


ps = subject.SegPSD(:,:,segNum); % 2D array of power values; nElecs * nFreqs
F  = subject.FreqSamples; % Vector of frequencies in ps

lowerF  = freqRange(1);
upperF  = freqRange(2);

nF    = size(F,1); % Number of freq points
maxF  = F(end);    % Max freq in power spectrum
stepF = maxF / nF; % Steps between successive freqs

lowFpoint  = floor(lowerF / stepF);  % Lower F boundery in number of points (i.e. number of freq steps)
highFpoint = ceil(upperF / stepF);   % Higher F boundery in number of points


% Calculate absolute power within 
absPower = mean(ps(:,lowFpoint:highFpoint));

% Calculate the total power
lowF_tot  = 1;      % NOTE: These should NOT be hard coded! These should be constants set for each 
highF_tot = 50;     %       subject, or constants as part of a superclass of all subjects

lowFpoint_tot  = floor(lowF_tot / stepF);  % Lower F boundery in number of points for the entire freq range to use
highFpoint_tot = ceil(highF_tot / stepF);  % Higher F boundery in number of points for the entire freq range to use
totPower = sum(ps(lowFpoint_tot:highFpoint_tot,:)); % Calculate total power, i.e. the denominator

% Calculate the relative power
rngPower = sum(ps(:,lowFpoint:highFpoint)); % Calculate total power within freq range of interest, i.e. the numerator
relPower = rngPower / totPower * 100;
end

