classdef ImageBooleanOpAction < imagem.gui.ImagemAction
%IMAGEOVERLAYACTION Open a dialog to compute imposed minima
%
%   Class ImageBooleanOpAction
%
%   Example
%   ImageBooleanOpAction
%
%   See also
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2012-11-04,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2011 INRA - Cepia Software Platform.


%% Properties
properties
    handles;
    
    opList = {@or, @and, @xor};
    opNames = {'Or', 'And', 'Exclusive Or'};
    
end % end properties


%% Constructor
methods
    function this = ImageBooleanOpAction(viewer)
    % Constructor for ImageBooleanOpAction class
        this = this@imagem.gui.ImagemAction(viewer, 'imageBooleanOp');
    end

end % end constructors

methods
    function actionPerformed(this, src, event) %#ok<INUSD>
        disp('image arithmetic');
        
        createFigure(this);
    end
    
    function hf = createFigure(this)
        
        % action figure
        hf = figure(...
            'Name', 'Boolean Operation', ...
            'NumberTitle', 'off', ...
            'MenuBar', 'none', 'Toolbar', 'none');
        set(hf, 'units', 'pixels');
        pos = get(hf, 'Position');
        pos(3:4) = [250 200];
        set(hf, 'Position', pos);
        
        this.handles.figure = hf;
        
        imageNames = getImageNames(this.viewer.gui.app);
        
        % vertical layout
        vb  = uix.VBox('Parent', hf, ...
            'Spacing', 5, 'Padding', 5);
        
        gui = this.viewer.gui;
        
        % one panel for value text input
        mainPanel = uix.VBox('Parent', vb);

        % combo box for the first image
        this.handles.imageList1 = addComboBoxLine(gui, mainPanel, ...
            'First image:', imageNames);
        
        % combo box for the operation name
        this.handles.operationList = addComboBoxLine(gui, mainPanel, ...
            'Operation:', this.opNames);
        
        % combo box for the second image
        this.handles.imageList2 = addComboBoxLine(gui, mainPanel, ...
            'Second image:', imageNames);
        
        % button for control panel
        buttonsPanel = uix.HButtonBox('Parent', vb, 'Padding', 5);
        uicontrol('Parent', buttonsPanel, ...
            'String', 'OK', ...
            'Callback', @this.onButtonOK);
        uicontrol('Parent', buttonsPanel, ...
            'String', 'Cancel', ...
            'Callback', @this.onButtonCancel);
        
        set(vb, 'Heights', [-1 40] );
    end
    

    function closeFigure(this)
        % clean up viewer figure
        
        % close the current fig
        close(this.handles.figure);
    end
    
end

%% GUI Items Callback
methods
    function onButtonOK(this, varargin)        
        
        gui = this.viewer.gui;
        
        doc1 = getDocument(gui.app, get(this.handles.imageList1, 'Value'));
        img1 = doc1.image;

        doc2 = getDocument(gui.app, get(this.handles.imageList2, 'Value'));
        img2 = doc2.image;
        
        % get operation as function handle
        opIndex = get(this.handles.operationList, 'Value');
        op = this.opList{opIndex};
        opName = char(op);
        
        if ndims(img1) ~= ndims(img2)
            error('Input images must have same dimension');
        end
        if any(size(img1) ~= size(img2))
            error('Input images must have same size');
        end
        % check inputs
        if ~isBinaryImage(img1) || ~isBinaryImage(img2)
            error('Input images must be binary');
        end
        
        
        % compute result image
        res = op(img1, img2);
        
        % add image to application, and create new display
        newDoc = addImageDocument(gui, res);
        
        % add history
        string = sprintf('%s = %s(%s, %s));\n', ...
            newDoc.tag, opName, doc1.tag, doc2.tag);
        addToHistory(gui.app, string);

        closeFigure(this);
    end
    
    function onButtonCancel(this, varargin)
        closeFigure(this);
    end
    
end

end % end classdef

