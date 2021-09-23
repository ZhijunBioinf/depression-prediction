function [all_sessions_fea] = merge_all_features(data_dir, all_topic_presence, all_audio_fea, all_video_fea, all_semantic_fea)

% Inputs:
%   data_dir: directory storing the data sets downloaded from DAIC-WOZ database.
%   all_topic_presence: topic presence feature for all sessions.
%   all_audio_fea: audio features for all sessions.
%   all_video_fea: video features for all sessions.
%   all_semantic_fea: semantic features for all sessions.
% Output:
%   all_sessions_fea: merged features for all sessions.

sessions = struct2table(dir(data_dir));
sessions = split(sessions.name(3:end), '_');
sessions_id = str2double(sessions(:,1));
% 3 sessions do not have Ellie's speech, so features are extracted for 186 sessions.
all_sessions_fea = nan(186, 31671); % (1 topic presence + 237 audio + 60 video + 93 semantic) x 81 topics = 31671

i = 1;
for m = 1:length(sessions_id)
    if sessions_id(m) == 451 || sessions_id(m) == 458 || sessions_id(m) == 480
        continue
    end
    
    tmp_fea = cell(1,81);
    for n = 1:length(tmp_fea)
        topic_presence = all_topic_presence{m}(n);
        if topic_presence == 1
            audio_fea = all_audio_fea{m}(n,:);
            video_fea = all_video_fea{m}(n,:);
            
            patt_file_name = sprintf('session-%d_topic-%d_speech.txt', sessions_id(m), n);
            tf = strcmp(all_semantic_fea.Filename, patt_file_name);
            semantic_fea = table2array(all_semantic_fea(tf,3:end));
            tmp_fea{n} = [topic_presence audio_fea video_fea semantic_fea];
        else
            tmp_fea{n} = -ones(1,391);
        end
    end
    
    all_sessions_fea(i,:) = cell2mat(tmp_fea);
    i = i+1;
end

