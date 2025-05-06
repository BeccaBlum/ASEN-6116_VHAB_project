% Modified by: Rebecca Blum
% Major changes (lines): 31-63, 164-173, 247-275, and 324-327

classdef PhotobioreactorTutorial< vsys
    %PHOTOBIOREACTORTUTORIAL 
    %   Cabin system that incorporates human, CCAA and PBR (PBR has algae
    %   as subsysstem). The cabin system and human are based on the V-HAB
    %   tutorial of the human model.
    
    properties (SetAccess = protected, GetAccess = public)
        % Photobioreactor
        
        % Struct with Photobioreactor Properties
        txPhotobioreactorProperties;
        
        % PBR object
        oPBR;
        
        % Human (from V-HAB Human Tutorial)
        tCurrentFoodRequest;
        cScheduledFoodRequest = cell(0,0);
        fFoodPrepTime = 3*60;
        fInitialFoodPrepMass;
        iCrewMembers;
        
    end
    
    methods
        function this = PhotobioreactorTutorial(oParent, sName)
            this@vsys(oParent, sName, 3600);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Parameters and levels  
            % 1: Photobioreactor volume 
            PBR_volume_list = [0.05, 0.06, 0.07];
            % 2: Dissolved CO concentration (crew member) 
            CM_list = [2, 4, 6]; 
            % 3: Light intensity
            light_intensity_list = [100, 200, 300];%.............base value
%             light_intensity_list = [100 + 5, 200 + 10, 300 + 15];%..error
%             light_intensity_list = [100 - 5, 200 - 10, 300 - 15];%..error
            % 4: Light color
            light_color_list = ["RedExperimental", "Daylight", "Green"];

            root = "C:\Users\Rebecca Blum\OneDrive - UCB-O365\Desktop\Spacecraft Life Support Systems\Newer V-HAB\V-HAB-main\user\+blbe\+introduction\";
            filename = root + "parameters.txt";
            parameters = dlmread(filename,',');     %readlines(filename,"EmptyLineRule","skip")

            PBR_volume = PBR_volume_list(parameters(2));
            CM = CM_list(parameters(3));
            light_intensity = light_intensity_list(parameters(4));
            light_color = char(light_color_list(parameters(5)));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %% Create Photobioreactor
            % Number of CrewMember goes here:
            this.iCrewMembers = CM;

            % Set some important input values. set[] for value if should
            % not be specified. E.g. struct('sLightColor', [])
            this.txPhotobioreactorProperties = ...
                struct(...
                'sLightColor',              light_color, ...          %Radiation energy source (light) of photobioreactor. options:Red, Blue, Yellow, Green, Daylight, RedExperimental
                'fSurfacePPFD',             light_intensity, ...                        %[µmol/m2s] irradiance on surface of PBR. best performance when selecting a value at or just below inhibition -> maximum of PBR in saturated growth zone. Above inhibition growth would be inhibited.
                'fGrowthVolume',            this.iCrewMembers * PBR_volume, ... %[m3]. Algal growth volume filled with growth medium. 0.0625
                'fDepthBelowSurface',       0.0025, ...                     %[m]. depth of the photobioreactor below the irradiated surface. Typically has strong influence on growth because of radiation attenuation at high depths.
                'fMembraneSurface',         10, ...                         %[m2]. Area of air exchange membrane. can be limiting when pressure gradient is low and surface small
                'fMembraneThickness',       0.0001, ...                     %[m]. Thickness of air exchange membrane.
                'sMembraneMaterial',        'SSP-M823 Silicone',...         %type of air exchange membrane. options: 'none', 'SSP-M823 Silicone' or 'Cole Parmer Silicone' (details see AtmosphericGasExchange P2P of algae module)
                'fCirculationVolumetricFlowPerFilter', 4.167*10^-7,...      %[m3/s] equal to 25ml/min. Volumetric flow to each filter of the harvester. More means higher ciruclation and faster harvesting capability
                'fNumberOfParallelFilters', 30, ...                         %number of parallel filters since one is not enough for large volumes.
                'bUseUrine',                false);                          %should urine be used for supply or just nitrate (then set to false).          
            
