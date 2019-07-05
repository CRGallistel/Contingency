function Params = TSparameterarray(PA)
% GUI taking user through the setting of the experimental parameters in the
% parameter array PA, which must be a 21x2 cell array
%
%Syntax: Params = TSparameterarray(PA)

Params = PA;

if nargin <1
    display('21x3 cell array containing parameters to be set must be given in call')
    return
end

if ~iscell(PA) || size(PA,1)~=21 || size(PA,2)~=3
    
    display('Parameter array must by 21 x 3 cell array')
    return
end

while 1 % processing Dawn
    Dawn = input(sprintf(...
        '\nCurrent dawn is %s;\nto change it enter new military time (e.g. 14:30 or 01:30 or 00:00) ',...
        PA{2,2}),'s');
    
    if isempty(Dawn)
        break
        
    elseif length(Dawn)==5 && regexp(Dawn,'\d\d:\d\d')

        PA{2,2} = Dawn;
        DV = datevec(Dawn);
        PA{2,3} = 3600*DV(4) + 60*DV(5) + DV(6); % dawn in seconds
        
        display(sprintf('\nDawn (house lights on) will be at %s (= %d seconds past local midnight)\n',PA{2,2},PA{2,3}))
        break
        
    else
        
        display('Dawn time not correctly specified; must be in military format')
        
    end % 
    
end % while processing Dawn

while 1 % processing Dusk
    Dusk = input(sprintf(...
        '\nCurrent dusk is %s;\n to change it enter new military time(e.g. 14:30 or 01:30 or 00:00) ',...
        PA{3,2}),'s');
    
    if isempty(Dusk)
        break
        
    elseif length(Dusk)==5 && regexp(Dusk,'\d\d:\d\d')

        PA{3,2} = Dusk;
        DV = datevec(Dusk);
        PA{3,3} = 3600*DV(4) + 60*DV(5) + DV(6); % dusk in seconds
        
        display(sprintf('\n Dusk (house lights off) will be at %s (= %d seconds past local midnight)\n',PA{3,2},PA{3,3}))
        break
        
    else
        
        display('Dusk time not correctly specified; must be in military format')
        
    end % 
    
end % while processing Dusk

while 1 % processing start of early feeding phase
    FdPhase1 = input(sprintf(...
        '\nFirst feeding phase currently starts at %s;\n to change it enter new military time (e.g. 14:30 or 01:30 or 00:00) . \n To eliminate a feeding phase make start and stop times the same: ',...
        PA{4,2}),'s');
    
    if isempty(FdPhase1)
        break
        
    elseif length(FdPhase1)==5 && regexp(FdPhase1,'\d\d:\d\d')

        PA{4,2} = FdPhase1;
        DV = datevec(FdPhase1);
        PA{4,3} = 3600*DV(4) + 60*DV(5) + DV(6); % start of early feeding phase in seconds
        
        display(sprintf('\n 1st feeding phase will start at %s (= %d seconds past local midnight)\n',PA{4,2},PA{4,3}))
        break
        
    else
        
        display(sprintf('\nTime not correctly specified; must be in military format (e.g. 00:30)\n'))
        
    end % 
    
end % while processing start of early feeding phase

while 1 % processing stop of early feeding phase
    FdPhase1Stp = input(sprintf(...
        '\nEnd of early feeding phase is currently %s;\n to change it enter new military time, e.g. 14:30 or 00:00. \n To eliminate it make start and stop times the same: ',...
        PA{5,2}),'s');
    
    if isempty(FdPhase1Stp )
        break
        
    elseif length(FdPhase1Stp )==5 && regexp(FdPhase1Stp ,'\d\d:\d\d')

        PA{5,2} = FdPhase1Stp ;
        DV = datevec(FdPhase1Stp );
        PA{5,3} = 3600*DV(4) + 60*DV(5) + DV(6); % start of early feeding phase in seconds
        
        display(sprintf('\n 1st feeding phase will end at %s (= %d seconds past local midnight)\n',PA{5,2},PA{5,3}))
        break
        
    else
        
        display(sprintf('\nTime not correctly specified; must be in military format (e.g. 00:30)\n'))
        
    end % 
    
end % while processing stop of early feeding phase

