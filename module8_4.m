function module_8_4
  % Remove interference with harmonics from sinusoid
  %
  % This Octave/MATLAB script was written to mimic a corresponding
  % Labview module (Module 6.1) that accompanies the free text 
  % "Signals and Systems: Theory and Applications" by Ulaby and Yagle
  % (ss2.eecs.umich.edu).
  %
  % In almost all cases the compuation code used in these scripts
  % is the same as that used in the Labview module.  Credit for the
  % computation code should go to the textbook authors.
  
  % These scripts have been tested under Octave 4.2.2, Octave 4.4.0
  % and MATLAB R2015a.  The Octave GUI implementation is still a
  % little buggy.  Some of strange plotting code used here attempts
  % to work around a few Octave bugs.

  % Copyright (C) 2018 Anthony Richardson <richardson.tony@gmail.com>
  %
  % This program is free software; you can redistribute it and/or modify it under
  % the terms of the GNU General Public License as published by the Free Software
  % Foundation; either version 3 of the License, or (at your option) any later
  % version.
  %
  % This program is distributed in the hope that it will be useful, but WITHOUT
  % ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
  % FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
  % details.
  %
  % You should have received a copy of the GNU General Public License along with
  % this program; if not, see <http://www.gnu.org/licenses/>.
  
  % Signal frequency (Hz)
  f1 = 30; 
  % Interference frequency (Hz)
  fi = 60;
  % Number of harmonics in interference
  ni = 3;

  % Pole Radius for comb Filter
  pr = 0.9;
  
  % Save initial simulation state
  simState('f1', f1); simState('fi', fi); 
  simState('ni', ni);  simState('pr', pr);
  
  % ichange indicates a change in one of the interference parameters
  % (either fi or ni)
  simState('ichange', true);
  
  clf;
  createPanel();
  createPlot();
end

function createPanel
  pos = [.65 0.05 .30 .41 ];
  p = uipanel ('position', pos, 'visible', 'off');
  simState('cpanel', p);
  
  
  %% BUG workaround - may be able to remove this in a
  %% future version of octave
  if (exist('OCTAVE_VERSION', 'builtin'))
    % The panel position seems to get messed up when the
    % window is resized in Octave. This was an attempt to fix it.
    %set(gcf, 'sizechangedfcn', @resetControlPanel);
    % That didn't work but this seems too.
    dellistener(gcf, 'position');
    addlistener (gcf, 'position', {@resetControlPanel, p, pos});
  end
  
  
  h = sliderControl(p, '# of interference harmonics', [1, 3], ...
                      simState('ni'), [.6 .6], ...
                      [0.05 .65 0.9 .25], @guiCallback );
  simState('nih', h);
  h = sliderControl(p, 'interference fundamental freq', [40, 80], ...
                      simState('fi'), [1 2], ...
                      [0.05 .35 0.9 .25], @guiCallback );
  simState('fih', h);
  h = sliderControl(p, 'Pole Radius', [0.5, 0.99], ...
                      simState('pr'), [0.01 0.05], ...
                      [0.05 .05 0.9 .25], @guiCallback );
  simState('prh', h);
end

% Reset GUI panel after window size change
function resetControlPanel(~, ~, p, pos)
  % Just setting the panel position does not seem to work but
  % maximizing it and then resetting the position does.
  set(p, 'visible', 'off');
  set(p, 'position', [1 1 0 0]);
  set(p, 'position', pos);
  set(p, 'visible', 'on');
end

