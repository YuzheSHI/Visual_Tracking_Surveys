function [seq, init_image] = get_sequence_info(seq)

    % wrapper of vot-2018 for early trackers,
    % transforming rotated bounding boxes to axis-aligned ones

    seq.frame = 0;

    [seq.handle, init_image_file, init_region] = vot('polygon');
    
    if isempty(init_image_file)
        init_image = [];
        return;
    end
    
    init_image = imread(init_image_file);
    
    bb_scale = 1;
    
    cx = mean(init_region(1:2:end)); % center x
    cy = mean(init_region(2:2:end)); % center y
    x1 = min(init_region(1:2:end)); % left x
    x2 = max(init_region(1:2:end)); % right x
    y1 = min(init_region(2:2:end)); % top y
    y2 = max(init_region(2:2:end)); % bottom y
    A1 = norm(init_region(1:2) - init_region(3:4)) * norm(init_region(3:4) - init_region(5:6));
    A2 = (x2 - x1) * (y2 - y1); 
    s = sqrt(A1/A2); % scale the area
    w = s * (x2 - x1) + 1;
    h = s * (y2 - y1) + 1;
    
    
    init_c = [cy cx];
    init_sz = bb_scale * [h w];
    
    im_size = size(init_image);
    
    seq.init_pos = init_c;
    seq.init_sz = min(max(round(init_sz), [1 1]), im_size(1:2));
    seq.num_frames = Inf;
    seq.region = init_region;

end