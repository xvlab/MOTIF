function side = judgeSide(point1, point2, point3)
    % point3 is the one to be judged
    x1 = point1(1); y1 = point1(2);
    x2 = point2(1); y2 = point2(2);
    x3 = point3(1); y3 = point3(2);
    S = (x1 - x3) * (y2 - y3) - (y1 - y3) * (x2 - x3);
    if S > 0
        side = "left";
    elseif S <= 0
        side = "right";
    end
end
