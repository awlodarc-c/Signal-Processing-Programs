function module_8_3
  % Demonstrate Sinusoidal Interference Removal
  %
  % This Octave/MATLAB script was written to mimic a corresponding
  % Labview module (Module 8.3) that accompanies the free text 
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
  
  % Interference level
  Ai = 0.5; 
  % Interference and notch frequencies
  fi = 800; fn = 800; 

  % Pole Radius for Notch Filter
  pr = 0.9;
  
  % Starting sample index for sample domain plots
  nind = 400;
  
  % Save initial simulation state
  simState('Ai', Ai); simState('fi', fi); simState('fn', fn);
  simState('pr', pr); simState('nind', nind);
  
  simState('xup', true);
  simState('yup', true);
  simState('zup', true);
  simState('hup', true);
  simState('xplay' , false);
  simState('yplay' , false);
  simState('zplay' , false);

  clf;
  createPanel();
  createPlot();
end

function createPanel
  pos = [.65 0.02 .32 .65 ];
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
  
  bg = uibuttongroup(p, 'position', [.0 .88 1 .12]);
  bx = uicontrol(bg, 'style', 'pushbutton', ...
                'units', 'normalized', ...
                'string', 'x', ...
                'callback', @guiCallback, ...
                'position', [0.45 0.1 .1 .8]);
  by = uicontrol(bg, 'style', 'pushbutton', ...
                'units', 'normalized', ...
                'string', 'y', ...
                'callback', @guiCallback, ...
                'position', [0.65 0.1 .1 .8]);
  bz = uicontrol(bg, 'style', 'pushbutton', ...
                'units', 'normalized', ...
                'string', 'z', ...
                'callback', @guiCallback, ...
                'position', [0.85 0.1 .1 .8]);
  uicontrol(bg, 'style', 'text', ...
                'units', 'normalized', ...
                'string', 'Play:', ...
                'position', [0.05  0.1 .2 .8]);
  
  simState('bx', bx);
  simState('by', by);
  simState('bz', bz);
  
  p = uipanel (p, 'position', [0 0 1 .88 ]);
  h = sliderControl(p, 'Interference Level', [0, 1], ...
                      simState('Ai'), [.05 .2], ...
                      [0.05 .78 0.9 .2], @guiCallback );
  simState('Aih', h);
  h = sliderControl(p, 'Interference Frequency', [600, 2000], ...
                      simState('fi'), [10 50], ...
                      [0.05 .57 0.9 .2], @guiCallback );
  simState('fih', h);
  h = sliderControl(p, 'Notch Frequency', [600, 2000], ...
                      simState('fn'), [10 50], ...
                      [0.05 .36 0.9 .2], @guiCallback );
  simState('fnh', h);
  h = sliderControl(p, 'Pole Radius', [0.5, 0.99], ...
                      simState('pr'), [0.01 0.05], ...
                      [0.05 .15 0.9 .2], @guiCallback );
  simState('prh', h);

  h = uicontrol(p, 'style', 'text', ...
                'units', 'normalized', ...
                'string', 'ready', ...
                'backgroundcolor', [.2 .2 .2], ...
                'foregroundcolor', [1 1 1], ...
                'position', [0.35  0.02 .3 .1]);
  simState('status', h);
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
  if (s == g.bx)
    simState('xplay', true);
  elseif (s == g.by)
    simState('yplay', true);
  elseif (s == g.bz)
    simState('zplay', true);
  elseif (s == g.Aih)
    % Ai slider (inter amplitude)
    v = round(get(s, 'value')/0.05)*0.05;
    set(s, 'value', v);
    set(get(s, 'userdata'), 'string', num2str(v));
    simState('Ai', v);
    simState('yup', true);
    simState('zup', true);
  elseif (s == g.fih)
    % fi slider  (interference freq)
    v = round(get(s, 'value')/10)*10;
    set(s, 'value', v);
    set(get(s, 'userdata'), 'string', num2str(v));
    simState('fi', v);
    simState('yup', true);
    simState('zup', true);
  elseif (s == g.fnh)
    % fn slider  (notch freq)
    v = round(get(s, 'value')/10)*10;
    set(s, 'value', v);
    set(get(s, 'userdata'), 'string', num2str(v));
    simState('fn', v);
    simState('hup', true);
    simState('yup', true);
    simState('zup', true);
  elseif (s == g.prh)
    % pole radius slider
    v = round(get(s, 'value')/0.01)*0.01;
    set(s, 'value', v);
    set(get(s, 'userdata'), 'string', num2str(v));
    simState('pr', v);
    simState('hup', true);
    simState('yup', true);
    simState('zup', true);
  end
  
  createPlot();
end

