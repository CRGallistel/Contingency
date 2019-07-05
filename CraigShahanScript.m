% script m-file CraigShahanAnalysis.m contains code for analyzing
% behavior-reinforcement contingencies in data collected by Andrew Craig
% in Tim Shahan's lab, March 2012 - June 2014. The purpose of the
% experiment was to apply the information-theoretic measure of contingency
% to data from responding on Variable Interval schedules of reinforcement.
% In the first of three experiments, we varied the VI schedules by an
% order of magnitude from rich (VI30s, Sessions 1:10, Phase 30) to moderate
% (VI165s, Sessions 11:20, Phase 165) to poor (VI300s, Sessions 21:30,
% Phase 300. In the second experiment, we varied the VI schedules over
% similar range (15, 60 & 240s) & within each schedule, we varied the delay 
% of reinforcement over 5 different values, 0.1x[0 1 4 16 64] in
% seconds. These 15 different Phases/Conditions are designated by Phase
% numbers that concatenate the VI with the integers in the delay vector
% [0 1 4 16 64]. Each Phase ran for 15 sessions. Thus Exper 2 comprises 
% Sessions 31-255. In the third experiment, the VI schedule was 60s. We 
% varied the percent of reinforcements that were randomly delivered, in 4 
% steps from 0% random reinforcement to 100%. The first of these
% phases (0% random reinforcement) lasted 20 sessions; the 3 steps with
% increasing percentages of random reinforcements lasted 40 sessions each.
% The file "CraigShahanWonlyData" contains the Experiment structure after
% setting it up and loading the data but before the analysis begins.
%
% This script requires for its execution that the TSsystem Toolbox (TSlib)
% and its subfolders be on Matlab's search path and that the
% CraigShahanHelperFunctions folder also be on Matlab's search path. These
% code folders may be found on and downloaded from the GitHub repository
% ContingencyInConditioningGHrepo
% tic
%% Cell 0: Establishing search paths to the folders containing relevant code
pth = cd;
if isdir('TSlib')
    addpath([pth '/TSlib'])
else
    fprintf('\nThe TSlib folder and its subfolders (if any) must be in this\ndirectory and on Matlab''s search path. It can be found on\nand downloaded from the GitHub repository\nContingencyInConditioningGHrepo\n')
end
% The TSlib folder contains the code for the TSlib Toolbox created by Adam
% Gallistel et al for the analysis of time-stamped event sequences
% Gallistel, C. R., Balci, F., Freestone, D., Kheifets, A., & King, A.
% (2017). A Cognitive neurogenetics screening system with a data-analysis
% toolbox. In V. Tucci (Ed.), Handbook of Neurobehavioral Genetics and
% Phenotyping. New York: Wiley.

if isdir('CraigShahanHelperFunctions')
    addpath([pth '/CraigShahanHelperFunctions'])
else
    fprintf('\n The folder CraigShahanHelperFunctions must be in this\ndirectory and on Matlab''s search path It can be found on\nand downloaded from the GitHub repository\nContingencyInConditioningGHrepo\n')
end
mkdir('ScriptCreatedFigures')

if exist('CraigShahanWonlyData.mat')
    TSloadexperiment([pth '/CraigShahanWonlyData'])
    TSexperimentbrowser
    Experiment.Name = [pth '/VIContingencyStructure']; % renaming the file in
    % which the structure will be saved
else    
    disp(char({'The execution of this script in its entirety assumes that an';...
        'Experiment structure named ''CraigShahanWonlyData.mat'' exists';...
        'in this folder and that it contains an already created Experiment';...
        'structure loaded with the raw data in the TSData fields at the Session';...
        'level. If you want only to study/manipulate some aspect of the code';...
        'in this script, you should not execute the script in its entirety;';...
        'rather, you should load the completed structure (the filed named';...
        'VIContingencyStructure.mat) and go to the relevant cell(s) in this';...
        'script--see Guide to the Script.docx'}))
end
TSsaveexperiment % saves the renamed structure
%% Cell 1: Peck Times
TSapplystat('PeckTimes','TSData',@Tms,Peck)
% Creates a field at the Session level containing the session times of all
% the pecks. % The first argument gives the name of the field into which
% the results of the computation are to be put (more often than not, that
% field is created by the command, as it is in this case, but that need not
% be the case). The 2nd argument names the field from which the data on
% which the computation operates are to be taken; the 3rd argument is a
% handle on a helper function, which does the computation. The 4th argument
% is an additonal input to that helper function. The 1st argument to the
% helper function is always the data in the field specified by the
% 2nd argument in this function. This function takes the data from the
% specified field and passes it to the helper function.

%% Cell 2: Reinforcement Times
TSapplystat('ReinfTimes','TSData',@Tms,Feed)
% creates a a field with all the reinforcement times
%{
function t = Tms(tsdata,Evnt)
t = tsdata(tsdata(:,2)==Evnt,1);
%}
%% Cell 3: Numbers of Pecks & Reinforcements in each Session 
TSapplystat('NumPecks','PeckTimes',@numel) % 'NumPecks' names the field
% into which the result is to be placed; 'PeckTimes', is the name of the
% field that contains the data from which the result is to be computed;
% @numel is a handle to the helper function, which, in this case, is the
% Matlab function, numel, that reports the number of elements in an array

TSapplystat('NumFeeds','ReinfTimes',@numel)

%% Cell 4: Rates of Reinforcement 
% These are simply the numbers of pecks or feeds in a session divided by
% the duration of the session. There is a Duration field for each session
% already; it is automatically created when the data for a session are
% loaded (provided the load function provides the information!). However,
% it is recorded as a "date string", that is, in days, hours, minutes and
% seconds, because that is what it is easy for the user to understand. This
% form is useless for computational purposes. That is why two other fields
% are also automatically created when the data for a session are loaded:
% MatlabStartDate and MatlabEndDate. These report the start and end times
% as simple numbers. The digits to the left of the decimal place specify
% the number of days since a long-ago reference day. The digits to the
% right of the decimal place specify the time of day as a decimal fraction 
% of the total day. We can use these fields to get a session duration in
% seconds (or minutes, or hours--whatever unit we want).

TSapplystat('SesDurInMins',{'MatlabEndDate' 'MatlabStartDate'},@SesDur)
% The first argument specifies names the field into which the result
% is to be placed. The second argument is a cell array containing the names
% of the two fields from which the data to be used are to be taken. The
% third argument is the name of a helper function, which we will create to
% do the simple job, which is to subtract the MatlabStartDate from the
% MatlabEndDate to get the fraction of a day that the session lasted, then
% multiply that fraction by the number of minutes in a day. This helper
% function must be stored on Matlab's currently active search path, so that
% Matlab can find it. Because this function will be in a separate file,
% there is a danger that in the future when this experiment is archived,
% copied to another computer, uploaded to the internet, emailed to another
% investigator, etc., the file for the helper function will become
% separated from this file. In that case, this command will cause a crash.
% Therefore, one should always reproduce the helper function as part of the
% comment on the TS command that calls it:
%{
function DurInMins = SesDur(ED,SD)

DurInMins = []; % always begin by assigning an empty output, so that, if the
% helper function does not succeed; it nonetheless returns a result

if isempty(ED) || isempty(SD) % always check for empty inputs
    return
else
    DrFrac = ED-SD; % the fraction of a day
    DurInMins = DrFrac*60*24;
end
%}

TSapplystat('PeckRate',{'NumPecks' 'SesDurInMins'},@rdivide) % The 1st
% argument specifies the name of the field into which the result is to be
% placed, the 2nd argument is a cell array giving the names of the fields
% from which the data to be used are to be taken. The contents of these
% fields are fed to the helper function in the order in which the field
% names appear in this cell array. The last argument is a handle on
% Matlab's rdivide function, which is the same as its ./ operator (but you
% cannot call an operator as a helper function)

TSapplystat('ReinfRate',{'NumFeeds' 'SesDurInMins'},@rdivide)

% Carrying Rates Up to Subject Level
% The basic question in this experiment is, How did our various
% manipulations affect the rate of pecking. We can get a first look at the
% answer simply by plotting the pecking rate across all the sessions. To do
% that, we will neeed a 2-col field that records the session number
% in one column and the pecking rate in the other. The appropriate place
% for such a field is at the Subject level, so creating this field is a job
% for TScombineover. Because the reiforcement rate also varied, we will
% also create a similar field for the reinforcement rate.

TScombineover('PeckRate_S','PeckRate','t') % The 1st argument specifies the
% name of the field into which we want the results to go. The 2nd argument
% is the name of the field that contains the data to be combined. The third
% argument, 't', tells TScombineover to add a column specifying the "trial"
% (in this case, the session) from which each datum came

TScombineover('ReinfRate_S','ReinfRate','t')
TSsaveexperiment
fprintf('\nExperiment structure saved ater completion of Cell 4\n')

%% Cell 5: Reinforcement Rates by Session (Figure 1 in first version of 
% Psych Review MS)
TSapplystat('','ReinfRate_S',@TSplot,'Xcol',2,'Ycol',1,'Xlbl','Session',...
    'LstRow',30,'Ylbl','Reinf/min','Ylm',[.1 4],'Scat','k*')
% First argument is the empty string, '', because this command does not
% create a new field. Second argument is the name of the field containing
% the data to be plotted. Third argument is a handle on the function that
% actually does the plotting (TSplot). The remaining arguments are what
% Matlab calls Variable-Value pairs. These are paired arguments in which
% the second argument (the value) must follow immediately the first
% argument (the name of the variable). The name of the variable must belong
% to the privileged list that the function recognizes as the names of
% variables. In this case, the function is TSplot, because all of these
% arguments will be passed to it. 'Xcol' is one of the variables whose name
% TSplot recognizes. When it sees this name in its input arguments,
% it expects the next argument to be the number of the column containing
% the data that are to be plotted as x-axis values. In this case, that
% number is 2, because the session numbers are in the 2nd column and we
% want the session numbers on the x axis of our plot. Ycol' is also on its
% list of possible variables. When it sees it, it expects the next argument
% to be the number of the column that contains the y data (in this case 1).
% 'Xlbl' is also on its list. When it sees that, it expects the next
% argument to be a string specifying a label for the x axis; similarly for
% 'Ylbl'. This command creates multiple panels on a single figure. One can
% control the number of rows and columns of panels using the 'Rows' and
% 'Cols' variables, which are on the list of possible variables. However,
% the default values for these variables are 4 and 2, which are just what
% we want, because there are 8 birds and we want a plot for each bird. So,
% we don't need to put in those Variable-Value pairs

% Adding vertical lines between sessions
for plt = 1:8
    subplot(4,2,plt)
    hold on
    set(gca,'YScale','log','YTick', [.2 .37 2.0],'FontSize',14)
    plot([10 10],ylim,'k--',[20 20],ylim,'k--')
    if plt<3
        text(1,2.9,['VI' num2str(Experiment.Subject(plt).Session(1).Phase)])
        text(11,2.9,['VI' num2str(Experiment.Subject(plt).Session(11).Phase)])
        text(21,2.9,['VI' num2str(Experiment.Subject(plt).Session(21).Phase)])
    end
    if plt<7
        xlabel('')
    else
        xlabel('Session')
    end
end
saveas(gcf,'ScriptCreatedFigures/originalmsFig1')

%% Cell 6: Peck Rates by Session (Fig 2 in first version of MS)
TSapplystat('','PeckRate_S',@TSplot,'Xcol',2,'Ycol',1,'Xlbl','Session',...
    'LstRow',30,'Ylbl','Pecks/min','Ylm',[0 160],'Scat','*')
%
for plt = 1:8 % adding vertical lines btw diff VIs & the VIs
    subplot(4,2,plt)
    hold on
    set(gca,'FontSize',14)
    plot([10 10],ylim,'k--',[20 20],ylim,'k--')
    if plt<3
        text(1,140,['VI' num2str(Experiment.Subject(plt).Session(1).Phase)])
        text(11,140,['VI' num2str(Experiment.Subject(plt).Session(11).Phase)])
        text(21,140,['VI' num2str(Experiment.Subject(plt).Session(21).Phase)])
    end
    if plt<7
        xlabel('')
    else
        xlabel('Session')
    end
end
saveas(gcf,'ScriptCreatedFigures/originalmsFig2')

% Cell 7 CONTAINS CODE FOR FIGURES NOT PUT IN PAPER BUT WHICH WERE USEFUL
% IN PRELIMINARY EXAMINATION OF THE DATA. SUGGEST SKIPPING NOW TO CELL 9
%% Cell 7: Peck Rate vs Reinforcement Rate Plot
% We did not put this in the paper, but it is of some interest
TSapplystat('',{'ReinfRate_S' 'PeckRate_S'},@TSplot,'Xcol',1,'Ycol',3,...
    'LstRow',30,'Xlbl','Reinf/min','Ylbl','Pecks/min','Scat','*','Xlm',[.1 2])
    
% Creates scatter plots with reinforcement rate on the x axis and pecking
% rate on the y axis. The 'Scat' variable takes as its value strings
% specifying the symbols to be used in plotting the points in a scatter
% point
%
for p = 1:8
    subplot(4,2,p)
    set(gca,'XScale','log','XTick',[.2 .5 2],'XTickLabel',{'0.2' '0.5' '2'})
    if p>6
        xlabel('Reinf/min (log scale)')
    else
        xlabel('')
    end
end
% saveas(gcf,'ScriptCreatedFigures/PdkRateVsReinfRate') 

%% Cell 8a: Computing IRI and iri Distributions
% The distribution of a variable often gives important, non-obvious
% information, so we next compute and plot the distributions of
% interresponse intervals (iri's) and interreinforcement intervals (IRI's)
close all % close previous figures

TSapplystat('iris','PeckTimes',@diff) % 1st arg is name of field into which
% results are to be placed; 2nd is name of field containing data to be
% used, 3rd is the handle on the helper function, which is Matlab's diff
% function, which computes the differences in successive values of a vector
%
TSapplystat('IRIs','ReinfTimes',@diff)

%% Cell 8b: Carrying iri & IRI Results Up to Phase-Specific Fields @ Subject Level
% We want to pool the data from different sessions in the same experimental
% condition and put the pooled data in a condition-specific field at the
% Subject level, so we use TSlimit to limit the sessions on which
% TScombineover operates:  [Execution time 1.09 s]

TSlimit('Phases',30) % limiting Sessions to those with VI30

TScombineover('irisPhase30','iris')

TScombineover('IRIsPhase30','IRIs')
%
TSlimit('Phases',165) % limiting Sessions to those with VI165

TScombineover('irisPhase165','iris')

TScombineover('IRIsPhase165','IRIs')
%
TSlimit('Phases',300) % limiting Sessions to those with VI300

TScombineover('irisPhase300','iris')

TScombineover('IRIsPhase300','IRIs')

%% Cell 8c: Plotting Interpeck Interval Distributions (not in paper, but of
% some interest)
% The tool for this is TSplotcdfs, which plots cumulative distribution
% functions, because best way to examine a distribution is to plot the
% cumulative distribution. The histogram is more common; it shows  discrete
% approximation to the true probability distribution. However, the
% appearance of the histogram depends strongly on an arbitrary choice of
% bin widths. (This is particularly so when the sample size is small.) The
% appearance of the empirical cumulative distribution, which is an estimate
% of the integral of the probability distribution, does not depend on any
% choices.

TSapplystat('',{'irisPhase30' 'irisPhase165' 'irisPhase300'},@TSplotcdfs,...
    'DataCols',{(1) (1) (1)},'Xlbl','InterPeckInts (s) ','Xlm',[0 5])
% The first argument is an empty string, because the command does not
% produce a field in which to store results. The second argument is a cell
% array, each cell of which contains the name of one of the fields
% containing to-be-plotted data. The third argument is the handle on the
% desired TS plot function. The 4th argument and 5th arguments are a
% Variable-Value pair specifying the to-be-plotted column(s) within each of
% the fields specified in the third argument. 'DataCols' is the variable
% and {(1) (1) (1)} is the value (It specifies the first column in each
% field.). A final two arguments specify x limits. 

% The first time we ran this command, we put no limit on the x axis. The
% resulting plots were dominated by a few extreme outliers, jamming most of
% the distribution up against the y axis. This is a common
% occurrence. The remedy is to set limits on the x axis such that most of
% the data are included in the display but the outliers are not because
% they lie beyond the upper x limit. To do that, we added the "Xlm"
% Variable-Value pair to the arguments.

% We see from the cumulative distribution that for most birds, an order of
% magnitude change in the rate of reinforcement had only small effects on
% the pecking pattern. The pecks came in bursts, because the distributions
% show an abrupt rise somewhere between 0.1 and 0.3 s, followed by a long
% slow climb. The size of this initial rise (hence the percentage of pecks
% occurring within a burst) and its exact location varies between birds.
% The effects of the change in VI are on the size but not the location of
% this initial rise, that is, the VI did not affect the interpeck interval
% within a burst, but it did (in some birds) affect the average length of a
% burst. This average length varied strikingly between birds. In S5, 50% of
% all pecks occurred within bursts, whereas in S8 only 10% did.
%

