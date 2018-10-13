% Sign restriction plot
% This code is a modification and extension on Ambrogio Cesa-Bianchi's sample code for
% "A VAR identified with sign restrictions"

% for more information,
% visit <https://sites.google.com/site/ambropo/MatlabCodes>

% Zelin Chen 
% email: zelinc@outlook.com, github: ZelinC
% University of Melbourne

%% 1. PRELIMINARIES
% =======================================================================
clear all; clear session; close all; clc
warning off all

% Load
[xlsdata, xlstext] = xlsread('AUS_transformed_monthly.xlsx');
% Define data
X = xlsdata(1:end,:); % remove NA values
% Define label for plots
dates = xlstext(1:end,1);
vnames = xlstext(1,2:end);
% Define number of variables and of observations
[nobs, nvar] = size(X);



%% VAR ESTIMATION
% =======================================================================
% Set the case for the VARout (0, 1, or 2)
det = 2;
% Set number of nlags
nlags = 6;
% Estimate 
[VAR, VARopt] = VARmodel(X,nlags,det);
% Print at screen and create table
VARopt.vnames = vnames;
[beta, tstat, TABLE] = VARprint(VAR,VARopt);


%% SIGN RESTRICTIONS
% =======================================================================
% Monetary policy shock
R(:,:,1) = [ 1     1     1    % Fed Funds
             1     1     -1    % inf
             1     1     0];  % unemp

% Supply shock
R(:,:,2) = [ 1     1     1    % Fed Funds
             1     1     1    % inf
             1     1     1];  % unemp
         
% Demand shock
R(:,:,3) = [ 1     1    1    % Fed Funds
             1     1    1    % inf
             1     1    -1];   % unemp



% Set options for IRFs and SR
VARopt.quality = 0;
VARopt.snames  = {'Monetary Policy Shock';'Supply Shock';'Demand Shock'};
VARopt.vnames  = vnames;
VARopt.ndraws  = 100;
VARopt.ident   = 'sr';

% Run sign restrictions routine
SRout = SR(VAR,R,VARopt);

% Plot IRFs
INFall = SRout.IRFall;
MED = SRout.IRFmed;
INF = SRout.IRFinf;
SUP = SRout.IRFsup;

jname = {'ffr';'infl';'unemp'};
kname = {'int';'supply';'demand'};


%% plot IRFs as all draws 
figure();
for j = 1:length(vnames) % variables
    for k = 1:length(vnames)  % shock
    
        % IRF for each draw of shock
        subplot(length(vnames),length(vnames),(j-1)*length(vnames)+k);
        hold on;
        for n = 1:VARopt.ndraws
            plot(1:VARopt.nsteps, INFall(:,j,k,n),'k') 
            titlename = strcat('var:', jname(j), ', shock:', kname(k));
            title(titlename)
        end
        hold off;
    end
end


%% Plot IRFs as median and CI
figure();
for j = 1:length(vnames) % variables
    for k = 1:length(vnames)  % shock
    
        % draw each plot
        subplot(length(vnames),length(vnames),(j-1)*length(vnames)+k);
        hold on;
        plot(1:VARopt.nsteps, MED(:,j,k),'k') 
        plot(1:VARopt.nsteps, INF(:,j,k),'r')
        plot(1:VARopt.nsteps, SUP(:,j,k),'r')
        titlename = strcat('var:', jname(j), ', shock:', kname(k));
        title(titlename)
        hold off;
        
    end
end
sgtitle('Subplot Grid Title')

