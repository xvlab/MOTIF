function Num = Str2NumFromHandle(h,DefaultNum)

str = get(h,'string');
str = str(str~=' ');
[Num, status] = str2num(str);
if ~status || Num <= 0
    Num = DefaultNum;
end

str = get(h,'string');
[Num, status] = str2num(str);
if ~status
    Num = DefaultNum;
end
if ~strcmp(get(h,'Tag'),'MinDispVal') && ~strcmp(get(h,'Tag'),'MaxDispVal')
    for idx = 1:length(Num)
        if Num(idx) <= 0
            Num(idx) = DefaultNum;
        end
    end
end
if strcmp(get(h,'Tag'),'MinDispVal') 
    if Num > DefaultNum
        Num = sign(DefaultNum)*abs(DefaultNum)/2;
    end
end
if strcmp(get(h,'Tag'),'MaxDispVal') 
    if Num < DefaultNum
        Num = sign(DefaultNum)*abs(DefaultNum)*2;
    end
end
if strcmp(get(h,'Tag'),'FendROI')
    str = get(h,'string');
    [Num, status] = str2num(str);
    if ~status || Num <= 0 || Num > DefaultNum
        Num = DefaultNum;
    end
end

Num = unique(Num);
set(h,'string',num2str(Num));