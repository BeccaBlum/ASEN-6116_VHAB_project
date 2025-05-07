%% Housekeeping
close all
clear all

%% Parameters and levels  
% 1: Photobioreactor volume 
PBR_volume_list = [0.05, 0.06, 0.07];
% 2: Dissolved CO concentration (crew member) 
CM_list = [2, 4, 6]; 
% 3: Light intensity
light_intensity_list = [100, 200, 300];
% 4: Light color
light_color_list = ["RedExperimental", "Daylight", "Green"];

variable_names = ["PBR Chlorella Growth Rate", "PBR CO_2 Consumption Rate", "PBR O_2 Production Rate Over Time", "Total Oxygen Evolution","Total Carbon Dioxide Assimilation", "Mass of Chlorella","Medium Temperature","Mass of dissolved O2","Mass of dissolved CO2"];

units = ["[kg/s]", "[kg/s]", "Production Rate [kg/s]", "Mass [kg]", "Mass [kg]", "Mass [kg]", "Temperature [K]", "Mass [kg]", "Mass [kg]"];
root = "C:\Users\Rebecca Blum\OneDrive - UCB-O365\Desktop\Spacecraft Life Support Systems\Newer V-HAB\V-HAB-main\user\+blbe\+introduction\";

red = [1 0 0];
blue = [0.3010 0.7450 0.9330];
green = [.1 .8 .1];
one = "-";
two = "--";
three = ":";

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Code for plotting Taguchi simulations 
light_red = [1, 0.569, 0.569];
light_pink = [1, 0.608, 0.929];%[1, 0.569, 0.792];
light_green = [0.675, 0.949, 0.675];
col = [red; blue; green; green; red; blue; blue; green; red];
% col = [red; blue; green; [1 0 1]; [0 0 0]; [0.8500 0.3250 0.0980];...
%       [0 1 0]; [0.4940 0.1840 0.5560]; 	[0 0 1] ];
col = [red; blue; light_red; [1 0 1]; light_pink; light_green;...
      [0.4660 0.6740 0.1880]; [0.4940 0.1840 0.5560]; 	[0 0 1] ];
style = [one, two, three, two, three, one, three, one, two];
w = [1, 1.5, 2, 1.5, 2, 1, 2, 1, 1.5];

L9 = [1, 1, 1, 1, 1; ...
      2, 1, 2, 2, 2; ...
      3, 1, 3, 3, 3; ...
      4, 2, 1, 2, 3; ...
      5, 2, 2, 3, 1; ...
      6, 2, 3, 1, 2; ...
      7, 3, 1, 3, 2; ...
      8, 3, 2, 1, 3; ...
      9, 3, 3, 2, 1];

leg = [];
for i = 1:9
    sim = L9(i,2:5);
    leg = [leg, PBR_volume_list(sim(1)) + ", " + CM_list(sim(2)) + ", "  + light_intensity_list(sim(3)) + ", "  + light_color_list(sim(4))];

    %xls_filename = root + "csv_files\no_humans\simulation_" + string(i) + ".xls";
    xls_filename = root + "csv_files\humans_24_hr\simulation_" + string(i) + ".xls";
    %xls_filename = root + "csv_files\not_taguchi_12_hr\simulation_" + string(i) + ".xls";
    %xls_filename = root + "csv_files\simulation_" + string(i) + ".xls";
    M = readmatrix(xls_filename);

    for j = [3,4]%1:length(variable_names) 
        figure(j)
        hold on 
        time = M(:,10)/(3600*24);
        plot(time,M(:,j),Color=col(i,1:3), LineWidth=1) %LineStyle=style(i),Color=col(i,1:3),LineWidth=w(i))
        title(variable_names(j))
%         subtitle("Legend: C_V [m^3], # of CM, E_e [µmol/m^2s], light color")
        hold off 
    end
end

for j = [3,4] %1:length(variable_names)
    figure(j)
    hold on 
    legend(leg(1), leg(2), leg(3), leg(4), leg(5), leg(6), leg(7), leg(8), leg(9))
    xlim([0,1])
    xlabel("Time [days]")
    ylabel(units(j))
    hold off 