function guiCallback(s, ~)
  g = simState();
  if (s == g.nih)
    % ni slider (# of harmonics)
    v = round(get(s, 'value'));
    set(s, 'value', v);
    set(get(s, 'userdata'), 'string', num2str(v));
    simState('ni', v);
    simState('ichange', true);
  elseif (s == g.fih)
    % fi slider  (interference freq)
    v = round(get(s, 'value'));
    set(s, 'value', v);
    set(get(s, 'userdata'), 'string', num2str(v));
    simState('fi', v);
    simState('ichange', true);
  elseif (s == g.prh)
    % pole radius slider
    v = round(get(s, 'value')/0.01)*0.01;
    set(s, 'value', v);
    set(get(s, 'userdata'), 'string', num2str(v));
    simState('pr', v);
  end
  
  createPlot();
end

function createPlot()

  %%{
  fs = 480;

  s = simState();

  persistent N
  if (isempty(N))
      N = 1:100;
  end
  persistent x 
  if (isempty(x))
      x = zeros(size(N));
  end
  persistent FXP

  %set(g.status, 'string', 'wait');
  persistent nplot
  if(isempty(nplot))
    nplot = 80:100;
  end
  
  persistent fplot
  if(isempty(fplot))
    fplot = (0:1000)*fs/2000;
  end
  
  % All plots but the first one change with any change to any of the
  % sim parameters.  The first one changes only with a change in the 
  % interference signal.  The flag ichange is true anytime there is 
  % a change to an interference parameter.
  
  % Data changes
  if(s.ichange)
    x = cos(2*pi*N*s.f1/fs);
    % The harmonic amplitudes were randomly generate (one time) in the
    % Labview module, but I don't see the value.
    Ai = [1 0.75 0.5];
    for n = 1:s.ni;
      x = x + Ai(n)*cos(2*pi*n*s.fi*N/fs);
    end
    FX = 2*abs((fft(x, 2000)))/length(N);
    FXP = FX(1:1001);
  end
  
  % The filter will change with a change to any of the parameters
  Z=exp(1i*2*pi*(-s.ni:s.ni)'*s.fi/fs);
  P=s.pr*exp(1i*2*pi*(-s.ni:s.ni)'*s.fi/fs);
  B=poly(Z);
  A=poly(P);
  W=exp(1i*2*pi*fplot/fs);
  HP=abs(polyval(B,W)./polyval(A,W));
  HP(HP<1e-9) = 1e-9;

  % The output will also change with a change to any parameter
  y = filter(B, A, x);
  FY = 2*abs((fft(y, 2000)))/length(N);
  FYP = FY(1:1001);
  
  % Create the plots
  plotw = 0.20;  ploth = 0.32; 
  plotrowy = [0.62  0.15];
  plotcolx = [0.07  0.35   0.60];
  
  if(s.ichange)
    subplot('position', [plotcolx(1) plotrowy(1) plotw ploth] );
    stem(nplot, x(nplot));
    grid on;
    xlim([nplot(1) nplot(end)]);
    xlabel('samples');
    ylabel('Value');
    h = title('Original (x)');
    p = get(h, 'position');
    xl = xlim();
    set(h, 'position', [xl(1) p(2:3)], 'horizontalalignment', 'left');
  end

  subplot('position', [plotcolx(2) plotrowy(1) plotw ploth]);
  semilogy(fplot, FXP);
  hold on
  semilogy(fplot, HP);
  hold off
  %yl = ylim();
  ylim([1e-3 4]);
  xlim([fplot(1) fplot(end) ]);
  grid on;
  xlabel('Freq (Hz)');
  ylabel('Value');
  h = title('Original (x)');
  p = get(h, 'position');
  xl = xlim();
  set(h, 'position', [xl(1) p(2:3)], 'horizontalalignment', 'left');
  
  subplot('position', [plotcolx(1) plotrowy(2) plotw ploth] );
  stem(nplot, y(nplot));
  grid on;
  ylim([-2 2]);
  xlabel('samples');
  ylabel('Value');
  h = title('Filtered (y)');
  p = get(h, 'position');
  xl = xlim();
  set(h, 'position', [xl(1) p(2:3)], 'horizontalalignment', 'left');

  subplot('position', [plotcolx(2) plotrowy(2) plotw ploth]);
  semilogy(fplot, FYP);
  %yl = ylim();
  ylim([1e-3 4]);
  xlim([fplot(1) fplot(end) ]);
  grid on;
  xlabel('Freq (Hz)');
  ylabel('Value');
  h = title('Filtered (y)');
  p = get(h, 'position');
  xl = xlim();
  set(h, 'position', [xl(1) p(2:3)], 'horizontalalignment', 'left');

  subplot('position', [plotcolx(3) 0.54 2*plotw 2*plotw] );
  angle = (-1:0.01:1)*pi;
  plot(cos(angle), sin(angle));
  grid on;
  axis([-1.2 1.2 -1.2 1.2], 'square');
  box('on');
  hold on;
  plot(real(Z), imag(Z), 'ok')
  plot(real(P), imag(P), 'xr')
  hold off;
  h = title('Pole/Zero Plot');
  p = get(h, 'position');
  xl = xlim();
  set(h, 'position', [xl(1) p(2:3)], 'horizontalalignment', 'left');
  xlabel('Real(z)');
  ylabel('Imag(z)');

  simState('ichange', false);
  axes('position', [0 0 1 1], 'visible', 'off');
  text(0.175, 0.03, 'f = 30 Hz', ...
                  'fontsize', 12, ...
                  'fontweight', 'bold', ...
                  'horizontalalignment', 'center');
  
  set(simState('cpanel'), 'visible', 'on');
  drawnow();
end

function v = simState(key, val)
  persistent state;
  if (nargin == 0)  
    % Return the entire struct
    v = state;
  elseif (nargin == 1)
    % Return a particular field from the struct
    v = state.(key);
  elseif (nargin == 2)
    % Set a key value (key must be a string)
    state.(key) = val;
    v = val;
  end
end

function h = sliderControl(parent, label, limits, val, step, pos, cback)
  % sliderstep = [minstep maxstep]
  % where minstep is fraction of range on arrow click
  % and maxstep is fraction of range on trough click
  h = uicontrol(parent, 'style' ,'slider',...
           'units', 'normalized',...
           'position', [pos(1) pos(2)+0.33*pos(4) pos(3) 0.32*pos(4)],...
           'min', limits(1), 'max', limits(2),...
           'sliderstep', [step(1)/(limits(2)-limits(1)) step(2)/(limits(2)-limits(1))],...
           'value', val, 'callback', cback);
  uicontrol(parent, 'style', 'text',...
           'units', 'normalized',...
           'position', [pos(1) pos(2) 0.2*pos(3) 0.3*pos(4)],...
           'horizontalalignment', 'left', ...
           'String', num2str(limits(1)));
  uicontrol(parent, 'style', 'text',...
           'units', 'normalized',...
           'position', [pos(1)+0.8*pos(3) pos(2) 0.2*pos(3) 0.3*pos(4)],...
           'horizontalalignment', 'right', ...
           'String', num2str(limits(2)));         
  uicontrol(parent, 'style', 'text',...
           'units', 'normalized',...
           'position', [pos(1) pos(2)+0.67*pos(4) pos(3) 0.3*pos(4)],...
           'horizontalalignment','left',...
           'String', label);        
  hc = uicontrol(parent, 'style', 'text',...
           'units', 'normalized',...
           'position', [pos(1)+.3*pos(3) pos(2) 0.4*pos(3) 0.3*pos(4)],...
           'backgroundcolor', [0.8 0.8 0.8], ...
           'String', num2str(val));
  set(h, 'userdata', hc);
end