subplot(4,2,1)
legend('30','165','300','location','SE')

%% Cell 8d: Plotting the Cumulative Distributions of IRIs (also not in paper)
TSapplystat('',{'IRIsPhase30' 'IRIsPhase165' 'IRIsPhase300'},@TSplotcdfs,...
    'DataCols',{(1) (1) (1)},'Xlbl','InterReinfInts (s) ','Xlm',[0 1000])
% We see as expected that there were dramatic differences in the
% distribution of IRIs between conditions. Note that these distributions
% are the same from bird to bird, which means that the large differences in
% the pecking patterns of the birds have negligible effects on the
% distributions of interreinforcement intervals that they experience. The
% steps in the distributions of IRIs result from the manner in which an
% appxoximation to an exponetial distribution was programed

subplot(4,2,1)
legend('30','165','300','location','SE')

%% Cell 9: Computing prospective contingency
% The principal purpose of this series of experiments is to measure the
% contingencies between pecking and reinforcement, vary those
% contingencies, and determine how that variation affects performance.
% The measure of the prospective contingency between r and R (response and
% Reinforcement) is the entropy of the distribution of rndt->R intervals
% minus the entropy of the distribution of r->R intervals, divided by the
% entropy of the distribution of rndt->R intervals. A rndt->R interval is the
% interval from a randomly chosen point in time to the next reinforcement.
% The entropy of this distribution, H_b, is a measure of basal uncertainty about
% when to expect the next R. A peck (r) predicts a reinforcement (R) to the
% extent that its occurrence reduces this uncertainty. If there is zero
% difference between the entropy of the distribution of r->R intervals,
% H_rR, and the basal entropy, then knowing when a response occurs does not
% reduce our uncertainty (or the bird's uncertainty!) about when the
% next reinforcement occurs. Because the entropies, H_b & H_rR, are the same,
% their difference, (Hb - HrR), is 0, and 0 divided by Hb gives a contingency
% of 0. If on the other hand, knowing when a response occurs leaves
% us with no uncertainty about when the next reinforcement occurs, then
% the H_rR is 0, (H_b - H_rR) is H_b, and the ratio of H_b to itself is, of
% course, 1. So we see that the measure of contingency ranges from 0 to
% 1, as it should. The entropy of the rR distribution measures how
% uncertain we are about when the next reinforcement will occur given that
% a response has just occurred. There is, however, another distribution we
% must consider, the distribution of what we will denote as Rbtr intervals,
% the intervals measured looking backward from a reinforcement to the most
% recent response. For the four basic operant schedules of
% reinforcement, the VI, the FI, the VR and the FR, every reinforcement is
% triggered by a response, and it occurs at a very short and fixed interval
% following the response that triggers it. Therefore, the distribution of
% Rbtr intervals has no entropy; given that a reinforcement has just
% occurred, we know with certainty that a response occurred a moment
% earlier. There is, therefore, no need to compute one of the contingencies
% we are interested in, the retrospective contingency between reinforcement
% and pecking. We know that this contingency is 1. So, the only question at
% this point is, What is the prospective contingency between pecking and
% reinforcement? To compute that, we need to compile two distributions: 1)
% the distribution of intervals from each peck to the next reinforcement,
% that is the rR ints and the distribution from a similar number of
% randomly chosen points in time to the next reinforcement, the intervals
% that we will denote as rndtR intervals

% Creating phase-specific raw data fields at the Subject level
% Although the distributions can be compiled at the session level, it is
% simpler to do the compilation at the Subject level after aggregating the
% data from all the sessions of a given phase.
close all

TSlimit('Phases',30)

TScombineover('Phase30RD','TSData','m')
% The 1st argument is the name we give to the field at the subject level
% into which we put the aggregated raw data from that phase, the 2nd
% argument is the name of the fields at the session level containing the
% raw data. The final argument, 'm', tells the TScombineover to create a
% continuously increasing across section time stamps


TSapplystat('Phase30rR','Phase30RD',@rRints,Peck,Feed)
% 1st argument is name of field into which the compilation of intervals
% will go; 2nd argument is the field containing the phase-specific
% aggregated raw data. Third argument is a handle on the custom function we
% create to compute these intervals. The last 2 arguments pass on to this
% helper function the numerical codes for the events. We write the
% helper function in a separate file, save it, but first copy it and paste
% it in here as part of the comments. Notice that the helper is short and
% simple and entirely focused on solving this one problem. This modularity
% greatly increases the intelligibility of the data-analysis code
%{
function Ints = rRints(tsd,Peck,Feed)
PT = tsd(tsd(:,2)==Peck,1)'; % row vector of the peck times
RT = tsd(tsd(:,2)==Feed,1); % vector of the reinforcement times
Ints=nan(length(PT),1);
r = 1;
for t = PT % stepping through the peck times
    try
        Ints(r,1) = RT(find(RT>t,1))-t;
    catch
        continue
    end
    r=r+1;
end
%}


TSapplystat('Phase30rndtR','Phase30RD',@rndtRInts,Peck,Feed) % the 3rd 
% argument is a handle on a custom function that we write to sprinkle
% random points on the time axis and compute the intervals from those
% points to the next reinforcement. Last two arguments pass on to the
% helper function the numerical codes for the two events. As always, we
% include in these comments a copy of the helper function
%{
function Ints = rndtRints(tsd,Peck,Feed)
NumPcks = sum(tsd(:,2)==Peck);
rndt = sort(unifrnd(0,tsd(end,1),1,NumPcks)); % row vector with as many
% randomly chosen points in totalized session time as there are number of
% pecks, sorted so that they strictly increase
RT = tsd(tsd(:,2)==Feed,1); % col vector of the reinforcement times
Ints=nan(NumPcks,1);
r=1;
for t = rndt % stepping through the randomly chosen points    
    try
        Ints(r,1) = RT(find(RT>t,1))-t; % interval to next R
    catch
        continue
    end
    r=r+1;
end
%}

%
% Now we repeat above sequence of 4 commands for each of the other phases,
% mutatis mutandis. This cell, which does an enormous amount of computation
% executes in 274.46 s, a little more than 4.5 minutes

TSlimit('Phases',165)
TScombineover('Phase165RD','TSData','m')
TSapplystat('Phase165rR','Phase165RD',@rRints,Peck,Feed)
TSapplystat('Phase165rndtR','Phase165RD',@rndtRInts,Peck,Feed)


TSlimit('Phases',300)
TScombineover('Phase300RD','TSData','m')
TSapplystat('Phase300rR','Phase300RD',@rRints,Peck,Feed)
TSapplystat('Phase300rndtR','Phase300RD',@rndtRInts,Peck,Feed) 

%
TSlimit('Phases',150)
TScombineover('Phase150RD','TSData','m')
TSapplystat('Phase150rR','Phase150RD',@rRints,Peck,Feed)
TSapplystat('Phase150rndtR','Phase150RD',@rndtRInts,Peck,Feed)
% This component executes in 2.67 s
%
TSlimit('Phases',151)
TScombineover('Phase151RD','TSData','m')
TSapplystat('Phase151rR','Phase151RD',@rRints,Peck,Feed)
TSapplystat('Phase151rndtR','Phase151RD',@rndtRInts,Peck,Feed) 
% This component executes in 2.58 s
%
TSlimit('Phases',154)
TScombineover('Phase154RD','TSData','m')
TSapplystat('Phase154rR','Phase154RD',@rRints,Peck,Feed)
TSapplystat('Phase154rndtR','Phase154RD',@rndtRInts,Peck,Feed)

TSlimit('Phases',1516)
TScombineover('Phase1516RD','TSData','m')
TSapplystat('Phase1516rR','Phase1516RD',@rRints,Peck,Feed)
TSapplystat('Phase1516rndtR','Phase1516RD',@rndtRInts,Peck,Feed)

TSlimit('Phases',1564)
TScombineover('Phase1564RD','TSData','m')
TSapplystat('Phase1564rR','Phase1564RD',@rRints,Peck,Feed)
TSapplystat('Phase1564rndtR','Phase1564RD',@rndtRInts,Peck,Feed)

TSlimit('Phases',600)
TScombineover('Phase600RD','TSData','m')
TSapplystat('Phase600rR','Phase600RD',@rRints,Peck,Feed)
TSapplystat('Phase600rndtR','Phase600RD',@rndtRInts,Peck,Feed) 

TSlimit('Phases',601)
TScombineover('Phase601RD','TSData','m')
TSapplystat('Phase601rR','Phase601RD',@rRints,Peck,Feed)
TSapplystat('Phase601rndtR','Phase601RD',@rndtRInts,Peck,Feed) 

TSlimit('Phases',604)
TScombineover('Phase604RD','TSData','m')
TSapplystat('Phase604rR','Phase604RD',@rRints,Peck,Feed)
TSapplystat('Phase604rndtR','Phase604RD',@rndtRInts,Peck,Feed) 

TSlimit('Phases',6016)
TScombineover('Phase6016RD','TSData','m')
TSapplystat('Phase6016rR','Phase6016RD',@rRints,Peck,Feed)
TSapplystat('Phase6016rndtR','Phase6016RD',@rndtRInts,Peck,Feed) 

TSlimit('Phases',6064)
TScombineover('Phase6064RD','TSData','m')
TSapplystat('Phase6064rR','Phase6064RD',@rRints,Peck,Feed)
TSapplystat('Phase6064rndtR','Phase6064RD',@rndtRInts,Peck,Feed) 

TSlimit('Phases',2400)
TScombineover('Phase2400RD','TSData','m')
TSapplystat('Phase2400rR','Phase2400RD',@rRints,Peck,Feed)
TSapplystat('Phase2400rndtR','Phase2400RD',@rndtRInts,Peck,Feed)
%
TSlimit('Phases',2401)
TScombineover('Phase2401RD','TSData','m')
TSapplystat('Phase2401rR','Phase2401RD',@rRints,Peck,Feed)
TSapplystat('Phase2401rndtR','Phase2401RD',@rndtRInts,Peck,Feed) 
%
TSlimit('Phases',2404)
TScombineover('Phase2404RD','TSData','m')
TSapplystat('Phase2404rR','Phase2404RD',@rRints,Peck,Feed)
TSapplystat('Phase2404rndtR','Phase2404RD',@rndtRInts,Peck,Feed) 
%

TSlimit('Phases',24016)
TScombineover('Phase24016RD','TSData','m')
TSapplystat('Phase24016rR','Phase24016RD',@rRints,Peck,Feed)
TSapplystat('Phase24016rndtR','Phase24016RD',@rndtRInts,Peck,Feed)

TSlimit('Phases',24064)
TScombineover('Phase24064RD','TSData','m')
TSapplystat('Phase24064rR','Phase24064RD',@rRints,Peck,Feed)
TSapplystat('Phase24064rndtR','Phase24064RD',@rndtRInts,Peck,Feed)
%
TSlimit('Phases',167)
TScombineover('Phase167RD','TSData','m')
TSapplystat('Phase167rR','Phase167RD',@rRints,Peck,Feed)
TSapplystat('Phase167rndtR','Phase167RD',@rndtRInts,Peck,Feed) 

TSlimit('Phases',56)
TScombineover('Phase56RD','TSData','m')
TSapplystat('Phase56rR','Phase56RD',@rRints,Peck,Feed)
TSapplystat('Phase56rndtR','Phase56RD',@rndtRInts,Peck,Feed) 

TSlimit('Phases',28)
TScombineover('Phase28RD','TSData','m')
TSapplystat('Phase28rR','Phase28RD',@rRints,Peck,Feed)
TSapplystat('Phase28rndtR','Phase28RD',@rndtRInts,Peck,Feed) 

TSlimit('Phases',0)
TScombineover('Phase0RD','TSData','m')
TSapplystat('Phase0rR','Phase0RD',@rRints,Peck,Feed)
TSapplystat('Phase0rndtR','Phase0RD',@rndtRInts,Peck,Feed)

% this cell executes in just under 6 minutes on my 2010 MacBook Pro,
% running Yosemite (OS10.10.5)

% TSsaveexperiment
fprintf('\nThe Experiment structure has been saved at the conclusion of Cell 9\n')

%% Cell 10: Graphing the 2 distributions for the first experiment
% (Figures 3-5 in the first MS)
TSapplystat('',{'Phase30rR' 'Phase30rndtR'},@TSplotcdfs,'DataCols',{(1) (1)},...
    'Xlbl','Interval (s)')
figure(1)
subplot(4,2,1)
legend('rR','rndtR','location','SE')
title('VI 30: S1')
for p=1:6;subplot(4,2,p);xlabel('');end
saveas(gcf,'ScriptCreatedFigures/originalmsFigure3')
%
TSapplystat('',{'Phase165rR' 'Phase165rndtR'},@TSplotcdfs,'DataCols',{(1) (1)},...
    'Xlbl','Interval (s)')
subplot(4,2,1)
legend('rR','rndtR','location','SE')
title('VI 165: S1')
for p=1:6;subplot(4,2,p);xlabel('');end
saveas(gcf,'ScriptCreatedFigures/originalmsFigure4')
%
TSapplystat('',{'Phase300rndtR' 'Phase300rR'},@TSplotcdfs,'DataCols',{(1) (1)},...
    'Xlbl','Interval (s)')

subplot(4,2,1)
legend('rR','rndtR','location','SE')
title('VI 300: S1')
for p=1:8;subplot(4,2,p);xlim([0 1100]);if p>6;xlabel('Interval (s)');else;xlabel('');end;end
saveas(gcf,'ScriptCreatedFigures/originalmsFigure5')
% In every case but 1 (Phase 165, S6), the distribution of intervals
% measured from each peck to the next reinforcement superimposes on the
% distribution of intervals measured from randomly chosen points in time to
% the next reinforcement. Because the distributions are the same, they have
% the same entropy. Therefore, there is no prospective contingency between
% a response and a reinforcement. In other words, knowing that the bird has
% just made a response does not reduce by any measurable amount the 
% uncertainty about when the next reinforcement will occur.

%% Cell 11a: Preliminaries to computing the contingency between rate of 
% pecking and rate of reinforcement: creating IRI "trials" and computing
% basic stats
close all
TSlimit('Phases',[30 165 300])
%
TSdefinetrialtype('IRI',[Feed Feed]) % Defines the intervals between reinforcements
% as "trials", that is, segments of interest, for which we want to compute
% statistics
%
TStrialstat('Pecks',@TSparse,'result=time(1)-starttime;',Peck) % finds all the
% pecks in each trial and records where in the trial they occurred, that
% is, the time elapsed since the last reinforcement. These times are put in
% a field at the trial level named "Pecks". They form a column vector in
% that field
%
TSapplystat('NumIRIpecks','Pecks',@numel); % creates a field at the trial level
% called NumPecks that contains the number of pecks between each
% interreinforcement interval
%
TSapplystat('PckRate',{'NumIRIpecks' 'TrialDuration' },@rdivide); % creates a field at
% the trial level named "PckRate", which contains the pecking rate during 
% the IRI. We avoid using 'PeckRate' as the name for this field because we
% have already used that as the name for a field at the Session level

%
TScombineover('IRIpeckRate','PckRate') % field at session level containing the
% pecking rate during each IRI
%
TScombineover('IRIdurs','TrialDuration') % field at session level containing the
% duration of each IRI

%% Cell 11b: Aggregating data at Subject level by phase: Phase 30

TSlimit('Phases',30)
%
TScombineover('Phase30IRIpeckRates','IRIpeckRate') % field at Subject level
%
TScombineover('Phase30IRIdurs','IRIdurs')


% Phase 165
TSlimit('Phases',165)

TScombineover('Phase165IRIpeckRates','IRIpeckRate') % field at Subject level

TScombineover('Phase165IRIdurs','IRIdurs')


% Phase 300
TSlimit('Phases',300)

TScombineover('Phase300IRIpeckRates','IRIpeckRate') % field at Subject level

TScombineover('Phase300IRIdurs','IRIdurs')


%% Cell 12: Correlation Coefficients (Phases 30, 165 & 300)
%
TSapplystat({'Phase30IRIdurVsPckRtCorr' 'Phase30CorrP'},...
    {'Phase30IRIpeckRates' 'Phase30IRIdurs'},@corr)
% Computing correlation coefficients and their p values using Matlab's corr
% function as the helper: 1st arg is a cell array giving the names of the
% fields into which the two outputs from corr are to go; 2nd arg is cell
% array giving the names of the fields that contain the x ^& y data; 3rd
% arg is the handle on the helper function.

TSapplystat({'Phase165IRIdurVsPckRtCorr' 'Phase165CorrP'},...
    {'Phase165IRIpeckRates' 'Phase165IRIdurs'},@corr)

TSapplystat({'Phase300IRIdurVsPckRtCorr' 'Phase300CorrP'},...
    {'Phase300IRIpeckRates' 'Phase300IRIdurs'},@corr)