%     saveas(gcf, root + "figures\" + variable_names(j) + ".png")
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% Code for plotting sensitivity simulations 
% L9 = [1, 1, 1, 1, 1; ... % 1, 2, 3, 4
%       2, 1, 2, 1, 1; ... % 1
%       3, 1, 1, 2, 1; ... % 2 
%       4, 1, 1, 1, 2; ... % 3 
%       5, 1, 3, 1, 1; ... % 1
%       6, 1, 1, 3, 1; ... % 2
%       7, 1, 1, 1, 3; ... % 3 
%       8, 1, 2, 2, 2; ... % 5, 6, 7
%       9, 1, 3, 2, 2; ... % 5
%       10, 1, 2, 3, 2; ...% 6
%       11, 1, 2, 2, 3; ...% 7
%       12, 1, 1, 2, 2; ...% 5
%       13, 1, 2, 1, 2; ...% 6
%       14, 1, 2, 2, 1; ...% 7
%       15, 1, 3, 3, 3; ...
%       16, 2, 1, 1, 1; ...% 4
%       17, 3, 1, 1, 1; ...% 4
%       18, 2, 2, 2, 2; ...
%       19, 2, 3, 2, 2; ...
%       20, 2, 1, 2, 2];
% 
% col = [red; blue; green];
% style = ["-", "--", ":"];
% w = [1, 1, 2];
% 
% k = 0;
% 
% leg = [];
% % bad = [8, 10, 13], [8, 11, 14]
% % Parameter that is changed:
% % Volume [1,16,17], 
% % # of CM [1,2,5], [8,9,12], [18, 19, 20]
% % Light intensity [1,3,6], [8, 10,13]
% % Light color [1, 4, 7], [8, 11, 14]
% for i = [8,9,12] % [18, 19, 20]%[9,8, 12] %[1,16,17] %[8, 9, 12] %[1,2,5] %[1,16,17] %[1,4,7] %[1,3,6] %[1, 2, 5] %sims
%     k = k + 1;
%     sim = L9(i,2:5);
%     %xls_filename = root + "csv_files\no_humans\simulation_" + string(i) + ".xls";
%     %xls_filename = root + "csv_files\humans_12_hr\simulation_" + string(i) + ".xls";
%     xls_filename = root + "csv_files\not_taguchi_12_hr\simulation_" + string(i) + ".xls"';
%     M = readmatrix(xls_filename);
%     
% %     xls_filename_pos_err = root + "csv_files\not_taguchi_12_hr\pos_err\simulation_" + string(i) + ".xls"';
% %     M_pos_err = readmatrix(xls_filename_pos_err);
% %     
% %     xls_filename_neg_err = root + "csv_files\not_taguchi_12_hr\neg_err\simulation_" + string(i) + ".xls"';
% %     M_neg_err = readmatrix(xls_filename_neg_err);
% 
%     sim = L9(i,2:5);
%     leg = [leg,PBR_volume_list(sim(1)) + ", " + CM_list(sim(2)) + ", "  + light_intensity_list(sim(3)) + ", "  + light_color_list(sim(4)), "error bound"];
% 
%     for j = [1,3,4] %length(variable_names) 
%         figure(j)
%         hold on 
%         time = M(:,10)/(3600*24);
% %         time_pos_err = M_pos_err(:,10)/(3600*24);
% %         time_neg_err = M_neg_err(:,10)/(3600*24);
% %         plot(time,M(:,j), LineStyle=style(sim(3)), Color=col(sim(4),:), LineWidth=1.5)
%         plot(time,M(:,j),Color="k",LineWidth=1.5)
% %         plot(time_pos_err,M_pos_err(:,j), Color="c")
% %         plot(time_neg_err,M_neg_err(:,j), Color="c")
%         title(variable_names(j))
%         hold off 
%     end
% end
% 
% for j = [1,3,4] %length(variable_names)
%     figure(j)
%     hold on 
%     legend(leg(1), leg(2), leg(3), leg(4), leg(5), leg(6)) % leg(7), leg(8), leg(9))
%     xlim([0,0.5])
%     xlabel("Time [days]")
%     ylabel(units(j))
%     subtitle("Legend: C_V [m^3], # of CM, E_e [µmol/m^2s], light color")
%     hold off
%     saveas(gcf, root + "figures\" + variable_names(j) + ".png")
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% Subplots for paper and presentation 
% L9 = [1, 1, 1, 1, 1; ... % 1, 2, 3, 4
%       2, 1, 2, 1, 1; ... % 1
%       3, 1, 1, 2, 1; ... % 2 
%       4, 1, 1, 1, 2; ... % 3 
%       5, 1, 3, 1, 1; ... % 1
%       6, 1, 1, 3, 1; ... % 2
%       7, 1, 1, 1, 3; ... % 3 
%       8, 1, 2, 2, 2; ... % 5 
%       9, 1, 3, 2, 2; ... % 5
%       10, 1, 2, 3, 2; ...
%       11, 1, 2, 2, 3; ...
%       12, 1, 1, 2, 2; ...% 5
%       13, 1, 2, 1, 2; ...
%       14, 1, 2, 2, 1; ...
%       15, 1, 3, 3, 3; ...
%       16, 2, 1, 1, 1; ...% 4
%       17, 3, 1, 1, 1];   % 4
% 
% vars = [1, 3, 4];
% leg = [];
% 
% for i = [1,16,17]
%     sim = L9(i,2:5);
%     leg = [leg, PBR_volume_list(sim(1)) + ", " + CM_list(sim(2)) + ", "  + light_intensity_list(sim(3)) + ", "  + light_color_list(sim(4))];
% end
% 
% for p = 1:3 
% %         figure(p)
%     for i = [1,16,17] %[8, 9, 12] %[1,2,5] %[1,16,17] %[1,4,7] %[1,3,6] %[1, 2, 5]
%         sim = L9(i,2:5);
%         xls_filename = root + "csv_files\not_taguchi_12_hr\simulation_" + string(i) + ".xls"';
%         M = readmatrix(xls_filename);
%         hold on 
%         subplot(4,1,p);
%         time = M(:,10)/(3600*24);
%         plot(time,M(:,vars(p)), LineWidth=1.5)
%         xlim([0,0.5])
% 
%         xlabel("Time [days]")
%         ylabel(units(vars(p)))
%         title(variable_names(vars(p)))
% %         subtitle("Legend: C_V [m^3], # of CM, PAR [µmol/m^2s], light color")
%         
%         if p == 3
%             legend(leg(1), leg(2), leg(3)) %, leg(4), leg(5), leg(6), leg(7), leg(8), leg(9))
%             sgtitle("Sensitivity of PBR Volume")
%             saveas(gcf, root + "figures\" + variable_names(vars(p)) + ".png")
%         end
%         hold off
%     end
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Code for plotting sensitivity simulations 
% L9 = [1, 1, 1, 1, 1; ... % 1, 2, 3, 4
%       2, 1, 2, 1, 1; ... % 1
%       3, 1, 1, 2, 1; ... % 2 
%       4, 1, 1, 1, 2; ... % 3 
%       5, 1, 3, 1, 1; ... % 1
%       6, 1, 1, 3, 1; ... % 2
%       7, 1, 1, 1, 3; ... % 3 
%       8, 1, 2, 2, 2; ... % 5, 6, 7
%       9, 1, 3, 2, 2; ... % 5
%       10, 1, 2, 3, 2; ...% 6
%       11, 1, 2, 2, 3; ...% 7
%       12, 1, 1, 2, 2; ...% 5
%       13, 1, 2, 1, 2; ...% 6
%       14, 1, 2, 2, 1; ...% 7
%       15, 1, 3, 3, 3; ...
%       16, 2, 1, 1, 1; ...% 4
%       17, 3, 1, 1, 1; ...% 4
%       18, 2, 2, 2, 2; ...
%       19, 2, 3, 2, 2; ...
%       20, 2, 1, 2, 2];
% 
% light_red = [1, 0.569, 0.569];
% light_pink = [1, 0.608, 0.929];%[1, 0.569, 0.792];
% light_green = [0.675, 0.949, 0.675];
% col = [red; [1 0 1]; green];
% col2 = [light_red; light_pink; light_green];
% style = ["-", "-", "-", "-", "--", ":"];
% w = [1, 1, 2];
% 
% k = 0;
% plot_vars = [3,4];
% 
% leg = [];
% % bad = [8, 10, 13], [8, 11, 14]
% % Parameter that is changed:
% % Volume [1,16,17], 
% % # of CM [1,2,5] X, [12, 8, 9] , [18, 19, 20]X
% % Light intensity [1,3,6], [8, 10,13] X
% % Light color [1, 4, 7], [8, 11, 14] X
% 
% for i = [12, 8, 9] %[1, 4, 7] %[1,3,6] %[1,16,17] %[1, 4, 7] %sims
%     k = k + 1;
%     sim = L9(i,2:5);
% 
%     xls_filename = root + "csv_files\not_taguchi_12_hr\simulation_" + string(i) + ".xls"';
%     M = readmatrix(xls_filename);
%     
%     xls_filename_pos_err = root + "csv_files\not_taguchi_12_hr\pos_err\simulation_" + string(i) + ".xls"';
%     M_pos_err = readmatrix(xls_filename_pos_err);
%     
%     xls_filename_neg_err = root + "csv_files\not_taguchi_12_hr\neg_err\simulation_" + string(i) + ".xls"';
%     M_neg_err = readmatrix(xls_filename_neg_err);
% 
%     sim = L9(i,2:5);
% %     leg = [leg, light_color_list(sim(4))];
% %     leg = [leg, light_intensity_list(sim(3)) + " [\mumol/m²/s]"];
%     leg = [leg,"CM = " + CM_list(sim(2))];  
% %     leg = [leg,"C_V = " + PBR_volume_list(sim(1)) + " [m^3/CM]"];  % + ", " + CM_list(sim(2)) + ", "  + light_intensity_list(sim(3)) + ", "  + light_color_list(sim(4))];
% %     legs = PBR_volume_list(sim(1)) + ", " + CM_list(sim(2)) + ", "  + light_intensity_list(sim(3)) + ", "  + light_color_list(sim(4));
% 
%     for j = 1:length(plot_vars) % variables to plot [1,3,4]
%         figure(1)
%         subplot(1,2,j);
%         hold on 
%         time = M(:,10)/(3600*24);
%         time_pos_err = M_pos_err(:,10)/(3600*24);
%         time_neg_err = M_neg_err(:,10)/(3600*24);
%         plot(time,M(:,plot_vars(j)), LineStyle=style(k), Color=col(k,:), LineWidth=1.5);
%         plot(time_pos_err,M_pos_err(:,plot_vars(j)), Color=col2(k,:), LineWidth=1.5,LineStyle="--", HandleVisibility="off")% col(k))
%         plot(time_neg_err,M_neg_err(:,plot_vars(j)), Color=col2(k,:),LineWidth=1.5, LineStyle="--", HandleVisibility="off") %col(k))
% %         plot(time_pos_err,M_pos_err(:,j), Color=col2(k,:), LineWidth=1.5,LineStyle="--", HandleVisibility="off")% col(k))
% %         if i == 1
% %             plot(time_pos_err,M_pos_err(:,plot_vars(j)), Color=col2(k,:), LineWidth=1.5,LineStyle="--", HandleVisibility="off")% col(k))
% %             plot(time_neg_err,M_neg_err(:,plot_vars(j)), Color=col2(k,:),LineWidth=1.5, LineStyle="--", HandleVisibility="off") %col(k))
% %         end 
% %         if i == 4
% %             plot(time,M(:,plot_vars(j)) + 0.05*M(:,plot_vars(j)), Color=col2(k,:), LineWidth=1.5,LineStyle="--", HandleVisibility="off")% col(k))
% %             plot(time,M(:,plot_vars(j)) - 0.05*M(:,plot_vars(j)), Color=col2(k,:),LineWidth=1.5, LineStyle="--", HandleVisibility="off") %col(k))
% %         end 
%         title(variable_names(plot_vars(j)))
%         hold off 
%     end
% end
% 
% for j2 = 1:length(plot_vars) %length(variable_names)
%     figure(1)
%     subplot(1,2,j2)
%     hold on 
%     if j2 == length(plot_vars)
%         legend(leg(1), leg(2), leg(3), Location="best") % leg(4), leg(5), leg(6), leg(7), leg(8), leg(9))
%     end
%     xlim([0,0.5])
%     xlabel("Time [days]")
%     ylabel(units(plot_vars(j2)))
% %     subtitle("Legend: C_V [m^3], # of CM, E_e [µmol/m^2s], light color")
%     hold off
% %     saveas(gcf, root + "figures\" + variable_names(j) + ".png")
% %     sgtitle(sprintf("Variation of  PBR volume with other parameters held constant\n # of CM = 2, Light intensity = 100 [\mu mol/m²/s], Light color = RedExperimental")) 
% 
% %     sgtitle({'Variation of the PBR Light Color','\fontsize{10}Volume Coefficient = 0.05 [m^3/CM]', 'Number of Crew Members = 2', 'Light intensity = 100 [\mumol/m²/s]'});
% %     sgtitle({'Variation of the PBR Light Intensity','\fontsize{10}Volume Coefficient = 0.05 [m^3/CM]', 'Number of Crew Members = 2', 'Light color = Red Experimental'});
%     sgtitle({'Variation of the Number of Crew Members, CM','\fontsize{10}Volume Coefficient = 0.05 [m^3/CM]', 'Light intensity = 200 [\mumol/m²/s]', 'Light color = Daylight'});
% %     sgtitle({'Variation of the PBR Volume Coefficient, C_V','\fontsize{10}Number of Crew Members = 2', 'Light intensity = 100 [\mumol/m²/s]', 'Light color = RedExperimental'});
% end