# frozen_string_literal: true

class Shrine
  module Plugins
    module RefreshRemoteMeta
      module AttacherMethods
        def refresh_metadata!(**options)
          file!.refresh_metadata!(**context, **options)
          set(file)
          record.save(validate: false)
        end
      end

      module FileMethods
        def refresh_metadata!(**options)
          @metadata = @metadata.merge(storage.refresh_metadata(id))
        end
      end
    end

    register_plugin(:refresh_remote_meta, RefreshRemoteMeta)
  end
end