classdef BinaryImageAction < imagem.gui.actions.CurrentImageAction
%INVERTIMAGEACTION Superclass for actions that require a current image
%
%   output = BinaryImageAction(input)
%
%   Example
%   BinaryImageAction
%
%   See also
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2012-03-13,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2011 INRA - Cepia Software Platform.

methods
    function this = BinaryImageAction(viewer, varargin)
        % calls the parent constructor
        this = this@imagem.gui.actions.CurrentImageAction(viewer, varargin{:});
    end
end

methods
    function b = isActivable(this)
        b = isActivable@imagem.gui.actions.CurrentImageAction(this);
        b = b && isBinaryImage(this.viewer.doc.image);
    end
end

end