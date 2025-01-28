# https://docs.google.com/spreadsheets/d/19DYGLMo4sf-fmhyKYA9A47abPovgp_oAxkPNVk8IZ2k
# https://docs.google.com/spreadsheets/d/1rxm6-A7-9GYrgIazdRX43X7GG6caQylwFPFF4yxD4eg

# Users with artist
SELECT COUNT(DISTINCT user.id) AS userCount
FROM corite_user user
         INNER JOIN artist ON user.id = artist.owner_id
WHERE artist.date_updated BETWEEN '2024-12-01' AND '2024-12-21';

# Users got tag `interacted-with-aflow.co`
SELECT COUNT(*)
FROM corite_user user
         INNER JOIN user_tags ON user.id = user_tags.user_id
WHERE user_tags.tag_id = 193419
  AND (user_tags.date_updated BETWEEN '2024-12-01' AND '2024-12-20');

# Monthly Active Users.
# There are amount of users who have any new tick user state during the period.
# Excluded states for several ticks in Find your flow
# because we added CM summarization one day and triggered its creation in one go for all users
# at that moment. So it's not true to say that all users was active at that date.
SELECT COUNT(DISTINCT user.id) as userCount
FROM corite_user user
         INNER JOIN tick_user_state tickState ON user.id = tickState.user_id
WHERE tickState.status = 5
  AND tickState.tick_id <> 388
  AND tickState.tick_id <> 413
  AND tickState.tick_id <> 483
  AND tickState.tick_id <> 484
  AND (tickState.date_updated BETWEEN '2024-12-01' AND '2024-12-20');

# Total Sessions Finalized
SELECT COUNT(*)
FROM quest_user_state questState
WHERE questState.status = 5
  AND (questState.date_updated BETWEEN '2024-12-01' AND '2024-12-20');

# User roles: Team member or artist
SELECT JSON_UNQUOTE(artist_data.value) as role,
       COUNT(*)                        as amount
FROM artist
         INNER JOIN artist_data ON artist.id = artist_data.artist_id
WHERE artist_data.name = 'user__role'
  AND artist.date_updated BETWEEN '2024-12-01' AND '2024-12-20'
GROUP BY artist_data.value;


# ----------------------------------------------------------
# https://docs.google.com/spreadsheets/d/1L-CCXh0N0wDnTLz_K_4ZucRmPsWRN7g1YMxSQdsDbDE

# Spotify artist followers weekly
SELECT tickState.id,
       JSON_UNQUOTE(JSON_EXTRACT(tickState.result, '$.spotify.followers.total')) AS followers,
       JSON_UNQUOTE(JSON_EXTRACT(tickState.result, '$.spotify.name'))            AS artist,
       JSON_UNQUOTE(JSON_EXTRACT(tickState.result, '$.spotify.id'))              AS spotifyId,
       sessionState.user_id,
       user.first_name,
       user.last_name,
       user.email,
       tickState.date_updated
FROM tick_user_state tickState
         INNER JOIN step_user_state stepState ON tickState.step_state_id = stepState.id
         INNER JOIN action_user_state actionState ON stepState.action_state_id = actionState.id
         INNER JOIN quest_user_state sessionState ON actionState.quest_state_id = sessionState.id
         INNER JOIN corite_user user ON sessionState.user_id = user.id
WHERE tickState.tick_id = 40
  AND sessionState.status = 5
  AND (tickState.date_updated between '2024-11-04' AND '2024-12-20')
ORDER BY CAST(JSON_UNQUOTE(JSON_EXTRACT(tickState.result, '$.spotify.followers.total')) AS UNSIGNED) DESC;


# ----------------------------------------------------------
# https://docs.google.com/spreadsheets/d/12Hw7BSIMFZX-s2jWdWK4fP1wFIlNdu7tm6xTP3T8Q3I

# User counts by completed Session count excluding Find your flow
SELECT questCount.uniqueSessionCount,
       COUNT(questCount.user_id) AS userCount
FROM (
         SELECT questState.user_id, COUNT(DISTINCT questState.quest_id) AS uniqueSessionCount
         FROM quests
                  INNER JOIN quest_user_state questState ON questState.quest_id = quests.id
         WHERE questState.status = 5
           AND quest_id != 2
         GROUP BY questState.user_id
     ) AS questCount
GROUP BY questCount.uniqueSessionCount
ORDER BY questCount.uniqueSessionCount;

