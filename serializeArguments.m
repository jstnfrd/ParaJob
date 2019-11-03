function mat = serializeArguments(varargin)
    % build a matrix containing all combinations of the given arguments.
    % arguments shall be vectors (cell-arrays or numeric arrays).
    % note: you might want to use cell2mat(mat) to convert output to
    % numeric array
    %
    % EXAMPLE CALL:
    % mat = serializeArguments(11:13, 21:24, {'Quad', 'Tri'})
    % --------------------------------------------------------------------
    
    
    if numel(varargin) > 1
        % serialize rest of data:
        mat_ = serializeArguments(varargin{2:end});
        % now "the rest of data" is already serialized in mat_
        
        firstarg = sanitize(varargin{1});
        
        ni = numel(firstarg);
        nj = size(mat_,1);
        nk = size(mat_,2);
        mat = cell(ni*nj,nk+1);
        
        % now serialize (current) first argument with "rest of arugments"
        for i = 1:ni
            % create vector of data(1,i)
            di = repelem(firstarg(i),nj,1);
            rows = nj * (i-1) + (1:nj);
            mat(rows,:) = [di mat_];
        end
    else
        mat = sanitize(varargin{1});
    end
end

function vec = sanitize(vec)
    % turn numeric vectors into cell-vectors and make sure all columns are
    % column vectors
   
    for i = 1:numel(vec)
        if ~iscell(vec)
            vec = num2cell(vec);
        end
        if numel(size(vec)) > 2 || ...
           (size(vec, 1) > 1 && size(vec, 2) > 1)
            error('invalid size: [%s]\n', int2str(size(vec)))
        elseif size(vec, 2) > 1
            % data needs to be transposed to be a column vector
            vec = vec';
        end
    end
end
