require 'pathname'

module Jekyll
  # a converter is required to avoid interpreting rendered HTML
  class CopyConverter < Converter
    ROOT = Pathname.new(__FILE__).parent.parent

    safe true
    priority :low

    def matches( ext )
      ext =~ /^\.copy$/i
    end

    def output_ext( ext )
      ".html"
    end

    def convert( content )
      rendered = []

      content.split(/\n/).each do |file|
        unless file.nil? or file.empty?
          path = ROOT + "_includes" + file
          if path.exist?
            rendered << File.read( path )
          else
            $stderr.puts "WARNING: Cannot find included file #{path}"
            rendered << "Cannot find file #{path}"
          end
        end
      end

      rendered.join("\n")
    end
  end
end