while 1 % processing start of middle feeding phase
    FdPhase2 = input(sprintf(...
        '\nSecond feeding phase currently starts at %s;\n to change it enter new military time, e.g. 14:30 or 00:00. \n To eliminate it, make start and stop times the same: ',...
        PA{6,2}),'s');
    
    if isempty(FdPhase2)
        break
        
    elseif length(FdPhase2)==5 && regexp(FdPhase2,'\d\d:\d\d')

        PA{6,2} = FdPhase2;
        DV = datevec(FdPhase2);
        PA{6,3} = 3600*DV(4) + 60*DV(5) + DV(6); % start of early feeding phase in seconds
        
        display(sprintf('\n 2nd feeding phase will start at %s (= %d seconds past local midnight) \n',PA{6,2},PA{6,3}))
        break
        
    else
        
        display(sprintf('\nTime not correctly specified; must be in military format (e.g. 00:30)\n'))
        
    end % 
    
end % while processing start of middle feeding phase

while 1 % processing stop of middle feeding phase
    FdPhase2Stp = input(sprintf(...
        '\nEnd of 2nd feeding phase is currently %s;\n to change it enter new military time, e.g. 14:30 or 00:00. \n To eliminate it, make start and stop times the same: ',...
        PA{7,2}),'s');
    
    if isempty(FdPhase2Stp )
        break
        
    elseif length(FdPhase2Stp )==5 && regexp(FdPhase2Stp ,'\d\d:\d\d')

        PA{7,2} = FdPhase2Stp ;
        DV = datevec(FdPhase2Stp );
        PA{7,3} = 3600*DV(4) + 60*DV(5) + DV(6); % stop of middle feeding phase in seconds
        
        display(sprintf('\n 2nd feeding phase will end at %s (= %d seconds past local midnight) \n',PA{7,2},PA{7,3}))
        break
        
    else
        
        display(sprintf('\nTime not correctly specified; must be in military format (e.g. 00:30)\n'))
        
    end % 
    
end % while processing stop of middle feeding phase

while 1 % processing start of late feeding phase
    FdPhase3  = input(sprintf(...
        '\n3rd & last feeding phase currently starts at %s;\n to change it enter new military time, e.g. 14:30 or 00:00. \n To eliminate it, make start and stop times the same: ',...
        PA{8,2}),'s');
    
    if isempty(FdPhase3 )
        break
        
    elseif length(FdPhase3 )==5 && regexp(FdPhase3 ,'\d\d:\d\d')

        PA{8,2} = FdPhase3 ;
        DV = datevec(FdPhase3 );
        PA{8,3} = 3600*DV(4) + 60*DV(5) + DV(6); % start of early feeding phase in seconds
        
        sprintf('\n 2nd feeding phase will start at %s (= %d seconds past local midnight)\n',PA{8,2},PA{8,3})
        break
        
    else
        
        display(sprintf('\nTime not correctly specified; must be in military format (e.g. 00:30)\n'))
        
    end % 
    
end % while processing start of late feeding phase

while 1 % processing stop of late feeding phase
    FdPhase3Stp = input(sprintf(...
        '\nEnd of 3rd feeding phase is currently %s;\n to change it enter new military time, e.g. 14:30 or 00:00. \n To eliminate it make start and stop times the same: ',...
        PA{9,2}),'s');
    
    if isempty(FdPhase3Stp )
        break
        
    elseif length(FdPhase3Stp )==5 && regexp(FdPhase3Stp ,'\d\d:\d\d')

        PA{9,2} = FdPhase3Stp ;
        DV = datevec(FdPhase3Stp );
        PA{9,3} = 3600*DV(4) + 60*DV(5) + DV(6); % start of early feeding phase in seconds
        
        sprintf('\n 3rd & last feeding phase will end at %s (= %d seconds past local midnight)\n',PA{9,2},PA{9,3})
        break
        
    else
        
        display(sprintf('\nTime not correctly specified; must be in military format (e.g. 00:30)\n'))
        
    end % 
    
end % while processing stop of late feeding phase

while 1 % ITI
    
    ITI = input(sprintf(...
        '\nThe ITI in seconds (if there is one) is currently %d;\n if you want to change it, enter new value \n(<=10000) ',PA{10,2}));
    
    if isempty(ITI)
        break
    else
        PA{10,2}=ITI;PA{10,3}=ITI;
        break
    end
    
end


while 1 % p(switch)
    
    psw = input(sprintf(...
        '\nThe probability of a switch trial is currently %0.4f;\n if you want to change it, enter new value \n(0<=p<=1) ',PA{11,2}));
    
    if isempty(psw)
        break
    elseif (psw>=0) && (psw<=1)
        PA{11,2}=psw;PA{11,3} = psw*10000;
        break
    else
        display(sprintf('\np(switch) must be >=0 and <=1\n'))
    end
    
