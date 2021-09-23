function [topic_presence, audio_feature, video_feature, topic_id] = topicWise_feature_mapping_eachSession(unzip_dir, sessionID, topicsName, semantic_session_dir)

% Inputs:
%   unzip_dir: directory storing files extracted from a session's directory.
%   sessionID: session identifier.
%   topicsName: a cell array containing names of extracted topics (see Supplementary material associated with this article).
%   semantic_session_dir: directory storing the topic-wise transcripts for a specific session.
% Outputs:
%   topic_presence: topic presence feature for one session.
%   audio_feature: audio features for one session.
%   video_feature: video features for one session.
%   topic_id: topic identifiers presented for one session.

num_topics = length(topicsName);
topic_presence = -ones(num_topics,1);
audio_feature = -ones(num_topics, 237); % (74 covarep + 5 formants) x 3(mean, max, min) = 237
video_feature = -ones(num_topics, 60); % 20(action units) x 3(mean, max, min) = 60
topic_id = [];

covarep = load([unzip_dir filesep num2str(sessionID) '_COVAREP.csv']);
formant = load([unzip_dir filesep num2str(sessionID) '_FORMANT.csv']);
action_units = readtable([unzip_dir filesep num2str(sessionID) '_CLNF_AUs.txt']);
action_units = table2array(action_units(:,5:end));

transcript = readtable([unzip_dir filesep num2str(sessionID) '_TRANSCRIPT.csv']);
row = size(transcript,1);
i = 1;
j = 1;
while i <= row
    if strcmp(transcript.speaker{i}, 'Ellie')
        Ellie_words = strsplit(cell2mat(transcript.value(i)));
        
        for n = 1:num_topics
            name_words = strsplit(cell2mat(topicsName(n)));
            if length(Ellie_words)==1 && length(name_words)==1 && strcmp(Ellie_words, name_words) % for topic name: "why"
                topic_record = n;
                break
            elseif all(ismember(name_words, Ellie_words))
                topic_record = n;
                break
            else
                topic_record = 0;
            end
        end
        
        if topic_record ~= 0
            topic_id(j) = topic_record; j = j+1;
            topic_presence(topic_record) = 1;
            i = i+1;
            while strcmp(transcript.speaker{i}, 'Ellie') && i<=row
                i = i+1;
            end
            if i>row, break; end
            subject_speech = [];
            time_interval = [];
            while strcmp(transcript.speaker{i}, 'Participant') && i<=row
                subject_speech = [subject_speech transcript.value{i} ' '];
                time_interval = [time_interval transcript.start_time(i) transcript.stop_time(i)];
                i = i+1;
            end
            if i>row, break; end
            
            tmp_time_a = round(time_interval([1 end])*100);
            tmp_time_v = round(time_interval([1 end])*30);
            if tmp_time_a(2) > size(covarep,1) || tmp_time_a(2) > size(formant,1) || tmp_time_v(2) > size(action_units,1)
                topic_presence(topic_record) = -1;
                j = j-1; topic_id(j) = [];
                warning('Files downloaded in SESSION #%d may be incomplete!!', sessionID)
                break;
            end
            
            semantic_file_name = sprintf('session-%d_topic-%d_speech.txt', sessionID, topic_record);
            fid = fopen([semantic_session_dir filesep semantic_file_name], 'wt');
            fprintf(fid, '%s\n', subject_speech);
            fclose(fid);
            
            tmp = [covarep(tmp_time_a(1):tmp_time_a(2), :) formant(tmp_time_a(1):tmp_time_a(2), :)];
            audio_feature(topic_record,:) = [mean(tmp) max(tmp) min(tmp)];
            tmp = action_units(tmp_time_v(1):tmp_time_v(2), :);
            video_feature(topic_record,:) = [mean(tmp) max(tmp) min(tmp)];
        else
            i = i+1;
        end
    else
        i = i+1;
    end
end

if j == 1
    warning('No Ellie''s speech detected in SESSION #%d!!', sessionID)
end