%% Cell 13: Computing iri-IRI Contingencies in Experiment 1

Nx = 4; % number of bins in the marginal distribution on peck rates
Ny = 5; % number of bins in the marginal distribution on IRI durations
TSapplystat('Phase30IRIpckrateContNx4Ny5',{'Phase30IRIpeckRates' 'Phase30IRIdurs'},...
    @JntDistContingN,Nx,Ny)
%{
function [Cyx,MI,Hy] = JntDistContingN(Dx,Dy,Nx,Ny)
% Computes the extent to which the values in data vector Dy are contingent
% on the values in data vector Dx by discretizing the joint and marginal
% distributions into the number of marginal bins specified in the Nx and Ny
% integers.
%
% Syntax:   [Cyx,MI,Hy] = JntDistConting(Dx,Dy,Nx,Ny)
% where Cyx is the contingency of y on x, MI is the mutual information, and
% Hy is the available information
% Dx and Dy must be vectors of the same length. Nx and Ny must be integers
% specifying the number of bins in the marginal distributions. The
% partitioning divides the x range and the y range into Nx and Ny equal
% width bins. There are Nx?Ny bins in the joint distribution.
%
% The more bins in the joint distribution, the less reliable the estimates
% of the joint probabilities; hence, the less trustworthy the estimate of
% the contingency. On the other hand, having too few bins obscures the true
% structure of the joint distribution. It is good practice to examine the
% effects of varying the numbers of quantiles for the x and y variables
%
if numel(Dx) ~= numel(Dy)
    fprintf('\nInput Error: Data vectors not the same length\n')
    return
end

Xedges = linspace(min(Dx)-.01,max(Dx)+.01,Nx+1);
Yedges = linspace(min(Dy)-.01,max(Dy)+.01,Ny+1);

LVx = nan(length(Dx),Nx);
for c = 1:Nx % filling in the columns of the logical array for the X partition
    LVx(:,c) = Dx>=Xedges(c)&Dx<Xedges(c+1);
end

LVy = nan(length(Dy),Ny); 
for c = 1:Ny  % filling in the columns of the logical array for the Y partition
    LVy(:,c) = Dy>=Yedges(c)&Dy<Yedges(c+1);
end

%
histmat=nan(Nx,Ny); % initializing the histogram array. Matlab's hist2 command
% SHOULD compute this array BUT it seems to have a bug; it undercounts the
% upper right bin by 1. Weird!
for c = 1:Ny
    for r = 1:Nx
        histmat(r,c) = sum(LVx(:,r)&LVy(:,c)); % the count in bin r,c
    end
end
%
Xmarg = sum(histmat,2); % summing across the columns to get the marginal
% totals for Dx
Ymarg = sum(histmat); % summing across the rows to get the marginal
% totals for Dy

pXY = histmat/sum(histmat(:)); % joint probability distribution
pX = Xmarg/sum(Xmarg(:)); % X marginal 
pY = Ymarg/sum(Ymarg(:)); % Y marginal 

Hxy = nansum(pXY(:).*log2(1./pXY(:))); % joint entropy
Hx = nansum(pX.*log2(1./pX)); % X entropy
Hy = nansum(pY.*log2(1./pY)); % Yentropy

MI = (Hx+Hy-Hxy);

Cyx = MI/Hy;
if isnan(Cyx);keyboard;end    
%}
TSapplystat('Phase165IRIpckrateContNx4Ny5',{'Phase165IRIpeckRates' 'Phase165IRIdurs'},...
    @JntDistContingN,Nx,Ny)

TSapplystat('Phase300IRIpckrateContNx4Ny5',{'Phase300IRIpeckRates' 'Phase300IRIdurs'},...
    @JntDistContingN,Nx,Ny)

Nx = 8; % number of bins in the marginal distribution on peck rates
Ny = 8; % number of bins in the marginal distribution on IRI durations
TSapplystat('Phase30IRIpckrateContNx8Ny8',{'Phase30IRIpeckRates' 'Phase30IRIdurs'},...
    @JntDistContingN,Nx,Ny)
%
TSapplystat('Phase165IRIpckrateContNx8Ny8',{'Phase165IRIpeckRates' 'Phase165IRIdurs'},...
    @JntDistContingN,Nx,Ny)

TSapplystat('Phase300IRIpckrateContNx8Ny8',{'Phase300IRIpeckRates' 'Phase300IRIdurs'},...
    @JntDistContingN,Nx,Ny)

% Moving linearly binned contingencies up to Experiment level
TScombineover('Ph30IRIvsPkRateN4N5cont','Phase30IRIpckrateContNx4Ny5')
TScombineover('Ph30IRIvsPkRateN8N8cont','Phase30IRIpckrateContNx8Ny8')
TScombineover('Ph165IRIvsPkRateN4N5cont','Phase165IRIpckrateContNx4Ny5')
TScombineover('Ph165IRIvsPkRateN8N8cont','Phase165IRIpckrateContNx8Ny8')
TScombineover('Ph300IRIvsPkRateN4N5cont','Phase300IRIpckrateContNx4Ny5')
TScombineover('Ph300IRIvsPkRateN8N8cont','Phase300IRIpckrateContNx8Ny8')


%% Cell 14: Scatter Plots with Correlation Coefficients & Contingencies
% (Figures 6-8 in first MS)
TSapplystat('',{'Phase30IRIpeckRates' 'Phase30IRIdurs'},@TSplot,'Scat','.',...
    'Xlm',[0 3.5],'Ylm',[0 110],'Xlbl','Pecks/s','Ylbl','IRI duration (s)')
%  % scatter plot of IRI durations vs peck rates

% Putting the correlation coefficients & their p values on the plots
for p = 1:8 %stepping through the panels
    subplot(4,2,p)
    r = Experiment.Subject(p).Phase30IRIdurVsPckRtCorr;
    pv = Experiment.Subject(p).Phase30CorrP;
    C45 = Experiment.Subject(p).Phase30IRIpckrateContNx4Ny5;
    C88 = Experiment.Subject(p).Phase30IRIpckrateContNx8Ny8;
    text(.1,80,sprintf('r=%0.2f(p=%0.2f),C(4,5)=%0.2f',r,pv,C45))
    if p~=5
        text(2.2,65,sprintf('C(8,8)=%0.2f',C88))
    else
        text(.1,60,sprintf('C(8,8)=%0.2f',C88))
    end
    if p>6
        xlabel('Pecks/s')
    else
        xlabel('')
    end
end
saveas(gcf,'ScriptCreatedFigures/originalmsFigure6')
% The rows of points in the scatter plots result from the crude, highly
% discrete mode of programing the VI schedule. The correlations present a
% mixed picture: Three are insignificant (S3, S4 & S8); four are
% significantly positive (S1, S2, S5 & S7); and one is significantly
% negative (S6).

%
TSapplystat('',{'Phase165IRIpeckRates' 'Phase165IRIdurs'},@TSplot,'Scat','.',...
    'Xlm',[0 3.5],'Ylm',[0 600],'Xlbl','Pecks/s','Ylbl','IRI duration (s)')
%  % scatter plot of IRI durations vs peck rates

% Putting the correlation coefficients & their p values on the plots; also
% the C(4,5) and C(8,8) contingencies
for p = 1:8 %stepping through the panels
    subplot(4,2,p)
    r = Experiment.Subject(p).Phase165IRIdurVsPckRtCorr;
    pv = Experiment.Subject(p).Phase165CorrP;
    C45 = Experiment.Subject(p).Phase165IRIpckrateContNx4Ny5;
    C88 = Experiment.Subject(p).Phase165IRIpckrateContNx8Ny8;
    text(.5,450,sprintf('r=%0.2f(p=%0.2f),C(4,5)=%0.2f',r,pv,C45))
    if p~=5
        text(2.2,350,sprintf('C(8,8)=%0.2f',C88))
    else
        text(.5,350,sprintf('C(8,8)=%0.2f',C88))
    end
    if p>6
        xlabel('Pecks/s')
    else
        xlabel('')
    end
end
saveas(gcf,'ScriptCreatedFigures/originalmsFigure7')
% The rows of points in the scatter plots result from the crude, highly
% discrete mode of programing the VI schedule. The correlations present a
% mixed picture: Three are insignificant (S3, S4 & S8); four are
% significantly positive (S1, S2, S5 & S7); and one is significantly
% negative (S6).

%
TSapplystat('',{'Phase300IRIpeckRates' 'Phase300IRIdurs'},@TSplot,'Scat','.',...
    'Xlm',[0 3.5],'Ylm',[0 1100],'Xlbl','Pecks/s','Ylbl','IRI duration (s)')
%  % scatter plot of IRI durations vs peck rates

% Putting the correlation coefficients & their p values on the plots; also
% the C(4,5) and C(8,8) contingencies
for p = 1:8 %stepping through the panels
    subplot(4,2,p)
    r = Experiment.Subject(p).Phase300IRIdurVsPckRtCorr;
    pv = Experiment.Subject(p).Phase300CorrP;
    C45 = Experiment.Subject(p).Phase300IRIpckrateContNx4Ny5;
    C88 = Experiment.Subject(p).Phase300IRIpckrateContNx8Ny8;
    text(.2,850,sprintf('r=%0.2f(p=%0.2f),C(4,5)=%0.2f',r,pv,C45))
    if p~=5
        text(2.2,700,sprintf('C(8,8)=%0.2f',C88))
    else
        text(.2,700,sprintf('C(8,8)=%0.2f',C88))
    end
    if p>6
        xlabel('Pecks/s')
    else
        xlabel('')
    end
end
saveas(gcf,'ScriptCreatedFigures/originalmsFigure8')

%% Cell 15 Reality check: Cumulative Distributions from vertical tranches
% There is mutual information between two variables if the distribution of
% values for one variable depends on the value of the other variable. One
% can examine this graphically by plotting the cdfs of the IRIs in the
% above plots for data from vertical tranches through the scatter plot (the joint
% distribution) made at different values for the peck rate (the rate of
% pecking within an IRI). The following command calls a custom plotting
% function
close all
Phase = '30';
Xlm = [0 150];
TSapplystat('',{'Phase30IRIpeckRates' 'Phase30IRIdurs'},@TranchCDFs,Phase,Xlm)

Phase = '165';
Xlm = [0 600];
TSapplystat('',{'Phase165IRIpeckRates' 'Phase165IRIdurs'},@TranchCDFs,Phase,Xlm)

Phase = '300';
Xlm = [0 1250];
TSapplystat('',{'Phase300IRIpeckRates' 'Phase300IRIdurs'},@TranchCDFs,Phase,Xlm)
%{
function TranchCDFs(pkrates,IRIs,Phase,Xlm)
% makes vertical tranches through the distribution of
% InterReinforcementIntervals (vertical axis) versus IRI peck rates
% (horizontal axis) and plots the cdfs for the tranches on a common plot.
% The tranches are the quintiles of the peck rate distribution
%
A = [pkrates IRIs];
Q = quantile(pkrates,[.2 .4 .6 .8]);
Mx = max(pkrates);
LV(:,1) = pkrates<=Q(1);
LV(:,2) = pkrates>Q(1)&pkrates<=Q(2);
LV(:,3) = pkrates>Q(2)&pkrates<=Q(3);
LV(:,4) = pkrates>Q(3)&pkrates<Q(4);
LV(:,5) = pkrates>Q(4);
%
S = evalin('caller','sub'); % subject
if S<2
    figure
end
subplot(4,2,S)
cdfplot(A(LV(:,1),2))
set(gca,'FontSize',12)
hold on
cdfplot(A(LV(:,2),2))
cdfplot(A(LV(:,3),2))
cdfplot(A(LV(:,4),2))
cdfplot(A(LV(:,5),2))
xlim(Xlm)
if S<2
    legend('Q1','Q2','Q3','Q4','Q5','location','SE')
end
if mod(S,2)>0
    ylabel({'Cum Fraction';'w/i Tranche IRIs'})
end
if S>6
    xlabel('IRI')
end
title(['Phase ' Phase ': S' num2str(S)])
%}

% These 3 figures are saved in the Figures folder as .fig files with titles
% of the form Phase[x]wiTrancheCDFs.fig

% While there are often some significant differences betweeen one
% within-tranche CDF and another from the same subject, they are not
% systematic and they differ from Phase to Phase within a subject in a way
% that is not consistent between subjects. In some subjects in some
% phases, there are no differences

% TSsaveexperiment
fprintf('\nThe Experiment structure has been saved at the conclusion of Cell 15\n')
%%                     Gratis Reinforcement Experiment

%% Cell 16: Pecks per Minute vs Session in Gratis Reinforcement Experiment
%(Figure 9 in first MS)
close all
TSapplystat('','PeckRate_S',@TSplot,'Xcol',2,'Ycol',1,...
    'FrstRow',256,'Scat','.')
hold on
for p=1:8 % stepping through the 8 plots on the active figure, marking
    % condition transitions with vertical dashed lines
    subplot(4,2,p) % makes the pth panel the active panel
    hold on
    plot([275.5 275.5],ylim,'k--')
    plot([315.5 315.5],ylim,'k--')
    plot([355.5 355.5],ylim,'k--')
    if p>6
        xlabel('Session')
    else
        xlabel('')
    end
    if mod(p,2)>0
        ylabel('Pecks/min')
    else
        ylabel('')
    end
end
saveas(gcf,'ScriptCreatedFigures/originalmsFigure9')

%% Cell 17: Retrospective Intervals in Gratis R experiment
% Preliminaries to Figures S4 & S5 in original Supplementary Material)
TSlimit('Phases',[0 28 56]) % The three conditions with gratis reinforcements
TSapplystat({'RbckToP' 'RndTbcktoP'},'TSData',@RetroInts,Peck,Feed)
% Creates field at the Session level
% 1st arg is a cell array containing the names of the 2 fields into which
% the results are to be placed; 2nd arg is the name of the field containing
% the data to be used; 3rd arg is the handle on the custom helper function;
% last 2 args are the variables whose values are the numerical codes for
% pecks and reinforcements. They are passed in to RetroInts as additional 
% input arguments. While helper functions are usually short and simple, 
% they can be arbitrarily complex. This helper function is relatively 
% complex. The code for it follows:
%{
function [RbcktoP,RndTbcktoP] = RetroInts(D,P,R)
% computes the retrospective intervals necessary to compute the
% retrospective contingency, the intervals looking back from reinforcements
% to the most recent peck and the distribution looking back from randomly
% chosen points in time to the most recent peck. D is the data from the
% TSData field of a session; P is the numerical code for the Peck event; R
% is the numerical code for the Reinforcement event

LVp = D(:,2)==P; % flags pecks

if sum(LVp)==0 % if no pecks
    RbcktoP = []; % return empty values
    RndTbcktoP = [];
    return % terminate
end

rRw = find(D(:,2)==R); % reinforcement row numbers

n = numel(rRw); % number of reinforcements

RbcktoP = nan(n,1); % initializing vector

RndTbcktoP = nan(n,1); % initializing vector

%% computing intervals back from reinforcements
for i = 1:n % stepping through the reinforcements
    
    LV = LVp & D(:,1)<D(rRw(i),1); % flags pecks earlier than reinforcement
    % time: D(rRw(i),1) is the reinforcement time
    
    PrePcks = D(LV,1); % times for pecks preceding the reinforcement
    try
        RbcktoP(i) = D(rRw(i),1) - PrePcks(end);
    catch
        continue % sometimes a reinforcement is the first event, in which
        % case there is no retrospective interval
    end
end % of stepping though reinforcements computing intervals back to most
% recent peck

%% computing intervals back from random times

PckTms = D(LVp,1); % peck time vector

t = unifrnd(PckTms(1),D(rRw(end),1),n,1); % draws n times from distribution
% uniform on  the interval from the first peck to the last reinforcement,
% which is at time D(rRw(end),1)

A = sortrows([[t ones(size(t))];[PckTms zeros(size(PckTms))]],1);
% 2-col array combining random session times and peck times, with the
% random times flagged by 1's and the pecks times flagged by 0s. Array is
% sorted by event time

tRw = find(A(:,2)>0); % rows in A that contain random times

LVp2 = A(:,2)<1; % flags pecks in the A array

for i = 1:n % stepping through the random-time rows
    
    LVp3 = LVp2 & (A(:,1)<A(tRw(i),1)); % (A(:,1)<A(tRw(i),1)) flags the rows
    % less than the random time row. ANDing it with the peck flag flags the
    % pecks less than the random time
    
    PrePcks = A(LVp3,1); % peck times preceding the current random time
    
    RndTbcktoP(i) = A(tRw(i),1)-PrePcks(end); % interval from random time
    % back to the first preceding peck    
end
%}

% Comparing the cumulative distributions of retrospective
% intervals for phases 56, 28 & 0, where the retrospective contingency was
% degraded to varying extents by random reinforcements

 % Preliminary examination shows that some of these data contain
