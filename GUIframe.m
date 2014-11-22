function [h,s] = GUIframe(s)
close
%% GUI params
s.bdratio  = 1886/1991;
s.figwidth = 1100;
s.axwidth  = 800;
s.yoffset  = 15;
s.xoffset  = 15;
s.panelLineColor = repmat(0.75, 1,3);
s.backgcolor     = repmat(0.95, 1,3);
s.fontcolor      = repmat(0.2, 1,3);
%% Figure
h.Figure = figure('GraphicsSmoothing', 'off', 'Resize','off','Name','Price explorer',...
    'MenuBar','None','Toolbar','none','NumberTitle','off','Color',s.backgcolor,...
    'Position',[400 ,100, s.figwidth, 900]);
%% Axis
h.Axis = axes('Parent',h.Figure,...
    'NextPlot','add',...
    'Color','white','Layer','Top','Box','on','Xtick',[],'Ytick',[],...
    'Xcolor',s.panelLineColor,'Ycolor',s.panelLineColor,...
    'Units','pix',...
    'Position',[s.xoffset, s.yoffset, s.axwidth, s.axwidth*s.bdratio]);
%% Stats panel
textprop = {'Style','text', 'HorizontalAl','left','FontSize',10, 'Background',s.backgcolor,'Foreground',s.fontcolor, 'Units','normalized'};
h.Statspanel.Handle = uipanel('Parent',h.Figure,...
    'BorderType','line','Backg',s.backgcolor,'HighlightColor',s.panelLineColor,...
    'Units','pix',...
    'Position',[s.xoffset, 2*s.yoffset + s.axwidth*s.bdratio, s.axwidth,100]);
% Postcode 
h.Statspanel.PostcodePanel = uipanel('Parent',h.Statspanel.Handle,...
    'BorderType','none','HighlightColor',s.panelLineColor,'Backg',s.backgcolor,...
    'Units','normalized',...
    'Position',[0.01, .75, .22,.2]);
h.Statspanel.PostcodeLabel = uicontrol('Parent',h.Statspanel.PostcodePanel,...
    textprop{:},...
    'String','Postcode lookup: ',...
    'Position',[0, 0, 1,1]);
width = .4;
h.Statspanel.PostcodeEdit = uicontrol('Parent',h.Statspanel.PostcodePanel,...
    'Style','edit',...
    'HorizontalAl','left','FontSize',10,...
    'Foreground',s.fontcolor,...
    'Units','normalized',...
    'Position',[1-width, 0.2,width,.8]);
% Name
h.Statspanel.Name = uicontrol('Parent',h.Statspanel.Handle,...
    textprop{:},...
    'String','Name: Plumpton, Streat, East Chiltington and St. John (Without) Ward',...
    'Position',[.28, .75, .55,.2]);
% Code
h.Statspanel.Code = uicontrol('Parent',h.Statspanel.Handle,...
    textprop{:},...
    'String','Code: E05002685',...
    'Position',[.85, .75, .14,.2]);
% Area
h.Statspanel.Area = uicontrol('Parent',h.Statspanel.Handle,...
    textprop{:},...
    'String','Area (ha): 18013',...
    'Position',[0.01, .5, .2,.2]);
%% Layers panel
panelprop = {'BorderType','line','Backg',s.backgcolor,'HighlightColor',s.panelLineColor, 'Units','normalized'};
checkprop = {'Style','checkbox', 'HorizontalAl','left','FontSize',10, 'Background',s.backgcolor,'Foreground',s.fontcolor, 'Units','normalized',...
             'callback',@toggleCheckBox};
s.titheight = 25;

% Container
heightLayers = 145;
h.Layerspanel.Handle = uipanel('Parent',h.Figure,...
    'BorderType','none','Backg',s.backgcolor,'HighlightColor',s.panelLineColor,...
    'Units','pix',...
    'Position',[2*s.xoffset+s.axwidth, s.yoffset + s.axwidth*s.bdratio-heightLayers, s.figwidth-3*s.xoffset-s.axwidth,heightLayers]);
% Title
h.Layerspanel.Title = uipanel('Parent',h.Layerspanel.Handle,...
    panelprop{:},...
    'Position',[0, 1-s.titheight/heightLayers, 1, s.titheight/heightLayers]);
xoffset = 8;
xoffset = xoffset/(s.figwidth-3*s.xoffset-s.axwidth);
h.Layerspanel.TitleString = uicontrol('Parent',h.Layerspanel.Title,...
    textprop{:},...
    'String','Layers',...
    'Position',[xoffset, 0, 1, .8]);
