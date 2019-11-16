function  raw_result_output(sequence_name, tracker_name, res)
    % RAW_RESULT_OUTPUT 
    % Tracking Surveys 
    % the function saves raw result for UAV evaluation toolkit
    % @YuzheSHI, Computer Science, HUST
    
    res_path = '../raw_results/UAV/';
    
    if ~isfolder(res_path)
        mkdir(res_path);
    end
    
    res_path = [res_path sequence_name '/'];
    if ~isfolder([res_path])
        mkdir(res_path);
    end
    
    file = [res_path tracker_name '.txt'];
    if ~isfile(file)
        dlmwrite(file, res.res, 'precision', '%.2f', 'delimiter', ' ');
    end
end