% gross outliers. We need a criterion for discarding these outliers.
%
TSlimit('Phases',56)
TScombineover('Phase56_RbcktoPints','RbckToP')
TScombineover('Phase56_RndTbcktoPints','RndTbcktoP')

TSlimit('Phases',28)
TScombineover('Phase28_RbcktoPints','RbckToP')
TScombineover('Phase28_RndTbcktoPints','RndTbcktoP')

TSlimit('Phases',0)
TScombineover('Phase0_RbcktoPints','RbckToP')
TScombineover('Phase0_RndTbcktoPints','RndTbcktoP')
%
Crit=15;
TSapplystat('',{'Phase56_RndTbcktoPints' 'Phase56_RbcktoPints'},@TSplotcdfs,...
    'DataCols',{(1) (1)},'Xlm',[0 Crit])
subplot(4,2,1);title('Phase 56 (67% gratis): S1');legend('r<-rndT','r<-R','location','SE')
saveas(gcf,'ScriptCreatedFigures/S6 Gratis67%CDFsr<-rndT&r<-R')

TSapplystat('',{'Phase28_RndTbcktoPints' 'Phase28_RbcktoPints'},@TSplotcdfs,...
    'DataCols',{(1) (1)},'Xlm',[0 Crit])
subplot(4,2,1);title('Phase 28 (87% gratis): S1');legend('r<-rndT','r<-R','location','SE')
saveas(gcf,'ScriptCreatedFigures/S7 Gratis87%CDFsr<-rndT&r<-R')

Crit=45;
TSapplystat('',{'Phase0_RndTbcktoPints' 'Phase0_RbcktoPints'},@TSplotcdfs,...
    'DataCols',{(1) (1)},'Xlm',[0 Crit])
subplot(4,2,1);title('Phase 0 (100% gratis): S1');legend('r<-rndT','r<-R','location','SE')
saveas(gcf,'ScriptCreatedFigures/Gratis100%CDFsr<-rndT&r<-R')
% We see from the 3rd figure that in Phase 0, the distributions of
% intervals backward from reinforcements to the most recent peck
% superimpose on the distributions of intervals backward from randomly
% chosen points in time to the most recent peck, meaning that there was 0
% retrospective contingency in this phase, as intended

% We see in the 1st & 2nd figures firstly that the distributions of
% intervals backward from randomly chosen points in time (black curves)
% appear exponential. We see also that the distributions of intervals
% backward from reinforcements appear to be mixture distributions: One
% component of the mixture comes from the response-triggered
% reinforcements. These always yield backward intervals 0.01 second long.
% These appear as the steps at 0 in the graph of the cumulative
% distribution. In the 1st figure (Phase 56), this initial step appears to
% account for somewhat less than 40% of the distribution. In Phase 28, it
% appears to account for somewhat less than 20% of the distribution. The
% other component of the mixture appears to be the same exponential distribution
% as for the intervals back from randomly chosen points in time, AS IT
% SHOULD BE, because the free reinforcements occur at randomly chosen points
% in time!
%
% If these basal distributions are truly exponential, then we can compute 
% an entropy by finding the best fitting exponential and using it to
% estimate probability vectors

%% Cell 18: Reality check: Plotting Reinf rate & peck rate over the 0 
% contingency sessions to be sure that peck rate had no feedback effect on reinf. rate
TSlimit('Subjects','all')
TSlimit('Sessions',356:395)
figure
for S=1:8
    subplot(4,2,S)
    semilogy(Experiment.Subject(S).PeckRate_S(356:395,1))
    hold on
    semilogy(Experiment.Subject(S).ReinfRate_S(356:395,1))
    ylim([.2 70])
    set(gca,'YTick',[.5 1 2 5 10 20 50],'YTickLabel',...
        {'.5' '1' '2' '5' '10' '20' '50'})
    if S>6
        xlabel('Session')
    end
    if S == 5
        ylabel('E v e n t s / M i n u t e  (l o g  s c a l e)')
    end
    if S==1
        legend('Pecks','Rewards')
    end
end
    
%% Cell 19: Fitting Exponentials to r<-rndT Data in Gratis R Experiment
% Figures S4 & S5 in original Supplementary Material

close all
Crit = 15;
TSapplystat('Phase56_PhatExpFitRndTbcktoP','Phase56_RndTbcktoPints',...
    @expfitWOoutliers,Crit)
%{
function Params = expfitWOoutliers(D,Crit)
Params = [];
if ~isempty(D)
    D = D(D<Crit);
    Params = expfit(D);
end
%}
    
TSapplystat('Phase28_PhatExpFitRndTbcktoP','Phase28_RndTbcktoPints',...
    @expfitWOoutliers,Crit)

TSapplystat('Phase0_PhatExpFitRndTbcktoP','Phase0_RndTbcktoPints',...
    @expfitWOoutliers,Crit)
%
Crit = 15;
figure
for S=1:8
    subplot(4,2,S)
    LV = Experiment.Subject(S).Phase56_RndTbcktoPints<Crit; % flags data
    % < outlier criterion
    D = Experiment.Subject(S).Phase56_RndTbcktoPints(LV);
    cdfplot(D)
    hold on
    t = linspace(0,Crit);
    plot(t,expcdf(t,Experiment.Subject(S).Phase56_PhatExpFitRndTbcktoP),'r')
    if S==1
        title('Phase 56 (67% gratis): S1');legend('Data','ExpFit','location','SE')
    else
        title(['S' num2str(S)])
    end
    if S>6
        xlabel('r<rndT (s)')
    else
        xlabel('')
    end
    if mod(S,2)>0
        ylabel('Cum Frac Intvls')
    else
        ylabel('')
    end
end
saveas(gcf,'ScriptCreatedFigures/S4 Gratis67%expoFits')
%
figure
for S=1:8
    subplot(4,2,S)
    LV = Experiment.Subject(S).Phase28_RndTbcktoPints<Crit; % flags data
    % < outlier criterions
    D = Experiment.Subject(S).Phase28_RndTbcktoPints(LV);
    cdfplot(D)
    hold on
    t = linspace(0,Crit);
    plot(t,expcdf(t,Experiment.Subject(S).Phase28_PhatExpFitRndTbcktoP),'r')
    if S==1
        title('Phase 28 (87% gratis): S1');legend('Data','ExpFit','location','SE')
    else
        title(['S' num2str(S)])
    end
    if S>6
        xlabel('r<rndT (s)')
    else
        xlabel('')
    end
    if mod(S,2)>0
        ylabel('Cum Frac Intvls')
    else
        ylabel('')
    end
end
saveas(gcf,'ScriptCreatedFigures/S5 Gratis87%expoFits')

figure
for S=1:8
    subplot(4,2,S)
    LV = Experiment.Subject(S).Phase0_RndTbcktoPints<Crit; % flags data
    % < outlier criterions
    D = Experiment.Subject(S).Phase0_RndTbcktoPints(LV);
    cdfplot(D)
    hold on
    t = linspace(0,Crit);
    plot(t,expcdf(t,Experiment.Subject(S).Phase0_PhatExpFitRndTbcktoP),'r')
    if S==1
        title('Phase 0 (100% gratis): S1');legend('Data','ExpFit','location','SE')
    else
        title(['S' num2str(S)])
    end
    if S>6
        xlabel('r<rndT (s)')
    else
        xlabel('')
    end
    if mod(S,2)>0
        ylabel('Cum Frac Intvls')
    else
        ylabel('')
    end
end
saveas(gcf,'ScriptCreatedFigures/Gratis100%expoFits')
% With 2 exceptions in Phase 0, the exponential fits are excellent.
% There is no need to estimate entropies in Phase 0 because the
% distributions of intervals back from R and intervals back from random t's
% superpose in every case, telling us that there was 0 retrospective
% contingency. We are only interested in Phase 56 and Phase 28 entropies
% and these can now be estimated: The estimates of the basal
% entropies are obtained by using the best-fitting exponential to assign
% probability densities to bin centers and multiplying those probability
% densities by bin width to obtain probabilities. The choice of a bin width
% is dictated by the width of the bin that just captures the intervals from
% triggered reinforcements back to the most recent peck, the intervals that
% account for the initial step. The probability of a triggered
% reinforcement p_trig is the probability in the first bin. p_trig, the
% probability associated with the first bin, is the proportion of intervals
% <= 0.011 s, because the trigger latency was 0.01 s and jitter in the recording
% sometimes yielded measured trigger intervals of 0.011 s. The trigger
% interval (0.011 s) provides an empirically rooted bin width for the
% computation of the entropies. Probability estimates for the remaining
% bins of the same width are obtained from the best-fitting exponential.
% It assigns to each bin center a probability density. Multiplying the
% probability densities by the bin width (.011) and by (1-p_trig)--the
% fraction of the data that come from the exponential--we obtain a discrete
% probability vector that sums to 1-p_trig. The complete probability vector
% for the entropy of the mixture distribution has p_trig as its first value
% and the exponentially derived probabilities for all subsequent values.
% The probability vector for the basal entropy is simply the product of the
% bin width and the exponentially derived probabilities

%% Cell 20: Computing Retrospective Contingencies Phase56 & Phase28 (67% & 87% Gratis)
close all
TSapplystat({'Phase56RetroCont' 'Phase56p_trig'},{'Phase56_RbcktoPints' ...
    'Phase56_PhatExpFitRndTbcktoP'},@RetroCont) % 1st argument is cell
% array giving names of the fields into which the results are to be put
% (the entropy estimate and the estimate of the probabilty that a
% reinforcement was triggered by a peck); 2nd arg is cell array giving the
% names of the fields from which the data to be used come; 3rd arg is
% the handle on the custom function for computing the contingency

TSapplystat({'Phase28RetroCont' 'Phase28p_trig'},{'Phase28_RbcktoPints' ...
    'Phase28_PhatExpFitRndTbcktoP'},@RetroCont)
%{
function [Cont p_trig] = RetroCont(RbcktoPints,mu_hat)
% Computes the retrospective contingency between reinforcement and pecks in
% Experiment 3, where the RndTbcktoPints are exponentially distributed, as
% are the intervals back from the reinforcements not triggered by a peck

p_trig = sum(RbcktoPints<=.011)/length(RbcktoPints);

bc = .011/2:.011:15; % bin centers

p_basal = .011*exppdf(bc,mu_hat);

p_bckfrmR = [p_trig (1-p_trig)*p_basal];

H_pb = sum(p_basal.*log(1./p_basal)); % basal entropy

H_bR = sum(p_bckfrmR.*log(1./p_bckfrmR));

Cont = (H_pb - H_bR)/H_pb;    
%}
    
% Carrying retro contingencies up to Experiment level
TScombineover('Phase56RetroContingencies','Phase56RetroCont')
TScombineover('Phase28RetroContingencies','Phase28RetroCont')
Experiment.Phase167RetroContingencies = ones(8,1); % because r<-R dist has
% 0 entropy
Experiment.Phase0RetroContingencies = zeros(8,1); % because r<-R dist super-
% poses on r<-rndT dist, as expected

%% Cell 21: Mean Gratis R Peck Rates
TSapplystat('MeanGratisRpckRates','PeckRate_S',@MeanPckRatesV2,'Gratis')
% Creates a field at the Subject Level
% 1st arg is the name of the field into which the results are to be put;
% 2nd arg is the name of the field containing the data to be used; 3rd arg
% is the handle on the custom helper function; 4th arg tells helper
% function which which phase to do this for
%{
function MnR = MeanPckRatesV2(R,cond)
% computes the mean peck rate for the phases specified by cond argument,
% values for which are 'VI', 'Gratis' and 'Delay'

switch cond
    case 'VI'
        LV30 = R(:,2)<11; % logical vector flagging sessions for 1 phase
        LV165 = (R(:,2)>10)&(R(:,2)<21);
        LV300 = (R(:,2)>20)&(R(:,2)<31);
        MnR(1) = mean(R(LV30));
        MnR(2) = mean(R(LV165));
        MnR(3) = mean(R(LV300));
    case 'Gratis'
        LV167 = (R(:,2)>255)&(R(:,2)<276);
        LV56 = (R(:,2)>275)&(R(:,2)<316);
        LV28 = (R(:,2)>315)&(R(:,2)<356);
        LV0 = R(:,2)>355;
        MnR(1) = mean(R(LV167));
        MnR(2) = mean(R(LV56));
        MnR(3) = mean(R(LV28));
        MnR(4) = mean(R(LV0));
    case 'Delay'
        LV150 = (R(:,2)>30)&(R(:,2)<46);
        LV151 = (R(:,2)>45)&(R(:,2)<61);
        LV154 = (R(:,2)>60)&(R(:,2)<76);
        LV1516 = (R(:,2)>75)&(R(:,2)<91);
        LV1564 = (R(:,2)>90)&(R(:,2)<106);
        LV600 = (R(:,2)>105)&(R(:,2)<121);
        LV601 = (R(:,2)>120)&(R(:,2)<136);
        LV604 = (R(:,2)>135)&(R(:,2)<151);
        LV6016 = (R(:,2)>150)&(R(:,2)<166);
        LV6064 = (R(:,2)>165)&(R(:,2)<181);
        LV2400 = (R(:,2)>180)&(R(:,2)<196);
        LV2401 = (R(:,2)>195)&(R(:,2)<211);
        LV2404 = (R(:,2)>210)&(R(:,2)<226);
        LV24016 = (R(:,2)>225)&(R(:,2)<241);
        LV24064 = (R(:,2)>240)&(R(:,2)<256);
        MnR(1) = mean(R(LV150));
        MnR(2) = mean(R(LV151));
        MnR(3) = mean(R(LV154));
        MnR(4) = mean(R(LV1516));
        MnR(5) = mean(R(LV1564));
        MnR(6) = mean(R(LV600));
        MnR(7) = mean(R(LV601));
        MnR(8) = mean(R(LV604));
        MnR(9) = mean(R(LV6016));
        MnR(10) = mean(R(LV6064));
        MnR(11) = mean(R(LV2400));
        MnR(12) = mean(R(LV2401));
        MnR(13) = mean(R(LV2404));
        MnR(14) = mean(R(LV24016));
        MnR(15) = mean(R(LV24064));
end
%}
TScombineover('MeanGratisRpckRates_E','MeanGratisRpckRates')
TSapplystat('MeanNrmlzdGratisRpckRates','MeanGratisRpckRates_E',@nrmlz)

%% Cell 22: Graphing Normalized Mean Peck Rates Against Contingencies in
% Gratis R Experiment (Figure 10 in Research Gate MS; Figure 1 in Psych Review)
TSapplystat('',{'Phase0RetroContingencies' 'Phase28RetroContingencies' ...
    'Phase56RetroContingencies'  'Phase167RetroContingencies' ...
    'MeanNrmlzdGratisRpckRates'},@TSplot,'Xcol',4,'Ycol',5,'Xcol',3,'Ycol',6,...
    'Xcol',2,'Ycol',7,'Xcol',1,'Ycol',8,'Scat',{'k*' 'k*' 'k*' 'k*'},'Xlbl','r<-R Contingency',...
    'Ylbl','Normalized Mean Peck Rate','Rows',1,'Cols',1)
hold on
% Experiment.MeanGratisRpckRates_E;
plot([0 .11 .22 1],mean(Experiment.MeanNrmlzdGratisRpckRates(:,4:-1:1)),'ko--')
plot([.25 .25],ylim,'k-')
saveas(gcf,'ScriptCreatedFigures/originamsFig10_plshdFig1')

%% Cell 23: Graphing the r<-R & r<-rndT Distributions at Different Scales
% in Gratis R Experiment  (Figure 15 in the first MS)  
Phase56_RndTbcktoPints = Experiment.Subject(1).Phase56_RndTbcktoPints;
Phase56_RbcktoPints = Experiment.Subject(1).Phase56_RbcktoPints;
figure
LV1=Phase56_RndTbcktoPints<15; % getting rid of the gross outliers
LV2 = Phase56_RbcktoPints<15;
sum(LV2) % = 1522.00 n's for histograms
sum(LV1) % =1515.00

subplot(2,1,1)
    hist(Phase56_RbcktoPints(LV2),8)
    ylim([0 1500])
    set(gca,'FontSize',12,'YTick',[0 300 600 900 1200 1500],...
        'YTickLabel',{'0' '.2' '.4' '.6' '.8' '1.0'})
    xlabel('r<-R (s)')
    ylabel('Probability') 

subplot(2,1,2)
    hist(Phase56_RndTbcktoPints(LV1),8)
    ylim([0 1500])
    set(gca,'FontSize',12,'YTick',[0 300 600 900 1200 1500],...
        'YTickLabel',{'0' '.2' '.4' '.6' '.8' '1.0'})
    xlabel('r<-rndT (s)')
    ylabel('Probability')
saveas(gcf,'ScriptCreatedFigures/originalmsFig15')

% TSsaveexperiment
fprintf('\nThe Experiment structure has been saved at the conclusion of Cell 23\n')
%% Percent Triggered Reiforcements in Intermediate Gratis Conditions


%%                Delay of Reinforcement Experiment

