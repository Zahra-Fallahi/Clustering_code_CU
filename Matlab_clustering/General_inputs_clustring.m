function [main_datafolder,flag_data_manual]=General_inputs_clustring

addpath([cd '/Functions']);       % load the sub-functions
mkdir('Readouts');                % make a folder for saving the intermediate results
main_datafolder = cd;
% Main data folder where the results can be found. Change this to the correct path on your computer

flag_data_manual=true;            % If you want to feed data manually in othwr forms than fullfeeder data.

end