# 🧠Electrophysiology Experiment Analysis Summative Coursework🧠

## Description
This is a summative coursework project where I have analysed a series of electrophysiology experiments to investigate the effect of various drug conditions on hippocampal synaptic responses. This repo includes the "epanalysis.m" MatLab script file containing the code for the analysis, "Electrophysiology_analysis_report.pdf" which describes in more detail the data, methodology and results, as well as all the required files for analysis (.wcp electrophysiology experiment files, "import_wcp.m" MatLab function file to import the .wcp files and "notebook.xlsx" containing the filenames of the .wcp files.)

 *Note:* "epanalysis.m" is a function that takes in "notebook.xlsx" as an input and returns:
 1. A figure showing a timecourse plot of peak amplitudes from an example .wcp file. 
 2. A table showing the the peak amplitude of each experiment for each drug condition.


## Installation and usage
If you would like to try this script yourself:
1. Download all the files in this repo
2. Create a new MatLab file and run the epanalysis() function with "notebook.xlsx" as the input
    - **OPTIONAL** If you'd like to see the timecourse plot for a different experiment, you can change the input value in **line 90** of "epanalysis.m" from timecourse(1) to your desired experiment number (from 1 to 6)
