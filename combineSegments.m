function [combinedSegMatrix] = combineSegments(Resting_EEG)
% COMBINESEGMENTS Combines EEG segments into a 2D array (Channels x EEG time course)
%   
% Converts a 3D matrix (MxNxP) into a 2D matrix (MxN*P) 
%
% Author: Kevin McEvoy
% Last Update: */*/*

% Get the number of: channels, time points per segment, and segments
[nChans, nPoints, nSegs]  = size(Resting_EEG);

% Preallocate space for the new matrix
combinedSegMatrix = zeros(nChans, nPoints * nSegs);

% Add each segment to the second dimension of the new matrix
for i = 1:nSegs
    combinedSegMatrix(:,((i-1)*nPoints)+1:i*nPoints) = Resting_EEG(:,:,i);
end