function createPlot()

  %%{
  fs = 44100;
  % Keep x, y, and z persistent so that they can be played without
  % having to be recalculated
  persistent x 
  if (isempty(x))
      x = csvread('trumpet.csv');
  end
  persistent y 
  if(isempty(y))
      y = zeros(size(x));
  end
  persistent z 
  if (isempty(z))
      z = zeros(size(x));
  end
  
  % These are persistent for performance reasons.
  % They only need to be computed once and never change.
  persistent N 
  if (isempty(N))
      N = length(x);
  end
  %persistent t 
  %if (isempty(t))
  %    t = (0:L-1)/fs;
  %end
  fplot_max = 5000;
  persistent wind
  if (isempty(wind))
      Nplot = round(fplot_max*N/fs)+1;
      wind =(1:Nplot);
  end
  persistent wplot
  if (isempty(wplot))
      wplot =(wind-1)*fs/N;
  end
  
  % These are needed to compute z and FZ
  persistent FH FY

  %}
  s = simState();
  %%{
  set(s.status, 'string', 'wait');

  nplot = s.nind+(0:99);

  dw = 0.05; plotw = 0.20;  
  dh = 0.05; ploth = 0.18; 
  plotrowy = [2*ploth+7*dh  ploth+4*dh   dh ]+ dh;
  plotcolx = [dw            plotw+3*dw   2*plotw+5*dw] + dw;
  
  if(s.xup)
    FX = fft(x);
    FXI = 2*abs(FX(wind))/N;
    subplot('position', [plotcolx(1) plotrowy(1) plotw ploth]);
    stem(nplot, x(nplot));
    grid on;
    xlim(s.nind+[0 100]);
    xlabel('samples');
    ylabel('Value');
    h = title('Original (x)');
    p = get(h, 'position');
    xl = xlim();
    set(h, 'position', [xl(1) p(2:3)], 'horizontalalignment', 'left');
  
    %subplot(3,3,2);
    subplot('position', [plotcolx(2) plotrowy(1) plotw ploth]);
    semilogy(wplot/1000, FXI);
    xlim([0 fplot_max/1000]);
    ylim([1e-5 1]);
    grid on;
    xlabel('Frequency (kHz)');
    ylabel('Value');
    h = title('Original (x)');
    p = get(h, 'position');
    xl = xlim();
    set(h, 'position', [xl(1) p(2:3)], 'horizontalalignment', 'left');

    simState('xup', false);
  end
  
  if(s.hup)
    wn=2*pi*s.fn/fs;
    B = [1     -2*cos(wn)    1];
    A = [1     -2*s.pr*cos(wn)    s.pr*s.pr];
    h = filter(B, A, [1 zeros(1, 99)]);
    w = 2*pi*(wind-1)/length(x);
    EW = exp(1j*w);
    FH=polyval(B, EW)./polyval(A, EW);
    
    subplot('position', [plotcolx(3) plotrowy(1) plotw ploth]);
    stem(0:50, h(1:51));
    grid on;
    %xlim([0 tplotmax]);
    xlabel('samples');
    ylabel('Value');
    h = title('Impulse Response');
    p = get(h, 'position');
    xl = xlim();
    set(h, 'position', [xl(1) p(2:3)], 'horizontalalignment', 'left');

    simState('hup', false);
  end

  if(s.yup)  
    y=x+s.Ai *cos(2*pi*s.fi*(1:N)/fs);  
    FY = fft(y);
    FYI = 2*abs(FY(wind))/N;
    FHI=abs(FH(wind));
    
    subplot('position', [plotcolx(1) plotrowy(2) plotw ploth]);
    stem(nplot, y(nplot));
    grid on;
    xlim(s.nind+[0 100]);
    xlabel('samples');
    ylabel('Value');
    h = title('Orig + Inter (y)');
    p = get(h, 'position');
    xl = xlim();
    set(h, 'position', [xl(1) p(2:3)], 'horizontalalignment', 'left');
    
    subplot('position', [plotcolx(2) plotrowy(2) plotw ploth]);
    semilogy(wplot/1000, FYI);
    hold on;
    semilogy(wplot/1000, FHI, 'r');
    hold off;
    xlim([0 fplot_max/1000]);
    ylim([1e-5 1]);
    grid on;
    xlabel('Frequency (kHz)');
    ylabel('Value');
    h =title('Orig + Inter (y)');
    p = get(h, 'position');
    xl = xlim();
    set(h, 'position', [xl(1) p(2:3)], 'horizontalalignment', 'left');

    simState('yup', false);
  end

  if(s.zup)
    wo=2*pi*s.fn;
    B = [1     -2*cos(wo/fs)    1];
    A = [1     -2*s.pr*cos(wo/fs)    s.pr*s.pr];
    z = filter(B, A, y);
    
    FZ = fft(z);
    FZI = 2*abs(FZ(wind))/N;

    subplot('position', [plotcolx(1) plotrowy(3) plotw ploth]);
    stem(nplot, z(nplot));
    grid on;
    xlim(s.nind+[0 100]);
    xlabel('samples');
    ylabel('Value');
    h = title('Filtered (z)');
    p = get(h, 'position');
    xl = xlim();
    set(h, 'position', [xl(1) p(2:3)], 'horizontalalignment', 'left');
    
    subplot('position', [plotcolx(2) plotrowy(3) plotw ploth]);
    semilogy(wplot/1000, FZI);
    xlim([0 fplot_max/1000]);
    ylim([1e-5 1]);
    grid on;
    xlabel('Frequency (kHz)');
    ylabel('Value');
    h = title('Filtered (z)');
    p = get(h, 'position');
    xl = xlim();
    set(h, 'position', [xl(1) p(2:3)], 'horizontalalignment', 'left');

    simState('zup', false);
  end
  
  if(s.xplay)
    xplayer = audioplayer(x, fs);
    playblocking(xplayer);
    simState('xplay', false);
  end

  if(s.yplay)
    yplayer = audioplayer(y, fs);
    playblocking(yplayer);
    simState('yplay', false);
  end

  if(s.zplay)
    zplayer = audioplayer(z, fs);
    playblocking(zplayer);
    simState('zplay', false);
  end

  %}
  set(s.cpanel, 'visible', 'on');
  drawnow();
  set(s.status, 'string', 'ready');
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