%% CELL 24: Graphing Pecks/s vs Session for the Delay of Reinforcement Sessions
% (Figure 11 in first MS)
close all
TSapplystat('','PeckRate_S',@TSplot,'Xcol',2,'Ycol',1,'FrstRow',31,...
    'LstRow',255,'Scat','.')
hold on
for p=1:8 % stepping through the 8 plots on the active figure
    subplot(4,2,p) % makes the pth panel the active panel
    hold on
    plot([45.5 45.5],ylim,'k--')
    plot([60.5 60.5],ylim,'k--')
    plot([75.5 75.5],ylim,'k--')
    plot([90.5 90.5],ylim,'k--')
    plot([105.5 105.5],ylim,'k-')
    plot([120.5 120.5],ylim,'k--')
    plot([135.5 135.5],ylim,'k--')
    plot([150.5 150.5],ylim,'k--')
    plot([165.5 165.5],ylim,'k--')
    plot([180.5 180.5],ylim,'k-')
    plot([195.5 195.5],ylim,'k--')
    plot([210.5 210.5],ylim,'k--')
    plot([225.5 225.5],ylim,'k--')
    plot([240.5 240.5],ylim,'k--')
    if p>6
        xlabel('Session')
    else
        xlabel('')
    end
    if mod(p,2)>0
        ylabel('Pecks/min')
    else
        ylabel('')
    end 
end
saveas(gcf,'ScriptCreatedFigures/originalmsFig11')


%% Cell 25: r<-R Intervals in the Delay of Reinforcement Condition

TSlimit('Sessions','all') % next command limits the Sessions to those where
% the r<-R intervals varies.
TSlimit('Phases',[151 154 1516 1564 601 604 6016 6064 2401 2404 24016 24064])
TSapplystat({'RbckToP' 'RndTbcktoP'},'TSData',@RetroInts,Peck,Feed)
% For the code for RetroInts, see Cell 17

% Bringing Phase-specific retrospective intervals up to Subject level
% Copied here for ease of ref: TSlimit('Phases',[151 154 1516 1564 601 604
% 6016 6064 2401 2404 24016 24064])
TSlimit('Phases',151)
TScombineover('Phase151_RbcktoPints','RbckToP')
TScombineover('Phase151_RndTbcktoPints','RndTbcktoP')

TSlimit('Phases',154)
TScombineover('Phase154_RbcktoPints','RbckToP')
TScombineover('Phase154_RndTbcktoPints','RndTbcktoP')

TSlimit('Phases',1516)
TScombineover('Phase1516_RbcktoPints','RbckToP')
TScombineover('Phase1516_RndTbcktoPints','RndTbcktoP')

TSlimit('Phases',1564)
TScombineover('Phase1564_RbcktoPints','RbckToP')
TScombineover('Phase1564_RndTbcktoPints','RndTbcktoP')

TSlimit('Phases',601)
TScombineover('Phase601_RbcktoPints','RbckToP')
TScombineover('Phase601_RndTbcktoPints','RndTbcktoP')

TSlimit('Phases',604)
TScombineover('Phase604_RbcktoPints','RbckToP')
TScombineover('Phase604_RndTbcktoPints','RndTbcktoP')

TSlimit('Phases',6016)
TScombineover('Phase6016_RbcktoPints','RbckToP')
TScombineover('Phase6016_RndTbcktoPints','RndTbcktoP')

TSlimit('Phases',6064)
TScombineover('Phase6064_RbcktoPints','RbckToP')
TScombineover('Phase6064_RndTbcktoPints','RndTbcktoP')

TSlimit('Phases',2401)
TScombineover('Phase2401_RbcktoPints','RbckToP')
TScombineover('Phase2401_RndTbcktoPints','RndTbcktoP')

TSlimit('Phases',2404)
TScombineover('Phase2404_RbcktoPints','RbckToP')
TScombineover('Phase2404_RndTbcktoPints','RndTbcktoP')

TSlimit('Phases',24016)
TScombineover('Phase24016_RbcktoPints','RbckToP')
TScombineover('Phase24016_RndTbcktoPints','RndTbcktoP')

TSlimit('Phases',24064)
TScombineover('Phase24064_RbcktoPints','RbckToP')
TScombineover('Phase24064_RndTbcktoPints','RndTbcktoP')


%% Cell 26: Histograms for estimating RbcktoP entropies (last fig is Fig 12
% in first MS)

for S=1:8
    subplot(4,2,S)
    hist(Experiment.Subject(S).Phase154_RbcktoPints)
    xlim([0 max(Experiment.Subject(S).Phase154_RbcktoPints)])
    ylabel('Instances')
    xlabel('RbcktoP')
    if S==1
        title('Phase 154')
    end
end
%
figure
for S=1:8
    subplot(4,2,S)   
    hist(Experiment.Subject(S).Phase1516_RbcktoPints)
    xlabel('RbcktoP')
    xlim([0 max(Experiment.Subject(S).Phase1516_RbcktoPints)])
    ylabel('Instances')
    if S < 2
        title('Phase 1516')
    end
end
    
figure
for S=1:8
    subplot(4,2,S)
    hist(Experiment.Subject(S).Phase1564_RbcktoPints)
    xlabel('RbcktoP')
    xlim([0 max(Experiment.Subject(S).Phase1564_RbcktoPints)])
    ylabel('Instances')
    if S<2
        title('Phase 1564')
    end    
end    


figure
for S=1:8
    subplot(4,2,S)
    hist(Experiment.Subject(S).Phase604_RbcktoPints)
    xlabel('RbcktoP')
    xlim([0 max(Experiment.Subject(S).Phase604_RbcktoPints)])
    ylabel('Instances')
    if S<2
        title('Phase 604')
    end    
end

figure
for S=1:8
    subplot(4,2,S)
    hist(Experiment.Subject(S).Phase6016_RbcktoPints)
    xlabel('RbcktoP')
    xlim([0 max(Experiment.Subject(S).Phase6016_RbcktoPints)])
    ylabel('Instances')
    if S<2
        title('Phase 6016')
    end
end

figure
for S=1:8
    subplot(4,2,S)
    hist(Experiment.Subject(S).Phase6064_RbcktoPints)
    xlabel('RbcktoP')
    xlim([0 max(Experiment.Subject(S).Phase6064_RbcktoPints)])
    ylabel('Instances')
    if S<2
        title('Phase 6064')
    end
end

figure
for S=1:8
    subplot(4,2,S)
    hist(Experiment.Subject(S).Phase2404_RbcktoPints)
    xlabel('RbcktoP')
    xlim([0 max(Experiment.Subject(S).Phase2404_RbcktoPints)])
    ylabel('Instances')
    if S<2
        title('Phase 2404')
    end
end 

figure
for S=1:8
    subplot(4,2,S)
    hist(Experiment.Subject(S).Phase24016_RbcktoPints)
    xlabel('RbcktoP')
    xlim([0 max(Experiment.Subject(S).Phase24016_RbcktoPints)])
    ylabel('Instances')
    if S<2
        title('Phase 24016')
    end
end
%
figure % This is Figure 12 in the Research Gate MS; Figure 2 in Psych Rev
for S=1:8
    subplot(4,2,S)    
    hist(Experiment.Subject(S).Phase24064_RbcktoPints)
    xlabel('RbcktoP')
    xlim([0 max(Experiment.Subject(S).Phase24064_RbcktoPints)])
    if mod(S,2)>0
        ylabel('Instances')
    else
        ylabel('')
    end
    if S>6
        xlabel('r<-R Interval (s)')
    else
        xlabel('')
    end
    switch S
        case 1
            ylim([0 150])
        case 2
            ylim([0 250])
        case 3
            ylim([0 300])
        case 4
            ylim([0 500])
        case 5
            ylim([0 400])
        case 6
            ylim([0 150])
        case 7
            ylim([0 250])
        case 8
            ylim([0 300])
    end
end
saveas(gcf,'ScriptCreatedFigures/originalmsFig12_pblshdMSfig2')
%
% These r<-R distributions are highly irregular so we cannot obtain estimates
% of p values by fitting them with some common analytic distribution.
% Therefore, we must use "plug-in" estimates, that is, the raw estimates
% obtained from these histograms. To do this we use 10-bin histograms, so the
% bin widths are scaled to the delay (for the 0.4 delay, the bin widths are
% .04; for the 6.4 delay, they are 0.64). When we do this, there are often
% bins that have 0 counts, that is, bins for which the plug-in p is 0. We
% ignore these bins, that is, we treat them as if they were not part of the
% support for the distribution. The justification for this is that
% p*log(1/p)->0 as p->0. However, one may wonder how much this distorts
% the estimate of the entropy. When it comes to estimating the basal
% entropy, that is, the entropy of the distribution of intervals measured
% backwards from randomly chosen t's to the most recent peck, it is
% possible to check on how much distortion this may or may not produce,
% because we find that these distributions are generally well described by
% Weibull distributions. Thus, we can obtain two sets of p values for
% these distributions. One set, the plug-in set, is obtained using the same
% bin widths for these histograms as we used for the r<-R. Here, too, we
% simply ignore bins with 0 p estimates. The other set is obtained
% from the best-fitting Weibull distribution. This set has a non-zero p for
% every bin within the range of the data. The RetroConting helper function
% called upon in the following code gives both estimates

%% Cell 27: Computing r<-R Contingencies in Delay Experiment 4 different ways
close all
TSlimit('Subjects','all')
% 
TSapplystat('Phase2404RetroCont',{'Phase2404_RbcktoPints' ...
    'Phase2404_RndTbcktoPints'},@RetroConting3,false)
% Creates field at Subject level with 4 columns and 8 rows. Rows are
% subjects; odd cols are linear bin widths; even cols log bin widths; first
% two cols are for 3-bit precision; last two are for 4-bit
% 1st arg is field into which estimates of retro 
% contingency will be put; 2nd arg is cell array with the names of the 
% fields containing the data to be used; 3rd arg is the handle on the custom
% helper function, which is reproduced in the comments at the end of this
% sequence of commands; final argument is passed to the helper function to
% control whether it does (true) or does not (false, default) produce 
% figures. Don't set this to true for all of the commands at once, because
% that may generate so many figures that it freezes Matlab.
TSapplystat('Phase24016RetroCont',{'Phase24016_RbcktoPints' ...
    'Phase24016_RndTbcktoPints'},@RetroConting3,false)
TSapplystat('Phase24064RetroCont',{'Phase24064_RbcktoPints' ...
    'Phase24064_RndTbcktoPints'},@RetroConting3,false)

TSapplystat('Phase154RetroCont',{'Phase154_RbcktoPints' ...
   'Phase154_RndTbcktoPints'}, @RetroConting3,false) 
%
TSapplystat('Phase1516RetroCont',{'Phase1516_RbcktoPints' ...
    'Phase1516_RndTbcktoPints'},@RetroConting3,false)
%
TSapplystat('Phase1564RetroCont',{'Phase1564_RbcktoPints' ...
    'Phase1564_RndTbcktoPints'},@RetroConting3,false)

TSapplystat('Phase604RetroCont',{'Phase604_RbcktoPints' ...
    'Phase604_RndTbcktoPints'},@RetroConting3,false)
TSapplystat('Phase6016RetroCont',{'Phase6016_RbcktoPints' ...
    'Phase6016_RndTbcktoPints'},@RetroConting3,false)
TSapplystat('Phase6064RetroCont',{'Phase6064_RbcktoPints' ...
    'Phase6064_RndTbcktoPints'},@RetroConting3,false)
%{
function Cont = RetroConting3(RbcktoPints,RndTbcktoPints,fig)
% computes an estimate of the retrocontingency given the 
% precision (in bits) with which intervals are assumed to be represented.
% The precision is determined by the assumed Weber fraction. An assumed
% fraction of .125 implies 4 bits of precision, which is to say a standard
% deviation of 1/2^(bts-1) = 1/2^3 = 1 part in 8 of the mean; whereas an
% assumed fraction of .25 implies 3 pits of precision, which is to say a
% standard deviation of 1/2^2 = 1 part in 4 of the mean. It returns a row
% vector of 4 estimates. Element 1 assumes 3-bit representation of the
% intervals with linear bin widths; Element 2 assumes 3-bit rep w log bin
% widths; Element 3 assumes 4-bit rep w linear bin widths; Element 4
% assumes 4-bit rep w log bin widths. This is the code that revealed the
% minimum contingency when the entropies of hang-fire delay distributions 
% are computed using linear partitions.  
%
if isempty(fig)
    fig = false;
end
Cont = nan(1,4);
LRbcktoPints = log10(RbcktoPints);
LRndTbcktoPints = log10(RndTbcktoPints);
%
Mn = min([LRbcktoPints;LRndTbcktoPints]);
LRbcktoPintsT = abs(Mn) + LRbcktoPints; % all logs >=0
LRndTbcktoPintsT = abs(Mn) + LRndTbcktoPints; % ditto
%
Mxlin = max([RbcktoPints;RndTbcktoPints]); % longest interval
Mx = max([LRbcktoPintsT;LRndTbcktoPintsT]); % biggest log

Lvls8 = 8; % # number of distinguishable intervals; hence # of bins in
% plug=in entropy; hence # of distinct probabilities
Lvls16 = 16;
dF8 = 1/Lvls8; % delta fraction
dF16 = 1/Lvls16;
%
CVf8 = [.5*dF8 dF8*(1:(Lvls8-1))+.5*dF8]'; % critical levels within the range
EdgesLog8 = [0;CVf8*Mx]; % logarithmic bin edges
EdgesLin8 = [0;CVf8*Mxlin]; % linear bin edges

CVf16 = [.5*dF16 dF16*(1:(Lvls16-1))+.5*dF16]'; % critical levels within the range
EdgesLog16 = [0;CVf16*Mx]; % logarithmic bin edges
EdgesLin16 = [0;CVf16*Mxlin]; % linear bin edges
%
N8 = histc(LRbcktoPintsT,EdgesLog8); % counts for the conditional distribution
% using logarithmic bins
Nl8 = histc(RbcktoPints,EdgesLin8);

N16 = histc(LRbcktoPintsT,EdgesLog16); % counts for the conditional distribution
% using 16 logarithmic bins
Nl16 = histc(RbcktoPints,EdgesLin16); % ditto for linear bins

if fig
    S=evalin('caller','sub');
    figure
    subplot(4,2,1)
        bar(EdgesLin8,Nl8,'hist');title('CondCnts Lin8');xlabel('P<?R (s)')
    subplot(4,2,2)
        bar(EdgesLog8+Mn,N8,'hist');title('CondCnts Log8');xlabel('log_1_0(P<?R)')
    subplot(4,2,5)
        bar(EdgesLin16,Nl16,'hist');title('CondCnts Lin16');xlabel('P<?R (s)')
    subplot(4,2,6)
        bar(EdgesLog16+Mn,N16,'hist');title('CondCnts Log16');xlabel('log_1_0(P<?R)')
end
p8 = N8/sum(N8); % counts into log bins converted to probabilities
pl8 = Nl8/sum(Nl8); % counts into linear bins converted to probabilities

p16 = N16/sum(N16); % counts into log bins converted to probabilities
pl16 = Nl16/sum(Nl16); % counts into linear bins converted to probabilities

H_Rb8 = nansum(p8.*log(1./p8)); % estimated entropy of the RbcktoP, the
%  entropy of the conditional distribution using 8 log bins
H_RbL8 = nansum(pl8.*log(1./pl8)); % ditto using 8 linear bins

H_Rb16 = nansum(p16.*log(1./p16)); % estimated entropy of the RbcktoP, the
%  entropy of the conditional distribution using 16 log bins
H_RbL16 = nansum(pl16.*log(1./pl16));

N8 = histc(LRndTbcktoPintsT,EdgesLog8); % counts in log bins for Pck<-RndT
Nl8 = histc(RndTbcktoPints,EdgesLin8); % ditto for linear bins

N16 = histc(LRndTbcktoPintsT,EdgesLog16); % counts in log bins for Pck<-RndT
Nl16 = histc(RndTbcktoPints,EdgesLin16); % ditto for linear bins
if fig
    subplot(4,2,3)
        bar(EdgesLin8,Nl8,'hist');title('UnCondCnts Lin8');xlabel('P<?rndT (s)')
    subplot(4,2,4)
        bar(EdgesLog8+Mn,N8,'hist');title('UnCondCnts Log8');xlabel('log_1_0(P<?rndT)')
    subplot(4,2,7)
        bar(EdgesLin16,Nl16,'hist');title('UnCondCnts Lin16');xlabel('P<?rndT (s)')
    subplot(4,2,8)
        bar(EdgesLog16+Mn,N16,'hist');title('UnCondCnts Log16');xlabel('log_1_0(P<?rndT)')
end   
P8 = N8/sum(N8); % converted to probabilities
Pl8 = Nl8/sum(Nl8);

P16 = N16/sum(N16); % converted to probabilities
Pl16 = Nl16/sum(Nl16);

H_rndTb8 = nansum(P8.*log(1./P8)); % entropy of the RndTbcktoP, the entropy
% of the uncondtional or basal distribution, using log bins
H_rndTbL8 = nansum(Pl8.*log(1./Pl8)); % ditto for linear bins

H_rndTb16 = nansum(P16.*log(1./P16)); % entropy of the RndTbcktoP, the entropy
% of the uncondtional or basal distribution, using log bins
H_rndTbL16 = nansum(Pl16.*log(1./Pl16)); % ditto for linear bins

Cont(1,1) = (H_rndTbL8 - H_RbL8)/H_rndTbL8; % subjective contingency w
% linear bins and 3 bit temporal resolution
Cont(1,2) = (H_rndTb8 - H_Rb8)/H_rndTb8; % subjective contingency using log
% bins and 3 bit temporal resolutions

Cont(1,3) = (H_rndTbL16 - H_RbL16)/H_rndTbL16; % subjective contingency w
% linear bins and 4 bit temporal resolution
Cont(1,4) = (H_rndTb16 - H_Rb16)/H_rndTb16; % subjective contingency using
% log bins and 4 bit temporal resolutions
%}
    
