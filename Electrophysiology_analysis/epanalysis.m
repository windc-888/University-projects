function [T]=epanalysis(notebookname)
%%
%INTRODUCTION

%This function outputs 2 things:
%1: A figure showing a timecourse plot of peak fESPS amplitude from an
%electrophysiology experiment.
%The figure is setup in a way that the first row shows the time-course plot
%and the bottom rows show 4 example peak fESPS traces from each of the 
%4 drug conditions.

%2: A table outlining the peak fESPS amplitudes for each experimental
%condition from all experiment trials + their means 

%This function also runs a statistical analysis on the data using 
%one-way ANOVA,and will display a character array stating whether the 
%test found any significant difference.

%If the test finds a significant difference, it will also output the 
%calculated p-value and run a multiple comparisons test, 
%which will output an additional figure showing which groups were 
%significantly different from each other


%FUNCTION INPUT/OUTPUT

%Output[T]= the summary table containing mean fESPS amplitudes
%Input(notebookname)= the name of the .xlxs file containing the names of 
%the electrophysiology experiment files


%%
%LOOP FUNCTION TO BATCH IMPORT DATA
notebook=readtable(notebookname);
num_exp=height(notebook); % finding number of experiments

%Preallocating some values
baselinedata=[]; % cell containing data that has been set to baseline=0
filterdata=[]; %cell containing data that has been filtered
windowdata=[]; %cell containing data from only the specified time window
peakdata=[]; %cell containing peak fESPS amplitudes 

