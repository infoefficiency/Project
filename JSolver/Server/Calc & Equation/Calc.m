% This function is about calculation.
function ret = Calc(str)
error_classify = 0;
try
    %% Preprocess    
    mode = str(1);
    expr = str(3:end);    
    % �Է� ���� ���ڿ��� ��Ʈ���� �ν��� �� �ְ� ����
    expr = MAN_to_MATLAB(expr);
    from_comma_expr = [];
    if( nnz(expr == ',') )
        comma_idx = strfind(expr, ',');       
        from_comma_expr = expr(comma_idx(1):end);    
        expr = expr(1:comma_idx(1)-1);
       
    end
    % ���� ����
    sym_list = Get_Symbolic(expr);        
    for i = 1:length(sym_list)
        syms(sym_list(i));
    end
    expr = [expr, from_comma_expr];    
    
    %% Calculation
    if mode == 'C' || mode == 'A'
        error_classify = 1;
        % get result
        rst1 = eval(expr);
        % if result can be calculated more, then do it.
        if( isnumeric(rst1) ) % Non able to calculate more.
            ret = num2str(rst1);
        else % calculate more
            rst1 = char(rst1);
            rst2 = eval(rst1);
            
            if isa(rst2, 'double')
                rst2 = num2str(rst2, 10);
            elseif isa(rst2, 'sym')
                rst2 = char(rst2);
            end
            
            if strcmp(rst1, rst2)
                ret = rst1;
            else 
                ret = [rst1, ' = ', rst2];                
            end
        end
    %% Solve Equation.
    elseif mode == 'E'
        error_classify = 2;
        expr = Arrange(expr, sym_list);        
        if nnz( expr == '''' )            
            % prime�� ��ġ�� �ľ��ؼ� y'' => D2y �� �ٲ۴�.
            while true
                % find the position of  prime
                pos = strfind(expr, '''');
                % if not exist then, break
                if isempty(pos)
                    break;
                end
                % check the continuous length of prime
                len = 1;
                for i = 2:length(pos)
                    if pos(i) - pos(i-1) == 1
                        len = len + 1;
                    else
                        break;
                    end
                end
                % replace (variable + prime) to MATLAB syntax
                expr = strrep(expr, expr(pos(1)-1 : pos(1+len-1)), ['D', num2str(len), expr(pos(1)-1)]);              
            end
            
            % ----- 'x'�� ����ڿ� �°� ������ �� �ְ� �����ؾ��Ѵ�.
            rst = dsolve(expr, 'x');
            ret = char(rst);
        else            
            % Polynomial Equation   
            rst = solve(sym(expr));
            % save the solution.
            ret = char(rst(1));
            for i = 2:length(rst)
                ret = strcat(ret, [', ', char(rst(i))]);
            end
        end
    else
        ret = 'Error expression';
    end        
    
    % if 'return value' is character, then call MATLAB to MAN
    if ischar(ret)
        ret = MATLAB_to_MAN(ret);    
    end
catch
    if error_classify == 0
        ret = 'Error Input';
    elseif error_classify == 1
        ret = 'Calculation Error - report to the Maker. :)';
    elseif error_classify == 2
        ret = 'Equation Error - report to the Maker. :)';
    end   
end