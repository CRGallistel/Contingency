function [figure_handle, use_axis] = TSraster_v3(tsdata, trialdef,events, varargin)
% TSraster(TSDATA, TRIALDEF, EVENTS, ARG1, ARG2, ARG3, ARG4)
%
% 	Produces a raster plot of time stamped data. Trials and events must be identified and
%   then the y axis indicates trial number (with the first trial on the bottom) and the x axis
%   indicates time within each trial. Events that have duration (for example, head pokes) are 
%   represented as colored lines spanning that duration. Point events (for example, feeding events)
%   are represented as marked symbols at the appropriate time.
%   By default, the different events are offset slightly along the y axis so that ovelaping events
%   can be clearly seen.
%
% 	Arguments, Mandatory:
%		TSDATA -	2-column matrix of standard TSdata.
% 		TRIALDEF - 	A standard trial definition. Each line of the raster
%                   belongs to a different match range resulting from a
%                   TSmatch call on the TSdata and the trialdef match codes.
%		EVENTS -	2-column matrix, each row indicating a start event code
%                   and a stop event code. Point events are indicated by
%                   putting a 0 in the second column. All of the events
%                   passed in will be plotted. If start and stop codes are
%                   present, a line will be plotted where the event is 
%					happening. Each event's line will be given a different
%					color. If the event is a point event, a different point
%					marker will be used for each type of point event given.
%
% 	Arguments, Optional: May appear in any order as ARG1, ARG2, ARG3, ARG4.
%		COLORS -	Character string, same length as EVENTS.
%					Overrides the default coloring scheme. Each character
%					will be passed to Matlab's plot function when the
%					corresponding event type is drawn. 
%
%                   Example: 
%                   If there are 2 start-stop events and 2 point events,
%                   you might use 'rbx+'. This would plot the 2 start-stops
%                   as red and blue, and the point events as X's and +'s.
%					
%                   See help plot for a full list of characters that can be
%                   used. 
%
%                   If you wish to specify multiple characters for each
%                   event, then colors should be a character matrix. In
%                   that case there should be one row for each event, and
%                   the corresponding row will be passed to plot.
%
%                   Example:
%                   strvcat('r', 'b:', 'xg', '+y')
%
%                   If this string were passed, the blue line would be a
%                   dotted blue line, the x's would be green, and the +'s
%                   would be yellow. Using strvcat vertically concatenates
%                   the strings, and pads them with spaces if they are
%                   different lengths so you do not get errors.
%
%		OFFSETS  -	Row vector, same length as EVENTS.
%					Indicated the vertical offset to be used for the
%					events.  Multiple Events can be placed on the same line. 
%                   Each element of offset needs to be a positive integer.
%					1 signifies the bottom line of each trial. 
%
%                   The offset is not added to the y-coordinate, in fact
%                   the actual shift is scaled down by the maximum offset
%                   passed, so that offsets of [3 1 2] provide exactly the
%                   same result as [6 2 4]. 
%
%                   By default,	each event is placed on seperate evenly
%                   spaced lines. 
%
%		LABELS -	Cell Array of Character Strings. Same length as EVENTS.
%					These will be used in the legend, to label each type of
%					event. By default there is no legend.
%
%       AXES -      A handle to the axes to use. If this argument is
%                   present, TSraster will not create a new figure and will
%                   use this axes instead.
%
%  Returns:
%       figure -    A handle to the figure that was used.
%       axes -      A handle to the axes that was used.

% Assumptions in writing this code:
%   Most of the tsdata is in trials -- ITIs have relatively less data
%   No assumptions are made about the order of onoff signals
%   Onoff signals do not compose most of the data -- it will be quicker to
%   use find to operate on their indices than to search through the tsdata.


typepoint = (events(:,2) == 0); %If the second element is a 0, it is a point event. Otherwise it is a onoff event.

onoff_events = events(~typepoint, :); %Onoff events are in the rows where typepoint is false
point_events = events(typepoint, :);  %point events are in the rows where typepoint is true

num_onoff = sum(~typepoint); %count the number of 1's in the logical array to get number of onoffs or points
num_point = sum(typepoint);

onoff_default_colors = 'rbgmck'; %setting the default colors
point_default_colors = 'ox+sd*';

