class MatchWorker
  include Sidekiq::Worker
  include RiotApi

  def perform(game_id)
    # Skip if the game is somehow already saved
    unless Match.find_by(game_id: game_id)
      match_data = RiotApi.get_match(id: game_id)

      # Check that it is a ranked game for the current season
      if (match_data['queueId'] == RiotApi::RANKED_QUEUE_ID &&
        match_data['seasonId'] == RiotApi::ACTIVE_SEASON)
        MatchHelper.store_match(match_data)
      end
    end
  end
end
