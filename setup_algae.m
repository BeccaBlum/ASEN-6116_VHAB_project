% Modified by: Rebecca Blum
% Major changes (lines): 5-126 (minor edits or original code trimmed)
%                        127-168 (code written)

classdef setup_algae < simulation.infrastructure
    
    properties
    end
    
    methods
        function this = setup_algae(ptConfigParams, tSolverParams)
            
            ttMonitorConfig = struct ('oLogger', struct('cParams',{{true,100000}}));
            ttMonitorConfig.oTimeStepObserver.sClass = 'simulation.monitors.timestepObserver';
            ttMonitorConfig.oTimeStepObserver.cParams = { 0 };
            
            this@simulation.infrastructure('Cabin', ptConfigParams, tSolverParams, ttMonitorConfig);

            % Line below does not work as structure value is non-existent 
            %this.oTimer.fMinimumTimeStep = 60;
            this.iSimTicks = 10;
            trBaseCompositionUrine.H2O      = 0.9644;
            trBaseCompositionUrine.CH4N2O   = 0.0356;
            this.oSimulationContainer.oMT.defineCompoundMass(this, 'Urine', trBaseCompositionUrine)
            
            trBaseCompositionFeces.H2O          = 0.7576;
            trBaseCompositionFeces.DietaryFiber = 0.2424;
            this.oSimulationContainer.oMT.defineCompoundMass(this, 'Feces', trBaseCompositionFeces)
            
            blbe.introduction.systems.PhotobioreactorTutorial(this.oSimulationContainer, 'Cabin');
            
            % Line below does not work
            %this.oSimulationContainer.oTimer.fMinimumTimeStep = 100;
            this.fSimTime = 3600*12; %3600 %* 24 * 7;
            this.bUseTime = true;

        end
        
%% Log values to oLogger
% This section was heavily trimmed to exclude unnecessary oLogger entries 
%   that were originally in the section. This helped reduce simulation
%   time.

        function configureMonitors(this)

            oLog = this.toMonitors.oLogger;
            
            % Important phase masses.
            oLog.addValue('Cabin.toChildren.Photobioreactor.toStores.Harvester.toPhases.ChlorellaHarvest',  'fMass',    'kg',   'PBR System Harvester Store Chlorella Harvest Phase');
            
            % Growth values
            oLog.addValue('Cabin.toChildren.Photobioreactor.toChildren.ChlorellaInMedia.oPhotosynthesisModule', 'fAssimilationCoefficient',             '-', 'Assimilation Coefficient of Algal Culture');
            
            % Accumulated masses in and out 
            oLog.addValue('Cabin.toChildren.Photobioreactor.toChildren.ChlorellaInMedia.oPhotosynthesisModule',     'fTotalOxygenEvolution',            'kg',   'Total Oxygen Evolution');
            oLog.addValue('Cabin.toChildren.Photobioreactor.toChildren.ChlorellaInMedia.oPhotosynthesisModule',     'fTotalCarbonDioxideAssimilation',  'kg',   'Total Carbon Dioxide Assimilation');
            
            % Growth phase values
            oLog.addValue('Cabin.toChildren.Photobioreactor.toChildren.ChlorellaInMedia.toStores.GrowthChamber.toPhases.GrowthMedium',      'afMass(this.oMT.tiN2I.H2O)',       'kg',   'Mass of Water');
            oLog.addValue('Cabin.toChildren.Photobioreactor.toChildren.ChlorellaInMedia.toStores.GrowthChamber.toPhases.GrowthMedium',      'afMass(this.oMT.tiN2I.Chlorella)', 'kg',   'Mass of Chlorella');
            oLog.addValue('Cabin.toChildren.Photobioreactor.toChildren.ChlorellaInMedia.toStores.GrowthChamber.toPhases.GrowthMedium',      'fTemperature',                     'K',    'Medium Temperature');  
            
            %Atmospheric Exchange
            oLog.addValue('Cabin.toChildren.Photobioreactor.toChildren.ChlorellaInMedia.toStores.GrowthChamber.toPhases.GrowthMedium',      'afMass(this.oMT.tiN2I.O2)',        'kg',   'Mass of dissolved O2');
%             oLog.addValue('Cabin.toChildren.Photobioreactor.toChildren.ChlorellaInMedia.toStores.GrowthChamber.toPhases.AirInGrowthChamber','afPP(this.oMT.tiN2I.CO2)',         'Pa',   'CO2 Partial Pressure in Growth Chamber');
%             oLog.addValue('Cabin.toChildren.Photobioreactor.toChildren.ChlorellaInMedia.toStores.GrowthChamber.toPhases.AirInGrowthChamber','afPP(this.oMT.tiN2I.O2)',          'Pa',   'O2 Partial Pressure in Growth Chamber');
            oLog.addValue('Cabin.toChildren.Photobioreactor.toChildren.ChlorellaInMedia.toStores.GrowthChamber.toPhases.GrowthMedium',      'afMass(this.oMT.tiN2I.CO2)',       'kg',   'Mass of dissolved CO2');          
            
            %PAR module parameters  
            oLog.addValue('Cabin.toChildren.Photobioreactor.toChildren.ChlorellaInMedia.oPARModule', 'fAttenuationCoefficient',     '-', 'Attenuation Coefficient');          
            oLog.addValue('Cabin.toChildren.Photobioreactor.toChildren.ChlorellaInMedia.oPARModule', 'fNoGrowthVolume',             '-', 'No Growth Volume');
            oLog.addValue('Cabin.toChildren.Photobioreactor.toChildren.ChlorellaInMedia.oPARModule', 'fSaturatedGrowthVolume',      '-', 'Saturated Growth Volume');
            oLog.addValue('Cabin.toChildren.Photobioreactor.toChildren.ChlorellaInMedia.oPARModule', 'fLinearGrowthVolume',         '-', 'Linear Growth Volume');
                   
            % Algae module
            oLog.addValue('Cabin.oTimer',	'fTimeStep',                 's',   'fTimeStepFinal');           
            oLog.addValue('Cabin.toChildren.Photobioreactor.toChildren.ChlorellaInMedia.toStores.GrowthChamber.toPhases.GrowthMedium.toManips.substance',      'this.afPartialFlows(this.oMT.tiN2I.Chlorella)',   	'kg/s',   'PBR Chlorella Growth Rate');
            oLog.addValue('Cabin.toChildren.Photobioreactor.toChildren.ChlorellaInMedia.toStores.GrowthChamber.toPhases.GrowthMedium.toManips.substance',      'this.afPartialFlows(this.oMT.tiN2I.CO2)',           'kg/s',   'PBR CO_2 Consumption Rate');
            oLog.addValue('Cabin.toChildren.Photobioreactor.toChildren.ChlorellaInMedia.toStores.GrowthChamber.toPhases.GrowthMedium.toManips.substance',      'this.afPartialFlows(this.oMT.tiN2I.O2)',            'kg/s',   'PBR O_2 Production Rate');
            