for n=1:num_exp
    
    %Creating character array for each filename
    filename=char(notebook.Filename(n)); 
    alldata(n)=import_wcp(filename); %importing data
    
    %Setting baseline to 0
    baseline=mean(alldata(n).S{1}(1:80,:));
    baselinedata{n}=alldata(n).S{1}-baseline;
    
    %Filtering data using lowpass Butterworth filter 
    Fc=[250 250 250 250 150 250]; %cutoff values (see note at the end of
                                  %the section
    Fs=1/alldata(1).t_interval;  
    [b,a]=butter(4,Fc(n)/(Fs/2),'low');
    filterdata{n}=filtfilt(b,a,baselinedata{n});
    
    %Creating time axis
    timeaxis=0:alldata(1).t_interval:((height(alldata(1).S{:,1}))-1)...
        *alldata(1).t_interval;
    timeaxis=timeaxis'*1000; %converting to ms 
    
    %Finding data from time window
    %time window for 1st fESPS was determined to be 12-25 ms
    %We started at 12 because the stimulus was applied at 10 ms and we 
    %added an extra couple of ms so our analysis would ignore any
    %stimulus artifacts
    
    index=find(timeaxis>12 & timeaxis<25);
    windowdata{n}=filterdata{n}(index,:);
    
    %Finding peak amplitudes within time window
    peakdata{n}=min(windowdata{n});
    
    
    %*note: Cutoff values for the butterworth filter were determined
    %manually via trial and error by plotting the filtered data using
    %various cutoff values (ranging from 100-1000) on top of the raw data
    %and seeing which value resulted in the most suitably filtered line
    %ie. filtered enough but not so much that it distorts the original 
    %shape of the raw data
    
end 

%%
%PLOTTING TIME COURSE FOR EXPERIMENT 1
%Using the timecourse subfunction 
timecourse(1)


%%
%CREATING TABLE OUTPUT
%For loop to find peak amplitudes from all experiments 

%preallocating values
control_peak=zeros(1,6); %array containing all peak amplitudes for control
cado_peak=zeros(1,6); %array containing all peak amplitudes for CADO
dpcpx_peak=zeros(1,6); %array containing all peak amplitudes for DPCPX
nbqx_peak=zeros(1,6); %array containing all peak amplitudes for NBQX

for n=1:num_exp
    control_peak(n)=peakdata{n}((notebook.CADO(n))-1);
    cado_peak(n)=peakdata{n}((notebook.CADO_DPCPX(n))-1);
    dpcpx_peak(n)=peakdata{n}((notebook.CADO_DPCPX_NBQX(n))-1);
    nbqx_peak(n)=peakdata{n}((width(alldata(n).S{1,:}))-1);
end 

%Creating array with all the peak amplitude values
t=zeros(7,4);
t(1:6,1)=control_peak;
t(1:6,2)=cado_peak;
t(1:6,3)=dpcpx_peak;
t(1:6,4)=nbqx_peak;
t(7,:)=[mean(control_peak) mean(cado_peak) mean(dpcpx_peak)...
    mean(nbqx_peak)]; %last row contains all the means

T=array2table(t); %converting array to table 

%Setting table properties
T.Properties.VariableNames={'Control' 'CADO' 'DPCPX' 'NBQX'};
T.Properties.RowNames={char(notebook.Filename(1))...
    char(notebook.Filename(2)) char(notebook.Filename(3))...
    char(notebook.Filename(4)) char(notebook.Filename(5))...
    char(notebook.Filename(6)) 'Mean'};
T.Variables=round(T.Variables,3); % rounding values to 3 decimal points 



%%
%STATISTICAL ANALYSIS%

%Creating character array with all experimental conditions to be used
%as grouping variable for the anova test
Drugnames=char('Control','CADO','DPCPX','NBQX');

[p,~,stats]=anova1(t(1:6,:),Drugnames,'off'); %one-way ANOVA test

if p<0.05
    x=['There is evidence that mean fESPS peak amplitude is affected'...
        ' by the various drug treatments with a p-value of '...
        num2str(p)];
    disp(x)
    
    %Multiple comparisons test if ANOVA test was positive
    c=multcompare(stats);
    
else
    x=['There is no evidence that mean fESPS peak amplitude is affected'...
        ' by the various drug treatments.'];
    disp(x)
end

%%
%TIMECOURSE SUBFUNCTION

function timecourse(n)

%INFO

%This subfunction outputs a 2-by-4 timecourse subplot for 
%experiment number n.
%The top row subplots are the timecourse plot with lines showing when
%each drug was added and the bottom row 4 subplots show example traces
%of each of the 4 experimental conditions


%Making time axis for timecourse plot
num_rec=width(peakdata{n})-1;
timeaxis2=[0:10:num_rec*10];

%Creating subplots
tc=subplot(2,4,[1,4]); %main time course plot 
Control=subplot(2,4,5); %example trace for control
CADO=subplot(2,4,6); %example trace for CADO
DPCPX=subplot(2,4,7); %example trace for DPCPX
NBQX=subplot(2,4,8); %example trace for NBQX

%Time course plot
figure
plot(tc,timeaxis2,peakdata{n},'ok','MarkerFaceColor','w','MarkerSize',3)
set(tc,'YDir',"reverse")
ylabel(tc,'fESPS amplitude (mV)')
xlabel(tc,'time (s)')
ylim(tc,[-2 0])
title(tc,['Time course plot for experiment ' char(notebook.Filename(n))],...
    'Interpreter','none')

%Showing when each drug was added
hold(tc,"on")

x_cado=timeaxis2((notebook.CADO(n)):end); %creating X-axis for lines
x_dpxpc=timeaxis2(notebook.CADO_DPCPX(n):end);
x_nbqx=timeaxis2(notebook.CADO_DPCPX_NBQX(n):end);

y_cado=-1.*ones(1,length(x_cado)); %creating Y-axis for lines
y_dpxpc=-1.1.*ones(1,length(x_dpxpc));
y_nbqx=-1.2.*ones(1,length(x_nbqx));

p1=plot(tc,x_cado,y_cado,'LineWidth',3,'Color','#0072BD');
p2=plot(tc,x_dpxpc,y_dpxpc,'LineWidth',3,'Color','#77AC30');
p3=plot(tc,x_nbqx,y_nbqx,'LineWidth',3,'Color','#EDB120');

legend(tc,[p1 p2 p3],{'CADO','DPCPX','NBQX'},'Location',"northwest")

hold(tc,"off")

%Plotting the 4 example traces

%creating new time axis 
num_samp=height(alldata(n).S{:,1})-1;
time=[0:alldata(n).t_interval:num_samp*alldata(n).t_interval];
time=time'*1000;

%Traces taken at the time the next subsequent drug was added minus 1
%with the exception of the trace for NBQX as it is the final drug
%so its trace was taken as the total number of recordings minus 1 
plot(Control,time,filterdata{n}(:,(notebook.CADO(n))-1),'-k') %Control
plot(CADO,time,filterdata{n}(:,(notebook.CADO_DPCPX(n))-1),'-k') %CADO
plot(DPCPX,time,filterdata{n}(:,(notebook.CADO_DPCPX_NBQX(n))-1),'-k') %DPCPX
plot(NBQX,time,filterdata{n}(:,num_rec-1),'-k') %NBQX

%Setting plot params 

%setting axes limits
ylim([Control,CADO,DPCPX,NBQX],[-0.8 0.2]) 
xlim([Control,CADO,DPCPX,NBQX],[12 25])

%setting labels
ylabel(Control,'mV')
xlabel([Control,CADO,DPCPX,NBQX],'ms')

%setting titles
title(Control,'Control')
title(CADO,'CADO')
title(DPCPX,'DPCPX')
title(NBQX,'NBQX') 
end 
end 