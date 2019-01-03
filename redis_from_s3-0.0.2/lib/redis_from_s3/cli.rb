require 'aws-sdk'
require 'settingslogic'
require 'trollop'
require 'time'

module Redis_from_S3

  class CLI
    class Settings < Settingslogic
    end

    def initialize(argv)
      @opts = Trollop::options do
        opt :config, "config file path", :type => :string, :default => '/etc/redis_from_s3/config.yml'
      end

      unless ::File.exists?(::File.expand_path(@opts[:config]))
        puts "Config file #{@opts[:config]} doesn't exist!"
        exit 1
      end

      @settings = Settings.new(@opts[:config])
      Aws.config.update({
                          region: 'us-east-1',
                          credentials: Aws::Credentials.new(@settings.aws.aws_access_key_id, @settings.aws.aws_secret_access_key)
                        })
      @s3 = Aws::S3::Client.new(region: 'us-east-1')

      @file_to_download = ""
    end

    def run
      get_file_name
      download
    end

    def get_file_name
      begin
        @s3.head_bucket(bucket: @settings.aws.s3_bucket)
      rescue Aws::S3::Errors::NoSuchBucket => e
        msg = "No #{@settings.aws.s3_bucket} Bucket"
      rescue Aws::S3::Errors::Forbidden => e
        msg = "Access Denied to #{@settings.aws.s3_bucket} Bucket"
      rescue Aws::S3::Errors::NotFound => e
        msg = "#{@settings.aws.s3_bucket} Bucket Not Found"
      end
      if msg
        puts msg
        exit 1
      end

      a = []
      @s3.list_objects(bucket: @settings.aws.s3_bucket).contents.each { |c| a << c.key }
      @file_to_download = a.sort.reverse[1]
    end

    def download
      output = "#{@settings.dirs.temp}/#{@settings.files.output}"
      puts "Download latest Chronicle Redis keys dump from #{@settings.aws.s3_bucket}/#{@file_to_download} to #{output}"

      File.open(output, 'wb') do |file|
        reap = @s3.get_object({ bucket: @settings.aws.s3_bucket, key: @file_to_download }, target: file)
      end
    end

  end
end
