classdef ImageMorphoGradientAction < imagem.gui.actions.ScalarImageAction
%IMAGEMORPHOGRADIENTACTION  One-line description here, please.
%
%   Class ImageMorphoGradientAction
%
%   Example
%   ImageMorphoGradientAction
%
%   See also
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2011-12-15,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2011 INRA - Cepia Software Platform.


%% Properties
properties
end % end properties


%% Constructor
methods
    function this = ImageMorphoGradientAction(viewer)
        % calls the parent constructor
        this = this@imagem.gui.actions.ScalarImageAction(viewer, 'imageMorphoGradient');
    end

end % end constructors


%% Methods
methods
    function actionPerformed(this, src, event) %#ok<INUSD>
        disp('Compute Image morphological gradient');
        
        % get handle to viewer figure, and current doc
        viewer = this.viewer;
        doc = viewer.doc;
        
        se = ones(3, 3);
        
        % apply 'gradient' operation
        img2 = morphoGradient(doc.image, se);
        
        % add image to application, and create new display
        newDoc = addImageDocument(viewer.gui, img2);
        
        % add history
        string = sprintf('%s = morphoGradient(%s, ones(3,3));\n', ...
            newDoc.tag, doc.tag);
        addToHistory(this.viewer.gui.app, string);
    end
end % end methods

end % end classdef

