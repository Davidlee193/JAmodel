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
%
% AUTHOR: Roman Szewczyk, rszewczyk@onet.pl
%
% RELATED PUBLICATION(S):
% [1] Jiles D. C., Atherton D. "Theory of ferromagnetic hysteresis” Journal of Magnetism and Magnetic Materials 61 (1986) 48.
% [2] Szewczyk R. "Computational problems connected with Jiles-Atherton model of magnetic hysteresis". Advances in Intelligent Systems and Computing (Springer) 267 (2014) 275.
%
% USAGE:
% demo03_octave_view
% 
% IMPORTANT: Demo requires "odepkg", "struct" and "optim" packages installed and loaded  
%

clear all
clc

page_screen_output(0);
page_output_immediately(1);  % print immediately at the screen


fprintf('\n\nVisualization of the results of identification of Jiles-Atherton models parameters for four hysteresis loops.');
fprintf('\nDemonstration optimized for OCTAVE. For MATLAB please use demo03_matlab_view.m ');
fprintf('\nDemonstration requires odepkg package installed.\n\n');

% check if odepkg is installed. Load odepkg if installed, but not loaded.

inst_pkg = pkg ("list");

[i,j]=size(inst_pkg);

odepkg_inst=0;
odepkg_loaded=0;

for i=1:j
    if size(findstr(inst_pkg{1,i}.name,'odepkg'))>0
       odepkg_inst=1;
       if inst_pkg{1,i}.loaded==1;
          odepkg_loaded=1;
       end
    end
end

if odepkg_inst==0
   fprintf('\n *** ERROR: odepkg must be installed to solve ODEs.\n To solve problem try: pkg install -forge odepkg\n\n');
   return
else
   fprintf('\n odepkg installed...ok.');
end
   
 if odepkg_loaded==0
   fprintf('\n WARNING: odepkg is installed but not loaded.\n');
   pkg load odepkg
   fprintf(' Problem solved: odepkg is loaded now.\n\n');
   else
   fprintf('\n odepkg loaded...ok.\n\n');
end


% Load measured B(H) characterisitcs of Mn-Zn ferrite

cd ('Characterisitcs_mixed_mat');
load('H_M130_27s.mat');
load('B_M130_27s.mat');
cd ('..');
 
fprintf('Load measured B(H) characterisitcs of M130-27s electrical steel measured in the easy axis direction... done\n\n');

% prepare starting point for optimisation

mi0=4.*pi.*1e-7;

load('demo03_results.mat');

SolverType=1;
FixedStep=1;

func = @(JApointn) JAn_loops_target( [JApointn(1:7) 0], JApoint0, HmeasT, BmeasT, SolverType, FixedStep);

fprintf('calculations...\n\n');

Ftarget=func(JApoint_res);

BsimT = JAn_loops(JApoint0(1).*JApoint_res(1), JApoint0(2).*JApoint_res(2), JApoint0(3).*JApoint_res(3), ...
 JApoint0(4).*JApoint_res(4), JApoint0(5).*JApoint_res(5), JApoint0(6).*JApoint_res(6), 0, JApoint0(7).*JApoint_res(7), HmeasT, BmeasT, SolverType, FixedStep );

fprintf('Results of optimisation:\n'); 
fprintf('Target function value: Ftarget=%f\n',Ftarget);
fprintf('JA model params: a=%f(A/m), k=%f(A/m), c=%f, Ms=%e(A/m), alpha=%e, Kan=%e, psi=0, t=%f \n\n',  ...
 JApoint0(1).*JApoint_res(1), JApoint0(2).*JApoint_res(2), JApoint0(3).*JApoint_res(3), ...
 JApoint0(4).*JApoint_res(4), JApoint0(5).*JApoint_res(5), JApoint0(6).*JApoint_res(6), JApoint0(7).*JApoint_res(7) );
 
fprintf('done.\n\n');

plot(HmeasT, BmeasT,'or',HmeasT,BsimT,'k');
xlabel('H (A/m)');
ylabel('B (T)');
grid;

JApoint_optim=JApoint0.*[JApoint_res(1:7) 0 ];

save -v7 demo03_results.mat JApoint_optim JApoint0 JApoint_res
