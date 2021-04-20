function [Shaped, Baseline]=Case_inputs_clustring(specifyload)
% Input data test case

cityCase = 'TX';  % options: 'TX', 'NY, 'LA'

% Input measurements for clustering
startdayForClust = '01';              % In case of 1 day: '01' or '02' or ... or '10' or '11' ... or '31'
simCaseForClust = 'Baseline';         % options: 'Baseline' (use 1 day), 'BaselineWeek' (use 1 week)

% Measurements used for clustering evaluation
startdayForEvaluation = '01';         % 'FullMonth' for a whole month. In case of 1 day: '01' or '02' or ... or '10' or '11' ... or '31'
simCaseForEvaluation = 'Shaped';    % 'Baseline' , 'Real-time Pricing' , ''

%% Climatic zone specific data
% dictionairies to translate choices to folder names
citycode      = {'NY', 'LA', 'TX'};
feedernamemat = {'R2_1247_3_', 'R3_1247_3_', 'R5_2500_1_'}; feedername = containers.Map(citycode, feedernamemat);
numbuildsWith_hvac_mat  = {1114, 711, 2098};                numbuildsWith_hvac_dict = containers.Map(citycode, numbuildsWith_hvac_mat);
numbuildsFull_mat  = {1506, 1326, 2146};                    numbuildsFull_dict = containers.Map(citycode, numbuildsFull_mat);
simcode       = {'Baseline','Real-time Pricing','BaselineWeek'};
extensionmat  = {'BASE', 'RTP_R2_INTERP', 'BASE'};          extensionname = containers.Map(simcode, extensionmat);
simfoldermat  = {'_jul_70pct_1_normal_','_jul_70pct_1_RTP_','_jul_normal_1_full_week_' }; simfoldername = containers.Map(simcode, simfoldermat);

% number of buildings
numbuildsFull = numbuildsFull_dict(cityCase);
numbuildsOnlyHvac = numbuildsWith_hvac_dict(cityCase);

%% Read out data used for clustering and evaluation
% Data folder
% fullfeederfolderClust = [ main_datafolder simCaseForClust filesep feedername(cityCase) extensionname(simCaseForClust) filesep startdayForClust simfoldername(simCaseForClust) cityCase ] % folder to find the results
fullfeederfolderClust='C:\Users\zahra\Dropbox\Corbin Data\Results for Zahra\R5_2500_1_BASE_SOLAR_HIGH\21_jul_100pct';
% Read out the results
savenameClust = [ cd '/Readouts/' simCaseForClust '_' cityCase '_day' startdayForClust '_full.mat'];
savenameClust_2=[ cd '/Readouts/' 'Optimized' '_' cityCase '_day' startdayForClust '_full.mat'];

if not(exist( savenameClust,'file' ))
    % if the specified data has never been read out yet, read it out now and save it
    fullfeederdata = readoutchad(fullfeederfolderClust,true,false);
    save(savenameClust,'fullfeederdata');
    fullfeederdataClust = fullfeederdata; % rename to use throughout the rest of the program
else
    Baseline_all=load(savenameClust);
    Shaped_all=load(savenameClust_2);
end

%% remove zero HVAC profiles
test=(mean(Baseline_all.Baseline_full.coolelec,2));
if specifyload==1
    Baseline = Baseline_all.Baseline_full.coolelec(find(test~=0),:);
    Shaped= Shaped_all.Optimized_full.coolelec(find(test~=0),:);
else
    Baseline = Baseline_all.Baseline_full.elec_net(find(test~=0),:);
    Shaped= Shaped_all.Optimized_full.elec_net(find(test~=0),:);
end

end