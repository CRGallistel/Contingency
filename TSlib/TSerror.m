% TSERROR
%  

function TSerror(errorstring)

stack = dbstack('-completenames');

[thisfile calledfile callingfile] = stack.file;
[thisfun calledfun callingfun] = stack.name;
[thisline calledline callingline] = stack.line;

disp(sprintf('\n*** TS SYNTAX ERROR ***\n\n'));

temp = sprintf('<a href = "matlab: opentoline(''%s'',%d)">%s at line %d</a>',...
       callingfile, callingline,callingfun, callingline);
    % Note. Here we use the matlab opentoline function, which it
    % claims may not be supported in future versions. If it does dissapear,
    % then one can replace this line with the edit function. It does the same
    % thing but doesn't move to the offending line
    
    temp

disp(sprintf('A call was made in %s to %s with the arguments:',temp,calledfun));
disp(vars);
disp(sprintf('%s accepts the following input forms:',calledfun));



        
        