%             oLog.addVirtualValue('cumsum("PBR Chlorella Growth Rate"     .* "Timestep")', 'kg', 'PBR produced Chlorella Mass');
%             oLog.addVirtualValue('cumsum("PBR CO_2 Consumption Rate"     .* "Timestep")', 'kg', 'PBR consumed CO_2 Mass');
%             oLog.addVirtualValue('cumsum("PBR O_2 Production Rate"  .* "Timestep")', 'kg', 'PBR produced O_2 Mass');
%             oLog.addVirtualValue('cumsum("PBR H_2O Production Rate Rate" .* "Timestep")', 'kg', 'PBR produced H_2O Mass');'

        end

%% Plot variables and save variables to xls file
% This section was also trimmed to exclude unnecessary plots. A section was
%   added to save certain oLogger variables to a simulation unique xls file 
%   that could be later accessed and used to analyze data. 

        function plot(this, varargin)
            % Define Plots           
            close all
            
            oPlotter = plot@simulation.infrastructure(this);
            
            % Tries to load stored data from the hard drive if that option
            % was activated (see ttMonitorConfig). Otherwise it only
            % displays that no data was found
            try
                this.toMonitors.oLogger.readDataFromMat;
            catch
                disp('no data outputted yet')
            end
            
            %% plot options with custom labels for what is not available in V-HAB
            tPlotOptions.sTimeUnit = 'days';
  
            %% Plots (used in system testing only)
            
            %in outputs of PBR
            ioPlot{1,1} = oPlotter.definePlot({'"Total Carbon Dioxide Assimilation"'}, 'Total Carbon Dioxide Assimilation', tPlotOptions);
            ioPlot{1,2} = oPlotter.definePlot({'"Total Oxygen Evolution"'}, 'Total Oxygen Evolution', tPlotOptions);
            
            joPlot{1,1}=oPlotter.definePlot({'"PBR Chlorella Growth Rate"'}, 'PBR Chlorella Growth Rate', tPlotOptions);
            joPlot{1,2}=oPlotter.definePlot({'"PBR CO_2 Consumption Rate"'}, 'PBR CO_2 Consumption Rate', tPlotOptions);
            joPlot{1,3}=oPlotter.definePlot({'"PBR O_2 Production Rate"'}, 'PBR O_2 Production Rate', tPlotOptions);     
            
            % plotter functions

            oPlotter.defineFigure(ioPlot, 'Total Produced and Consumed Masses');
            oPlotter.defineFigure(joPlot, 'Input and Output Rates');          
%             oPlotter.plot();..............used during script testing only
            
            root = "C:\Users\Rebecca Blum\OneDrive - UCB-O365\Desktop\Spacecraft Life Support Systems\Newer V-HAB\V-HAB-main\user\+blbe\+introduction\";

            % Read in parameters to get simulation number. Used to create 
            %   unique xls file. 
            filename = root + "parameters.txt";
            parameters = dlmread(filename,',');     
            filename2 = "simulation_" + string(parameters(1)) + ".xls";
            xls_filename = root + "xls_files\" + filename2;
            
            % Variables to save to xls file
            variable_names = ["PBR Chlorella Growth Rate", ...
                              "PBR CO_2 Consumption Rate", ...
                              "PBR O_2 Production Rate", ...
                              "Total Oxygen Evolution", ...
                              "Total Carbon Dioxide Assimilation", ...
                              "Mass of Chlorella", ...
                              "Medium Temperature", ...
                              "Mass of dissolved O2", ...
                              "Mass of dissolved CO2"];
            
            % Location of logged data labels. Used to get index of logged
            %   data vectors. 
            logged_items = string({this.toMonitors.oLogger.tLogValues.sLabel});

            fprintf("\n Writing to " + filename2 + "... \n")

            M = [];

            % Locate each variable & append corresponding vector to matrix
            for i = 1:length(variable_names)
                index = find(logged_items == variable_names(i));
                variable = rmmissing(this.toMonitors.oLogger.mfLog(:,index));
                M = [M, variable];
            end

            % Add time vector to matrix 
            M = [M, this.toMonitors.oLogger.afTime(:)];

            % Write matrix to xls file 
            writematrix(M,xls_filename,'Sheet',1,'Range',"A1:J" + string(length(variable)),'WriteMode','overwritesheet')

            fprintf("File written \n")
        end 
    end  
end