% Aggregating contingency estimates at Experiment level
TSlimit('Subjects','all')
TScombineover('Phase154RetroContingencies','Phase154RetroCont')
TScombineover('Phase1516RetroContingencies','Phase1516RetroCont')
TScombineover('Phase1564RetroContingencies','Phase1564RetroCont')
TScombineover('Phase604RetroContingencies','Phase604RetroCont')
TScombineover('Phase6016RetroContingencies','Phase6016RetroCont')
TScombineover('Phase6064RetroContingencies','Phase6064RetroCont')
TScombineover('Phase2404RetroContingencies','Phase2404RetroCont')
TScombineover('Phase24016RetroContingencies','Phase24016RetroCont')
TScombineover('Phase24064RetroContingencies','Phase24064RetroCont')

%% Cell 28: Normalized Mean Peck Rates in Delayed R Experiment
TSapplystat('MeanDelayRpckRates','PeckRate_S',@MeanPckRatesV2,'Delay')
% Creates 15-col field at the Subject level. For helper function code, see
% Cell 21
TScombineover('MeanDelayRpckRates_E','MeanDelayRpckRates')
% Each row is a subject; each column is 1 of the 15 conditions (3 VIs x 5
% trigger delays)
TSapplystat('MeanNrmlzdDelayRpckRates','MeanDelayRpckRates_E',@nrmlz)
%{
function PRn = nrmlz(PR)
M = max(PR,[],2); % max peck rate for each bird
NF = repmat(M,1,size(PR,2)); % making array same size as PR
PRn = PR./NF; % dividing by normalizing factor
%}
% TSsaveexperiment
fprintf('\nThe Experiment structure has been saved at the conclusion of Cell 28\n')

%% Cell 29:  Figures 3 & 4 in Psych Review:
% Double-y axis figures, with left axis plotting mean peck rate (not
% normalized!) against hang-fire delays (on x axis) and right axis plotting
% contingency vs those delays. Each figure is 8 rows x 3 columns, one row
% for each bird and one column for each VI. First figure plots linear
% contingency; second plots logarithmic contingency. 3 bits (8 bins) in
% both cases

xVals = log10([.01 .1 .4 1.6 6.4]);

figure % first of the two figures
Y1 = Experiment.MeanDelayRpckRates_E; % 8 x 15 column array; rows are birds
% Cols 1:5 are from the 5 hang-fire intervals with VI15; Cols 6-10 same
% with VI60; Cols 11-15 same with VI 240. The contingencies for the 0 and
% .1 hang fire are all 1. 
Y2_15 = [repmat([1 1],8,1) Experiment.Phase154RetroContingencies(:,1) ...
    Experiment.Phase1516RetroContingencies(:,1) ...
    Experiment.Phase1564RetroContingencies(:,1)];
    % The linear 3-bit contingencies are in Col 1 of these fields
Y2_60 = [repmat([1 1],8,1) Experiment.Phase604RetroContingencies(:,1) ...
    Experiment.Phase6016RetroContingencies(:,1) ...
    Experiment.Phase6064RetroContingencies(:,1)];
Y2_240 = [repmat([1 1],8,1) Experiment.Phase2404RetroContingencies(:,1) ...
    Experiment.Phase24016RetroContingencies(:,1) ...
    Experiment.Phase24064RetroContingencies(:,1)];

subplot(8,3,1)
    [Ax,~,H2] = plotyy(xVals,Y1(1,1:5),xVals,Y2_15(1,:));
    hold(Ax(2));plot(Ax(2),xlim,[.25 .25],':k')
    set(Ax(1),'XTick',10,'XTickLabel',{'.01' '0.1' '0.4' '1.6' '6.4'},...
        'Xlim',[-2.1 log10(7)],'YLim',[0 141],'YTick',[0 40 80 120])
    set(Ax(2),'Xlim',[-2.1 log10(7)],'YLim',[0 1.05],'YColor','k','YTick',1.5);
    set(H2,'Marker','*','Color','k','LineStyle','--')

    title('VI15s','FontWeight','normal')
subplot(8,3,2)
    [Ax,~,H2] = plotyy(xVals,Y1(1,6:10),xVals,Y2_60(1,:));
    hold(Ax(2));plot(Ax(2),xlim,[.25 .25],':k')
    set(Ax(1),'XTick',10,'XTickLabel',{'.01' '0.1' '0.4' '1.6' '6.4'},...
        'Xlim',[-2.1 log10(7)],'YLim',[0 141],'YTick',150)
    set(Ax(2),'Xlim',[-2.1 log10(7)],'YLim',[0 1.05],'YColor','k','YTick',1.5);
    set(H2,'Marker','*','Color','k','LineStyle','--')
     title('VI60s','FontWeight','normal')
subplot(8,3,3)
    [Ax,~,H2] = plotyy(xVals,Y1(1,11:15),xVals,Y2_240(1,:));
    hold(Ax(2));plot(Ax(2),xlim,[.25 .25],':k')
    set(Ax(1),'XTick',10,'XTickLabel',{'.01' '0.1' '0.4' '1.6' '6.4'},...
        'Xlim',[-2.1 log10(7)],'YLim',[0 141],'YTick',150)
    set(Ax(2),'Xlim',[-2.1 log10(7)],'YLim',[0 1.05],'YColor','k','YTick',[0 .5 1]);
    set(H2,'Marker','*','Color','k','LineStyle','--')
    title('VI240s','FontWeight','normal')
    
subplot(8,3,4)
    [Ax,~,H2] = plotyy(xVals,Y1(2,1:5),xVals,Y2_15(2,:));
    hold(Ax(2));plot(Ax(2),xlim,[.25 .25],':k')
    set(Ax(1),'XTick',10,'XTickLabel',{'.01' '0.1' '0.4' '1.6' '6.4'},...
        'Xlim',[-2.1 log10(7)],'YLim',[0 141],'YTick',[0 40 80 120])
    set(Ax(2),'Xlim',[-2.1 log10(7)],'YLim',[0 1.05],'YColor','k','YTick',150);
    set(H2,'Marker','*','Color','k','LineStyle','--')
subplot(8,3,5)
    [Ax,~,H2] = plotyy(xVals,Y1(2,6:10),xVals,Y2_60(2,:));
    hold(Ax(2));plot(Ax(2),xlim,[.25 .25],':k')
    set(Ax(1),'XTick',10,'XTickLabel',{'.01' '0.1' '0.4' '1.6' '6.4'},...
        'Xlim',[-2.1 log10(7)],'YLim',[0 141],'YTick',150)
    set(Ax(2),'Xlim',[-2.1 log10(7)],'YLim',[0 1.05],'YColor','k','YTick',150);
    set(H2,'Marker','*','Color','k','LineStyle','--')
subplot(8,3,6)
    [Ax,~,H2] = plotyy(xVals,Y1(2,11:15),xVals,Y2_240(2,:));
    hold(Ax(2));plot(Ax(2),xlim,[.25 .25],':k')
    set(Ax(1),'XTick',10,'XTickLabel',{'.01' '0.1' '0.4' '1.6' '6.4'},...
        'Xlim',[-2.1 log10(7)],'YLim',[0 141],'YTick',150)
    set(Ax(2),'Xlim',[-2.1 log10(7)],'YLim',[0 1.05],'YColor','k','YTick',[0 .5 1]);
    set(H2,'Marker','*','Color','k','LineStyle','--')
    
subplot(8,3,7)
    [Ax,~,H2] = plotyy(xVals,Y1(3,1:5),xVals,Y2_15(3,:));
    hold(Ax(2));plot(Ax(2),xlim,[.25 .25],':k')
    set(Ax(1),'XTick',10,'XTickLabel',{'.01' '0.1' '0.4' '1.6' '6.4'},...
        'Xlim',[-2.1 log10(7)],'YLim',[0 141],'YTick',[0 40 80 120])
    set(Ax(2),'Xlim',[-2.1 log10(7)],'YLim',[0 1.05],'YColor','k','YTick',150);
    set(H2,'Marker','*','Color','k','LineStyle','--')
subplot(8,3,8)
    [Ax,~,H2] = plotyy(xVals,Y1(3,6:10),xVals,Y2_60(3,:));
    hold(Ax(2));plot(Ax(2),xlim,[.25 .25],':k')
    set(Ax(1),'XTick',10,'XTickLabel',{'.01' '0.1' '0.4' '1.6' '6.4'},...
        'Xlim',[-2.1 log10(7)],'YLim',[0 141],'YTick',150)
    set(Ax(2),'Xlim',[-2.1 log10(7)],'YLim',[0 1.05],'YColor','k','YTick',150);
    set(H2,'Marker','*','Color','k','LineStyle','--')
subplot(8,3,9)
    [Ax,~,H2] = plotyy(xVals,Y1(3,11:15),xVals,Y2_240(3,:));
    hold(Ax(2));plot(Ax(2),xlim,[.25 .25],':k')
    set(Ax(1),'XTick',10,'XTickLabel',{'.01' '0.1' '0.4' '1.6' '6.4'},...
        'Xlim',[-2.1 log10(7)],'YLim',[0 141],'YTick',150)
    set(Ax(2),'Xlim',[-2.1 log10(7)],'YLim',[0 1.05],'YColor','k','YTick',[0 .5 1]);
    set(H2,'Marker','*','Color','k','LineStyle','--')
    
subplot(8,3,10)
    [Ax,~,H2] = plotyy(xVals,Y1(4,1:5),xVals,Y2_15(4,:));
    hold(Ax(2));plot(Ax(2),xlim,[.25 .25],':k')
    set(Ax(1),'XTick',10,'XTickLabel',{'.01' '0.1' '0.4' '1.6' '6.4'},...
        'Xlim',[-2.1 log10(7)],'YLim',[0 141],'YTick',[0 40 80 120])
    set(Ax(2),'Xlim',[-2.1 log10(7)],'YLim',[0 1.05],'YColor','k','YTick',150);
    set(H2,'Marker','*','Color','k','LineStyle','--')
subplot(8,3,11)
    [Ax,~,H2] = plotyy(xVals,Y1(4,6:10),xVals,Y2_60(4,:));
    hold(Ax(2));plot(Ax(2),xlim,[.25 .25],':k')
    set(Ax(1),'XTick',10,'XTickLabel',{'.01' '0.1' '0.4' '1.6' '6.4'},...
        'Xlim',[-2.1 log10(7)],'YLim',[0 141],'YTick',150)
    set(Ax(2),'Xlim',[-2.1 log10(7)],'YLim',[0 1.05],'YColor','k','YTick',150);
    set(H2,'Marker','*','Color','k','LineStyle','--')
subplot(8,3,12)
    [Ax,~,H2] = plotyy(xVals,Y1(4,11:15),xVals,Y2_240(4,:));
    hold(Ax(2));plot(Ax(2),xlim,[.25 .25],':k')
    set(Ax(1),'XTick',10,'XTickLabel',{'.01' '0.1' '0.4' '1.6' '6.4'},...
        'Xlim',[-2.1 log10(7)],'YLim',[0 141],'YTick',150)
    set(Ax(2),'Xlim',[-2.1 log10(7)],'YLim',[0 1.05],'YColor','k','YTick',[0 .5 1]);
    set(H2,'Marker','*','Color','k','LineStyle','--')
    
subplot(8,3,13)
    [Ax,~,H2] = plotyy(xVals,Y1(5,1:5),xVals,Y2_15(5,:));
    hold(Ax(2));plot(Ax(2),xlim,[.25 .25],':k')
    set(Ax(1),'XTick',10,'XTickLabel',{'.01' '0.1' '0.4' '1.6' '6.4'},...
        'Xlim',[-2.1 log10(7)],'YLim',[0 141],'YTick',[0 40 80 120])
    set(Ax(2),'Xlim',[-2.1 log10(7)],'YLim',[0 1.05],'YColor','k','YTick',150);
    set(H2,'Marker','*','Color','k','LineStyle','--')
subplot(8,3,14)
    [Ax,~,H2] = plotyy(xVals,Y1(5,6:10),xVals,Y2_60(5,:));
    hold(Ax(2));plot(Ax(2),xlim,[.25 .25],':k')
    set(Ax(1),'XTick',10,'XTickLabel',{'.01' '0.1' '0.4' '1.6' '6.4'},...
        'Xlim',[-2.1 log10(7)],'YLim',[0 141],'YTick',150)
    set(Ax(2),'Xlim',[-2.1 log10(7)],'YLim',[0 1.05],'YColor','k','YTick',150);
    set(H2,'Marker','*','Color','k','LineStyle','--')
subplot(8,3,15)
    [Ax,~,H2] = plotyy(xVals,Y1(5,11:15),xVals,Y2_240(5,:));
    hold(Ax(2));plot(Ax(2),xlim,[.25 .25],':k')
    set(Ax(1),'XTick',10,'XTickLabel',{'.01' '0.1' '0.4' '1.6' '6.4'},...
        'Xlim',[-2.1 log10(7)],'YLim',[0 141],'YTick',150)
    set(Ax(2),'Xlim',[-2.1 log10(7)],'YLim',[0 1.05],'YColor','k','YTick',[0 .5 1]);
    set(H2,'Marker','*','Color','k','LineStyle','--')
    
subplot(8,3,16)
    [Ax,~,H2] = plotyy(xVals,Y1(6,1:5),xVals,Y2_15(6,:));
    hold(Ax(2));plot(Ax(2),xlim,[.25 .25],':k')
    set(Ax(1),'XTick',10,'XTickLabel',{'.01' '0.1' '0.4' '1.6' '6.4'},...
        'Xlim',[-2.1 log10(7)],'YLim',[0 141],'YTick',[0 40 80 120])
    set(Ax(2),'Xlim',[-2.1 log10(7)],'YLim',[0 1.05],'YColor','k','YTick',150);
    set(H2,'Marker','*','Color','k','LineStyle','--')
  
subplot(8,3,17)
    [Ax,~,H2] = plotyy(xVals,Y1(6,6:10),xVals,Y2_60(6,:));
    hold(Ax(2));plot(Ax(2),xlim,[.25 .25],':k')
    set(Ax(1),'XTick',10,'XTickLabel',{'.01' '0.1' '0.4' '1.6' '6.4'},...
        'Xlim',[-2.1 log10(7)],'YLim',[0 141],'YTick',150)
    set(Ax(2),'Xlim',[-2.1 log10(7)],'YLim',[0 1.05],'YColor','k','YTick',150);
    set(H2,'Marker','*','Color','k','LineStyle','--')
subplot(8,3,18)
    [Ax,~,H2] = plotyy(xVals,Y1(6,11:15),xVals,Y2_240(6,:));
    hold(Ax(2));plot(Ax(2),xlim,[.25 .25],':k')
    set(Ax(1),'XTick',10,'XTickLabel',{'.01' '0.1' '0.4' '1.6' '6.4'},...
        'Xlim',[-2.1 log10(7)],'YTick',150)
    set(Ax(2),'Xlim',[-2.1 log10(7)],'YLim',[0 141],'YLim',[0 1.05],'YColor','k','YTick',[0 .5 1]);
    set(H2,'Marker','*','Color','k','LineStyle','--')
    
subplot(8,3,19)
    [Ax,~,H2] = plotyy(xVals,Y1(7,1:5),xVals,Y2_15(7,:));
    hold(Ax(2));plot(Ax(2),xlim,[.25 .25],':k')
    set(Ax(1),'XTick',10,'XTickLabel',{'.01' '0.1' '0.4' '1.6' '6.4'},...
        'Xlim',[-2.1 log10(7)],'YLim',[0 141],'YTick',[0 40 80 120])
    set(Ax(2),'Xlim',[-2.1 log10(7)],'YLim',[0 1.05],'YColor','k','YTick',150);
    set(H2,'Marker','*','Color','k','LineStyle','--')
