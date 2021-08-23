require "crest"
require "json"

module Bunny
  class File
    include JSON::Serializable

    @[JSON::Field(key: "Guid")]
    property guid : String

    @[JSON::Field(key: "StorageZoneName")]
    property storage_zone_name : String

    @[JSON::Field(key: "Path")]
    property path : String

    @[JSON::Field(key: "ObjectName")]
    property object_name : String

    @[JSON::Field(key: "Length")]
    property length : UInt32

    @[JSON::Field(key: "LastChanged")]
    property last_changed : String

    @[JSON::Field(key: "IsDirectory")]
    property is_directory : Bool

    @[JSON::Field(key: "ServerId")]
    property server_id : UInt32

    @[JSON::Field(key: "UserId")]
    property user_id : String

    @[JSON::Field(key: "DateCreated")]
    property date_created : String

    @[JSON::Field(key: "StorageZoneId")]
    property storage_zone_id : UInt32
  end

  class Cdn
    VERSION      = "0.1.0"
    ENDPOINT_URL = "https://storage.bunnycdn.com"

    def initialize(@access_key : String)
    end

    def upload(storage_zone : String, path : String, file : IO | String) : HTTP::Client::Response
       HTTP::Client.put(
        "#{ENDPOINT_URL}/#{storage_zone}/#{path}",
        headers: HTTP::Headers{"AccessKey" => @access_key},
        form: file
      )
    end

    def download(storage_zone : String, path : String, output : IO)
      HTTP::Client.get(
        "#{ENDPOINT_URL}/#{storage_zone}/#{path}",
        headers: HTTP::Headers{"AccessKey" => @access_key},
      ) do |response|
        puts path
        puts "body"
        puts response.body
        puts "body_io"
        puts response.body_io
        puts response.status_code

        if response.success?
          if response.body?
            output << response.body
          elsif response.body_io?
            IO.copy(response.body_io, output)
          else
            raise Exception.new("error download")
          end
        else
          raise Exception.new("error download")
        end
      end
    end

    def browser_files(storage_zone : String, path : String)
      body = Crest.get(
        "#{ENDPOINT_URL}/#{storage_zone}/#{path}/",
        headers: {"AccessKey" => @access_key},
        logging: true
      ).body

      Array(Bunny::File).from_json(body)
    end
  end
end
