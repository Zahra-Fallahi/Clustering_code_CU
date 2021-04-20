function [ data2 ] = readoutchad( inputfolder, plotresults, alloutput )
%READOUTCHAD Read out results from Chad's simulations

tic

% read out the files
listing = dir(inputfolder);

% find the number of timesteps
thiscaseindoortemp = 0;
for i = 1:10
    % just scan the first 10 entries
    if length(listing(i).name) > 5
        if listing(i).name(end-3:end) == '.csv'
            filename = [inputfolder filesep listing(i).name ];
            dyn_data_build = csvread( filename ,1,1); % read output from the excel file
            [header] = readCsvHeader( filename);
            [ pos3 ] = findPosCsvHeader( header , 'Zone:Drybulb [C]', true,  filename );
            thiscaseindoortemp = dyn_data_build(:,pos3-1)';
        end
    end
end
% did it find a result file? then continue
if thiscaseindoortemp == 0
    error(['Could not find a csv file in ' inputfolder]);
else
    timeSteps = length(thiscaseindoortemp);
end

% read out all results
maxsize = length(listing); % maximum size of the result vector: will be shortened after

data.coolcoil    = zeros(maxsize,timeSteps); % consumption of cooling coil
data.coolfan     = zeros(maxsize,timeSteps); % consumption of fan for cooling
data.indoortemp  = zeros(maxsize,timeSteps); % indoor room temperature
data.coilstaging = zeros(maxsize,timeSteps); % staging of the cooling coil (information from smart thermostat)
data.tempsetp    = zeros(maxsize,timeSteps); % optimized setpoint for indoor room temperature
data.heatelec    = zeros(maxsize,timeSteps);
data.lights      = zeros(maxsize,timeSteps);
data.generic     = zeros(maxsize,timeSteps);
data.PV          = zeros(maxsize,timeSteps);
data.elec_total  = zeros(maxsize,timeSteps);

countersuccess=0;
countpv=0;
tt=1;
for i = 1:maxsize
    if mod(i,100) == 0
        disp(['Loading profile ' num2str(i) ]);
    end
    
    if length(listing(i).name) > 5
        if listing(i).name(end-3:end) == '.csv'
            countersuccess = countersuccess+1;
            
            filename = [inputfolder filesep listing(i).name ];
            dyn_data_build = csvread( filename ,1,1);
            
            % read out the header
            [header] = readCsvHeader( filename);
            
            % assign data
            % is there cooling installed?
            if not(isempty( findPosCsvHeader( header , 'HVAC:CoolingCoil:Electricity [J]', false , filename ) ))
                [ pos1 ] = findPosCsvHeader( header , 'HVAC:CoolingCoil:Electricity [J]',true , filename );
                data.coolcoil(i,:)   = dyn_data_build(:,pos1-1)';
                [ pos2 ] = findPosCsvHeader( header , 'HVAC:CoolingFan:Electricity [J]',true , filename  );
                data.coolfan(i,:)    = dyn_data_build(:,pos2-1)';
                
                % determine part load factor
                test2 = dyn_data_build(:,pos1-1)';
                test3 = zeros(size(test2));
                % could be cases where the heat pump never went to stage 2: then put that correct
                if not(  sum(and( test2 > (max(test2)*0.25), test2 < (max(test2)*0.75) ))  )
                    % so no cases between 0 and max: chiller never went to stage 2
                    test3( test2 > (max(test2)*0.75)) = 0.5;
                    test3( and( test2 > (max(test2)*0.25), test2 < (max(test2)*0.75) )) = 0;
                else
                    % there are cases in the middle: chiller used stage 2
                    test3( test2 > (max(test2)*0.75)) = 1;
                    test3( and( test2 > (max(test2)*0.25), test2 < (max(test2)*0.75) )) = 0.5;
                end
                data.coilstaging(i,:) = test3;
                
            end
            [ pos3 ] = findPosCsvHeader( header , 'Zone:Drybulb [C]',true , filename  );
            data.indoortemp(i,:) = dyn_data_build(:,pos3-1)';
            %data.otherElec(i,:)  = sum(dyn_data_build(:,6:8),2)';
            
            [ pos7 ] = findPosCsvHeader( header , 'Zone:CoolingSetpoint [C]',true , filename  );
            data.tempsetp(i,:) = dyn_data_build(:,pos7-1)';
            
            data.heatelec(i,:)=dyn_data_build(:,findPosCsvHeader( header , 'HVAC:HeatingFan:Electricity [J]',true , filename  )-1)';
            data.lights(i,:)=dyn_data_build(:,findPosCsvHeader( header , 'Lights:Electricity [J]',true , filename  )-1)';
            
            ind_generic=find(~cellfun(@isempty,strfind(header,'Generic-Load')));
            data.generic(i,:)=sum(dyn_data_build(:,(ind_generic)-1),2)';