onoff_colors = mod(0:num_onoff-1,numel(onoff_default_colors)) + 1; 
point_colors = mod(0:num_point-1,numel(point_default_colors)) + 1; 
% Assign an integer from 1 to the number of default colors to each slot in 
% onoff_colors and point_colors. Do this by starting with an array
% 0:num-1, then mod it by the number of defaults. Add 1 to it so that the
% numbers range from 1:num.

onoff_colors = onoff_default_colors(onoff_colors)';
point_colors = point_default_colors(point_colors)';
% Use the integer indices generated above to reference the default
% character arrays. The result will be a row vector of characters,
% transpose it to get a default column vector of characters.

onoff_offsets = 1:num_onoff; %Default offsets
point_offsets = 1:num_point; 

labels = {}; %Default labels are an empty array.
use_axis = NaN; %default axis is NaN, flag to make a new one.

while(numel(varargin) >= 1) %Treat varargin as a queue. As long as there are elements to pop off, keep going.
    if ischar(varargin{1}) %If its a char, it must be the colors character array.
        if any(size(varargin{1}) == 1) %If its a 1-dimensional vector, 
            if (size(varargin{1}, 2) ~= 1) %then check if its a column vector. If it isnt, transpose it.
                varargin{1} = varargin{1}';
            end
            onoff_colors = varargin{1}(~typepoint); %Since we have a column vector, we can just use typepoint
            point_colors = varargin{1}(typepoint);  %as a logical index along the one dimension.
        else
            onoff_colors = varargin{1}(~typepoint,:); %It is a matrix. use typepoint only along rows, 
            point_colors = varargin{1}(typepoint,:);  %keep each row together.
        end
    elseif isnumeric(varargin{1}) || all(ishandle(varargin{1})) % added the OR 6/3/16 CRG
        if numel(varargin{1})==1 && all(ishandle(varargin{1}))
            %If it is a scalar and a handle, it must be an axis to use.
            use_axis = varargin{1};
        elseif all(floor(varargin{1}) == varargin{1})
            onoff_offsets = varargin{1}(~typepoint); %It's the offset array, divide it using typepoint.
            point_offsets = varargin{1}(typepoint);  
        elseif numel(varargin{1}) == 1
            warning('Discarding scalar argument. It looks like you were trying to pass an axes but it is invalid.');
        end
    elseif iscellstr(varargin{1})
        labels = varargin{1};   %labels gets the cell string.
        labels = [labels(~typepoint) labels(typepoint)]; %sort it so that onoffs are first
    else
        warning('An invalid argument was passed to TSraster -- Skipping.');
    end
    varargin(1) = []; %pop varargin(1) off, so varargin{2} takes its place, and keep whileing.
end

onoff_handles = nan(1,num_onoff);%We need to collect handles for each graphed object in order to
point_handles = nan(1,num_point);%pass them to the legend function.

offset_values = linspace(0,.2,max([onoff_offsets point_offsets]));
% offset_values takes a linear spacing from 0 to .2. The number of entries
% is the maximum offset for any event. The actual y value offset is indexed
% from this array using the offset for the event, ensuring that all offset
% values are evenly spaced from 0 to .2.

[matches,bindings] = TSmatch(tsdata,trialdef);
% Run tsmatch against tsdata using the trialdef.

numtrials = numel(bindings);

% if isnan(use_axis)
%     figure_handle = figure;
%     use_axis = gca;
% else
%     figure_handle = get(use_axis,'Parent');
%     figure(figure_handle);
%     axes(use_axis);
%     cla reset;
% end   % Replaced with code below 6/3/16 CRG
if ishandle(use_axis)
    figure_handle = get(use_axis,'Parent');
    figure(figure_handle);
    axes(use_axis);
    cla reset;
else
    figure_handle = figure;
    use_axis = gca;
end
if numtrials < 1 
    return; 
end

hold on;

trialrows = zeros(numtrials,2);
for i = 1:numel(bindings)
    trialrows(i,1) = bindings{i}(1);
    trialrows(i,2) = bindings{i}(end);
end
% bindings{i}(1) is the starting row of the i'th trial
% bindings{i}(end) is the ending row of the i'th trial
% trialrows now contains an N x 2 matrix where N is the number of trials.
% The first column contains the starts of the trials, the second column
% contains the ends of the trials.

startingstate = zeros(1,numtrials);
% preallocate the starting state variable

