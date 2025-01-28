# Tokens for CM.artistDetails summary.
# Tick 388 is an LLM tick in the "Find Your Flow" session,
#   so you have usage information in the User state.
# It's good to mention that this ticket was chosen because
#   all users definitely have results only in this session.
SELECT JSON_UNQUOTE(JSON_EXTRACT(tickState.result, '$.usage.completionTokens')) AS completionTokens,
       JSON_UNQUOTE(JSON_EXTRACT(tickState.result, '$.usage.promptTokens'))     AS promptTokens
FROM tick_user_state tickState
WHERE tickState.tick_id = 388
  AND tickState.status = 5
  AND (tickState.date_updated between '2024-10-07' AND '2024-10-14');


# Metric from CM.
# Now it's artistDetails.cm_statistics.sp_monthly_listeners, but you can specify some other.
SELECT JSON_EXTRACT(tickState.result, '$.artistDetails.cm_statistics.sp_monthly_listeners') AS metric,
       artist.id                                                                            AS artistID,
       artist.title                                                                         AS artistName,
       tickState.id                                                                         as tickStateID,
       user.id                                                                              as userID,
       user.email,
       tickState.result
FROM tick_user_state tickState
         INNER JOIN step_user_state stepState ON tickState.step_state_id = stepState.id
         INNER JOIN action_user_state actionState ON stepState.action_state_id = actionState.id
         INNER JOIN quest_user_state sessionState ON actionState.quest_state_id = sessionState.id
         INNER JOIN corite_user user ON sessionState.user_id = user.id
         INNER JOIN artist ON user.id = artist.owner_id
WHERE tickState.tick_id = 41
  AND sessionState.status = 5
  AND JSON_EXTRACT(tickState.result, '$.artistDetails.cm_statistics.sp_monthly_listeners') != 'null'
ORDER BY CAST(JSON_UNQUOTE(JSON_EXTRACT(tickState.result,
                                        '$.artistDetails.cm_statistics.sp_monthly_listeners')) AS UNSIGNED);


# Artist attributes in ticks.
# It selects all artist attributes names that we saved in all saveToArtist ticks.
SELECT CONCAT('https://admin.corite.com/?entity=Tick&action=edit&id=', id) as Tick,
       JSON_UNQUOTE(JSON_EXTRACT(details, '$.data[0].attr'))               as ArtistAttribute
FROM ticks
WHERE ticks.handler = 'saveToArtist';


# All text fields: input type text and textarea
SELECT tick.id,
       tick.alias,
       JSON_UNQUOTE(JSON_EXTRACT(tick.details, '$.form[0]')) AS form0,
       JSON_UNQUOTE(JSON_EXTRACT(tick.details, '$.form[1]')) AS form1,
       JSON_UNQUOTE(JSON_EXTRACT(tick.details, '$.form[2]')) AS form2,
       JSON_UNQUOTE(JSON_EXTRACT(tick.details, '$.form[3]')) AS form3,
       JSON_UNQUOTE(JSON_EXTRACT(tick.details, '$.form[4]')) AS form4,
       tick.details
FROM ticks as tick
WHERE tick.type = 2
    AND tick.details LIKE '%"widget":"text"%'
   OR tick.details LIKE '%"type":"textarea"%';


# All chips fields
SELECT tick.id,
       tick.alias,
       JSON_UNQUOTE(JSON_EXTRACT(tick.details, '$.form[0].name'))  AS formName0,
       JSON_UNQUOTE(JSON_EXTRACT(tick.details, '$.form[0].label')) AS formLabel0,
       JSON_UNQUOTE(JSON_EXTRACT(tick.details, '$.form[1].name'))  AS formName1,
       JSON_UNQUOTE(JSON_EXTRACT(tick.details, '$.form[1].label')) AS formLabel1,
       JSON_UNQUOTE(JSON_EXTRACT(tick.details, '$.form[2].name'))  AS formName2,
       JSON_UNQUOTE(JSON_EXTRACT(tick.details, '$.form[2].label')) AS formLabel2,
       JSON_UNQUOTE(JSON_EXTRACT(tick.details, '$.form[3].name'))  AS formName3,
       JSON_UNQUOTE(JSON_EXTRACT(tick.details, '$.form[3].label')) AS formLabel3,
       JSON_UNQUOTE(JSON_EXTRACT(tick.details, '$.form[4].name'))  AS formName4,
       JSON_UNQUOTE(JSON_EXTRACT(tick.details, '$.form[4].label')) AS formLabel4,
       tick.details
