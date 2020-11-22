%% peakPickerScript   =   Finds the peaks in a user defined window, for a user
%       defined number of components and subjects, for a user defined set
%       of electrodes then for each component it creates a csv text file containing  
%       the peak, average around the peak, the latency of the peak, and a flag (i.e. 
%       1 or 0) if the peak occured at the edge of the window.
%
%  This script differs from 'peakPickerScript_elecAvg' by finding peaks
%  within each INDIVIDUAL electrode rather than the AVERAGE of all
%  electrodes within a user defined group of electrodes
%
% Created By: Kevin McEvoy
% Last Edited: */*/*

%% PARAMETER SELECTION (Edit this section only)

subjects     = {'092s03v2';'113s03v2';%'113s03v2';'116s03v2';'117s03v2';'119s03v2';'133s09v2';'144s01v2';'153s01v2';'165s01v2';'166s02v2';'174s09v2';'184s01v2';'195s01v2'
                };
%subjects     = {'119s03v1';'138s01v1';'144s01v1';'155s03v1';'161s01v1';'162s01v1';'165s01v1';'166s02v1';'169s01v1';'170s01v1';'174s09v1';'175s03v1';'178s03v1';'184s01v1';'190s03v1';'200s01v1';'201s01v1'};
                %'133s09v1';
conditions   = {'Expected';
                'Prob'};
varsNameEnd  = {''};                 %This is a list of alternate endings to variables names
%                 '_lauren';          %   within the .mat files exported from netstation. Standard
%                 '_laure';           %   variable names are a combination of a condition and subject
%                 '_engage';          %   (e.g. 'Nonsocial_Average119s03v1') but sometimes there is 
%                 '_engag';           %   an additional ending that needs to be accoutned for (e.g.
%                 '_2'};              %   'Social_Average133s09v1_enage')
fileNameEnd  = '.f.s.bl.b.a.r.mat'; %This is the last part of the .mat file name
segStart     = -100;                %Segment start time in ms (i.e. when the baseline started)
samplingRate = 250;                 %Sampling Rate
components   = {'P3',[111,350];     %First column is component name and second column is the [start, end] times of the component
                'N1',[23,255];};
                %'N1',[70,150];    
                %'Nc',[500,800]};
% electrodes   = [66 67	70	71	75	74	81	82	77	76	83	84];       %The list of electrodes to find the peaks in
electrodes   = [27	24	20	19	16	11	12	5	4	118	124	123];
showPlots    = true;



%% ***************** DO NOT EDIT ANY CODE BELOW THIS POINT *****************
%% INTERNAL VARIABLE CALCULATIONS          
nSubjects   = size(subjects,1);
nElectrodes = length(electrodes);
nConditions = size(conditions,1);
nComponents = size(components,1);
nNames      = size(varsNameEnd,1);

columnNames = {'peak', 'latency','average_peak','peak_at_edge'};


%% COMPONENTS FOR-LOOP
for compNum = 1:nComponents
    peaks = zeros(nSubjects,4,nElectrodes,nConditions);
    
    % Determine if the current component is positive or negative
    if strncmpi('p',components{compNum,1},1)
        peakSign = 'positive';
    elseif strncmpi('n',components{compNum,1},1)
        peakSign = 'negative';
    else
        error('Component names must start with the letter P or N');
    end
    
    %% SUBJECTS FOR-LOOP
    for subjNum = 1:nSubjects
        % Load subject's data from their .mat file that was exported from Net Station 
        dataFileName = [subjects{subjNum}, fileNameEnd];
        load(dataFileName);

        %% CONDITIONS FOR-LOOP
        for condNum = 1:nConditions
            
            % Cycle through the possible var names to find what it was named by Net Station
            for iName = 1:nNames
                varName = [conditions{condNum}];    %[conditions{condNum}, subjects{subjNum}, varsNameEnd{iName}];
                if exist(varName,'var')
                    eval(['data  = ' varName ';']);
                    break;
                end                    
            end

            %% GET PEAKS
            if strcmp(peakSign,'positive')
                for electrodeNum = 1:nElectrodes
                    [peaks(subjNum,1,electrodeNum,condNum)... 
                     peaks(subjNum,2,electrodeNum,condNum)...
                     peaks(subjNum,3,electrodeNum,condNum)...
                     peaks(subjNum,4,electrodeNum,condNum)] = getMaxPeak(data(electrodes(electrodeNum),:),components{compNum,2}(1,1),components{compNum,2}(1,2),segStart,samplingRate);
                end
            elseif strcmp(peakSign,'negative')
                for electrodeNum = 1:nElectrodes
                    [peaks(subjNum,1,electrodeNum,condNum)... 
                     peaks(subjNum,2,electrodeNum,condNum)...
                     peaks(subjNum,3,electrodeNum,condNum)...
                     peaks(subjNum,4,electrodeNum,condNum)] = getMinPeak(data(electrodes(electrodeNum),:),components{compNum,2}(1,1),components{compNum,2}(1,2),segStart,samplingRate);
                end
            else
                error('Could not determine the polarity of the peak');
            end
            
            % Edit peaks at the edge of windows            
            if showPlots && peaks(subjNum,4,electrodeNum,condNum)
                % First setup the figure for displaying a channel's EEG, with window boundaries
                nSamples = length(data(electrodes(electrodeNum),:));
                timeStep = 1 / samplingRate * 1000;

                segEnd   = (timeStep * (nSamples - 1)) + segStart;

                timePoints = [segStart:timeStep:segEnd];

                hfig = figure;

                plot(timePoints,data(electrodes(electrodeNum),:));

                line([segStart segEnd],[0 0],'Color','k','HitTest','off'); % Put a vertical line a t=0
                yLims = ylim;
                line([0 0],[yLims(1) yLims(2)],'Color','k','HitTest','off'); % Puts a horizontal line at y=0
                
                line([components{compNum,2}(1) components{compNum,2}(1)], [yLims(1) yLims(2)],'Color','m','HitTest','off'); %Put magenta vertical lines at the window boundaries
                line([components{compNum,2}(2) components{compNum,2}(2)], [yLims(1) yLims(2)],'Color','m','HitTest','off');

                title([components{compNum,1}, ' (' num2str(components{compNum,2}(1)), ' - ', num2str(components{compNum,2}(2)),...
                       'ms)  /  ', conditions{condNum}, '  /  Electrode: ' num2str(electrodes(electrodeNum))]);
                set(hfig,'Name',['Subject: ', subjects{subjNum}]);
                
                % Setup Matlab for being able to interact with a plot using the mouse
                dcm_obj = datacursormode(hfig);
                set(dcm_obj,'DisplayStyle','window','Enable','on');
                set(dcm_obj,'UpdateFcn',{@updatePeak,data(electrodes(electrodeNum),:),timePoints,hfig});

                hbox = msgbox(['A peak was found outside the window at ' num2str(peaks(subjNum,2,electrodeNum,condNum)), ' ms and ',...
                               num2str(peaks(subjNum,1,electrodeNum,condNum)), ' uV. Select a new peak then press OK or just press OK to keep the current peak.'],'Peak at Window Edge');
                hbox_pos = get(hbox,'Position');
                hfig_pos = get(hfig,'Position');
                hbox_x   = ((hfig_pos(3) - hbox_pos(3)) / 2) + hfig_pos(1);
                hbox_y   = hfig_pos(2) - hbox_pos(4) - 30;

                set(hbox,'Position',[hbox_x, hbox_y, hbox_pos(3), hbox_pos(4)]);
                uiwait(hbox);

                if ishandle(hfig)
                    if ~isempty(get(hfig,'UserData'))
                        peaks(subjNum,:,electrodeNum,condNum) = get(hfig,'UserData');
                        disp(['New ', components{compNum,1}, 'peak at ', num2str(peaks(subjNum,2,electrodeNum,condNum)), ' ms and ' num2str(peaks(subjNum,1,electrodeNum,condNum)),...
                              ' uV (SUBJECT: ' subjects{subjNum}, ' ELECTRODE: ' num2str(electrodes(electrodeNum)), ' CONDITION: ' conditions{condNum} ')']);
                    else
                        disp('New peak not selected. The original peak will be kept');
                    end
                    close(hfig);
                else
                    disp('Figure was closed. The original peak will be kept');
                end
            end
                
            eval(['clear data ' varName]);
        end % END CONDITIONS FOR-LOOP
    end % END SUBJECCTS FOR-LOOP

    
%% EXPORT PEAK DATA TO A CSV (COMMA SEPARATED VALUE) TEXT FILE    
    [success,msg] = mkdir('Peaks');
    fileName = [pwd '\Peaks\Peaks_', components{compNum,1}, '.txt'];
    counter = 1;
    while exist(fileName,'file')
        fileName = [pwd '\Peaks\Peaks_', components{compNum,1},  '(', num2str(counter) ').txt'];
        counter = counter + 1;
    end
    fid = fopen(fileName,'w');
    fprintf(fid,'%s\n,',fileName);

    % Write the second line of output
    for iCondition = 1:nConditions
        for iElectrode = 1:nElectrodes
            fprintf(fid,'Condition: %s, Electrode: %s, , ,',conditions{iCondition},num2str(electrodes(iElectrode)));
        end
    end
    fprintf(fid,'\n,');
    
    % Write the third line of output
    for iCondition = 1:nConditions
        for iElectrode = 1:nElectrodes
            fprintf(fid,'%s, %s, %s, %s,',columnNames{1,:});
        end
    end
    fprintf(fid,'\n');
    fclose(fid);
    
    % Write the subject number and his/her corresponding peak data
    for iSubject = 1:nSubjects
        fid = fopen(fileName,'a');
        fprintf(fid,'%s,',subjects{iSubject});
        fclose(fid);
        
        subjectData = peaks(iSubject,:,:,:);
        dlmwrite(fileName,subjectData,'-append');
    end
    
    disp(['Wrote peaks to the file: ' fileName]);
end % END COMPONENTS FOR-LOOP