for e = 1:num_onoff
    on_row = find(tsdata(:,2) == onoff_events(e,1));
    off_row = find(tsdata(:,2) == onoff_events(e,2));
    %on_row now is the vector of row indexes of all on events in the tsdata
    %off_row contains the row indexes of all off events.
    %These are recomputed every time we start the next onoff event.

    
    % After this if statement and for loop, startingstate(T) will indicate
    % whether the state of this event at the start of trial T is ON (true)
    % OFF (false) or the same as at the end of trial T-1 (NaN).
    %
    % This is done by iterating over the ITI's before each trial and seeing
    % whether an on or an off appears last. If an on appears most recently
    % then the starting state for this trial is on. If an off appears most
    % recently, then the starting state is off.
    
    most_recent_on_rows = on_row(on_row <= trialrows(1,1));
    % Gets only the indices less than the start index of the first trial.
    
    if isempty(most_recent_on_rows) 
        startingstate(1) = false; 
    else 
        most_recent_off_rows = off_row(off_row <= trialrows(1,1));
        if isempty(most_recent_off_rows) startingstate(1) = true;
        else
            startingstate(1) = most_recent_on_rows(end) > most_recent_off_rows(end);
        end
    end
    % The logic is different here from in the for loop. This is because we
    % know that the session starts with all signals off. So, if no on rows
    % are found, it doesnt matter if off_rows are empty or not, it has to
    % start off. When we are in the for loop, we have to check if there are
    % any off signals also. If there are no offs or ons in the ITI, then
    % the state at the start of the trial is the same as it was at the end
    % of the previous trial. 
    
    for t = 2:numtrials

        most_recent_on_rows = on_row((on_row <= trialrows(t,1)) & (on_row >= trialrows(t-1,2)));
        most_recent_off_rows = off_row((off_row <= trialrows(t,1)) & (off_row >= trialrows(t-1,2)));
        % Compute most recent indices for ons and offs during the ITI.
        
        if isempty(most_recent_on_rows) 
            if isempty(most_recent_off_rows)
                startingstate(t) = NaN; %if both are empty, starting state is unknown => NaN.
            else
                startingstate(t) = false; %If only the on is empty, starting state is off => false.
            end
        else 
            if isempty(most_recent_off_rows) 
                startingstate(t) = true; %If only the off is empty, starting state is on => true.
            else    
                startingstate(t) = most_recent_on_rows(end) > most_recent_off_rows(end);
                %If neither is empty, compare the end element of both
                %(which must be the maximum since these arrays are sorted
                %lists of indices).
            end 
        end 
    end
    
    % Now we have found starting states for all trials, lets iterate
    % through trials and find starts and ends. These will be plotted
    % immediately.
    
    state = false; %Session starts with event off.
    lastrow = 0;   %lastrow variable will hold the last found state change
    handle = NaN;  %handle for this event will default to NaN.
                   %it will be overwritten each time plot is called, we
                   %dont care since we only need 1 valid handle.
    
    for t = 1:numtrials
        trialstarttime = tsdata(trialrows(t,1),1); %this will be subtracted from all x-coordinates
        y = repmat(t + offset_values(onoff_offsets(e)), 1, 2); %y = t + offset value indexed using the offset argument. Repmat it so that there are 2 y's since we will have 2 x's.
        
        if ~isnan(startingstate(t)) 
            state = startingstate(t); %If its ~nan, set state to its value. If it is nan, let it keep the value it had when it ended the last trial.
        end
        
        if state %If state is on, create an artificial on signal at the start of trial.
            lastrow = trialrows(t,1);
        end
        
        trial_on_rows = on_row(on_row >= trialrows(t,1) & on_row <= trialrows(t,2));
        trial_off_rows = off_row(off_row >= trialrows(t,1) & off_row <= trialrows(t,2));
        %Get the row indices which are in bounds for this trial.
        
        on_idx = 1;  %We will create a queue of on signals and off signals.
        off_idx = 1; %These indices will move down the each of the queues 
                     %until one is exhausted.
        while (state && off_idx <= numel(trial_off_rows)) || (~state && on_idx <= numel(trial_on_rows)) 
        %If the state is on and there are off signals remaining or the state is off and there are on signals remaining, keep going.
        %This is because if it is on and we havent reached the end of the
        %off list, it means the event did not continue till the end of the
        %trial and we need to find out when exactly it did and Vice versa.
        
            if state
                while off_idx <= numel(trial_off_rows) && trial_off_rows(off_idx) < lastrow %If the state is on, then keep popping off the off queue until we run out or find one after the last state change, (must be an on signal)
                    off_idx = off_idx + 1;
                end
                
                if off_idx <= numel(trial_off_rows) %If we didnt just run out of elements, then we must have found one that works.
                    handle = plot(use_axis, tsdata([lastrow, trial_off_rows(off_idx)], 1) - trialstarttime, y, onoff_colors(e,:)); % Do the plot using lastrow and this row as the x coordinates (after converting them to times), use the colors and save the handle in handle.
                    state = false; % State is now off.
                    lastrow = trial_off_rows(off_idx); % The new lastrow is this off signal
                    off_idx = off_idx + 1; % Pop it off the off queue.

                    % sometimes even though the state is on, there are ON
                    % events occuring before the first OFF. These need to
                    % be eliminated, since if left alone, they will get
                    % cycled through on the next cycle and cause a fatal
                    % error since they will have occured before LASTROW.
                    while on_idx <= numel(trial_on_rows) && trial_on_rows(on_idx) < lastrow %If the state is off, then keep popping off the on queue until we run out or find one after the last state change, (must be an off signal)
                        on_idx = on_idx + 1;
                    end
                end
            else
                while on_idx <= numel(trial_on_rows) && trial_on_rows(on_idx) < lastrow %If the state is off, then keep popping off the on queue until we run out or find one after the last state change, (must be an off signal)
                    on_idx = on_idx + 1;
                end

                if (trial_on_rows(on_idx) >= lastrow) %If we didnt just run out of elements, then we must have found one that works.
                    state = true; % State is now on.
                    lastrow = trial_on_rows(on_idx); %The new lastrow is this on signal
                    on_idx = on_idx + 1; % Pop it off the on queue.
                end
            end
        end
        
        if state % If the trial ended with state on then draw a line from last row to the end of the trial.
            handle = plot(use_axis, tsdata([lastrow, trialrows(t,2)], 1) - trialstarttime, y, onoff_colors(e,:));
        end
    end
    onoff_handles(e) = handle(1); %handle(1) ensures only a single scalar handle is passed back.
