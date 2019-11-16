function speed_output(speed, trackers)

    machine_speed = 1;
    % test the speed of local machine
    
    path = '../raw_results/speed/';

    if ~isfolder(path)
        mkdir(path);
    end

    file = [path 'speed_UAV.txt']; 
    
    fid = fopen(file, "a");

    for i = 1:length(trackers)
        fprintf("%s: %.2f\n",trackers{i}.name, speed{i}/machine_speed);
    end
    fclose(fid);
end

