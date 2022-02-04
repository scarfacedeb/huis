# frozen_string_literal: true

require 'pstore'

module Huis
  class Store
    attr_reader :pstore

    def initialize(path = ENV["PSTORE_PATH"])
      @pstore = PStore.new(path)

      @pstore.transaction do
        @pstore[:queries] ||= Set.new
      end
    end

    def queries
      @pstore.transaction(true) do
        @pstore[:queries]
      end
    end

    def append(queries)
      @pstore.transaction do
        @pstore[:queries].merge(queries)
      end
    end
  end
end
