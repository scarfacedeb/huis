# frozen_string_literal: true

require "rack"
require "json"
require "set"
require "huis/store"

module Huis
  class Server
    attr_reader :store

    def self.start
      Rack::Server.start(
        app: Server.new, Port: 3399
      )
    end

    def initialize(store = Store.new)
      @store = store
    end

    def call(env)
      queries = env['rack.input'].gets.to_s.split('|').to_set
      queries -= store.queries

      return [200, {}, ["No new queries"]] if queries.empty?

      responses = queries.map { Huis.walter.search(_1) }

      store.append(queries)

      [200, {}, [JSON.dump(responses)]]
    end
  end
end