end    

% After this for loop, all onoff's have been plotted, w/ handles accumulated.
% Move on to the point events now.

for e = 1:num_point
    
    handle = NaN; % handle defaults to NaN, as before.
    on_row = find(tsdata(:,2) == point_events(e,1)); %on_row contains indices of the point event.
    
    for t = 1:numtrials
        trialstarttime = tsdata(trialrows(t,1),1); %these values were used in the onoff for loop as well.
        y = t + offset_values(point_offsets(e));
        
        %Take the on_rows, restrict the range to the start and end of this
        %trial, then use them as row indices to the time column of tsdata
        %to convert the rows into times. Store in trial_on_times.
        trial_on_times = tsdata(on_row(on_row >= trialrows(t,1) & on_row <= trialrows(t,2)), 1);
        
        if ~isempty(trial_on_times)  %If we have at least one, plot it with the right settings, repmatting the y value so that the arrays are the same size, and saving the handle.
            handle = plot(use_axis, trial_on_times - trialstarttime, repmat(y,1, numel(trial_on_times)), point_colors(e,:)); %The e'th row of colors is passed.
        end
    end
    point_handles(e) = handle(1); %handle(1) ensures only a single scalar handle is passed back.
end

max_x = max(tsdata(trialrows(:,2), 1) -tsdata(trialrows(:,1), 1)); %max_x is the duration of the longest trial.

xlabel('Trial Time (s)') %label our axes
ylabel('Trial Number')
axis([0 max_x+5 0 numtrials+1]); %set the axes using 0 to max_x plus a little bit for the x, and 0 to num_trials + 1 for the y.

%eventsUsed = [~isnan(onoff_handles) ~isnan(point_handles)];
% handles entries that are NaN were never plotted. We dont want to pass
% these to the legend function. the events used variable commented out
% above used to be in the code but was removed since it was only used once.
% You can see how it was used below.

if ~isempty(labels)
    
