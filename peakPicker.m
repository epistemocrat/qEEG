%function [] = peakPicker(electrode, windowMin, windowMax)

% Sttandard Values:
% windowMin = .250;
% windowMax = .500;
% segStart = -.1;
% samplingRate = 250;

nSamples = length(electrode);
timeStep = 1 / samplingRate;

segEnd   = (timeStep * (nSamples - 1)) + segStart;

timePoints = [segStart:timeStep:segEnd];

windowIndex = find((timePoints >= windowMin) & (timePoints <= windowMax));
windowStartIndex = min(squeeze(windowIndex));
windowStartValue = electrode(windowStartIndex);

windowEndIndex = max(squeeze(windowIndex));
windowEndValue = electrode(windowEndIndex);

peakPower = max(electrode(windowIndex));
peakIndex = find(electrode == peakPower);

% IF the peak is at the edge of the window then find the next two peaks
% outside each side of the window and compare them
if (peakPower == windowStartValue) || (peakPower == windowEndValue)
    
    % Find the closest peak before the window
    peakLow = windowStartValue;
    for peakLowIndex = (windowStartIndex - 1):-1:1
        peakLowTemp = electrode(peakLowIndex)
        
        if peakLowTemp < peakLow
            break;
        else
            peakLow = peakLowTemp;
        end
    end
    
    %Find the closest peak after the window
    peakHigh = windowEndValue;
    for peakHighIndex = (windowEndIndex + 1):nSamples
        peakHighTemp = electrode(peakHighIndex)
        
        if peakHighTemp < peakHigh
            break;
        else
            peakHigh = peakHighTemp;
        end
    end

    % Select the next highest peak outside of the window
    if peakHigh > peakLow
        peakPower = peakHigh;
        peakIndex = peakHighIndex;
    elseif peakHigh < peakLow
        peakPower = peakLow;
        peakIndex = peakLowIndex;
    else
        errordlg('Something went wrong. The low peak and high peak are equal','Peak Error');
    end
end

peakLatency = timePoints(peakIndex);
peakWindowIndex = (peakIndex - 3):(peakIndex + 3);
peakAverage = mean(electrode(peakWindowIndex));   
    
