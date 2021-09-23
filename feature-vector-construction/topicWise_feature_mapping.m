function [all_topic_presence, all_audio_fea, all_video_fea, all_topic_id] = topicWise_feature_mapping(data_dir, unzip_dir, topicsName, semantic_dir)

sessions = struct2table(dir(data_dir));
sessions = sessions.name(3:end);
if exist(unzip_dir, 'dir')
    rmdir(unzip_dir, 's')
    disp(['Remove dir: ' unzip_dir])
end

num_sessions = length(sessions);
all_topic_presence = cell(num_sessions,1);
all_audio_fea = cell(num_sessions,1);
all_video_fea = cell(num_sessions,1);
all_topic_id = cell(num_sessions,1);
for m = 1:length(sessions)
    C = split(sessions{m}, '_');
    tic
    if ispc
        unzip([data_dir filesep sessions{m}], unzip_dir);
    elseif isunix || ismac
        [~, cmdout] = system(['unzip ' data_dir filesep sessions{m} ' -d ' unzip_dir]);
    end
    fprintf('## Unzip files from session #%s, elapsed time is %gs\n', C{1}, toc)
    
    semantic_session_dir = [semantic_dir '_session-' C{1}];
    if ~exist(semantic_session_dir, 'dir')
        mkdir(semantic_session_dir);
        fprintf('Make semantic folder for session #%s\n', C{1})
    end
    
    fprintf('------------ Topic-wise feature mapping for session #%s: start... \n', C{1});
    [topic_presence, audio_feature, video_feature, topic_id] = topicWise_feature_mapping_eachSession(unzip_dir, str2double(C{1}), topicsName, semantic_session_dir);
    all_topic_presence{m} = topic_presence;
    all_audio_fea{m} = audio_feature;
    all_video_fea{m} = video_feature;
    all_topic_id{m} = topic_id;
    fprintf('Topic-wise feature mapping for session #%s: done!! Elapsed time is %gs\n\n', C{1}, toc);
    
    rmdir(unzip_dir, 's')
end



