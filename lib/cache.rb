class Cache
  class << self
    ###
    ### Retrieving Information from the Cache
    ###

    # Returns the current patch version
    def get_patch
      Rails.cache.read(:patch)
    end

    # @collection_key the plural collection identifier such as champions, items
    # Returns a hash of all collection names mapped to their ids
    def get_collection(collection_key)
      Rails.cache.read(collection_key)
    end

    # @collection_key the singular collection identifier such as champion, item
    # @entry_name the name of the collection entry to lookup in the collection
    # Returns the information on the collection entry found by name in the collection
    def get_collection_entry(collection_key, entry_name)
      search_params = {}
      search_params[collection_key] = entry_name
      Rails.cache.read(search_params)
    end

    # @position the metric used to rank the champions such as kills, deaths
    # @elo the elo for the rankings such as gold, silver
    # @role the role being ranked such as top, mid
    # Returns a list of champion names in ranked order
    def get_champion_rankings(position, elo, role)
      Rails.cache.read({ position: position, elo: elo, role: role })
    end

    # @name the name of the champion
    # @role the role the champion is playing in
    # @elo the elo the champion is playing in
    # Returns the matchups for the specified champion in that role and elo
    def get_champion_matchups(name, role, elo)
      Rails.cache.read(matchups: { name: name, role: role, elo: elo })
    end

    # @name the name of the champion
    # @role the role the champion is playing in
    # @elo the elo the champion is playing in
    # Returns the performance information of the champion in that role and elo
    def get_champion_role_performance(name, role, elo)
      Rails.cache.read({ name: name, role: role, elo: elo })
    end

    # @name the name of the summoner
    # @region the region the summoner is playing in
    # Returns the id of the summoner
    def get_summoner_id(name, region)
      Rails.cache.read(id: { name: name, region: region })
    end

    # @name the name of the summoner
    # @region the region the summoner is playing in
    # Returns the queues for the summoner
    def get_summoner_queues(name, region)
      Rails.cache.read(queues: { name: name, region: region })
    end

    ###
    ### Setting Information into the Cache
    ###

    # @patch_number the patch as a string of the form {major}.{minor} version
    # Returns success or failure status
    def set_patch(patch_number)
      Rails.cache.write(:patch, patch_number)
    end

    # @name the name of the champion
    # @role the role the champion is playing in
    # @elo the elo the champion is playing in
    # matchups the matchup data for how the champion with name @name does against
    # other champions
    # Returns success or failure status
    def set_champion_matchups(name, role, elo, matchups)
      Rails.cache.write({ matchups: { name: name, role: role, elo: elo } }, matchups)
    end

    # @position the metric used to rank the champions such as kills, deaths
    # @elo the elo for the rankings such as gold, silver
    # @role the role being ranked such as top, mid
    # @rankings the rankings for champion performance in @role and @elo
    # Returns success or failure status
    def set_champion_rankings(position, elo, role, rankings)
      Rails.cache.write({ position: position, elo: elo, role: role }, rankings)
    end

    # @name the name of the champion
    # @role the role the champion is playing in
    # @elo the elo the champion is playing in
    # @performance the performance of the champion with @name in @role and @elo
    # Returns success or failure status
    def set_champion_role_performance(name, role, elo, performance)
      Rails.cache.write({ name: name, role: role, elo: elo }, performance)
    end

    # @collection_key the plural collection identifier such as champions, items
    # @ids_to_names the id to name hash for entries of the collection
    # Returns success or failure status
    def set_collection(collection_key, ids_to_names)
      Rails.cache.write(collection_key, ids_to_names)
    end

    # @collection_key the singular collection identifier such as champion, item
    # @entry_name the name of the collection entry to lookup in the collection
    # @entry_info the information on the collection entry found by name in the
    # collection
    # Returns success or failure status
    def set_collection_entry(collection_key, entry_name, entry_info)
      search_params = {}
      search_params[collection_key] = entry_name
      Rails.cache.write(search_params, entry_info)
    end

    # @name the name of the summoner
    # @region the region the summoner is playing in
    # @id the summoner id
    # Returns success or failure status
    def set_summoner_id(name, region, id)
      Rails.cache.write({ id: { name: name, region: region } }, id)
    end

    # @name the name of the summoner
    # @region the region the summoner is playing in
    # @queues the queues for the summoner
    # @expiration the default expiration is 25 minutes, approximate duration of
    # one game
    # Returns success or failure status
    def set_summoner_queues(name, region, queues, expiration = 25.minutes)
      Rails.cache.write(
        { queues: { name: name, region: region } },
        queues,
        expires_in: expiration
      )
    end
  end

  # Define a get_or_set method that will retrieve the requested cache entry
  # or set it to the value returned from the provided block
  methods(false).map(&:to_s).select { |method_name| method_name.start_with?('get_') }
    .each do |method_name|
      base_method_name = method_name.split('get_').last
      define_singleton_method("get_or_set_#{base_method_name}") do |*args, &block|
        return_value = send(method_name, *args)
        return return_value if return_value
        block.call.tap do |rv|
          send("set_#{base_method_name}", *(args + [rv]))
        end
      end
    end
end
