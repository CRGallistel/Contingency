% TSMATCH Searches TSdata for matches to matchcode combinations.
%   TSMATCH (TSDATA, MATCHCODES) searches the TSDATA for matches to
%   matchcode combinations specified in matchcodes. Works like a search
%   engine or a regular expression engine. Match codes are row vectors of
%   TS event codes which represent a search query. They specify a sequence
%   of codes which must appear in order but not necessarilly next to
%   eachother. For example [17 11 12] would search for the code 17 followed 
%   by the code 11 followed by the code 12 in succession in the data. Match
%   codes can also be more complicated. If you specify a negative code,
%   then that will signify that the code is not allowed to appear in that
%   position. For example [17 -13 12] would search for the code 17 followed
%   by 12, without a 13 in the middle. 
%
%   You can specify multiple match combinations at once using a cellarray
%   of row vectors. The results will be collated together so that none of
%   the returned matches are overlapping regions.
%   
%   TSMATCH returns 2 outputs, match and bindings. Match is an array
%   of length equal to the number of matches found. The number at each
%   index tells which matchcode set was matched, using the indexes of those 
%   sets when they were passed in in the MATCHCODES cell array. Bindings is
%   a cell array of row vectors, where each row vector is the row index of 
%   the positive codes that appeared in that match. 
%
%   All matches that are returned are guaranteed to be non-overlapping and
%   in sequential order. However, starting and ending indices may be shared
%   by adjacent matches. When collating the results from 2 or more 
%   matchcode arguments, preference is given to those that terminate
%   earliest without overlapping. For those that end at the same time, the
%   tie is given to the matchcode that appeared first in the cell array.
%
%   You can change the rules for determining priority in overlapping
%   matches by using the optional FLAGS argument. By default the ending
%   codes are compared, and ties are broken by giving priority to codes
%   defined earlier in the matchcodes cell array. If the character 's' is
%   present in the FLAGS string, then the starting codes will be compared
%   instead of the ending codes. The difference here is subtle; essentially
%   the most important change is the way that matches are handled when one
%   range completely encloses another range. In normal mode, the inside
%   match would beat the outside match because it ends earlier. In 's'
%   mode the outside match would beat the inside match. If this is the 
%   behavoir that you want then you should use 's' mode. Other modes may be
%   introduced in the future.
%
%   Examples:
%   [match, bindings] = TSmatch(tsdata, {[7 2]});
%       finds all places in tsdata where a 7 is followed eventually by a 2.
%       bindings is a cellarray of the indices where the 7 and 2 are found.
%
%   [match, bindings] = TSmatch(tsdata, {[7 1 2]});
%       finds all places in tsdata where a 7 is followed eventually by a 2,
%       with a 1 in between. bindings contains the indices of the 7's, 1's
%       and 2's.
%
%   [match, bindings] = TSmatch(tsdata, {[7 -3 2]});
%       finds all places in tsdata where a 7 is followed eventually by a 2,
%       with no 3's in between. bindings contains the indices of the 7's
%       and 2's.
%
%   [match, bindings] = TSmatch(tsdata, {[7 1 -3 2]});
%       finds all places in tsdata where a 7 is followed by 1 and then a 2,
%       with no 3's in between the 1 and 2. 3's may appear between the 7
%       and 1 however.
%
%   [match, bindings] = TSmatch(tsdata, {[7 -3 1 -3 2]});
%       finds all places in tsdata where a 7 is followed by 1 and then a 2,
%       with no 3's anywhere. 3's may not be between 7 and 1 or 1 and 2.
%
%   [match, bindings] = TSmatch(tsdata, {[7 7]});
%       finds all regions between two 7's and stores the starts and ends in
%       bindings. 7's are recycled when you do this; the same seven will
%       serve as the start of one match and the end of the one before it.
%
%   [match, bindings] = TSmatch(tsdata, {[0 7]});
%       The code 0 is a metacharacter in TSmatch. It matches the first
%       code in the data and only that code. The matchcode above will
%       return 1 match starting at the first code and ending at the first
%       7.
%
%   [match, bindings] = TSmatch(tsdata, {[7 inf]});
%       The code inf is a metacharacter in TSmatch. It matches the last
%       code in the data and only that code. The matchcode above will
%       return 1 match starting at the first 7 and ending at the last code
%       in the data.
%   
%   More Examples:
%       For the following tsdata:
%
%          2    17
%          5    11
%          6    13
%          8    11
%         13    12
%         22    17
%         24    11
%         28    13
%         29    11
%         30    12
%
%       [match, bindings] = TSmatch(tsdata, {[17 12]})
%           match = [1 1]
%           bindings = {[1 5] [6 10]}
%
%       [match, bindings] = TSmatch(tsdata, {[17 11 12]})
%           match = [1 1]
%           bindings = {[1 2 5] [6 7 10]}
%
%       [match, bindings] = TSmatch(tsdata, {[17 13 12]})
%           match = [1 1]
%           bindings = {[1 3 5] [6 8 10]}
%
%       [match, bindings] = TSmatch(tsdata, {[17 -11 13 12]})
%           match = []
%           bindings = {}
%
%       [match, bindings] = TSmatch(tsdata, {[17 11 -13 12]})
%           match = [1 1]
%           bindings = {[1 4 5] [6 9 10]}
%
%       [match, bindings] = TSmatch(tsdata, {[17 -13 11 -13 12]})
%           match = []
%           bindings = {}
%
%
%       See also TSparse, TSedit, TStrialstat, TSdefinetrial

