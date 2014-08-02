module Rack
  module Zippy
    class ServeableFile

      attr_reader :path, :full_path_info

      def initialize(options)
        raise ArgumentError.new(':has_encoding_variants option must be given') unless options.has_key?(:has_encoding_variants)

        @path = options[:path]
        @full_path_info = options[:full_path_info]
        @has_encoding_variants = options[:has_encoding_variants]
        @is_gzipped = options[:is_gzipped]
      end

      def headers
        headers = { 'Content-Type'  => Rack::Mime.mime_type(::File.extname(full_path_info)) }
        headers.merge! cache_headers

        headers['Vary'] = 'Accept-Encoding' if encoding_variants?
        headers['Content-Encoding'] = 'gzip' if gzipped?

        headers['Content-Length'] = ::File.size(path).to_s
        return headers
      end

      def cache_headers
        case full_path_info
          when PRECOMPILED_ASSETS_SUBDIR_REGEX
            lifetime = :year
            last_modified = CACHE_FRIENDLY_LAST_MODIFIED
          when '/favicon.ico'
            lifetime = :month
            last_modified = CACHE_FRIENDLY_LAST_MODIFIED
          else
            lifetime = :day
        end

        headers = { 'Cache-Control' => "public, max-age=#{SECONDS_IN[lifetime]}" }
        headers['Last-Modified'] = last_modified if last_modified

        return headers
      end

      def response_body
        [::File.read(path)]
      end

      def self.find_first(options)
        asset_compiler = options[:asset_compiler]
        full_path_info = build_full_path_info(options[:path_info])
        
        is_path_info_serveable = has_static_extension?(full_path_info) && !asset_compiler.compiles?(full_path_info)
        return nil if !is_path_info_serveable

        asset_root = options[:asset_root]
        file_path = "#{asset_root}#{full_path_info}"
        include_gzipped = options[:include_gzipped]

        gzipped_file_path = "#{file_path}.gz"
        gzipped_file_present = ::File.file?(gzipped_file_path) && ::File.readable?(gzipped_file_path)

        has_encoding_variants = gzipped_file_present

        if include_gzipped && gzipped_file_present
          return ServeableFile.new(
              :path => gzipped_file_path,
              :full_path_info => full_path_info,
              :has_encoding_variants => has_encoding_variants,
              :is_gzipped => true
          )
        end

        is_serveable = ::File.file?(file_path) && ::File.readable?(file_path)

        if is_serveable
          return ServeableFile.new(
              :path => file_path,
              :full_path_info => full_path_info,
              :has_encoding_variants => has_encoding_variants
          )
        end

        return nil
      end

      def self.has_static_extension?(path)
        path =~ AssetServer::STATIC_EXTENSION_REGEX
      end

      def encoding_variants?
        return @has_encoding_variants
      end

      def gzipped?
        return @is_gzipped
      end

      def ==(other)
        return false if other.nil?
        return true if self.equal?(other)
        return self.class == other.class &&
          self.gzipped? == other.gzipped? &&
          self.encoding_variants? == other.encoding_variants? &&
          self.path == other.path &&
          self.full_path_info == other.full_path_info
      end
      alias_method :eql?, :==

      private

      # Old last-modified headers encourage caching via browser heuristics. Use it for year-long cached assets.
      CACHE_FRIENDLY_LAST_MODIFIED = 'Mon, 10 Jan 2005 10:00:00 GMT'

      SECONDS_IN = {
          :day => 24*60*60,
          :month => 31*(24*60*60),
          :year => 365*(24*60*60)
      }.freeze

      ROOT_INDEX_ALIASES = ['/index', '/', ''].freeze

      def self.build_full_path_info(path_info)
        if ROOT_INDEX_ALIASES.include?(path_info)
          return '/index.html'
        end
        return path_info
      end

    end
  end
end
