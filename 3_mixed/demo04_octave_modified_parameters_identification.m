% The MIT License (MIT)
%
% Copyright (c) 2016 Roman Szewczyk
%
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in all
% copies or substantial portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
% SOFTWARE.
% 
%
% DESCRIPTION:
% Demonstration of identification of parameters of Jiles-Atherton model of four hysteresis loops with increase of magnetizing field amplitude
% fminsearch() function used with Nelder and Mead Simplex algorithm (a derivative-free method)
% Target function is sum of squared RELATIVE differences between results of modelling and simulation.
%
% AUTHOR: Roman Szewczyk, rszewczyk@onet.pl
%
% RELATED PUBLICATION(S):
% [1] Jiles D. C., Atherton D. "Theory of ferromagnetic hysteresis” Journal of Magnetism and Magnetic Materials 61 (1986) 48.
% [2] Szewczyk R. "Computational problems connected with Jiles-Atherton model of magnetic hysteresis". Advances in Intelligent Systems and Computing (Springer) 267 (2014) 275.
%
% USAGE:
% demo03_octave_simple_parametrs_identification
% 
% IMPORTANT: Demo requires "odepkg", "struct" and "optim" packages installed and loaded  
%

clear all
clc

page_screen_output(0);
page_output_immediately(1);  % print immediately at the screen


fprintf('\n\nDemonstration of identification of Jiles-Atherton models parameters for four hysteresis loops.');
fprintf('\nDemonstration optimized for OCTAVE. For MATLAB please use demo03_matlab_simple_parameters_identification.m ');
fprintf('\nDemonstration requires odepkg, struct and optim packages installed.\n\n');


% check if odepkg is installed. Load odepkg if installed, but not loaded.
ChkPkg('odepkg');

% check if struct is installed. Load odepkg if installed, but not loaded.
ChkPkg('struct');

% check if optim is installed. Load odepkg if installed, but not loaded.
ChkPkg('optim');

% Load measured B(H) characterisitcs of M130_27s electrical steel

cd ('Characterisitcs_mixed_mat');
load('H_M130_27s.mat');
load('B_M130_27s.mat');
cd ('..');
 
fprintf('Load measured B(H) characterisitcs of M130-27s electrical steel measured in the easy axis direction... done\n\n');

% prepare starting point for optimisation

mi0=4.*pi.*1e-7;

Ms0=max(max(BmeasT))./mi0;
a0=10;
alpha0=1e-6;
k0=10;
c0=0.7;        % Initial parameters of Jiles-Atherton model for optimisation
Kan0=100;
psi=0;      % WARNING! psi=0 is constant!
t0=0.8;


JApoint0=[a0 k0 c0 Ms0 alpha0 Kan0 psi t0];

SolverType=4;
FixedStep=1;

func = @(JApointn) JAn_loops_target_mod( [JApointn(1:7) 0], JApoint0, HmeasT, BmeasT, SolverType, FixedStep);

options=optimset('Display','iter','MaxFunEvals',1500);

fprintf('Optimization process started... (first cycle expected in less than 10 min.)\n\n');

tic

JApoint_res=fminsearch(func,[1 1 1 1 1 1 1],options);

toc

fprintf('\n\nOptimiation process done.\n\n');

Ftarget=func(JApoint_res);

BsimT = JAn_loops(JApoint0(1).*JApoint_res(1), JApoint0(2).*JApoint_res(2), JApoint0(3).*JApoint_res(3), ...
 JApoint0(4).*JApoint_res(4), JApoint0(5).*JApoint_res(5), JApoint0(6).*JApoint_res(6), 0, JApoint0(7).*JApoint_res(7), HmeasT, BmeasT, SolverType, FixedStep );

fprintf('Results of optimisation:\n'); 
fprintf('Target function value: Ftarget=%f\n',Ftarget);
fprintf('JA model params: a=%f(A/m), k=%f(A/m), c=%f, Ms=%e(A/m), alpha=%e, Kan=%e, psi=0, t=%f \n\n',  ...
 JApoint0(1).*JApoint_res(1), JApoint0(2).*JApoint_res(2), JApoint0(3).*JApoint_res(3), ...
 JApoint0(4).*JApoint_res(4), JApoint0(5).*JApoint_res(5), JApoint0(6).*JApoint_res(6), JApoint0(7).*JApoint_res(7) );
 
fprintf('Optimisation done.\n\n');

plot(HmeasT, BmeasT,'or',HmeasT,BsimT,'k');
xlabel('H (A/m)');
ylabel('B (T)');
grid;

JApoint_optim=JApoint0.*[JApoint_res(1:7) 0 ];

save -v7 demo04_results.mat JApoint_optim JApoint0 JApoint_res
