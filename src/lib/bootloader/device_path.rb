require "yast"

module Bootloader
  # Class for device path
  #
  # @example device path can be defined explicitly
  #   DevicePath.new("/devs/sda")
  # @example definition by UUID is translated to device path
  #   dev = DevicePath.new("UUID=\"0000-00-00\"")
  #   dev.path -> "/dev/disk/by-uuid/0000-00-00"
  class DevicePath
    Yast.import "Mode"

    attr_reader :path

    # Performs initialization
    #
    # @param dev [<String>] either a path like /dev/sda or special string for uuid or label
    def initialize(dev)
      @path =  if dev_by_uuid?(dev)
        # if defined by uuid, convert it
        dev.sub(/UUID="([-a-zA-Z0-9]*)"/, '/dev/disk/by-uuid/\1')
      elsif dev_by_label?(dev)
        # as well for label
        dev.sub(/LABEL="(.*)"/, '/dev/disk/by-label/\1')
      else
        # add it exactly (but whitespaces) as specified by the user
        dev.strip
      end
    end

    # @return [Boolean] true if the @path exists in the system
    def exists?
      # almost any byte sequence is potentially valid path in unix like systems
      # AY profile can be generated for whatever system so we cannot decite if
      # particular byte sequence is valid or not
      return true if Mode.config

      # uuids are generated later by mkfs, so not known in time of installation
      # so whatever can be true
      return true if Mode.installation && (uuid? || label?)

      File.exists?(path)
    end

    alias_method :valid?, :exists?

  private

    def dev_by_uuid?(dev)
      dev =~ /UUID=".+"/
    end

    def uuid?
      path =~ /by-uuid/
    end

    def dev_by_label?(dev)
      dev =~ /LABEL=".+"/
    end

    def label?
      path =~ /by-label/
    end
  end
end