% sLightColor: Radiation energy source (light) of photobioreactor. options: Red, Blue, Yellow, Green, Daylight, RedExperimental 
% fSurfacePPFD: [µmol/m2s] irradiance on surface of PBR. best performance when selecting a value at or just below inhibition -> maximum of PBR in saturated growth zone. Above inhibition growth would be inhibited. 
% fGrowthVolume: [m3]. Algal growth volume filled with growth medium. 0.0625 
% fDepthBelowSurface: [m]. depth of the photobioreactor below the irradiated surface. Typically has strong influence on growth because of radiation attenuation at high depths. 
% fMembraneSurface: [m2]. Area of air exchange membrane. can be limiting when pressure gradient is low and surface small 
% fMembraneThickness: [m]. Thickness of air exchange membrane. 
% sMembraneMaterial: type of air exchange membrane. options: 'none', 'SSP-M823 Silicone' or 'Cole Parmer Silicone' (details see AtmosphericGasExchange P2P of algae module) 
% fNumberOfParallelFilters: [m3/s] equal to 25ml/min. Volumetric flow to each filter of the harvester. More means higher ciruclation and faster harvesting capability 
% bUseUrine: number of parallel filters since one is not enough for large volumes. 

%should urine be used for supply or just nitrate (then set to false). 
            % Create photobioreactor object and pass the set properties. If
            % not specified here, the struct does not have to be passed and
            % values will be set automatically by the photobioreactor
            % system. This automatically set photobioreactor is capable of
            % supporting one human in terms of air revitalization and water
            % processing. Further changes, e.g. to the growth rate (large
            % potential for size decrease)
            % Photobioreactor class creates algae as its own child system
            components.matter.PBR.systems.Photobioreactor(this, 'Photobioreactor', this.txPhotobioreactorProperties);
            
            %% Create CCAA subsystem from V-HAB tutorial for CCAA
            % Initial ratio for amount of flow that is channeled through
            % the CHX
            % temperature for the coolant passing through the CCAA
            fCoolantTemperature = 280;
            
            % Struct containg basic atmospheric values for the
            % initialization of the CCAA
            tAtmosphere.fTemperature = 295;
            tAtmosphere.rRelHumidity = 0.8;
            tAtmosphere.fPressure = 101325;
            
            % Name for the asscociated CDRA subsystem, leave empty if CCAA
            % is used as standalone
            sCDRA = [];
            
            % Adding the subsystem CCAA
            components.matter.CCAA.CCAA(this, 'CCAA', 60, fCoolantTemperature, tAtmosphere, sCDRA);
            
            %% Add Human to cabin from V-HAB tutorial for Human Model
            
            % Crew planer
            % Since the crew schedule follows the same pattern every day,
            % it was changed to a loop. Thereby, longer mission durations
            % can easily be set just by changing the iLengthOfMission
            % parameter. Currently, 10 days are set. If the number is
            % higher tan the actual simulation time, this does not make any
            % difference. If it is too short, the impact of the humans
            % stops somewhen during the simulation time and the simulation
            % is not usable. So make sure to ajust the parameter properly.
            
            iLengthOfMission = 200; % [d
            ctEvents = cell(iLengthOfMission, this.iCrewMembers);
            
            % Nominal Operation
            tMealTimes.Breakfast = 0.1*3600;
            tMealTimes.Lunch = 6*3600;
            tMealTimes.Dinner = 15*3600;
                       
            for iCrewMember = 1:this.iCrewMembers
                
                iEvent = 1;
                
                for iDay = 1:iLengthOfMission
                    if iCrewMember == 1 || iCrewMember == 4
                        
                        ctEvents{iEvent, iCrewMember}.State = 2;
                        ctEvents{iEvent, iCrewMember}.Start = ((iDay-1) * 24 +  1) * 3600;
                        ctEvents{iEvent, iCrewMember}.End = ((iDay-1) * 24 +  1.5) * 3600;
                        ctEvents{iEvent, iCrewMember}.Started = false;
                        ctEvents{iEvent, iCrewMember}.Ended = false;
                        ctEvents{iEvent, iCrewMember}.VO2_percent = 0.75;
                        
                    elseif iCrewMember==2 || iCrewMember ==5
                        ctEvents{iEvent, iCrewMember}.State = 2;
                        ctEvents{iEvent, iCrewMember}.Start = ((iDay-1) * 24 +  5) * 3600;
                        ctEvents{iEvent, iCrewMember}.End = ((iDay-1) * 24 +  5.5) * 3600;
                        ctEvents{iEvent, iCrewMember}.Started = false;
                        ctEvents{iEvent, iCrewMember}.Ended = false;
                        ctEvents{iEvent, iCrewMember}.VO2_percent = 0.75;
                        
                    elseif iCrewMember ==3 || iCrewMember == 6
                        ctEvents{iEvent, iCrewMember}.State = 2;
                        ctEvents{iEvent, iCrewMember}.Start = ((iDay-1) * 24 +  9) * 3600;
                        ctEvents{iEvent, iCrewMember}.End = ((iDay-1) * 24 +  9.5) * 3600;
                        ctEvents{iEvent, iCrewMember}.Started = false;
                        ctEvents{iEvent, iCrewMember}.Ended = false;
                        ctEvents{iEvent, iCrewMember}.VO2_percent = 0.75;
                    end
                    
                    iEvent = iEvent + 1;
                    
                    ctEvents{iEvent, iCrewMember}.State = 0;
                    ctEvents{iEvent, iCrewMember}.Start =   ((iDay-1) * 24 +  14) * 3600;
                    ctEvents{iEvent, iCrewMember}.End =     ((iDay-1) * 24 +  22) * 3600;
                    ctEvents{iEvent, iCrewMember}.Started = false;
                    ctEvents{iEvent, iCrewMember}.Ended = false;
                    
                    iEvent = iEvent + 1;
                end
            end
            
            % Changed from detailed human to simple human model
            for iCrewMember = 1:this.iCrewMembers
                
                txCrewPlaner.ctEvents = ctEvents(:, iCrewMember);
                txCrewPlaner.tMealTimes = tMealTimes;
                
                components.matter.Human(this, ['Human_', num2str(iCrewMember)], true, 40, 82, 1.829, txCrewPlaner, this.iCrewMembers);
                
                clear txCrewPlaner;
            end
            
            eval(this.oRoot.oCfgParams.configCode(this));
            
        end
        
        
        function createMatterStructure(this)
            createMatterStructure@vsys(this);
            
            %% Cabin store
            % atmosphere
            matter.store(this, 'Cabin', 65);
            
            fAmbientTemperature = 295; %
            % uses the custom air helper to generate an air phase with a
            % defined co2 level and relative humidity
            fCO2Percent = 0.0062;
            %                                                       %store         volume      %deviation from air_custom phase, set Argon to 0                                        rel hum   pressure
            cAirHelper = matter.helper.phase.create.air_custom(this.toStores.Cabin, 65, struct('CO2', fCO2Percent),  fAmbientTemperature, 0.4, 1e5);
            % Adding a phase to the store 'Cabin', 65 m^3 air
            oCabinPhase = matter.phases.gas(this.toStores.Cabin, 'CabinAir', cAirHelper{1}, cAirHelper{2}, cAirHelper{3});
            
            % Store for Potable Water
            matter.store(this, 'PotableWaterStorage', 1);
            oPotableWaterPhase = matter.phases.liquid(this.toStores.PotableWaterStorage, 'PotableWater', struct('H2O', 100), 295, 101325);
            
            % store for urine
            matter.store(this, 'UrineStorage', 1);
            oUrinePhase = matter.phases.mixture(this.toStores.UrineStorage, 'Urine', 'liquid', struct('Urine', 16), 295, 101325);
            
            % store for  feces storage
            matter.store(this, 'FecesStorage', 1);
            oFecesPhase = matter.phases.mixture(this.toStores.FecesStorage, 'Feces', 'solid', struct('Feces', 1), 295, 101325);
            
            % Nitrate Supply
            oStore = matter.store(this, 'NutrientSupply', 0.1); 
            
            oNutrientSupply = oStore.createPhase( 'liquid', 'boundary', 'NutrientSupply', oStore.fVolume, struct('H2O', 0.1, 'NO3', 0.9), oCabinPhase.fTemperature, oCabinPhase.fPressure); 
            
            % Adds a food store to the system
            tfFood = struct('Food', 1000);
            oFoodStore = components.matter.FoodStore(this, 'FoodStore', 100, tfFood);
            
            
            %% Photobioreactor Connections
            %Interface to PBR for air revitalization
            matter.procs.exmes.gas(this.toStores.Cabin.toPhases.CabinAir, 'To_PBR');
            matter.procs.exmes.gas(this.toStores.Cabin.toPhases.CabinAir, 'From_PBR');
            matter.branch(this,'Cabin_Outlet' ,{}, 'Cabin.To_PBR');
            matter.branch(this, 'Cabin_Inlet' ,{},'Cabin.From_PBR');
            
            %interface from PBR for produced water
            matter.procs.exmes.liquid(this.toStores.PotableWaterStorage.toPhases.PotableWater, 'Water_from_PBR');
            matter.procs.exmes.liquid(this.toStores.PotableWaterStorage.toPhases.PotableWater, 'Water_to_PBR');
            matter.branch(this, 'Water_Inlet',{} ,'PotableWaterStorage.Water_from_PBR');
            matter.branch(this, 'Water_Outlet',{} ,'PotableWaterStorage.Water_to_PBR');
            
            % interface to PBR for urine processing
            matter.procs.exmes.mixture(this.toStores.UrineStorage.toPhases.Urine, 'Urine_to_PBR');
            matter.branch(this, 'Urine_PBR',{}, 'UrineStorage.Urine_to_PBR');
            
            %connection from PBR for harvested Chlorella biomass
            matter.procs.exmes.mixture(this.toStores.FoodStore.toPhases.Food, 'Chlorella_from_PBR');
            matter.branch(this, 'Chlorella_Inlet',{} ,'FoodStore.Chlorella_from_PBR');
            
            matter.branch(this, 'Nitrate_PBR',{}, oNutrientSupply);
            
            %set interfaces in photobioreactor child system
            this.toChildren.Photobioreactor.setIfFlows('Cabin_Outlet', 'Cabin_Inlet', 'Water_Inlet', 'Urine_PBR', 'Chlorella_Inlet', 'Nitrate_PBR', 'Water_Outlet');
            
            
            %% CREW SYSTEM           

            % Changed from detailed human to simple human model
            for iHuman = 1:this.iCrewMembers
                % Add Exmes for each human
                matter.procs.exmes.gas(oCabinPhase,             ['AirOut',      num2str(iHuman)]);
                matter.procs.exmes.gas(oCabinPhase,             ['AirIn',       num2str(iHuman)]);
                matter.procs.exmes.liquid(oPotableWaterPhase,   ['DrinkingOut', num2str(iHuman)]);
                matter.procs.exmes.mixture(oFecesPhase,         ['Feces_In',    num2str(iHuman)]);
                matter.procs.exmes.mixture(oUrinePhase,         ['Urine_In',    num2str(iHuman)]);

                % Add interface branches for each human
                matter.branch(this, ['Air_Out',         num2str(iHuman)],  	{}, [oCabinPhase.oStore.sName,             '.AirOut',      num2str(iHuman)]);
                matter.branch(this, ['Air_In',          num2str(iHuman)], 	{}, [oCabinPhase.oStore.sName,             '.AirIn',       num2str(iHuman)]);
                matter.branch(this, ['Feces',           num2str(iHuman)],  	{}, [oFecesPhase.oStore.sName,             '.Feces_In',    num2str(iHuman)]);
                matter.branch(this, ['PotableWater',    num2str(iHuman)], 	{}, [oPotableWaterPhase.oStore.sName,      '.DrinkingOut', num2str(iHuman)]);
                matter.branch(this, ['Urine',           num2str(iHuman)], 	{}, [oUrinePhase.oStore.sName,             '.Urine_In',	num2str(iHuman)]);

                % register each human at the food store
                requestFood = oFoodStore.registerHuman(['Solid_Food_', num2str(iHuman)]);
                this.toChildren.(['Human_', num2str(iHuman)]).bindRequestFoodFunction(requestFood);

                % Set the interfaces for each human
                this.toChildren.(['Human_',         num2str(iHuman)]).setIfFlows(...
                                ['Air_Out',         num2str(iHuman)],...
                                ['Air_In',          num2str(iHuman)],...
                                ['PotableWater',    num2str(iHuman)],...
                                ['Solid_Food_',     num2str(iHuman)],...
                                ['Feces',           num2str(iHuman)],...
                                ['Urine',           num2str(iHuman)]);
            end
            
            %% CCAA  (from V-HAB CCAA Tutorial)
            % Coolant store for the coolant water supplied to CCAA
            matter.store(this, 'CoolantStore', 1);
            
            % Adding a phase to the store 'Tank_3', 1 m^3 water
            oCoolantPhase = matter.phases.liquid(this.toStores.CoolantStore, ...  Store in which the phase is located
                'Coolant_Phase', ...        Phase name
                struct('H2O', 1), ...      Phase contents
                280.15, ...                Phase temperature
                101325);                 % Phase pressure
            
            % Store to gather the condensate from CCAA
            matter.store(this, 'CondensateStore', 1);
            
            % Adding a phase to the store 'Tank_3', 1 m^3 water
            oCondensatePhase = matter.phases.liquid(this.toStores.CondensateStore, ...  Store in which the phase is located
                'Condensate_Phase', ...        Phase name
                struct('H2O', 1), ...      Phase contents
                280.15, ...                Phase temperature
                101325);                 % Phase pressure
            
            %define branches for CCAA
            matter.branch(this, 'CCAA_Air_In',              {}, oCabinPhase);
            matter.branch(this, 'CCAA_Air_Out',             {}, oCabinPhase);
            matter.branch(this, 'CCAA_CondensateOutput',    {}, oCondensatePhase);
            matter.branch(this, 'CCAA_CoolantInput',        {}, oCoolantPhase);
            matter.branch(this, 'CCAA_CoolantOutput',       {}, oCoolantPhase);
            
            % now the interfaces between this system and the CCAA subsystem
            % are defined
            this.toChildren.CCAA.setIfFlows('CCAA_Air_In', 'CCAA_Air_Out', 'CCAA_CondensateOutput', 'CCAA_CoolantInput', 'CCAA_CoolantOutput');         

        end
        
        function createThermalStructure(this)
            createThermalStructure@vsys(this);
            
            % Adding heat sources to keep the cabin and coolant water at a
            % constant temperature
            oHeatSource = components.thermal.heatsources.ConstantTemperature('Cabin_Constant_Temperature');
            this.toStores.Cabin.toPhases.CabinAir.oCapacity.addHeatSource(oHeatSource);
            
            oHeatSource = components.thermal.heatsources.ConstantTemperature('Coolant_Constant_Temperature');
            this.toStores.CoolantStore.toPhases.Coolant_Phase.oCapacity.addHeatSource(oHeatSource);
            
            oCabinPhase = this.toStores.Cabin.toPhases.CabinAir;

            % Changed from detailed human to simple human model
            for iHuman = 1:this.iCrewMembers
                this.toChildren.(['Human_', num2str(iHuman)]).createHumanHeatSource();
            end

        end
        
        
        function createSolverStructure(this)
            createSolverStructure@vsys(this);
            
            % For storage phases we set a fixed time step of 20 seconds
            tTimeStepProperties.fMaxStep = this.fTimeStep;
                    
            % set time steps
            csStoreNames = fieldnames(this.toStores);
            for iStore = 1:length(csStoreNames)
                for iPhase = 1:length(this.toStores.(csStoreNames{iStore}).aoPhases)
                    oPhase = this.toStores.(csStoreNames{iStore}).aoPhases(iPhase);
                    oPhase.setTimeStepProperties(tTimeStepProperties);
                    oPhase.oCapacity.setTimeStepProperties(tTimeStepProperties);
                end
            end
            
            tTimeStepProperties = struct();
            tTimeStepProperties.rMaxChange = inf;
            
            this.toStores.CondensateStore.toPhases.Condensate_Phase.setTimeStepProperties(tTimeStepProperties);
            this.toStores.CondensateStore.toPhases.Condensate_Phase.oCapacity.setTimeStepProperties(tTimeStepProperties);
            
            this.toStores.UrineStorage.toPhases.Urine.setTimeStepProperties(tTimeStepProperties);
            this.toStores.UrineStorage.toPhases.Urine.oCapacity.setTimeStepProperties(tTimeStepProperties);
            
            this.toStores.FecesStorage.toPhases.Feces.setTimeStepProperties(tTimeStepProperties);
            this.toStores.FecesStorage.toPhases.Feces.oCapacity.setTimeStepProperties(tTimeStepProperties);
            
            this.toStores.PotableWaterStorage.toPhases.PotableWater.setTimeStepProperties(tTimeStepProperties);
            this.toStores.PotableWaterStorage.toPhases.PotableWater.oCapacity.setTimeStepProperties(tTimeStepProperties);
            
            
            this.setThermalSolvers();
        end
    end
    
    methods (Access = protected)
        
        function exec(this, ~)
            exec@vsys(this);
            
            % This code synchronizes everything once a day
            this.oTimer.synchronizeCallBacks();
        end
    end
end