%
%                   ***** PROGRAMMER NOTES HERE *****
%
% Last Modified: Chris Beck, 8/28/05
%
% Implementation notes:
%   TSmatch now uses a very different implementation from what it used to
%   use. It employs a helper function to find bindings for each matchcode
%   one at a time. It then merges these bindings to ensure that there are
%   no overlaps.
%
%   TSmatch_helper:
%       First thing that is new is that poscodes and negcodes are broken up
%       into different storage structures. Poscodes are simply an array
%       containing the positive codes in the matchcode. Negcodes is a cell
%       array of the same size. Each cell contains an array of codes which
%       are not allowed to appear before the corresponding poscode.
%
%       Binding forms a stack structure of the current bindings as we loop
%       over the TSdata. It is an array preallocated to the same size as
%       the number of poscodes. lbinding is the number of "real" elements
%       that it holds. When lbinding == lpos, we have matched all the
%       poscodes and we dump them all into bindings{end+1}, which is
%       returned at the end.
%
%       Whenever a poscode is encountered, we add it to binding array and
%       then continue our sequential search, with lbinding incremented so
%       that now we are searching for the next poscode.
%
%       Whenever a negcode is encountered, we must pop off the last binding
%       and move our location back to where we found the now disqualified
%       poscode. This is important, because we do not look for or keep
%       track of negcodes other than the ones we are immediately concerned
%       with. Example: 
%
%       matchcode = [1 -4 2 -5 3]
%       tsdata =
%           1
%           2
%           4
%           5
%           2
%           3
%
%       TSmatch finds the 1, then the 2. When it gets to the 4, it ignores
%       it because the next poscode is 3 and its negcode set is [5]. When
%       it sees the 5, it pops off the binding and now loc moves back to
%       where it found that 2 that just got popped off. Now it sees the 4
%       and its looking for a new 1. No matches are found, which is the
%       right answer. 
%
%       If we do not jump back to the 2, and just stay at the 5 looking for
%       a new 2, we would find the 2 and the 3 and report a match, even
%       though that is clearly not a match. That is why we have to pop off
%       the bindings and jump back rather than just continue on
%       sequentially.
%
%       Whenever a binding is completed, we jump back to where we found the
%       first binding. This is important for when we merge the results of
%       TSmatch_helper calls, and will be explained in greater detail
%       later. It does seem strange that we do this, because it means that
%       TSmatch_helper *will* return overlapping bindings:
%
%       matchcode = [1 2 3]
%       tsdata =
%           7
%           1
%           4
%           1
%           2
%           3
%
%           In this case, TSmatch_helper will return 2 matches [2 5 6] and
%           [4 5 6]. This is desired behavoir though, and it will be sorted
%           out by TSmatch afterwards.
%
%   TSmatch:
%       After collecting all of these bindings, they are "merged" together,
%       not unlike the way sorted arrays are merged in the mergesort
%       algorithm. The exact method varies slightly depending on which flag
%       you are using. Essentially, each of the cell arrays of bindings
%       returned by TSmatch_helper is treated as a queue. As long as the
%       "someremaining" flag is true, we perform the following loop. 
%
%       First, make sure the leading candidate from each sorted queue is
%       not empty, and that the first row number from that binding is not <
%       the currow variable, which is the end row of the last binding we
%       admitted. Using currow ensures no overlaps. Anything that is on the
%       wrong side of currow is deleted.
%
%       During this time we also initialize the "earliestSoFar" variable to
%       the first nonempty queue.
%
%       Second, check each of the remaining queues against the
%       "earliestSoFar" queue. If their leader is nonempty and its end row
%       is less than the "earliestSoFar"'s end row (default version) or,
%       for 's' flag mode, if its start row is less than the
%       "earliestSoFar"'s start row, then that queue becomes the new 
%       earliestSoFar. Finally, having gone through all the queues, we take
%       the earliestSoFar, append its index number to the match array and
%       its binding to the bindings cell array, delete that binding, and
%       update currow.
%
%   Guarantees Made By These Functions:
%       There are a few guarantees that must be made by TSmatch_helper for
%       this approach to work. One of them is that the set of starting
%       indices for each of the bindings returned by TSmatch_helper must be
%       sorted ascending. This is necessary for 's' flag to work, and for
%       the currow system to work. Also, the set of ending indices must be
%       sorted ascending as well. If this is not met, then default mode
%       will not work. TSmatch_helper does make all of these guarantees.
%
%       For starting indices, it is clearly true, because nothing can make
%       loc go backwards behind a previous match for the starting binding.
%       Even when you pop off a negative code on the first binding, it just
%       goes on normally, and then loc is increased by 1. And when you
%       complete a match, it only goes right back to the first binding, not
%       behind it, and then loc is increased by 1. So the starting bindings
%       will always be sorted ascending. 
%
%       For ending indices, the reason why it is sorted is not quite so
%       obvious. Certainly nothing stops the ending loc from going
%       backwards. However, we know that starting indices must be
%       ascending, so if ever there was an ending index that was
%       descending, that would mean that we would have a pair of nested
%       matches for a single matchcode:
%
%           [   .
%           [   .   ]
%           [   .   ]
%           [   .   ]
%           [   .   ]
%           [   .
%           [   .
%               .
%
%       This is impossible. If TSmatch could find the outside match, then
%       that would mean that in the span of TSdata from the start of the
%       outside match to the start of the inside match, a) there is no
%       sequence of codes in that span that would totally kill off the
%       binding and cancel the start code for the outside match, and b)
%       there is no sequence of codes in that span that would complete the
%       match, because otherwise that is the match that would have been
%       returned, not the outside match that was returned.
%
%       So, when TSmatch is done with that span and hits the the starting
%       code for the inside match, it already has partially completed the
%       outside match. For the span of TSdata where we have hypothesized
%       the inside match, we know that there is at least one example of
%       every poscode that is not disqualified. So, when our partially
%       completed match eventually meets up with these codes, it MUST find
%       the codes that it needs to be completed within that span. In fact,
%       it MUST end on the ending code of the inside code. So,
%       TSmatch_helper would in fact return this: 
%
%           [   .
%           [   .   ]
%           [   .   ]
%           [   .   ]
%           [   .   ]
%               .
%               .
%               .
%
%       So, while it is possible, and in fact frequent for TSmatch_helper
%       to return nested matches of that sort, where the ends are the same
%       and the starts are ascending, (we noted one case above in the
%       examples), it is impossible for the ending indices to ever decrease
%       between 2 successive matches.
%
%       At the moment, this guarantee can be met because we have a
%       well-defined setup of what constitutes a match code. There is only
%       one possible sequence of poscodes that works, and for each single
%       code, either it is disqualified or it isnt. The guarantee above
%       will still work if we allow "or"ing of poscodes: e.g., if we have a
%       matchcode [1 (2 3) 4], presumably where the ( and ) are
%       metacharacter integers, so that [1 2 4] would be a match and [1 3
%       4] would also be a match. 
%
%       However, if we allowed people to do things like have the 2 in that
%       case have one neg code and the 3 have a different neg code, e.g., 
%       [1 2 6 4] would be allowed and [1 3 5 4] would be allowed, but [1 2
%       5 4] would not and [1 3 6 4] would not, then I believe that the
%       argument above would no longer hold up, and it would become
%       possible to have situations with nested matches resulting from
%       TSmatch_helper.
%
%       If we do adopt modifications that destroy these and the other
%       underlying postconditions assumed by this implementation, then we
%       will have to either adopt a totally new implementation scheme, or
%       perform sorting of each of the queues before "merging" them to
%       guarantee that postcondition. Serious investigation needs to be
%       done to ensure that these postcondition guarantees are not
%       overlooked when future changes are made to this function.

function [match, bindings] = TSmatch(tsdata, varargin)

if numel(varargin) == 1
    matchcodes = varargin{1}; %If only 1, then either they used a single [] match code or they used a cell array to group several matchcodes
else
    matchcodes = varargin; %If more, then they used multiple [] matchcodes without {}.
end

match = [];
bindings = {};
if isempty(tsdata);return;end % added by CRG 11/8/11


data = tsdata; %Make a copy of TSdata where timestamps are overwritten with row numbers
data(:,1) = 1:size(tsdata,1); %Perform the timestamp overwrite

flags = ''; %flags defaults to empty string
    
if (iscell(matchcodes))
    if (length(matchcodes) > 1)
    	if ischar(matchcodes{end})      %if we have multiple matchcodes, check if the end is char, then it is the string of flags
    		flags = matchcodes{end};
    		matchcodes(end) = [];  
    	end
        binds{length(matchcodes)} = []; %binds will hold the queues of match_helper outputs.
        for i = 1:length(matchcodes)
            binds{i} = match_helper(data, matchcodes{i});
        end
        
        %reconcile bindings
        % This is done using the same concept as merge sort. The current
        % row is maintined in a variable. 2 passes continue until each
        % index of binds is empty. In the first pass, the front of each
        % bind index is deleted until a bind is found in that index which
        % starts at or later than the current row, or until that list is
        % exhausted. In the second pass, the survivors are compared to find
        % which is has the lowest start index. Ties are given to the which
        % ever occurs first. * This mode is enabled by 's' in the flag
        
        if any('s' == flags)
             
        % Original version of merge: Criterion is the position of first code
        % only. Earliest wins, tie goes to order of appearance in
        % matchcodes. This is now triggered by 's' flag, for 'start'.
        %
        % So for the TSdata 1,2,3,4:
        % [1 2] > [3 4]  -- No overlap
        % [1 3] > [2 4]  -- Overlap, [1 3] first code appears earlier than [2 4] first code
        % [1 4] > [2 3]  -- Overlap, [1 4] first code appears earlier than [2 3] first code
        % [1 3] > [2 3]  -- Overlap, [1 3] first code appears earlier than [2 4] first code
        % [1 2] ? [1 3]  -- Determined by order of appearance in cell array
        
        
        currow = 1;
        someRemaining = true;
        
        while (someRemaining)
            someRemaining = false;
            earliestSoFar = -1;
            for i=1:length(binds)
                if ~isempty(binds{i}) && ~isempty(binds{i}{1})
                    while ~isempty(binds{i}) && ~isempty(binds{i}{1}) && (binds{i}{1}(1) < currow)
                        binds{i}(1) = [];
                    end
                    if ~isempty(binds{i}) && ~isempty(binds{i}{1})
                        someRemaining = true;
                        if earliestSoFar == -1
                            earliestSoFar = i;
                        end
                    end
                end
            end
            
            if (someRemaining)
                i = earliestSoFar;
                while i <= length(binds)
                    if ~isempty(binds{i}) && ~isempty(binds{i}{1}) && (binds{i}{1}(1) < binds{earliestSoFar}{1}(1))
                        earliestSoFar = i;
                    end
                    i = i + 1;
                end
                match(end+1) = earliestSoFar;
                bindings{end+1} = binds{earliestSoFar}{1};
                binds{earliestSoFar}(1) = [];
                currow = bindings{end}(end);
            end
        end

        else
        
        % New version of merge: Criterion is the position of last code. 
        % Earliest wins, tie goes to order of appearance in matchcodes cell
        % array. This is default mode.
        %
        % So for the tsdata 1,2,3,4:
        % [1 2] > [3 4]  -- No overlap
        % [1 3] > [2 4]  -- Overlap, [1 3] last code appears earlier than [2 4] last code
        % [1 4] < [2 3]  -- Overlap, [2 3] last code appears earlier than [1 4] last code
        % [1 2] > [1 3]  -- Overlap, [1 2] last code appears earlier than [1 3] last code
        % [1 3] ? [2 3]  -- Determined by order of appearance in cell array
        
        currow = 1;
        someRemaining = true;
        
        while (someRemaining)
            someRemaining = false;
            earliestSoFar = -1;
            for i=1:length(binds)
                if ~isempty(binds{i}) && ~isempty(binds{i}{1})
                    while ~isempty(binds{i}) && ~isempty(binds{i}{1}) && (binds{i}{1}(1) < currow)
                        binds{i}(1) = [];
                    end
                    if ~isempty(binds{i}) && ~isempty(binds{i}{1})
                        someRemaining = true;
                        if earliestSoFar == -1
                            earliestSoFar = i;
                        end
                    end
                end
            end
            
            if (someRemaining)
                i = earliestSoFar;
                while i <= length(binds)
                    if ~isempty(binds{i}) && ~isempty(binds{i}{1}) && (binds{i}{1}(end) < binds{earliestSoFar}{1}(end))
                        earliestSoFar = i;
                    end
                    i = i + 1;
                end
                match(end+1) = earliestSoFar;
                bindings{end+1} = binds{earliestSoFar}{1};
                binds{earliestSoFar}(1) = [];
                currow = bindings{end}(end);
            end
        end
        end
    else % Simple case, only one set of bindings to "merge"
        bindings = match_helper(data, matchcodes{1});
        i=2;
        while (i <= length(bindings))
            if bindings{i}(1) < bindings{i-1}(end)
                bindings(i) = [];
            else
                i = i + 1;
            end
        end
        match(1:length(bindings)) = 1;
    end
else %Simple case, again.
    bindings = match_helper(data, matchcodes);
    i = 2;
    while (i <= length(bindings))
        if bindings{i}(1) < bindings{i-1}(end)
            bindings(i) = [];
        else
            i = i + 1;
        end
    end
    match(1:length(bindings)) = 1;
end


function bindings = match_helper(tsdata, matchcodes)

binding = [];   %binding keeps track of the current array of bindings for the current match
lbinding = 0;   %binding will be preallocated later, lbinding keeps track of which is the next index of binding to be set. It is the true length of the binding array.
bindings = {};  %bindings is where the binding array goes when it is finished. bindings{end+1} = binding is what is used to add this set to the end.

eqTSstart = matchcodes == TSstart;      %Check to see if TSstart or TSend
eqTSend = matchcodes == TSend;         %are present in these codes

if any(eqTSstart) || any(eqTSend)      %If either were, then replace with
    matchcodes(eqTSstart) = 0;          %0 and inf metacharacters, and 
    matchcodes(eqTSend) = inf;
end

zeroispresent = false;
infispresent = false;
LTneg10 = matchcodes < -10;              %added 8/10/05 to partly vectorize this
metachar = matchcodes < 11 & matchcodes ~= 0;

%Matchcodes are broken up into poscodes and negcodes. This is more
%efficient then the old implementation.

poscodes = [];                       % set poscodes for this match blank
negcodes = {[]};                     % set negcodes for this match blank
for x = 1:length(matchcodes)         % for each code
    if LTneg10(x)                    % if neg
        negcodes{end} = [negcodes{end} -matchcodes(x)];    %add it to the most recent negcode array
    else
        if metachar(x)               %code is a metacharacter, -10 to 10 and not 0
            error('TSmatch:reservedCharacter',['Found metacharacter in matchcode that is not yet defined: ' num2str(matchcodes(x)) ...
                '\nCodes from -10 to 10 are reserved characters which may have special meaning in the future.\nAs of 8/28/05 this code is undefined.\n']);
        else
            poscodes(end+1) = matchcodes(x);                      %next poscode equals this code
            negcodes{end+1} = [];                                    %its correponding negcode array is empty
            if matchcodes(x) == 0                                    %Added 6/30/05, needed to make sure keep track of zero and inf metacharacters,
                zeroispresent = true;                                %   so that below, when unimportant TSdata entries are removed, we know if we have to keep
            elseif isinf(matchcodes(x))                              %   the first and last entries of TSdata, since these may be needed.
                infispresent = true;
            end
        end
    end
end

importantlines = ismember2(tsdata(:,2), abs(matchcodes)); %Make a logical array of lines that will be kept in the TSdata

if (zeroispresent)                          %added 6/30/05, makes sure that first line is kept if a zero was found above
    importantlines(1) = true;
end
if (infispresent)                           %added 6/30/05, makes sure that last line is kept if a inf was found above
    importantlines(end) = true;
end

tsdata = tsdata( importantlines, :);   %remove tsdatas that arent in the codes we care about

lpos = length(poscodes);               %lpos will keep track of how many poscodes there are, and how many bindings we need to declare a match
sizetsdata = size(tsdata, 1);          %number of rows of tsdata

binding(lpos) = 0; %binding should be as long as lpos, and it will be 
                   %preallocated to this size. lbinding will be used to
                   %keep track of how long it really is, rather than using
                   %end+1 and end to resize it. 

loc = 1;          %loc is the current row
while (loc <= sizetsdata)   %while we have not run out of rows,
    ln = tsdata(loc, 2);        %ln gets current event code
    if any(ln == negcodes{lbinding + 1})    %if ln matches any of these neg codes,
        loc = binding(lbinding);            %pop off a binding into loc variable: this is very important, see notes for explanation

        lbinding = lbinding - 1;            %lbinding decreases by one since we popped one off
    else                                    %if no negcodes matches, check poscodes
        if (ln == poscodes(lbinding + 1))   %if it matches the next poscode, 
            lbinding = lbinding + 1;        %lbinding increases by one,
            binding(lbinding) = loc;        %push loc onto the stack
            if lbinding == lpos             %if we have maxed out, we have a match.
                loc = binding(1);           %standard code repeated below, loc gets the first binding
    
                bindings{end+1} = binding;  %and we pop all of them off into the bindings cell array
                lbinding = 0;               %now binding is empty  =>  lbinding = 0
            end
        elseif (loc == 1 && poscodes(lbinding + 1) == 0) %if we are at the start and next code is 0,
            lbinding = lbinding + 1;                     %then this one matches, lbinding increases by 1
            binding(lbinding) = loc;                     %push it on the stack
            if lbinding == lpos                          %if stack is now full, loc gets first binding
                loc = binding(1);                       
    
                bindings{end+1} = binding;               %add binding to bindings
                lbinding = 0;                            %binding is empty
            end
        elseif (loc == sizetsdata && isinf(poscodes(lbinding + 1))) %if we are at the end and next code is inf,
            lbinding = lbinding + 1;                     %then this one matches, lbinding increases by 1
            binding(lbinding) = loc;                     %push it on the stack
            if lbinding == lpos                          %if stack is now full, loc gets first binding
                loc = binding(1);
    
                bindings{end+1} = binding;               %add binding to bindings
                lbinding = 0;                            %binding is empty
            end
        end
    end
    
    loc = loc + 1;  %each pass, increase loc by 1.
end

% Done.

% Map bindings onto tsdata row numbers; we need to do this since we took
% out unimportant lines at the beginning of this function.
for i=1:length(bindings)
    bindings{i} = tsdata(bindings{i}, 1)';
end

% We now have all the row bindings for this matchcode set. match_helper
% exits now, returns to TSmatch, which will reconcile all the bindings
% returned from the different calls to match_helper


% To make the ismember call go faster, I copied the code from the ismember
% function and removed alot of the extra cases that it supports that will
% not be used by TSmatch. This includes checking for strings and cell
% strings, etc.

function [tf] = ismember2(a,s)
%ISMEMBER True for set member.
%   ISMEMBER(A,S) for the array A returns an array of the same size as A
%   containing 1 where the elements of A are in the set S and 0 otherwise.
%   A and S can be cell arrays of strings.
%
%   ISMEMBER(A,S,'rows') when A and S are matrices with the same
%   number of columns returns a vector containing 1 where the rows of
%   A are also rows of S and 0 otherwise.
%
%   [TF,LOC] = ISMEMBER(...) also returns an index array LOC containing the
%   highest absolute index in S for each element in A which is a member of S
%   and 0 if there is no such index.
%
%   See also UNIQUE, INTERSECT, SETDIFF, SETXOR, UNION.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.23.4.3 $  $Date: 2004/04/16 22:07:48 $

%   Cell array implementation in @cell/ismember.m

numelA = numel(a);
numelS = numel(s);

  
  % Initialize types and sizes.
  
  tf = false(size(a));
  
  % Handle empty arrays and scalars.
  
  if numelA == 0 || numelS <= 1
    if (numelA == 0 || numelS == 0)
      return
      
    % Scalar A handled below.
    % Scalar S: find which elements of A are equal to S.
    elseif numelS == 1
      tf = (a == s);
      return
    end
  else
    % General handling.
    % Use FIND method for very small sizes of the input vector to avoid SORT.
    scalarcut = 5;  
    if numelA <= scalarcut
      for i=1:numelA
        tf(i) = any(a(i)==s(:));   % ANY returns logical.
      end
    else
      % Use method which sorts list, then performs binary search.            
      % Convert to double for quicker sorting, to full to work in C helper.
      a = double(a);
      
      s = double(s);

        % Find out whether list is presorted before sort
        % If the list is short enough, SORT will be faster than ISSORTED
        % If the list is longer, ISSORTED can potentially save time
        checksortcut = 1000;
        if numelS > checksortcut
          sortedlist = issorted(s(:));
        else
          sortedlist = 0;
        end 
        if ~sortedlist
          s = sort(s(:));
        end

      
      % Two C-Helper Functions are used in the code below:
      
      % ISMEMBC  - S must be sorted - Returns logical vector indicating which 
      % elements of A occur in S
      % ISMEMBC2 - S must be sorted - Returns a vector of the locations of 
      % the elements of A occurring in S.  If multiple instances occur,
      % the last occurrence is returned          
      
      % Check for NaN values - NaN values will be at the end of S,
      % but may be anywhere in A.
      
        % No NaN values, call ISMEMBC directly.
          tf = ismembc(a,s);

      
    end
  end
  