% Body
yoffset   = 8;
nchild    = 5;
rowheight = (heightLayers - s.titheight - (nchild+1)*yoffset)/nchild;
rowheight = rowheight/(heightLayers - s.titheight);
yoffset   = yoffset/(heightLayers-s.titheight);
h.Layerspanel.Body = uipanel('Parent',h.Layerspanel.Handle,...
    panelprop{:},...
    'Position',[0, 0, 1,1-s.titheight/heightLayers]);
% Map
h.Layerspanel.BodyCheckMap = uicontrol('Parent',h.Layerspanel.Body,...
    checkprop{:},'Value',1,...
    'String','Map','Tag','map',...
    'Position',[xoffset, 5*yoffset+4*rowheight, 1, rowheight]);
% Scatter
h.Layerspanel.BodyCheckDeals = uicontrol('Parent',h.Layerspanel.Body,...
    checkprop{:},...
    'String','Trades','Tag','scatter',...
    'Position',[xoffset, 4*yoffset+3*rowheight, 1, rowheight]);
% Boundaries
h.Layerspanel.BodyCheckBoundaries = uicontrol('Parent',h.Layerspanel.Body,...
    checkprop{:},...
    'String','Boundaries','Tag','boundaries',...
    'Position',[xoffset, 3*yoffset+2*rowheight, 1, rowheight]);
% Excluded
h.Layerspanel.BodyCheckBoundariesExcluded = uicontrol('Parent',h.Layerspanel.Body,...
    checkprop{:},...
    'String','Excluded boundaries','Tag','excluded',...
    'Position',[xoffset, 2*yoffset+rowheight, 1, rowheight]);
% Tiles
h.Layerspanel.BodyCheckTiles = uicontrol('Parent',h.Layerspanel.Body,...
    checkprop{:},...
    'String','Tiles','Tag','tiles',...
    'Position',[xoffset, yoffset, 1, rowheight]);
%% Tiles panel
checkprop = {'Style','radiobutton','Enable','off', 'HorizontalAl','left','FontSize',10, 'Background',s.backgcolor,'Foreground',s.fontcolor, 'Units','normalized'};
heightTiles = 100;
h.Tilespanel.Handle = uipanel('Parent',h.Figure,...
    'BorderType','none','Backg',s.backgcolor,'HighlightColor',s.panelLineColor,...
    'Units','pix',...
    'Position',[2*s.xoffset+s.axwidth, s.axwidth*s.bdratio-heightTiles-heightLayers, s.figwidth-3*s.xoffset-s.axwidth,heightTiles]);
% Title
h.Tilespanel.Title = uipanel('Parent',h.Tilespanel.Handle,...
    panelprop{:},...
    'Position',[0, 1-s.titheight/heightTiles, 1, s.titheight/heightTiles]);
h.Tilespanel.TitleString = uicontrol('Parent',h.Tilespanel.Title,...
    textprop{:},...
    'String','Tiles',...
    'Position',[xoffset, 0, 1, .8]);
% Body
yoffset   = 8;
nchild    = 3;
rowheight = (heightTiles - s.titheight - (nchild+1)*yoffset)/nchild;
rowheight = rowheight/(heightTiles-s.titheight);
yoffset   = yoffset/(heightTiles-s.titheight);
h.Tilespanel.Body = uipanel('Parent',h.Tilespanel.Handle,...
    panelprop{:},...
    'Position',[0, 0, 1,1-s.titheight/heightTiles]);
% Average
h.Tilespanel.BodyRadioAvg = uicontrol('Parent',h.Tilespanel.Body,...
    checkprop{:},...
    'String','Average price','Tag','avg',...
    'Position',[xoffset, 3*yoffset+2*rowheight, 1, rowheight]);
% Density
h.Tilespanel.BodyRadioWeighted = uicontrol('Parent',h.Tilespanel.Body,...
    checkprop{:},...
    'String','Area weighted price','Tag','weighted',...
    'Position',[xoffset, 2*yoffset+rowheight, 1, rowheight]);
% Trend
h.Tilespanel.BodyRadioTrend = uicontrol('Parent',h.Tilespanel.Body,...
    checkprop{:},...
    'String','Price trends','Tag','trend',...
    'Position',[xoffset, yoffset, 1, rowheight]);
end