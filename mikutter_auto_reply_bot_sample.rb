# -*- coding: utf-8 -*-

Plugin.create(:mikutter_auto_reply_bot_sample) do

    DEFINED_TIME = Time.new.freeze

    # load reply dictionaries
    begin
        default = YAML.load_file(File.join(__dir__, 'dic/default.yml'))
        shika = YAML.load_file(File.join(__dir__, 'dic/shika.yml'))
        sql = YAML.load_file(File.join(__dir__, 'dic/sql.yml'))
        version = YAML.load_file(File.join(__dir__, 'dic/version.yml'))
    rescue LoadError
        notice 'Could not load yml file'
    end

    on_appear do |ms|
        ms.each do |m|
            if m.message.to_s =~ /ひよわ焼き/ and m[:created] > DEFINED_TIME and !m.retweet? and !m.user.is_me?
                # select reply dic & get sample reply
                if m.message.to_s =~ /OR/
                    reply = sql.sample
                elsif m.message.to_s =~ /--version|-v/
                    reply = version.sample
                else
                    reply = default.sample
                end

                # send reply & fav
                Service.primary.post(:message => "@#{m.user.idname} #{reply}", :replyto => m)
            elsif m.message.to_s =~ /鹿焼き/ and m[:created] > DEFINED_TIME and !m.retweet?
                # 毎回は発動しないようにする
                if [*1..10].sample > 3
                    # select reply dic & get sample reply
                    reply = shika.sample

                    # send reply & fav
                    Service.primary.post(:message => "@#{m.user.idname} #{reply}", :replyto => m)
                end
            end
        end
    end

end
