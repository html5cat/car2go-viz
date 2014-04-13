function car2go( varargin)
% car2go visualize and analyse
clear all
global currData haxMap hTblCarData haxGraph

figName = 'car2go';
singleton = true;
% Note: if non-singleton then take care about 1) Global vars 2) timer 
%


% ========================================================================
% ====    Keep Single     ================================================
% ========================================================================
if singleton
    allGUIs = findall(0,'name',figName);
    isGUIopen = allGUIs > 0;
    if numel(isGUIopen) > 0
        lastGUI = allGUIs(end); 
        figure(lastGUI)
        choice = questdlg('Only one instance','', ...
            'Stay in Existing','Close Existing and Open New','Stay in Existing');
        % Handle response
        switch choice
            case 'Stay in Existing'
                disp([mfilename,'=>',choice ])
                return;
            case 'Close Existing and Open New'
                disp([mfilename,'=>',choice])
                delete(allGUIs)
        end

    end
end

% ========================================================================
% ====    Size and Colours     ===========================================
% ========================================================================
colors = bone(20);
bgc = colors(12,:);
colors = repmat(colors(8,:),10,1);
% colors = colors(8:end,:);
% bgc = colors(4,:);

set(0, 'unit','pixels')
% Default units
tmp = get(0,'screensize');
if tmp(3) > 1400
    defaultFontsize = 8;
    figW = 0.4;
else
    defaultFontsize = 7;
    figW = 0.65;
end

% ========================================================================
% ====    MAIN FIGURE     ================================================
% ========================================================================

set(0, 'unit','normalized')
hF = figure(...    'numbertitle', 'off',...
    'WindowStyle','normal',...
    'name', figName,...
    'units', 'normalized',...
    'color', bgc,...
    'position',[0.02 0.1 figW 0.8],... %ceil(get(0,'screensize') .* [1 1 0.975 0.65]),...
    'menubar', 'none','toolbar','none','visible','on');

set(hF,'DefaultUicontrolUnits','normalized',...
    'DefaultUicontrolFontSize',defaultFontsize);

% ========================================================================
% ====    TAB PANEL     ==================================================
% ========================================================================
MainPnlNames = {'Map','Table','Graph'};

set(0, 'unit','pixels')
[~,hMainPnl,~] = tabPanel(hF,MainPnlNames,...
    'panelpos',[0.02 0.05 0.95 0.65],...
    'tabpos','Top',...
    'tabHeight',75,...
    'colors',colors,...
    'highlightColor','w',...'c'
    'tabCardPVs',{'bordertype','etchedin','fontsize',defaultFontsize},...
    'tabLabelPVs',{'fontsize',11,'Rotation',0});


hTopPnl = uipanel('parent',hF,'units','normalized',...
            'pos',[0.02 0.72 0.95 0.25],'backgroundcolor',bgc);


% ========================================================================
% ====  Get Config Params  ===============================================
% ========================================================================

if nargin == 0
    [InputData] = ioCarCfgF('r');
else
    CarCfgFname = varargin{1};
    [InputData] = ioCarCfgF('r',CarCfgFname);
end


% ========================================================================
% ====  Get Car Data    ==================================================
% ========================================================================

htableInpF = uitable(hTopPnl,'Tag','tableInpF',...
    'units','normalized','pos',[0.02 0.35 0.68 0.6],'enable','on');

inpFLegend = {'city','input_file_name','frq'};

ColW_inpData = colWidth(htableInpF, inpFLegend);
isVarEdit = false(1,3);

set(htableInpF,'ColumnEditable',isVarEdit,...
    'ColumnName',inpFLegend,'ColumnWidth', ColW_inpData,...
    'Data', InputData);
isNew_inpF = false;

currCarInpF = InputData{1,2};
currData = readCarData(currCarInpF);

% ========================================================================
% ====    Tab Panels Content     =========================================
% ========================================================================

for iTab = 1:length(MainPnlNames)
    setupPanel(MainPnlNames{iTab},iTab);
end

% ========================================================================
% ========================================================================
% ====   NESTED  FUNCTIONS     ===========================================
% ========================================================================
% ========================================================================

    function carData = readCarData(carInpF)
        fid = fopen(carInpF,'r');
        nums = fread(fid);
        strCfg = char(nums');
        fclose(fid);

        exp_data = ...
            ['"([\d- :]*)"\,'...    % Date
             ' *(\w{3,6})\,'...     % license
             ' *(-?\d{1,3}\.\d{0,6})\, *(-?\d{1,3}\.\d{0,6})\,'... %lat, lon
             ' *(\d{1,3})\, *([\w]{1,6})\, *([\w]{1,6})\s+']; % fuel, ext, int
                    
        data = regexpi(strCfg,exp_data,'tokens');
        
        car_lic = cellfun(@(x) x{2}, data,'uni',false);
        car_date = cellfun(@(x) datenum(x{1},'yyyy-mm-dd HH:MM:SS'), data,'uni',false);
        
        carData.Legend = LineLegends;
        carData.RawData = data;

    end
        

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function UpdatePanel
        % Handles to be updated
        % haxMap hTblCarData haxGraph

        ColW_CarData = colWidth(hTblCarData, currData.Legend);
        isVarEdit = false(1,length(currData.Legend));
        
        set(hTblCarData,'ColumnEditable',isVarEdit,...
            'ColumnName',currData.Legend,'ColumnWidth', ColW_CarData,...
            'Data', currData.RawData);
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function setupPanel(MainPnlNames,iTab)
        % Handles to be updated
        % haxMap hTblCarData haxGraph
        parent = hMainPnl{iTab};
        bgc = get(parent,'backgroundcolor');
        switch MainPnlNames{1}
            case 'Map'
                % Initially, displays static map (png OR jpg) with known
                % GEO corners such that each point can be properly
                % coordinated
                haxMap = axes('parent',parent,'units','normalized',...
                    'pos',[0.02 0.03 0.73 0.8]);
            case 'Table'
                % Initially, displays raw data from input file
                hTblCarData = uitable(parent,'Tag','CarData','enable','inactive',...
                    'units','normalized','pos',[0.02 0.03 0.73 0.8]);
                
            case 'Graph'
                haxGraph = axes('parent',parent,'units','normalized',...
                    'pos',[0.02 0.03 0.73 0.8]);
                
        end
        
        UpdatePanel;
        
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



% -----------------------------------------------------------------
% ----   colWidth    ----------------------------------------------
% -----------------------------------------------------------------
function colW = colWidth(hTable, strCell)
    % Calculates column width for the given cell Array of strings

    posUnits = get(hTable,'units');
    set(hTable,'units','pixels')
    tmppos = get(hTable,'pos');
    maxLpxl = tmppos(3);
    set(hTable,'units',posUnits)

    [nr,nc] = size(strCell);
    maxLpxl = maxLpxl - (29+1.25*nc);
    maxW = 10*ones(1,nc);
    colW = num2cell(maxW);
    for j = 1:nc
        for i = 1:nr
            colW_ = length(strCell{i,j})*6;
            if colW_ > colW{j}
                colW{j} = colW_;
            end
        end
    end

    colWmat = cell2mat(colW);
    Lpxl = sum(colWmat);
    scale = maxLpxl/Lpxl;
    colWmat = round(scale*colWmat);
    colW = num2cell(colWmat); % mat2cell more complicated

end



% ========================================================================
% ====     End of Functions     ==========================================
% ========================================================================

    
end    

% ========================================================================
% ====     THE END      =================================================
% ========================================================================
