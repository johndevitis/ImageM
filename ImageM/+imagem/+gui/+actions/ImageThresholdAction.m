classdef ImageThresholdAction < imagem.gui.ImagemAction
%IMAGETHRESHOLDACTION Apply a threshold operation to current image
%
%   output = ImageThresholdAction(input)
%
%   Example
%   ImageThresholdAction
%
%   See also
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2011-11-11,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2011 INRA - Cepia Software Platform.

properties
    value = 0;
    inverted = false;
    handles;
end

methods
    function this = ImageThresholdAction(parent)
        % calls the parent constructor
        this = this@imagem.gui.ImagemAction(parent, 'thresholdImage');
    end
end

methods
    function actionPerformed(this, src, event) %#ok<INUSD>
        disp('apply Threshold to current image');
        
        % get handle to parent figure, and current doc
        viewer = this.parent;
        doc = viewer.doc;
        
        if ~isScalarImage(doc.image)
            warning('ImageM:WrongImageType', ...
                'Threshold can be applied only on scalar images');
            return;
        end
        
        createThresholdFigure(this);
        setThresholdValue(this, 50);
        updateWidgets(this);
    end
    
    function hf = createThresholdFigure(this)
        
        % action figure
        hf = figure(...
            'Name', 'Image Threshold', ...
            'NumberTitle', 'off', ...
            'MenuBar', 'none', 'Toolbar', 'none');
        set(hf, 'units', 'pixels');
        pos = get(hf, 'Position');
        pos(3:4) = 200;
        set(hf, 'Position', pos);
        
        this.handles.figure = hf;
        
        
        % compute background color of most widgets
        if ispc
            bgColor = 'White';
        else
            bgColor = get(0,'defaultUicontrolBackgroundColor');
        end
        
        % vertical layout
        vb  = uiextras.VBox('Parent', hf, 'Spacing', 5, 'Padding', 5);
        
        % one panel for value text input
        mainPanel = uiextras.VBox('Parent', vb);
        line1 = uiextras.HBox('Parent', mainPanel, 'Padding', 5);
        uicontrol(...
            'Style', 'Text', ...
            'Parent', line1, ...
            'String', 'Threshold Value:');
        this.handles.valueEdit = uicontrol(...
            'Style', 'Edit', ...
            'Parent', line1, ...
            'String', '50', ...
            'BackgroundColor', bgColor, ...
            'Callback', @this.onTextValueChanged);
        set(line1, 'Sizes', [-1 -1]);

        % one slider for changing value
        this.handles.valueSlider = uicontrol(...
            'Style', 'Slider', ...
            'Parent', mainPanel, ...
            'Min', 0, 'Max', 255, ...
            'SliderStep', [1/256 10/256], ...
            'BackgroundColor', bgColor, ...
            'Callback', @this.onSliderValueChanged);
        set(mainPanel, 'Sizes', [35 25]);
        
        % setup listeners for slider continuous changes
        listener = handle.listener(this.handles.valueSlider, 'ActionEvent', ...
            @this.onSliderValueChanged);
        setappdata(this.handles.valueSlider, 'sliderListeners', listener);

        % one checkbox to decide the threshold side
        this.handles.sideCheckBox = uicontrol(...
            'Style', 'CheckBox', ...
            'Parent', mainPanel, ...
            'String', 'Threshold greater', ...
            'Value', 1, ...
            'Callback', @this.onSideChanged);
            
        % button for control panel
        buttonsPanel = uiextras.HButtonBox( 'Parent', vb, 'Padding', 5);
        uicontrol( 'Parent', buttonsPanel, ...
            'String', 'OK', ...
            'Callback', @this.onButtonOK);
        uicontrol( 'Parent', buttonsPanel, ...
            'String', 'Cancel', ...
            'Callback', @this.onButtonCancel);
        
        set(vb, 'Sizes', [-1 40] );
    end
    
    function bin = computeThresholdedImage(this)
        % Compute the result of threshold
        if this.inverted
            bin = this.parent.doc.image < this.value;
        else
            bin = this.parent.doc.image > this.value;
        end

    end
    function closeFigure(this)
        % clean up parent figure
        this.parent.doc.previewImage = [];
        updateDisplay(this.parent);
        
        % close the current fig
        close(this.handles.figure);
    end
    
    function setThresholdValue(this, newValue)
        this.value = max(min(round(newValue), 255), 1);
    end
    
    function updateWidgets(this)
        
        set(this.handles.valueEdit, 'String', num2str(this.value))
        set(this.handles.valueSlider, 'Value', this.value);
        
        % update preview image of the document
        bin = computeThresholdedImage(this);
        doc = this.parent.doc;
        doc.previewImage = overlay(doc.image, bin);
        updateDisplay(this.parent);
    end
    
end

%% GUI Items Callback
methods
    function onButtonOK(this, varargin)        
        % apply the threshold operation
        bin = computeThresholdedImage(this);
        addImageDocument(this.parent.gui, bin);
        closeFigure(this);
    end
    
    function onButtonCancel(this, varargin)
        closeFigure(this);
    end
    
    function onSliderValueChanged(this, varargin)
        val = get(this.handles.valueSlider, 'Value');
        
        setThresholdValue(this, val);
        updateWidgets(this);
    end
    
    function onTextValueChanged(this, varargin)
        val = str2double(get(this.handles.valueEdit, 'String'));
        if ~isfinite(val)
            return;
        end
        
        setThresholdValue(this, val);
        updateWidgets(this);
    end
    
    function onSideChanged(this, varargin)
        this.inverted = ~get(this.handles.sideCheckBox, 'Value');
        updateWidgets(this);
    end
end

end