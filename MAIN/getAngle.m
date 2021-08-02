function [angle] = getAngle(point1, point2, point3)
    %point2 is the vertex
    x1 = point1(1); y1 = point1(2);
    x2 = point2(1); y2 = point2(2);
    x3 = point3(1); y3 = point3(2);
    a2 = (x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2);
    b2 = (x3 - x2) * (x3 - x2) + (y3 - y2) * (y3 - y2);
    c2 = (x1 - x3) * (x1 - x3) + (y1 - y3) * (y1 - y3);
    a = sqrt(a2);
    b = sqrt(b2);
    pos = (a2 + b2 - c2) / (2 * a * b); % 求出余弦值
    angle = acos(pos); % 余弦值装换为弧度值
    angle = angle * 180 / pi; % 弧度值转换为角度值
end