FROM ticks as tick
WHERE tick.type = 2
  AND tick.details LIKE '%"type":"chips"%';


# All slider fields
SELECT tick.id,
       tick.alias,
       JSON_UNQUOTE(JSON_EXTRACT(tick.details, '$.form[0]')) AS form0,
       JSON_UNQUOTE(JSON_EXTRACT(tick.details, '$.form[1]')) AS form1,
       JSON_UNQUOTE(JSON_EXTRACT(tick.details, '$.form[2]')) AS form2,
       JSON_UNQUOTE(JSON_EXTRACT(tick.details, '$.form[3]')) AS form3,
       JSON_UNQUOTE(JSON_EXTRACT(tick.details, '$.form[4]')) AS form4,
       tick.details
FROM ticks as tick
WHERE tick.type = 2
  AND tick.details LIKE '%"type":"slider"%';


# Comparison of the old Spotify bio and the bio suggested by Aflow
# in session Boost Spotify bio (#8)
SELECT artist.id                                                                                    as artistId,
       CONCAT('https://open.spotify.com/artist/', JSON_UNQUOTE(data1.value))                        as spotify,
       CAST(JSON_UNQUOTE(JSON_EXTRACT(tickState1.result, '$.spotify.followers.total')) AS UNSIGNED) as followers,
       JSON_UNQUOTE(data2.value)                                                                    as newBio,
       JSON_UNQUOTE(JSON_EXTRACT(tickState2.result, '$.bio'))                                       as oldBio,
       corite_user.id                                                                               as userId,
       corite_user.email
FROM artist
         INNER JOIN corite_user ON artist.owner_id = corite_user.id
         INNER JOIN artist_data as data1 ON artist.id = data1.artist_id
         INNER JOIN artist_data as data2 ON artist.id = data2.artist_id
         INNER JOIN tick_user_state as tickState1 ON corite_user.id = tickState1.user_id
         INNER JOIN tick_user_state as tickState2 ON corite_user.id = tickState2.user_id
WHERE data1.name = 'spotify_artist_id'
  AND data2.name = 'spotifyBio'
  AND tickState1.tick_id = 40
  AND tickState2.tick_id = 132
GROUP BY artist.id
ORDER BY followers DESC
;


# Amount of artists without chartmetric data
SELECT COUNT(*)
FROM artist
         INNER JOIN artist_data as data1 ON artist.id = data1.artist_id
         LEFT JOIN artist_data AS data2 ON artist.id = data2.artist_id AND data2.name = 'chartmetric_id'
WHERE data1.name = 'spotify_artist_id'
  AND data1.value <> ''
  AND data2.artist_id IS NULL;


# Usage
# https://docs.google.com/spreadsheets/d/12Hw7BSIMFZX-s2jWdWK4fP1wFIlNdu7tm6xTP3T8Q3I
SELECT CONCAT('https://admin.corite.com/?entity=User&action=show&id=', resource_usage.user_id)      as userLink,
       corite_user.email,
       resource_usage.points,
       resource_usage.amount,
       resource_usage.unit,
       CONCAT('https://admin.corite.com/?entity=TickUserState&action=show&id=', tick_user_state.id) as tickStateLink,
       CONCAT('https://admin.corite.com/?entity=Tick&action=edit&id=', ticks.id)                    as tickLink,
       ticks.alias                                                                                  as tickAlias,
       ticks.handler,
       JSON_UNQUOTE(JSON_EXTRACT(tick_user_state.result, '$.settings.model'))                       as llmModel,
       action_user_state.quest_state_id                                                             as sessionStateId,
       actions.quest_id                                                                             as sessionId
FROM resource_usage
         INNER JOIN tick_user_state ON resource_usage.ref = tick_user_state.id
         INNER JOIN step_user_state ON tick_user_state.step_state_id = step_user_state.id
         INNER JOIN action_user_state ON step_user_state.action_state_id = action_user_state.id
         INNER JOIN ticks ON tick_user_state.tick_id = ticks.id
         INNER JOIN steps ON ticks.step_id = steps.id
         INNER JOIN actions ON steps.action_id = actions.id
         INNER JOIN corite_user ON resource_usage.user_id = corite_user.id
WHERE resource_usage.ref_type = 'tick'
ORDER BY resource_usage.points DESC;