subplot(8,3,20)
    [Ax,~,H2] = plotyy(xVals,Y1(7,6:10),xVals,Y2_60(7,:));
    hold(Ax(2));plot(Ax(2),xlim,[.25 .25],':k')
    set(Ax(1),'XTick',10,'XTickLabel',{'.01' '0.1' '0.4' '1.6' '6.4'},...
        'Xlim',[-2.1 log10(7)],'YLim',[0 141],'YTick',150)
    set(Ax(2),'Xlim',[-2.1 log10(7)],'YLim',[0 1.05],'YColor','k','YTick',150);
    set(H2,'Marker','*','Color','k','LineStyle','--')
subplot(8,3,21)
    [Ax,~,H2] = plotyy(xVals,Y1(7,11:15),xVals,Y2_240(7,:));
    hold(Ax(2));plot(Ax(2),xlim,[.25 .25],':k')
    set(Ax(1),'XTick',10,'XTickLabel',{'.01' '0.1' '0.4' '1.6' '6.4'},...
        'Xlim',[-2.1 log10(7)],'YLim',[0 141],'YTick',150)
    set(Ax(2),'Xlim',[-2.1 log10(7)],'YLim',[0 1.05],'YColor','k','YTick',[0 .5 1]);
    set(H2,'Marker','*','Color','k','LineStyle','--')
    
subplot(8,3,22)
    [Ax,~,H2] = plotyy(xVals,Y1(8,1:5),xVals,Y2_15(8,:));
    hold(Ax(2));plot(Ax(2),xlim,[.25 .25],':k')
    set(Ax(1),'XTick',xVals,'XTickLabel',{'.01' '0.1' '0.4' '1.6' '6.4'},...
        'Xlim',[-2.1 log10(7)],'YLim',[0 141],'YTick',[0 40 80 120])
    set(Ax(2),'Xlim',[-2.1 log10(7)],'YLim',[0 1.05],'YColor','k','YTick',150);
    set(H2,'Marker','*','Color','k','LineStyle','--')
subplot(8,3,23)
    [Ax,~,H2] = plotyy(xVals,Y1(8,6:10),xVals,Y2_60(8,:));
    hold(Ax(2));plot(Ax(2),xlim,[.25 .25],':k')
    set(Ax(1),'XTick',xVals,'XTickLabel',{'.01' '0.1' '0.4' '1.6' '6.4'},...
        'Xlim',[-2.1 log10(7)],'YLim',[0 141],'YTick',150)
    set(Ax(2),'Xlim',[-2.1 log10(7)],'YLim',[0 1.05],'YColor','k','YTick',150);
    set(H2,'Marker','*','Color','k','LineStyle','--')
     xlabel('Hang-Fire Int (s, log scale)')
subplot(8,3,24)
    [Ax,~,H2] = plotyy(xVals,Y1(8,11:15),xVals,Y2_240(8,:));
    hold(Ax(2));plot(Ax(2),xlim,[.25 .25],':k')
    set(Ax(1),'XTick',xVals,'XTickLabel',{'.01' '0.1' '0.4' '1.6' '6.4'},...
        'Xlim',[-2.1 log10(7)],'YLim',[0 141],'YTick',150)
    set(Ax(2),'Xlim',[-2.1 log10(7)],'YLim',[0 1.05],'YColor','k','YTick',[0 .5 1]);
    set(H2,'Marker','*','Color','k','LineStyle','--')
 saveas(gcf,'ScriptCreatedFigures/Fig3inPblshdMS')  

% Second of the two figures: 3-bit logarithmic contingency on right axis
figure % first of the two figures
Y1 = Experiment.MeanDelayRpckRates_E; % 8 x 15 column array; rows are birds
% Cols 1:5 are from the 5 hang-fire intervals with VI15; Cols 6-10 same
% with VI60; Cols 11-15 same with VI 240. The contingencies for the 0 and
% .1 hang fire are all 1. 
Y2_15 = [repmat([1 1],8,1) Experiment.Phase154RetroContingencies(:,2) ...
    Experiment.Phase1516RetroContingencies(:,2) ...
    Experiment.Phase1564RetroContingencies(:,2)];
    % The llogarithmic 3-bit contingencies are in Col 2 of these fields
Y2_60 = [repmat([1 1],8,1) Experiment.Phase604RetroContingencies(:,2) ...
    Experiment.Phase6016RetroContingencies(:,2) ...
    Experiment.Phase6064RetroContingencies(:,2)];
Y2_240 = [repmat([1 1],8,1) Experiment.Phase2404RetroContingencies(:,2) ...
    Experiment.Phase24016RetroContingencies(:,2) ...
    Experiment.Phase24064RetroContingencies(:,2)];

subplot(8,3,1)
    [Ax,~,H2] = plotyy(xVals,Y1(1,1:5),xVals,Y2_15(1,:));
    hold(Ax(2));plot(Ax(2),xlim,[.25 .25],':k')
    set(Ax(1),'XTick',10,'XTickLabel',{'.01' '0.1' '0.4' '1.6' '6.4'},...
        'Xlim',[-2.1 log10(7)],'YLim',[0 141],'YTick',[0 40 80 120])
    set(Ax(2),'Xlim',[-2.1 log10(7)],'YLim',[0 1.05],'YColor','k','YTick',1.5);
    set(H2,'Marker','*','Color','k','LineStyle','--')

    title('VI15s','FontWeight','normal')
subplot(8,3,2)
    [Ax,~,H2] = plotyy(xVals,Y1(1,6:10),xVals,Y2_60(1,:));
    hold(Ax(2));plot(Ax(2),xlim,[.25 .25],':k')
    set(Ax(1),'XTick',10,'XTickLabel',{'.01' '0.1' '0.4' '1.6' '6.4'},...
        'Xlim',[-2.1 log10(7)],'YLim',[0 141],'YTick',150)
    set(Ax(2),'Xlim',[-2.1 log10(7)],'YLim',[0 1.05],'YColor','k','YTick',1.5);
    set(H2,'Marker','*','Color','k','LineStyle','--')
     title('VI60s','FontWeight','normal')
subplot(8,3,3)
    [Ax,~,H2] = plotyy(xVals,Y1(1,11:15),xVals,Y2_240(1,:));
    hold(Ax(2));plot(Ax(2),xlim,[.25 .25],':k')
    set(Ax(1),'XTick',10,'XTickLabel',{'.01' '0.1' '0.4' '1.6' '6.4'},...
        'Xlim',[-2.1 log10(7)],'YLim',[0 141],'YTick',150)
    set(Ax(2),'Xlim',[-2.1 log10(7)],'YLim',[0 1.05],'YColor','k','YTick',[0 .5 1]);
    set(H2,'Marker','*','Color','k','LineStyle','--')
    title('VI240s','FontWeight','normal')
    
subplot(8,3,4)
    [Ax,~,H2] = plotyy(xVals,Y1(2,1:5),xVals,Y2_15(2,:));
    hold(Ax(2));plot(Ax(2),xlim,[.25 .25],':k')
    set(Ax(1),'XTick',10,'XTickLabel',{'.01' '0.1' '0.4' '1.6' '6.4'},...
        'Xlim',[-2.1 log10(7)],'YLim',[0 141],'YTick',[0 40 80 120])
    set(Ax(2),'Xlim',[-2.1 log10(7)],'YLim',[0 1.05],'YColor','k','YTick',150);
    set(H2,'Marker','*','Color','k','LineStyle','--')
subplot(8,3,5)
    [Ax,~,H2] = plotyy(xVals,Y1(2,6:10),xVals,Y2_60(2,:));
    hold(Ax(2));plot(Ax(2),xlim,[.25 .25],':k')
    set(Ax(1),'XTick',10,'XTickLabel',{'.01' '0.1' '0.4' '1.6' '6.4'},...
        'Xlim',[-2.1 log10(7)],'YLim',[0 141],'YTick',150)
    set(Ax(2),'Xlim',[-2.1 log10(7)],'YLim',[0 1.05],'YColor','k','YTick',150);
    set(H2,'Marker','*','Color','k','LineStyle','--')
subplot(8,3,6)
    [Ax,~,H2] = plotyy(xVals,Y1(2,11:15),xVals,Y2_240(2,:));
    hold(Ax(2));plot(Ax(2),xlim,[.25 .25],':k')
    set(Ax(1),'XTick',10,'XTickLabel',{'.01' '0.1' '0.4' '1.6' '6.4'},...
        'Xlim',[-2.1 log10(7)],'YLim',[0 141],'YTick',150)
    set(Ax(2),'Xlim',[-2.1 log10(7)],'YLim',[0 1.05],'YColor','k','YTick',[0 .5 1]);
    set(H2,'Marker','*','Color','k','LineStyle','--')
    
subplot(8,3,7)
    [Ax,~,H2] = plotyy(xVals,Y1(3,1:5),xVals,Y2_15(3,:));
    hold(Ax(2));plot(Ax(2),xlim,[.25 .25],':k')
    set(Ax(1),'XTick',10,'XTickLabel',{'.01' '0.1' '0.4' '1.6' '6.4'},...
        'Xlim',[-2.1 log10(7)],'YLim',[0 141],'YTick',[0 40 80 120])
    set(Ax(2),'Xlim',[-2.1 log10(7)],'YLim',[0 1.05],'YColor','k','YTick',150);
    set(H2,'Marker','*','Color','k','LineStyle','--')
subplot(8,3,8)
    [Ax,~,H2] = plotyy(xVals,Y1(3,6:10),xVals,Y2_60(3,:));
    hold(Ax(2));plot(Ax(2),xlim,[.25 .25],':k')
    set(Ax(1),'XTick',10,'XTickLabel',{'.01' '0.1' '0.4' '1.6' '6.4'},...
        'Xlim',[-2.1 log10(7)],'YLim',[0 141],'YTick',150)
    set(Ax(2),'Xlim',[-2.1 log10(7)],'YLim',[0 1.05],'YColor','k','YTick',150);
    set(H2,'Marker','*','Color','k','LineStyle','--')
subplot(8,3,9)
    [Ax,~,H2] = plotyy(xVals,Y1(3,11:15),xVals,Y2_240(3,:));
    hold(Ax(2));plot(Ax(2),xlim,[.25 .25],':k')
    set(Ax(1),'XTick',10,'XTickLabel',{'.01' '0.1' '0.4' '1.6' '6.4'},...
        'Xlim',[-2.1 log10(7)],'YLim',[0 141],'YTick',150)
    set(Ax(2),'Xlim',[-2.1 log10(7)],'YLim',[0 1.05],'YColor','k','YTick',[0 .5 1]);
    set(H2,'Marker','*','Color','k','LineStyle','--')
    
subplot(8,3,10)
    [Ax,~,H2] = plotyy(xVals,Y1(4,1:5),xVals,Y2_15(4,:));
    hold(Ax(2));plot(Ax(2),xlim,[.25 .25],':k')
    set(Ax(1),'XTick',10,'XTickLabel',{'.01' '0.1' '0.4' '1.6' '6.4'},...
        'Xlim',[-2.1 log10(7)],'YLim',[0 141],'YTick',[0 40 80 120])
    set(Ax(2),'Xlim',[-2.1 log10(7)],'YLim',[0 1.05],'YColor','k','YTick',150);
    set(H2,'Marker','*','Color','k','LineStyle','--')
subplot(8,3,11)
    [Ax,~,H2] = plotyy(xVals,Y1(4,6:10),xVals,Y2_60(4,:));
    hold(Ax(2));plot(Ax(2),xlim,[.25 .25],':k')
    set(Ax(1),'XTick',10,'XTickLabel',{'.01' '0.1' '0.4' '1.6' '6.4'},...
        'Xlim',[-2.1 log10(7)],'YLim',[0 141],'YTick',150)
    set(Ax(2),'Xlim',[-2.1 log10(7)],'YLim',[0 1.05],'YColor','k','YTick',150);
    set(H2,'Marker','*','Color','k','LineStyle','--')
subplot(8,3,12)
    [Ax,~,H2] = plotyy(xVals,Y1(4,11:15),xVals,Y2_240(4,:));
    hold(Ax(2));plot(Ax(2),xlim,[.25 .25],':k')
    set(Ax(1),'XTick',10,'XTickLabel',{'.01' '0.1' '0.4' '1.6' '6.4'},...
        'Xlim',[-2.1 log10(7)],'YLim',[0 141],'YTick',150)
    set(Ax(2),'Xlim',[-2.1 log10(7)],'YLim',[0 1.05],'YColor','k','YTick',[0 .5 1]);
    set(H2,'Marker','*','Color','k','LineStyle','--')
    
subplot(8,3,13)
    [Ax,~,H2] = plotyy(xVals,Y1(5,1:5),xVals,Y2_15(5,:));
    hold(Ax(2));plot(Ax(2),xlim,[.25 .25],':k')
    set(Ax(1),'XTick',10,'XTickLabel',{'.01' '0.1' '0.4' '1.6' '6.4'},...
        'Xlim',[-2.1 log10(7)],'YLim',[0 141],'YTick',[0 40 80 120])
    set(Ax(2),'Xlim',[-2.1 log10(7)],'YLim',[0 1.05],'YColor','k','YTick',150);
    set(H2,'Marker','*','Color','k','LineStyle','--')
subplot(8,3,14)
    [Ax,~,H2] = plotyy(xVals,Y1(5,6:10),xVals,Y2_60(5,:));
    hold(Ax(2));plot(Ax(2),xlim,[.25 .25],':k')
    set(Ax(1),'XTick',10,'XTickLabel',{'.01' '0.1' '0.4' '1.6' '6.4'},...
        'Xlim',[-2.1 log10(7)],'YLim',[0 141],'YTick',150)
    set(Ax(2),'Xlim',[-2.1 log10(7)],'YLim',[0 1.05],'YColor','k','YTick',150);
    set(H2,'Marker','*','Color','k','LineStyle','--')
subplot(8,3,15)
    [Ax,~,H2] = plotyy(xVals,Y1(5,11:15),xVals,Y2_240(5,:));
    hold(Ax(2));plot(Ax(2),xlim,[.25 .25],':k')
    set(Ax(1),'XTick',10,'XTickLabel',{'.01' '0.1' '0.4' '1.6' '6.4'},...
        'Xlim',[-2.1 log10(7)],'YLim',[0 141],'YTick',150)
    set(Ax(2),'Xlim',[-2.1 log10(7)],'YLim',[0 1.05],'YColor','k','YTick',[0 .5 1]);
    set(H2,'Marker','*','Color','k','LineStyle','--')
    
subplot(8,3,16)
    [Ax,~,H2] = plotyy(xVals,Y1(6,1:5),xVals,Y2_15(6,:));
    hold(Ax(2));plot(Ax(2),xlim,[.25 .25],':k')
    set(Ax(1),'XTick',10,'XTickLabel',{'.01' '0.1' '0.4' '1.6' '6.4'},...
        'Xlim',[-2.1 log10(7)],'YLim',[0 141],'YTick',[0 40 80 120])
    set(Ax(2),'Xlim',[-2.1 log10(7)],'YLim',[0 1.05],'YColor','k','YTick',150);
    set(H2,'Marker','*','Color','k','LineStyle','--')
  
subplot(8,3,17)
    [Ax,~,H2] = plotyy(xVals,Y1(6,6:10),xVals,Y2_60(6,:));
    hold(Ax(2));plot(Ax(2),xlim,[.25 .25],':k')
    set(Ax(1),'XTick',10,'XTickLabel',{'.01' '0.1' '0.4' '1.6' '6.4'},...
        'Xlim',[-2.1 log10(7)],'YLim',[0 141],'YTick',150)
    set(Ax(2),'Xlim',[-2.1 log10(7)],'YLim',[0 1.05],'YColor','k','YTick',150);
    set(H2,'Marker','*','Color','k','LineStyle','--')
subplot(8,3,18)
    [Ax,~,H2] = plotyy(xVals,Y1(6,11:15),xVals,Y2_240(6,:));
    hold(Ax(2));plot(Ax(2),xlim,[.25 .25],':k')
    set(Ax(1),'XTick',10,'XTickLabel',{'.01' '0.1' '0.4' '1.6' '6.4'},...
        'Xlim',[-2.1 log10(7)],'YTick',150)
    set(Ax(2),'Xlim',[-2.1 log10(7)],'YLim',[0 141],'YLim',[0 1.05],'YColor','k','YTick',[0 .5 1]);
    set(H2,'Marker','*','Color','k','LineStyle','--')
    
subplot(8,3,19)
    [Ax,~,H2] = plotyy(xVals,Y1(7,1:5),xVals,Y2_15(7,:));
    hold(Ax(2));plot(Ax(2),xlim,[.25 .25],':k')
    set(Ax(1),'XTick',10,'XTickLabel',{'.01' '0.1' '0.4' '1.6' '6.4'},...
        'Xlim',[-2.1 log10(7)],'YLim',[0 141],'YTick',[0 40 80 120])
    set(Ax(2),'Xlim',[-2.1 log10(7)],'YLim',[0 1.05],'YColor','k','YTick',150);
    set(H2,'Marker','*','Color','k','LineStyle','--')