legend([onoff_handles(~isnan(onoff_handles)) point_handles(~isnan(point_handles))]',...
    labels([~isnan(onoff_handles) ~isnan(point_handles)])');

end
% % =======
% function [figure_handle, use_axis] = TSraster_v3(tsdata, trialdef,events, varargin)
% % TSraster(TSDATA, TRIALDEF, EVENTS, ARG1, ARG2, ARG3, ARG4)
% %
% % 	Produces a raster plot of time stamped data. Trials and events must be identified and
% %   then the y axis indicates trial number (with the first trial on the bottom) and the x axis
% %   indicates time within each trial. Events that have duration (for example, head pokes) are 
% %   represented as colored lines spanning that duration. Point events (for example, feeding events)
% %   are represented as marked symbols at the appropriate time.
% %   By default, the different events are offset slightly along the y axis so that ovelaping events
% %   can be clearly seen.
% %
% % 	Arguments, Mandatory:
% %		TSDATA -	2-column matrix of standard TSdata.
% % 		TRIALDEF - 	A standard trial definition. Each line of the raster
% %                   belongs to a different match range resulting from a
% %                   TSmatch call on the TSdata and the trialdef match codes.
% %		EVENTS -	2-column matrix, each row indicating a start event code
% %                   and a stop event code. Point events are indicated by
% %                   putting a 0 in the second column. All of the events
% %                   passed in will be plotted. If start and stop codes are
% %                   present, a line will be plotted where the event is 
% %					happening. Each event's line will be given a different
% %					color. If the event is a point event, a different point
% %					marker will be used for each type of point event given.
% %
% % 	Arguments, Optional: May appear in any order as ARG1, ARG2, ARG3, ARG4.
% %		COLORS -	Character string, same length as EVENTS.
% %					Overrides the default coloring scheme. Each character
% %					will be passed to Matlab's plot function when the
% %					corresponding event type is drawn. 
% %
% %                   Example: 
% %                   If there are 2 start-stop events and 2 point events,
% %                   you might use 'rbx+'. This would plot the 2 start-stops
% %                   as red and blue, and the point events as X's and +'s.
% %					
% %                   See help plot for a full list of characters that can be
% %                   used. 
% %
% %                   If you wish to specify multiple characters for each
% %                   event, then colors should be a character matrix. In
% %                   that case there should be one row for each event, and
% %                   the corresponding row will be passed to plot.
% %
% %                   Example:
% %                   strvcat('r', 'b:', 'xg', '+y')
% %
% %                   If this string were passed, the blue line would be a
% %                   dotted blue line, the x's would be green, and the +'s
% %                   would be yellow. Using strvcat vertically concatenates
% %                   the strings, and pads them with spaces if they are
% %                   different lengths so you do not get errors.
% %
% %		OFFSETS  -	Row vector, same length as EVENTS.
% %					Indicated the vertical offset to be used for the
% %					events.  Multiple Events can be placed on the same line. 
% %                   Each element of offset needs to be a positive integer.
% %					1 signifies the bottom line of each trial. 
% %
% %                   The offset is not added to the y-coordinate, in fact
% %                   the actual shift is scaled down by the maximum offset
% %                   passed, so that offsets of [3 1 2] provide exactly the
% %                   same result as [6 2 4]. 
% %
% %                   By default,	each event is placed on seperate evenly
% %                   spaced lines. 
% %
% %		LABELS -	Cell Array of Character Strings. Same length as EVENTS.
% %					These will be used in the legend, to label each type of
% %					event. By default there is no legend.
% %
% %       AXES -      A handle to the axes to use. If this argument is
% %                   present, TSraster will not create a new figure and will
% %                   use this axes instead.
% %
% %  Returns:
% %       figure -    A handle to the figure that was used.
% %       axes -      A handle to the axes that was used.
% 
% % Assumptions in writing this code:
% %   Most of the tsdata is in trials -- ITIs have relatively less data
% %   No assumptions are made about the order of onoff signals
% %   Onoff signals do not compose most of the data -- it will be quicker to
% %   use find to operate on their indices than to search through the tsdata.
% 
% 
% typepoint = (events(:,2) == 0); %If the second element is a 0, it is a point event. Otherwise it is a onoff event.
% 
% onoff_events = events(~typepoint, :); %Onoff events are in the rows where typepoint is false
% point_events = events(typepoint, :);  %point events are in the rows where typepoint is true
% 
% num_onoff = sum(~typepoint); %count the number of 1's in the logical array to get number of onoffs or points
% num_point = sum(typepoint);
% 
% onoff_default_colors = 'rbgmck'; %setting the default colors
% point_default_colors = 'ox+sd*';
% 
% onoff_colors = mod(0:num_onoff-1,numel(onoff_default_colors)) + 1; 
% point_colors = mod(0:num_point-1,numel(point_default_colors)) + 1; 
% % Assign an integer from 1 to the number of default colors to each slot in 
% % onoff_colors and point_colors. Do this by starting with an array
% % 0:num-1, then mod it by the number of defaults. Add 1 to it so that the
% % numbers range from 1:num.
% 
% onoff_colors = onoff_default_colors(onoff_colors)';
% point_colors = point_default_colors(point_colors)';
% % Use the integer indices generated above to reference the default
% % character arrays. The result will be a row vector of characters,
% % transpose it to get a default column vector of characters.
% 
% onoff_offsets = 1:num_onoff; %Default offsets
% point_offsets = 1:num_point; 
% 
% labels = {}; %Default labels are an empty array.
% use_axis = NaN; %default axis is NaN, flag to make a new one.
% 
% while(numel(varargin) >= 1) %Treat varargin as a queue. As long as there are elements to pop off, keep going.
%     if ischar(varargin{1}) %If its a char, it must be the colors character array.
%         if any(size(varargin{1}) == 1) %If its a 1-dimensional vector, 
%             if (size(varargin{1}, 2) ~= 1) %then check if its a column vector. If it isnt, transpose it.
%                 varargin{1} = varargin{1}';
%             end
%             onoff_colors = varargin{1}(~typepoint); %Since we have a column vector, we can just use typepoint
%             point_colors = varargin{1}(typepoint);  %as a logical index along the one dimension.
%         else
%             onoff_colors = varargin{1}(~typepoint,:); %It is a matrix. use typepoint only along rows, 
%             point_colors = varargin{1}(typepoint,:);  %keep each row together.
%         end
%     elseif isnumeric(varargin{1}) 
%         if numel(varargin{1})==1 && all(ishandle(varargin{1}))
%             %If it is a scalar and a handle, it must be an axis to use.
%             use_axis = varargin{1};
%         elseif all(floor(varargin{1}) == varargin{1})
%             onoff_offsets = varargin{1}(~typepoint); %It's the offset array, divide it using typepoint.
%             point_offsets = varargin{1}(typepoint);  
%         elseif numel(varargin{1}) == 1
%             warning('Discarding scalar argument. It looks like you were trying to pass an axes but it is invalid.');
%         end
%     elseif iscellstr(varargin{1})
%         labels = varargin{1};   %labels gets the cell string.
%         labels = [labels(~typepoint) labels(typepoint)]; %sort it so that onoffs are first
%     else
%         warning('An invalid argument was passed to TSraster -- Skipping.');
%     end
%     varargin(1) = []; %pop varargin(1) off, so varargin{2} takes its place, and keep whileing.
% end
% 
% onoff_handles = nan(1,num_onoff);%We need to collect handles for each graphed object in order to
% point_handles = nan(1,num_point);%pass them to the legend function.
% 
% offset_values = linspace(0,.2,max([onoff_offsets point_offsets]));
% % offset_values takes a linear spacing from 0 to .2. The number of entries
% % is the maximum offset for any event. The actual y value offset is indexed
% % from this array using the offset for the event, ensuring that all offset
% % values are evenly spaced from 0 to .2.
% 
% [matches,bindings] = TSmatch(tsdata,trialdef);
% % Run tsmatch against tsdata using the trialdef.
% 
% numtrials = numel(bindings);
% 
% if isnan(use_axis)
%     figure_handle = figure;
%     use_axis = gca;
% else
%     figure_handle = get(use_axis,'Parent');
%     figure(figure_handle);
%     axes(use_axis);
%     cla reset;
% end
% 
% if numtrials < 1 
%     return; 
% end
% 
% hold on;
% 
% trialrows = zeros(numtrials,2);
% for i = 1:numel(bindings)
%     trialrows(i,1) = bindings{i}(1);
%     trialrows(i,2) = bindings{i}(end);
% end
% % bindings{i}(1) is the starting row of the i'th trial
% % bindings{i}(end) is the ending row of the i'th trial
% % trialrows now contains an N x 2 matrix where N is the number of trials.
% % The first column contains the starts of the trials, the second column
% % contains the ends of the trials.
% 
% startingstate = zeros(1,numtrials);
% % preallocate the starting state variable
% 
% for e = 1:num_onoff
%     on_row = find(tsdata(:,2) == onoff_events(e,1));
%     off_row = find(tsdata(:,2) == onoff_events(e,2));
%     %on_row now is the vector of row indexes of all on events in the tsdata
%     %off_row contains the row indexes of all off events.
%     %These are recomputed every time we start the next onoff event.
% 
%     
%     % After this if statement and for loop, startingstate(T) will indicate
%     % whether the state of this event at the start of trial T is ON (true)
%     % OFF (false) or the same as at the end of trial T-1 (NaN).
%     %
%     % This is done by iterating over the ITI's before each trial and seeing
%     % whether an on or an off appears last. If an on appears most recently
%     % then the starting state for this trial is on. If an off appears most
%     % recently, then the starting state is off.
%     
%     most_recent_on_rows = on_row(on_row <= trialrows(1,1));
%     % Gets only the indices less than the start index of the first trial.
%     
%     if isempty(most_recent_on_rows) 
%         startingstate(1) = false; 
%     else 
%         most_recent_off_rows = off_row(off_row <= trialrows(1,1));
%         if isempty(most_recent_off_rows) startingstate(1) = true;
%         else
%             startingstate(1) = most_recent_on_rows(end) > most_recent_off_rows(end);
%         end
%     end
%     % The logic is different here from in the for loop. This is because we
%     % know that the session starts with all signals off. So, if no on rows
%     % are found, it doesnt matter if off_rows are empty or not, it has to
%     % start off. When we are in the for loop, we have to check if there are
%     % any off signals also. If there are no offs or ons in the ITI, then
%     % the state at the start of the trial is the same as it was at the end
%     % of the previous trial. 
%     
%     for t = 2:numtrials
% 
%         most_recent_on_rows = on_row((on_row <= trialrows(t,1)) & (on_row >= trialrows(t-1,2)));
%         most_recent_off_rows = off_row((off_row <= trialrows(t,1)) & (off_row >= trialrows(t-1,2)));
%         % Compute most recent indices for ons and offs during the ITI.
%         
%         if isempty(most_recent_on_rows) 
%             if isempty(most_recent_off_rows)
%                 startingstate(t) = NaN; %if both are empty, starting state is unknown => NaN.
%             else
%                 startingstate(t) = false; %If only the on is empty, starting state is off => false.
%             end
%         else 
%             if isempty(most_recent_off_rows) 
%                 startingstate(t) = true; %If only the off is empty, starting state is on => true.
%             else    
%                 startingstate(t) = most_recent_on_rows(end) > most_recent_off_rows(end);
%                 %If neither is empty, compare the end element of both
%                 %(which must be the maximum since these arrays are sorted
%                 %lists of indices).
%             end 
%         end 
%     end
%     
%     % Now we have found starting states for all trials, lets iterate
%     % through trials and find starts and ends. These will be plotted
%     % immediately.
%     
%     state = false; %Session starts with event off.
%     lastrow = 0;   %lastrow variable will hold the last found state change
%     handle = NaN;  %handle for this event will default to NaN.
%                    %it will be overwritten each time plot is called, we
%                    %dont care since we only need 1 valid handle.
%     
%     for t = 1:numtrials
%         trialstarttime = tsdata(trialrows(t,1),1); %this will be subtracted from all x-coordinates
%         y = repmat(t + offset_values(onoff_offsets(e)), 1, 2); %y = t + offset value indexed using the offset argument. Repmat it so that there are 2 y's since we will have 2 x's.
%         
%         if ~isnan(startingstate(t)) 
%             state = startingstate(t); %If its ~nan, set state to its value. If it is nan, let it keep the value it had when it ended the last trial.
%         end
%         
%         if state %If state is on, create an artificial on signal at the start of trial.
%             lastrow = trialrows(t,1);
%         end
%         
%         trial_on_rows = on_row(on_row >= trialrows(t,1) & on_row <= trialrows(t,2));
%         trial_off_rows = off_row(off_row >= trialrows(t,1) & off_row <= trialrows(t,2));
%         %Get the row indices which are in bounds for this trial.
%         
%         on_idx = 1;  %We will create a queue of on signals and off signals.
%         off_idx = 1; %These indices will move down the each of the queues 
%                      %until one is exhausted.
%         while (state && off_idx <= numel(trial_off_rows)) || (~state && on_idx <= numel(trial_on_rows)) 
%         %If the state is on and there are off signals remaining or the state is off and there are on signals remaining, keep going.
%         %This is because if it is on and we havent reached the end of the
%         %off list, it means the event did not continue till the end of the
%         %trial and we need to find out when exactly it did and Vice versa.
%         
%             if state
%                 while off_idx <= numel(trial_off_rows) && trial_off_rows(off_idx) < lastrow %If the state is on, then keep popping off the off queue until we run out or find one after the last state change, (must be an on signal)
%                     off_idx = off_idx + 1;
%                 end
%                 
%                 if off_idx <= numel(trial_off_rows) %If we didnt just run out of elements, then we must have found one that works.
%                     handle = plot(use_axis, tsdata([lastrow, trial_off_rows(off_idx)], 1) - trialstarttime, y, onoff_colors(e,:)); % Do the plot using lastrow and this row as the x coordinates (after converting them to times), use the colors and save the handle in handle.
%                     state = false; % State is now off.
%                     lastrow = trial_off_rows(off_idx); % The new lastrow is this off signal
%                     off_idx = off_idx + 1; % Pop it off the off queue.
% 
%                     % sometimes even though the state is on, there are ON
%                     % events occuring before the first OFF. These need to
%                     % be eliminated, since if left alone, they will get
%                     % cycled through on the next cycle and cause a fatal
%                     % error since they will have occured before LASTROW.
%                     while on_idx <= numel(trial_on_rows) && trial_on_rows(on_idx) < lastrow %If the state is off, then keep popping off the on queue until we run out or find one after the last state change, (must be an off signal)
%                         on_idx = on_idx + 1;
%                     end
%                 end
%             else
%                 while on_idx <= numel(trial_on_rows) && trial_on_rows(on_idx) < lastrow %If the state is off, then keep popping off the on queue until we run out or find one after the last state change, (must be an off signal)
%                     on_idx = on_idx + 1;
%                 end
% 
%                 if (trial_on_rows(on_idx) >= lastrow) %If we didnt just run out of elements, then we must have found one that works.
%                     state = true; % State is now on.
%                     lastrow = trial_on_rows(on_idx); %The new lastrow is this on signal
%                     on_idx = on_idx + 1; % Pop it off the on queue.
%                 end
%             end
%         end
%         
%         if state % If the trial ended with state on then draw a line from last row to the end of the trial.
%             handle = plot(use_axis, tsdata([lastrow, trialrows(t,2)], 1) - trialstarttime, y, onoff_colors(e,:));
%         end
%     end
%     onoff_handles(e) = handle(1); %handle(1) ensures only a single scalar handle is passed back.
% end    
% 
% % After this for loop, all onoff's have been plotted, w/ handles accumulated.
% % Move on to the point events now.
% 
% for e = 1:num_point
%     
%     handle = NaN; % handle defaults to NaN, as before.
%     on_row = find(tsdata(:,2) == point_events(e,1)); %on_row contains indices of the point event.
%     
%     for t = 1:numtrials
%         trialstarttime = tsdata(trialrows(t,1),1); %these values were used in the onoff for loop as well.
%         y = t + offset_values(point_offsets(e));
%         
%         %Take the on_rows, restrict the range to the start and end of this
%         %trial, then use them as row indices to the time column of tsdata
%         %to convert the rows into times. Store in trial_on_times.
%         trial_on_times = tsdata(on_row(on_row >= trialrows(t,1) & on_row <= trialrows(t,2)), 1);
%         
%         if ~isempty(trial_on_times)  %If we have at least one, plot it with the right settings, repmatting the y value so that the arrays are the same size, and saving the handle.
%             handle = plot(use_axis, trial_on_times - trialstarttime, repmat(y,1, numel(trial_on_times)), point_colors(e,:)); %The e'th row of colors is passed.
%         end
%     end
%     point_handles(e) = handle(1); %handle(1) ensures only a single scalar handle is passed back.
% end
% 
% max_x = max(tsdata(trialrows(:,2), 1) -tsdata(trialrows(:,1), 1)); %max_x is the duration of the longest trial.
% 
% xlabel('Trial Time (s)') %label our axes
% ylabel('Trial Number')
% axis([0 max_x+5 0 numtrials+1]); %set the axes using 0 to max_x plus a little bit for the x, and 0 to num_trials + 1 for the y.
% 
% %eventsUsed = [~isnan(onoff_handles) ~isnan(point_handles)];
% % handles entries that are NaN were never plotted. We dont want to pass
% % these to the legend function. the events used variable commented out
% % above used to be in the code but was removed since it was only used once.
% % You can see how it was used below.
% 
% if ~isempty(labels)
%     
% legend([onoff_handles(~isnan(onoff_handles)) point_handles(~isnan(point_handles))]',...
%     labels([~isnan(onoff_handles) ~isnan(point_handles)])');
% 
% end

