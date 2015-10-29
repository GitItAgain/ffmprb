module Ffmprb

  class Process

    class Input

      class << self

        def resolve(io)
          return io  unless io.is_a? String

          case io
          when /^\/\w/
            File.open(io).tap do |file|
              Ffmprb.logger.warn "Input file does no exist (#{file.path}), will probably fail"  unless file.exist?
            end
          else
            fail Error, "Cannot resolve input: #{io}"
          end
        end

      end

      attr_accessor :io
      attr_reader :process

      def initialize(io, process)
        @io = self.class.resolve(io)
        @process = process
      end


      def copy(input)
        input.chain_copy self
      end


      def options
        defaults = %w[-noautorotate -thread_queue_size 32 -i]  # TODO parameterise
        defaults + [io.path]
      end

      def filters_for(lbl, video:, audio:)
        in_lbl = process.input_label(self)
        [
          *(if video && channel?(:video)
              if video.resolution && video.fps
                Filter.scale_pad_fps video.resolution, video.fps, "#{in_lbl}:v", "#{lbl}:v"
              elsif video.resolution
                Filter.scale_pad video.resolution, "#{in_lbl}:v", "#{lbl}:v"
              elsif video.fps
                Filter.fps video.fps, "#{in_lbl}:v", "#{lbl}:v"
              else
                Filter.copy "#{in_lbl}:v", "#{lbl}:v"
              end
            end),
          *(audio && channel?(:audio)? Filter.anull("#{in_lbl}:a", "#{lbl}:a"): nil)
        ]
      end

      def channel?(medium)
        io.channel? medium
      end


      def chain_copy(src_input)
        src_input
      end

    end

  end

end
