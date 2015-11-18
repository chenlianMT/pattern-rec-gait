function [rout] = nms(r, neighSize)
% Perform non-local maximum suppression on 1D data r.
% r         - data
% neighSize - neighbor size for suppression
% rout      = suppressed data
for n = 1:length(r),
    if r(n) ~= -1,
        % compute the indices of local region
        up = max(n-neighSize,1);
        down = min(n+neighSize,length(r));
        % carve out this local region and do suppression
        localpatch = r(up:down);
        localpatch((r(up:down))<r(n)) = -1;
        r(up:down) = localpatch;
    end
end
rout = r;

end