end

while 1 % p(short)
    
    ps = input(sprintf(...
        '\nThe probability of a short trial is currently %0.4f;\n if you want to change it, enter new value \n(0<=p<=1) ',PA{12,2}));
    
    if isempty(ps)
        break
    elseif (ps>=0) && (ps<=1)
        PA{12,2}=ps;PA{12,3} = ps*10000;
        break
    else
        display(sprintf('p(short) must be >=0 and <=1'))
    end
    
end

while 1 % Feed latency (or VI) on Hopper 1
    
    Fd1Lat = input(sprintf(...
        '\nThe expected number of secs to a feed on Hopper 1 is now %4.2f;\n if you want to change it, enter new value ',PA{13,2}));
    
    if isempty(Fd1Lat)
        break
    elseif (Fd1Lat>=0) && (Fd1Lat<=10000)
        PA{13,2}=Fd1Lat;PA{13,3} = Fd1Lat;
        break
    else
        display(sprintf('\nLatency must be >=0 and <=10000\n'))
    end
    
end
    
while 1 % Feed latency (or VI) on Hopper 2
    
    Fd2Lat = input(sprintf(...
        '\nThe expected number of secs to a feed on Hopper 2 is now %4.2f;\n if you want to change it, enter new value ',PA{14,2}));
    
    if isempty(Fd2Lat)
        break
    elseif (Fd2Lat>=0) && (Fd2Lat<=10000)
        PA{14,2}=Fd2Lat;PA{14,3} = Fd2Lat;
        break
    else
        display(sprintf('\nLatency must be >=0 and <=10000\n'))
    end
    
end


if strcmp('y',input('\nNext 4 parameters are unspecified. Do you want to specify 1 up to 4 additional parameters? [y/rtn] ','s'))
    
    r = 15;
    
    while 1
        
        NP = input('\nName of %dth new parameter? (If no further new parameters, hit rtn) ','s');
        
        if isempty(NP)
            break
        else
            PA{r,1} = NP;
        end
        
        if strcmp('y',input('\nIs its conventional/transparent value a string (e.g., 12:00)? ','y'))
            
            PA{r,2} = input('\nEnter string specifying conventional value: ','s');
            
            PA{r,3} = input('\nEnter corresponding number required by MedPC, e.g. 12*3600: ');
            
        elseif strcmp('y',input('\nIs it a probability? '))
            
            PA{r,2} = input('\nEnter p value: ');
            
            PA{r,3} = PA{r,2}*10000;
            
        elseif strcmp('y',input('\nIs it a latency or expected interval in seconds? [y/n] ','s'))
            
            PA{r,2} = input('\nEnter interval or temporal expectation in seconds: ');
            
            PA{r,3} = PA{r,2};
            
        else
            
            PA{r,2} = input('\nEnter Col 2 value in ParameterArray: ');
            
            PA{r,3} = input('\nEnter Col 3 value in ParamterArray: ');
            
        end
        
        r = r+1;
        
        if r > 18
            break
        end          
        
    end % while entering 4 unspecified parameters    
    
end % if there are new, that is, unspecified parameters

PA{19,2} = input('\nProtocol number (must be integer)? ');

PA{19,3} = PA{19,2};

PA{20,2} = input('\nInterval in minutes at which parameter array to be read by BKGRND: ');

PA{20,3} = PA{20,2};

PA{21,2} = input('\nVersion number for this parameter set in this session? (must be integer) ');

PA{21,3} = PA{21,2};

PAdisp = [cell(length(PA),1) PA];

PAdisp{1,1} = 'Row #';

for r = 2:21;PAdisp{r,1}=r;end

display(PAdisp) % Verifying correctness

if strcmp('y',input('\nIs this the desired ParameterArray? ','s'))
    
    Params = PA;
    
else
    
    while 1
        
        r = input('\nWhich row do you want to correct? [rtn if done w corrections] ');
        
        if isempty(r)
            break
            
        else
            
            PA{r,1} = input(sprintf('\nName of parameter (Currently: %s): ',PA{r,1}),'s');
            
            PA{r,2} = input('\nEnter value for Column 2: ');
            
            PA{r,3} = input('\nEnter value for Column 3: ');
            
        end
        
    end
    
    Params = PA;
    
end
            