%             data.generic(i,:)=dyn_data_build(:,(ind_generic)-1)'+...
%                 dyn_data_build(:,findPosCsvHeader( header , 'Generic-Load-1:Electricity [J]',true , filename  )-1)'+...
%                 dyn_data_build(:,findPosCsvHeader( header , 'Generic-Load-2:Electricity [J]',true , filename  )-1)';
            if not(isempty( findPosCsvHeader( header , 'PV:Electricity [J]', false , filename ) ))
            data.PV(i,:)=dyn_data_build(:,findPosCsvHeader( header , 'PV:Electricity [J]',true , filename  )-1)';
            countpv=countpv+1;
            end
%             HVAC:AuxiliaryHeatingCoil:Electricity [J]
%             HVAC:HeatingCoil:Electricity [J]
%             Zone:CoolingDelivered [J]
%             Zone:HeatingDelivered [J]
            ind_allelectric=find(~cellfun(@isempty,strfind(header,'Electricity [J]')));
            data.elec_net(i,:)=sum(dyn_data_build(:,(ind_allelectric)-1),2)';
        end
    end
end

disp(['There were ' num2str(countersuccess) ' buildings loaded !!!'])

% put to watt
data.coolcoil   = data.coolcoil*1/(5*60);   % from J/(5min) to J/s = W
data.coolfan    = data.coolfan*1/(5*60);    % from J/(5min) to J/s = W
data.heatelec   = data.heatelec*1/(5*60);    % from J/(5min) to J/s = W
data.lights     = data.lights*1/(5*60);    % from J/(5min) to J/s = W
data.generic    = data.generic*1/(5*60);    % from J/(5min) to J/s = W
data.PV         = data.PV*1/(5*60);    % from J/(5min) to J/s = W
data.elec_total = data.elec_net*1/(5*60);    % from J/(5min) to J/s = W
% delete all entries due to other files in the folder
data.coolcoil    = data.coolcoil(1:countersuccess,:); 
data.coolfan     = data.coolfan(1:countersuccess,:); 
data.coolelec    = data.coolcoil + data.coolfan;
data.indoortemp  = data.indoortemp(1:countersuccess,:); 
data.coilstaging = data.coilstaging(1:countersuccess,:); 
data.tempsetp    = data.tempsetp(1:countersuccess,:); 
data.heatelec    = data.heatelec(1:countersuccess,:); 
data.lights      = data.lights(1:countersuccess,:); 
data.generic     = data.generic(1:countersuccess,:); 
data.PV          = data.PV(1:countersuccess,:); 
data.elec_net    = data.elec_total(1:countersuccess,:);
data.elec_total  = data.elec_net - data.PV;
data.elec_totalMW= data.elec_total.*10^(-6);

data.HVACdemMW   = sum(data.coolcoil+data.coolfan,1)*10^(-6);
data.HVACmeanT   = mean(data.indoortemp,1);

meanP = mean(data.coolcoil+data.coolfan,2);
data.HVACmeanTwithHVAC   = mean(data.indoortemp(meanP ~=0,:),1);


if alloutput
    data2 = data; % give all output
else
    % keep a lower number of data
    data2.coolelec    = data.coolelec;
    data2.indoortemp  = data.indoortemp;
    data2.coilstaging = data.coilstaging;
end

if plotresults
    figure; 
    subplot(1,2,1); 
    plot((1:length(data.indoortemp(1,:)))/(12),data.HVACdemMW);
    xlabel('Time (h)'); ylabel('HVAC demand (MW)')
    
    subplot(1,2,2);
    plot((1:length(data.indoortemp(1,:)))/(12),data.HVACmeanT); hold on;
    plot((1:length(data.indoortemp(1,:)))/(12),data.HVACmeanTwithHVAC);
    xlabel('Time (h)'); ylabel('Mean indoor T (?C)'); legend('no hvac','with hvac')
    
end

toc

end


% extra function: find the correct position in the header
function [ pos ] = findPosCsvHeader( headerhere, variablename, show_warning, filename )
%findPosCsvHeader find the index of the header
pos = find(strcmp( headerhere, variablename));

if show_warning
    if isempty(pos)
        disp([ 'WARNING: Could not find variable ' variablename ' in ' filename])
    end
end

end

% extra function: find header of csv file
function [headerout] = readCsvHeader( filenamehere)
% read out header of the csv file
fid = fopen(filenamehere);
a = textscan(fid,'%s','Delimiter','\n');
fclose(fid);
b = a{1,1};
a = b{1,1};
headerout = strsplit(a,',');

end



