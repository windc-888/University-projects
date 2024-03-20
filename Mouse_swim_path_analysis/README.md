# Mouse Swim Path Analysis Summative Coursework

## Description
This is a summative coursework project completed with MatLab where I have analysed 16 .tif movie files of mice swimming in the Morris water maze test (more information [here](https://en.wikipedia.org/wiki/Morris_water_navigation_task)). The purpose of this project was to assess whether mice with Alzheimer's disease showed differences in swim-path patterns compared to normal healthy mice. This repo includes the "S1_690056125.m" file, which is a MatLab script that performs the analyses and the "Mouse_swim_path_report.pdf" which describes in more detail the data, methodology and results, as well as the neccessary .tif movie files and .xlsx file needed to perform the analysis. 

*Note:* "S1_690056125.m" is a function that takes in the user's current directory containing all necessary .tif and .xlsx files as an input and returns: 
1. A MatLab struct output containing mouse pixel coordinates as well as cummulative distance travelled in the movie.
2. A boxplot summarising the cummulative distance travelled by healthy vs Alzheimer's mice.
3. A figure showing two example mouse swim paths from a healthy mouse and an Alzheimer's mouse.

## Installation and usage
If you would like to try this script yourself:
1. Download all the files in this repo to obtain all 16 .tif files, "bliding_list.xlsx" and "S1_690056125.m" into your local directory.
2. Create a new MatLab file and run the S1_690056125() function with your local directory containing the above files as the input.