subplot(8,3,20)
    [Ax,~,H2] = plotyy(xVals,Y1(7,6:10),xVals,Y2_60(7,:));
    hold(Ax(2));plot(Ax(2),xlim,[.25 .25],':k')
    set(Ax(1),'XTick',10,'XTickLabel',{'.01' '0.1' '0.4' '1.6' '6.4'},...
        'Xlim',[-2.1 log10(7)],'YLim',[0 141],'YTick',150)
    set(Ax(2),'Xlim',[-2.1 log10(7)],'YLim',[0 1.05],'YColor','k','YTick',150);
    set(H2,'Marker','*','Color','k','LineStyle','--')
subplot(8,3,21)
    [Ax,~,H2] = plotyy(xVals,Y1(7,11:15),xVals,Y2_240(7,:));
    hold(Ax(2));plot(Ax(2),xlim,[.25 .25],':k')
    set(Ax(1),'XTick',10,'XTickLabel',{'.01' '0.1' '0.4' '1.6' '6.4'},...
        'Xlim',[-2.1 log10(7)],'YLim',[0 141],'YTick',150)
    set(Ax(2),'Xlim',[-2.1 log10(7)],'YLim',[0 1.05],'YColor','k','YTick',[0 .5 1]);
    set(H2,'Marker','*','Color','k','LineStyle','--')
    
subplot(8,3,22)
    [Ax,~,H2] = plotyy(xVals,Y1(8,1:5),xVals,Y2_15(8,:));
    hold(Ax(2));plot(Ax(2),xlim,[.25 .25],':k')
    set(Ax(1),'XTick',xVals,'XTickLabel',{'.01' '0.1' '0.4' '1.6' '6.4'},...
        'Xlim',[-2.1 log10(7)],'YLim',[0 141],'YTick',[0 40 80 120])
    set(Ax(2),'Xlim',[-2.1 log10(7)],'YLim',[0 1.05],'YColor','k','YTick',150);
    set(H2,'Marker','*','Color','k','LineStyle','--')
subplot(8,3,23)
    [Ax,~,H2] = plotyy(xVals,Y1(8,6:10),xVals,Y2_60(8,:));
    hold(Ax(2));plot(Ax(2),xlim,[.25 .25],':k')
    set(Ax(1),'XTick',xVals,'XTickLabel',{'.01' '0.1' '0.4' '1.6' '6.4'},...
        'Xlim',[-2.1 log10(7)],'YLim',[0 141],'YTick',150)
    set(Ax(2),'Xlim',[-2.1 log10(7)],'YLim',[0 1.05],'YColor','k','YTick',150);
    set(H2,'Marker','*','Color','k','LineStyle','--')
     xlabel('Hang-Fire Int (s, log scale)')
subplot(8,3,24)
    [Ax,~,H2] = plotyy(xVals,Y1(8,11:15),xVals,Y2_240(8,:));
    hold(Ax(2));plot(Ax(2),xlim,[.25 .25],':k')
    set(Ax(1),'XTick',xVals,'XTickLabel',{'.01' '0.1' '0.4' '1.6' '6.4'},...
        'Xlim',[-2.1 log10(7)],'YLim',[0 141],'YTick',150)
    set(Ax(2),'Xlim',[-2.1 log10(7)],'YLim',[0 1.05],'YColor','k','YTick',[0 .5 1]);
    set(H2,'Marker','*','Color','k','LineStyle','--')
saveas(gcf,'ScriptCreatedFigures/Fig4inPblshdMS')


%% Cell 30: Graphing the r<R & r<-rndT distributions for S1 at different delays &
% different scales to illustrate the effect of scale on contingency
% (Figure 14 in the first MS; Figure 5 in Psych Review)
close all
Phase604_RbcktoPints = Experiment.Subject(1).Phase604_RbcktoPints;
Phase604_RndTbcktoPints = Experiment.Subject(1).Phase604_RndTbcktoPints;
Phase6064_RbcktoPints = Experiment.Subject(1).Phase6064_RbcktoPints;
Phase6064_RndTbcktoPints = Experiment.Subject(1).Phase6064_RndTbcktoPints;
%
U1=[Phase604_RbcktoPints;Phase604_RndTbcktoPints];
edges1 = linspace(min(U1),max(U1),8);
U2 = [Phase6064_RbcktoPints;Phase6064_RndTbcktoPints];
edges2=linspace(min(U2),max(U2),8);
%
N1c = histc(Phase604_RbcktoPints,edges1);
N1u = histc(Phase604_RndTbcktoPints,edges1);
N2c = histc(Phase6064_RbcktoPints,edges2);
N2u = histc(Phase6064_RndTbcktoPints,edges2);

figure
subplot(3,2,1)
    hist(Phase604_RbcktoPints,8)
    set(gca,'FontSize',12,'YTick',[100 200 300],'YTickLabel',{'.17' '.34' '.5'})
    ylabel('Probability')
    xlabel('r<-R (s)')
    title('S1: VI60 Delay 0.4s')
    xlim([0 .45])
subplot(3,2,2)
    hist(Phase6064_RbcktoPints,8)
    set(gca,'FontSize',12,'YTick',[50 100 150 200],'YTickLabel',{'.08' '.17' '.25' '.33'})
    xlim([0 6.5])
    xlabel('r<-R (s)')
    title('S1: VI60 Delay 6.4s')
subplot(3,2,3)
    bar(edges1,N1c,'histc')
    set(gca,'FontSize',12,'YTick',[200 400 600],'YTickLabel',{'.33' '.67' '1.0'})
    xlim([0 16])
    ylabel('Probability')
    xlabel('r<-R (s)')
subplot(3,2,4)
    bar(edges2,N2c,'histc')
    set(gca,'FontSize',12,'YTick',[200 400 600],'YTickLabel',{'.33' '.67' '1.0'})
    xlim([0 90])
    xlabel('r<-R (s)')
subplot(3,2,5)
    bar(edges1,N1u,'histc')
    set(gca,'FontSize',12,'YTick',[200 400 600],'YTickLabel',{'.33' '.67' '1.0'})
    xlim([0 16])
    ylabel('Probability')
    xlabel('r<?rndT (s)')
subplot(3,2,6)
    bar(edges2,N2u,'histc')
    set(gca,'FontSize',12,'YTick',[200 400 600],'YTickLabel',{'.33' '.67' '1.0'})
    xlim([0 90])
    xlabel('r<-rndT (s)')
fprintf('The Experiment structure has been saved at the\nconclusion of Cell 30,the last data-analysis cell\n')
TSsaveexperiment
saveas(gcf,'ScriptCreatedFigures/originalmsFig14fig5inpblshdMS')
% ET = toc;

return
%% Simulations w 30s Resetting Delay (Figure 16 in first MS)
% Code from here on irrelevant to Psych Review paper but interesting to
% specialists
close all
%% simulating contingency btw rate of pecking and inter-reinforcement
% interval for resetting 30s delay protocol, assuming exponential
% distribution of interresponse intervals
d = 30; % delay in seconds
mu = [8 16 32 64]; % expected inter-peck interval in seconds
I = nan(1000,4);
T = nan(1001,4);
RT = cell(1,4);
r = cell(1,4);
tsd = cell(1,4);
IRI = cell(1,4);
N=(1:1001)'; % count vector
NP = cell(1,4);
%
for c=1:4
    %%
    I(:,c) = exprnd(mu(c),1000,1);
    T(:,c) = [0;cumsum(I(:,c))]; % elapsed time
    LV = I(:,c)>d; % flags inter-peck intervals that produce reinforcement
    LVt = [LV;false]; % flags trigger pecks
    r{c} = N(LV); % row #s of peck triggering intervals
    RT{c} = T(LV,c)+d; % reinforcement times
    tsd{c} = sortrows([[T(:,c) Peck*ones(size(T(:,c)))];[RT{c} Feed*ones(size(RT{c}))]]);
    IRI{c} = [RT{c}(1);diff(RT{c})]; 
     % inter-reinforcement intervals
    NP{c} = [r{c}(1);diff(r{c})];% peck counts within the IRIs
end
%% 
for c = 2:4
    lam = NP{c}./IRI{c};
    figure;scatterhist(lam,IRI{c},'NBins',8,'Direction','out')
    set(gca,'FontSize',14)
end
figure(1)
set(gca,'XTick',[.025 .05 .075],'XTickLabel',{'40' '20' '13'})
xlabel('Average Inter-Peck Int (s)')
ylabel('Inter-Reinf Int (s)')
text(.025,500,'C_r_-_>_R=.00')
text(.025,450,'C_r_<_-_R=1.0')
text(.025,400,'C(8,8)=.18')
title('\mu = 16s')
saveas(gcf,'ScriptCreatedFigures/msFig16ExpoSim30sReset_mu16s')

figure(2)
set(gca,'XTick',[.025 .05 .075],'XTickLabel',{'40' '20' '13'})
xlabel('Average Inter-Peck Int (s)')
ylabel('Inter-Reinf Int (s)')
text(.05,260,'C_r_-_>_R=.17')
text(.05,230,'C_r_<_-_R=1.0')
text(.05,200,'C(8,8)=.08')
title('\mu = 32s')
saveas(gcf,'ScriptCreatedFigures/msFig16ExpoSim30sReset_mu32s')

figure(3)
set(gca,'XTick',[.025 .05 .075],'XTickLabel',{'40' '20' '13'})
xlabel('Average Inter-Peck Int (s)')
ylabel('Inter-Reinf Int (s)')
text(.05,400,'C_r_-_>_R=.58')
text(.05,350,'C_r_<_-_R=1.0')
text(.05,300,'C(8,8)=.22')
title('\mu = 64s')
saveas(gcf,'ScriptCreatedFigures/msFig16ExpoSim30sReset_mu64s')

%% IRI vs Rate Contingency in Exponential Simulations
C88e = nan(1,4);
for c = 2:4
    lam = NP{c}./IRI{c};
    lamedges = linspace(0,max(lam)+.01,9);
    IRIedges = linspace(29,max(IRI{c}+1),9);
    hstmat = hist2(lam,IRI{c},lamedges,IRIedges);
    % the sum across the columns of hstmat gives the marginal lam distribution;
    % the sum down the rows gives the marginal IRI distribution
    %
    M_lam = sum(hstmat,2);
    M_IRI = sum(hstmat);
    N = sum(hstmat(:));
    p_lam = M_lam/N;
    p_IRI = M_IRI/N;
    p_jnt = hstmat/N;
    H_lam = nansum(p_lam.*log(1./p_lam));
    H_IRI = nansum(p_IRI.*log(1./p_IRI));
    H_jnt = nansum(p_jnt(:).*log(1./p_jnt(:)));
    C88e(c) = (H_IRI+H_lam-H_jnt)/H_IRI;
end
%% Prospective & Retrospective Contingencies in exponential case
% Retrospective contingencies are always 1, because the peck that
% immediately precedes a reinforcement always comes 30s earlier
pRints = cell(1,4);
rndInts = cell(1,4);
CpRe = nan(1,4);
for c = 1:4
    pRints{c} = rRints(tsd{c},Peck,Feed);
    rndInts{c} = rndtRInts(tsd{c},Peck,Feed);
    U = [pRints{c};rndInts{c}-1]; % union of the sets of intervals
    Edges = linspace(min(U)-1,max(U)+1,9); % bin edges
    NpR = histc(pRints{c},Edges);
    p_pR = NpR/sum(NpR);
    H_pR = nansum(p_pR.*log(1./p_pR));
    Nrnd = histc(rndInts{c},Edges);
    p_rndR = Nrnd/sum(Nrnd);
    H_rndR = nansum(p_rndR.*log(1./p_rndR));
    CpRe(c) = (H_rndR-H_pR)/H_rndR;
    if CpRe(c)<0
        CpRe(c)=0;
    end
end

%% Contingency Simulation with Normally Distributed Pecks
% interval for resetting 30s delay protocol, assuming normal
% distribution of interresponse intervals
d = 30; % delay in seconds
mu = [20 26 32 40]; % expected inter-peck interval in seconds
w = .25; % Weber fraction
I = nan(1000,4);
T = nan(1001,4);
RT = cell(1,4);
r = cell(1,4);
tsd = cell(1,4);
IRI = cell(1,4);
N=(1:1001)'; % count vector
NP = cell(1,4);
%
for c=1:4
    %%
    I(:,c) = normrnd(mu(c),w*mu(c),1000,1);
    T(:,c) = [0;cumsum(I(:,c))]; % elapsed time
    LV = I(:,c)>d; % flags inter-peck intervals that produce reinforcement
    LVt = [LV;false]; % flags trigger pecks
    r{c} = N(LV); % row #s of peck triggering intervals
    RT{c} = T(LV,c)+d; % reinforcement times
    tsd{c} = sortrows([[T(:,c) Peck*ones(size(T(:,c)))];[RT{c} Feed*ones(size(RT{c}))]]);
    IRI{c} = [RT{c}(1);diff(RT{c})]; 
     % inter-reinforcement intervals
    NP{c} = [r{c}(1);diff(r{c})];% peck counts within the IRIs
end
%% IRI vs Rate Contingency in Gaussian Simulations
C88g = nan(1,4);
for c = 2:4
    lam = NP{c}./IRI{c};
    lamedges = linspace(0,max(lam)+.01,9);
    IRIedges = linspace(29,max(IRI{c}+1),9);
    hstmat = hist2(lam,IRI{c},lamedges,IRIedges);
    % the sum across the columns of hstmat gives the marginal lam distribution;
    % the sum down the rows gives the marginal IRI distribution
    %
    M_lam = sum(hstmat,2);
    M_IRI = sum(hstmat);
    N = sum(hstmat(:));
    p_lam = M_lam/N;
    p_IRI = M_IRI/N;
    p_jnt = hstmat/N;
    H_lam = nansum(p_lam.*log(1./p_lam));
    H_IRI = nansum(p_IRI.*log(1./p_IRI));
    H_jnt = nansum(p_jnt(:).*log(1./p_jnt(:)));
    C88g(c) = (H_IRI+H_lam-H_jnt)/H_IRI;
end
% C88g = NaN          0.20          0.17          0.28
%% Prospective & Retrospective Contingencies in Gaussian Simulations (2nd
% col of 
% Retrospective are always 1
pRints = cell(1,4);
rndInts = cell(1,4);
CpRg = nan(1,4);
for c = 1:4
    pRints{c} = rRints(tsd{c},Peck,Feed);
    rndInts{c} = rndtRInts(tsd{c},Peck,Feed);
    U = [pRints{c};rndInts{c}-1]; % union of the sets of intervals
    Edges = linspace(min(U)-1,max(U)+1,9); % bin edges
    NpR = histc(pRints{c},Edges);
    p_pR = NpR/sum(NpR);
    H_pR = nansum(p_pR.*log(1./p_pR));
    Nrnd = histc(rndInts{c},Edges);
    p_rndR = Nrnd/sum(Nrnd);
    H_rndR = nansum(p_rndR.*log(1./p_rndR));
    CpRg(c) = (H_rndR-H_pR)/H_rndR;
    if CpRg(c)<0
        CpRg(c)=0;
    end
end
%%
for c = 2:4
    lam = NP{c}./IRI{c};
    figure;scatterhist(lam,IRI{c},'NBins',8,'Direction','out')
    set(gca,'FontSize',14)
end
%%
figure(1)
set(gca,'XTick',[.025 .033 .045],'XTickLabel',{'40' '30' '22'})
xlabel('Average Inter-Peck Int (s)')
ylabel('Inter-Reinf Int (s)')
text(.025,325,'C_r_-_>_R=.00')
text(.025,275,'C_r_<_-_R=1.0')
text(.025,225,'C(8,8)=.20')
title('\mu = 26s; \sigma=.25*20')
saveas(gcf,'ScriptCreatedFigures/msFig16GaussSim30ResetMu26Sig5')

figure(2)
set(gca,'XTick',[.025 .033 .045],'XTickLabel',{'40' '30' '22'})
xlabel('Average Inter-Peck Int (s)')
ylabel('Inter-Reinf Int (s)')
text(.02,250,'C_r_-_>_R=.17')
text(.02,200,'C_r_<_-_R=1.0')
text(.02,150,'C(8,8)=.17')
title('\mu = 32s; \sigma=.25*32')
saveas(gcf,'ScriptCreatedFigures/msFig16GaussSim30ResetMu32Sig8')

figure(3)
set(gca,'XTick',[.02 .033 .045],'XTickLabel',{'50' '30' '22'})
xlabel('Average Inter-Peck Int (s)')
ylabel('Inter-Reinf Int (s)')
text(.018,100,'C_r_-_>_R=.67')
text(.035,100,'C_r_<_-_R=1.0')
text(.035,90,'C(8,8)=.28')
title('\mu = 40s;\sigma=.25*40')
saveas(gcf,'ScriptCreatedFigures/msFig16GaussSim30ResetMu40Sig10')

close all
