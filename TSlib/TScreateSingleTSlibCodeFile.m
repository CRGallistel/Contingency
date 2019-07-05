function TScreateSingleTSlibCodeFile
% Creates a text file containing all of the TS commands, with each function
% delimited by 'startfunction' and 'endfunction'. The TSsystem can be
% installed by calling TSwriteoutfunctions with 'TSlibCodeFile.txt' as the
% input argument
%%
fid =fopen('TSlibCodeFile.txt','a'); % 
files1 = dir('*.m');
files2 = dir('*.txt');
files = [files1;files2];
%%
fprintf(fid,'\nTSlib functions as of %s\n\n',date);
for f = 1:length(files)
    if strcmp('TScreateSingleTSlibCodeFile.m',files(f).name) ||...
            strcmp('TSlibCodeFile.txt',files(f).name)
        continue % Don't process self
    end
    raw = fileread(files(f).name);
    fprintf(fid,'\nstartfunction\nfunName: %sEndOfFunName\n%s\nendfunction\n',...
        files(f).name,raw);
end
fclose(fid);