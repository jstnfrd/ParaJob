function s = pjFormatFunctionCall(Func, Args)
   s = sprintf(' %s(%s)', func2str(Func), fmtArgs(Args));
end

function s = fmtArgs(Args)
    
    s = [];
    for i = 1:numel(Args)
        if isnumeric(Args{i}) && numel(Args{i}) == 1
            %argf = num2str(Args{i});
            s = [s sprintf('%s, ', num2str(Args{i}))]; %#ok<*AGROW>
        elseif isnumeric(Args{i})
            %argf = num2str(Args{i});
            s = [s sprintf('[%s], ', num2str(Args{i}))]; %#ok<*AGROW>
        elseif ischar(Args{i})
            s = [s sprintf('''%s'', ', Args{i})];
        else
            argf = evalc(sprintf('disp(Args{%i})', i));
            s = [s sprintf('[%s], ', argf(1:end-1))];
        end
    end
    
    if ~isempty(s) && strcmp(s(end-1:end), ', ')
        s = s(1:end-2);
    end
end