# https://docs.google.com/spreadsheets/d/1FnCOD1_-8H3uEPmZ5HBhSmbsmkcYmnt_b9KAQwr17jQ
# All reactions should have textfield name 'rating'.

# Reaction ratings all
SELECT sessions.id       AS sessionID,
       sessions.title    AS sessionTitle,
       tickState.tick_id AS tickID,
       ticks.alias       AS tickAlias,
       CASE
           WHEN JSON_EXTRACT(tickState.result, '$.ratingDetails') IS NOT NULL
               THEN JSON_EXTRACT(tickState.result, '$.ratingLabel')
           WHEN JSON_EXTRACT(tickState.result, '$.response_ratingDetails') IS NOT NULL
               THEN JSON_EXTRACT(tickState.result, '$.response_ratingLabel')
           END           AS question,
       CASE
           WHEN JSON_EXTRACT(tickState.result, '$.ratingDetails') IS NOT NULL
               THEN JSON_EXTRACT(tickState.result, '$.rating')
           WHEN JSON_EXTRACT(tickState.result, '$.response_ratingDetails') IS NOT NULL
               THEN JSON_EXTRACT(tickState.result, '$.response_rating')
           END           AS resultValue,
       CASE
           WHEN JSON_EXTRACT(tickState.result, '$.ratingDetails') IS NOT NULL THEN
               IF(JSON_EXTRACT(tickState.result, '$.rating') = 'other',
                  '"No"',
                  IF(JSON_EXTRACT(tickState.result, '$.ratingDetails[0].value') IS NOT NULL,
                     JSON_EXTRACT(tickState.result, '$.ratingDetails[0].value'),
                     JSON_EXTRACT(tickState.result, '$.ratingDetails[0].label')))
           WHEN JSON_EXTRACT(tickState.result, '$.response_ratingDetails') IS NOT NULL THEN
               IF(JSON_EXTRACT(tickState.result, '$.response_rating') = 'other',
                  '"No"',
                  IF(JSON_EXTRACT(tickState.result, '$.response_ratingDetails[0].value') IS NOT NULL,
                     JSON_EXTRACT(tickState.result, '$.response_ratingDetails[0].value'),
                     JSON_EXTRACT(tickState.result, '$.response_ratingDetails[0].label')))
           END           AS resultLabel,
       COUNT(*)          AS amount,
       tickState.result  AS fullResultObject
FROM tick_user_state tickState
         INNER JOIN step_user_state stepState ON tickState.step_state_id = stepState.id
         INNER JOIN action_user_state actionState ON stepState.action_state_id = actionState.id
         INNER JOIN quest_user_state sessionState ON actionState.quest_state_id = sessionState.id
         INNER JOIN quests sessions ON sessionState.quest_id = sessions.id
         INNER JOIN ticks ON tickState.tick_id = ticks.id
WHERE ticks.type = 2
  AND (
    JSON_EXTRACT(tickState.result, '$.response_rating') <> '[]'
        OR JSON_EXTRACT(tickState.result, '$.ratingDetails') <> '[]'
    )
GROUP BY JSON_EXTRACT(tickState.result, '$.response_rating'),
         JSON_EXTRACT(tickState.result, '$.rating'),
         sessions.id,
         tickState.tick_id
ORDER BY sessionID DESC, tickID, fullResultObject;

# ------------------------------------------------------------------------
# Reaction ratings last week
SELECT sessions.id       AS sessionID,
       sessions.title    AS sessionTitle,
       tickState.tick_id AS tickID,
       ticks.alias       AS tickAlias,
       CASE
           WHEN JSON_EXTRACT(tickState.result, '$.ratingDetails') IS NOT NULL
               THEN JSON_EXTRACT(tickState.result, '$.ratingLabel')
           WHEN JSON_EXTRACT(tickState.result, '$.response_ratingDetails') IS NOT NULL
               THEN JSON_EXTRACT(tickState.result, '$.response_ratingLabel')
           END           AS question,
       CASE
           WHEN JSON_EXTRACT(tickState.result, '$.ratingDetails') IS NOT NULL
               THEN JSON_EXTRACT(tickState.result, '$.rating')
           WHEN JSON_EXTRACT(tickState.result, '$.response_ratingDetails') IS NOT NULL
               THEN JSON_EXTRACT(tickState.result, '$.response_rating')
           END           AS resultValue,
       CASE
           WHEN JSON_EXTRACT(tickState.result, '$.ratingDetails') IS NOT NULL THEN
               IF(JSON_EXTRACT(tickState.result, '$.rating') = 'other',
                  '"No"',
                  IF(JSON_EXTRACT(tickState.result, '$.ratingDetails[0].value') IS NOT NULL,
                     JSON_EXTRACT(tickState.result, '$.ratingDetails[0].value'),
                     JSON_EXTRACT(tickState.result, '$.ratingDetails[0].label')))
           WHEN JSON_EXTRACT(tickState.result, '$.response_ratingDetails') IS NOT NULL THEN
               IF(JSON_EXTRACT(tickState.result, '$.response_rating') = 'other',
                  '"No"',
                  IF(JSON_EXTRACT(tickState.result, '$.response_ratingDetails[0].value') IS NOT NULL,
                     JSON_EXTRACT(tickState.result, '$.response_ratingDetails[0].value'),
                     JSON_EXTRACT(tickState.result, '$.response_ratingDetails[0].label')))
           END           AS resultLabel,
       COUNT(*)          AS amount,
       tickState.result  AS fullResultObject
FROM tick_user_state tickState
         INNER JOIN step_user_state stepState ON tickState.step_state_id = stepState.id
         INNER JOIN action_user_state actionState ON stepState.action_state_id = actionState.id
         INNER JOIN quest_user_state sessionState ON actionState.quest_state_id = sessionState.id
         INNER JOIN quests sessions ON sessionState.quest_id = sessions.id
         INNER JOIN ticks ON tickState.tick_id = ticks.id
WHERE ticks.type = 2
  AND (tickState.date_updated between '2024-11-04' AND '2024-12-20')
  AND (
    JSON_EXTRACT(tickState.result, '$.response_rating') <> '[]'
        OR JSON_EXTRACT(tickState.result, '$.ratingDetails') <> '[]'
    )
GROUP BY JSON_EXTRACT(tickState.result, '$.response_rating'),
         JSON_EXTRACT(tickState.result, '$.rating'),
         sessions.id,
         tickState.tick_id
ORDER BY sessionID DESC, tickID, fullResultObject;


# ------------------------------------------------------------------------
# ------------------------------------------------------------------------
# https://docs.google.com/spreadsheets/d/1lc5aWSq3tvI_rI-wZWwgMvJfe_fx7veG5c9-tmJV6R8
# Fields for feedback should have name 'feedback'

# Feedbacks all
SELECT sessions.id       AS sessionID,
       sessions.title    AS sessionTitle,
       tickState.tick_id AS tickID,
       ticks.alias       AS tickAlias,
       tickState.id      AS tickStateID,
       CASE
           WHEN JSON_EXTRACT(tickState.result, '$.feedback') IS NOT NULL
               THEN JSON_EXTRACT(tickState.result, '$.feedback')
           END           AS resultValue
FROM tick_user_state tickState
         INNER JOIN step_user_state stepState ON tickState.step_state_id = stepState.id
         INNER JOIN action_user_state actionState ON stepState.action_state_id = actionState.id
         INNER JOIN quest_user_state sessionState ON actionState.quest_state_id = sessionState.id
         INNER JOIN quests sessions ON sessionState.quest_id = sessions.id
         INNER JOIN ticks ON tickState.tick_id = ticks.id
WHERE ticks.type = 2
  AND JSON_EXTRACT(tickState.result, '$.feedback') != ''
  AND JSON_EXTRACT(tickState.result, '$.feedback') != 'null'
ORDER BY sessionID DESC, tickID, tickStateID;

# ------------------------------------------------------------------------
# Feedbacks last week
SELECT sessions.id       AS sessionID,
       sessions.title    AS sessionTitle,
       tickState.tick_id AS tickID,
       ticks.alias       AS tickAlias,
       tickState.id      AS tickStateID,
       CASE
           WHEN JSON_EXTRACT(tickState.result, '$.feedback') IS NOT NULL
               THEN JSON_EXTRACT(tickState.result, '$.feedback')
           END           AS resultValue
FROM tick_user_state tickState
         INNER JOIN step_user_state stepState ON tickState.step_state_id = stepState.id
         INNER JOIN action_user_state actionState ON stepState.action_state_id = actionState.id
         INNER JOIN quest_user_state sessionState ON actionState.quest_state_id = sessionState.id
         INNER JOIN quests sessions ON sessionState.quest_id = sessions.id
         INNER JOIN ticks ON tickState.tick_id = ticks.id
WHERE ticks.type = 2
  AND (tickState.date_updated between '2024-11-04' AND '2024-12-20')
  AND JSON_EXTRACT(tickState.result, '$.feedback') != ''
  AND JSON_EXTRACT(tickState.result, '$.feedback') != 'null'
ORDER BY sessionID DESC, tickID, tickStateID;


# ------------------------------------------------------------------------
# ------------------------------------------------------------------------
# https://docs.google.com/spreadsheets/d/1tNpMOBJvLV0TAos1SvzaQWDnWHpQZqUpojU3sp2VDOU
# Fields for questions to LLM should have name 'user_prompt'

# Questions to LLM all
SELECT sessions.id                                     AS sessionID,
       sessions.title                                  AS sessionTitle,
       tickState.tick_id                               AS tickID,
       ticks.alias                                     AS tickAlias,
       tickState.id                                    AS tickStateID,
       JSON_EXTRACT(tickState.result, '$.user_prompt') AS resultValue
FROM tick_user_state tickState
         INNER JOIN step_user_state stepState ON tickState.step_state_id = stepState.id
         INNER JOIN action_user_state actionState ON stepState.action_state_id = actionState.id
         INNER JOIN quest_user_state sessionState ON actionState.quest_state_id = sessionState.id
         INNER JOIN quests sessions ON sessionState.quest_id = sessions.id
         INNER JOIN ticks ON tickState.tick_id = ticks.id
WHERE ticks.type = 2
  AND JSON_EXTRACT(tickState.result, '$.user_prompt') IS NOT NULL
ORDER BY sessionID DESC, tickID, tickStateID;

# ------------------------------------------------------------------------
# Questions to LLM last week
SELECT sessions.id                                     AS sessionID,
       sessions.title                                  AS sessionTitle,
       tickState.tick_id                               AS tickID,
       ticks.alias                                     AS tickAlias,
       tickState.id                                    AS tickStateID,
       JSON_EXTRACT(tickState.result, '$.user_prompt') AS resultValue
FROM tick_user_state tickState
         INNER JOIN step_user_state stepState ON tickState.step_state_id = stepState.id
         INNER JOIN action_user_state actionState ON stepState.action_state_id = actionState.id
         INNER JOIN quest_user_state sessionState ON actionState.quest_state_id = sessionState.id
         INNER JOIN quests sessions ON sessionState.quest_id = sessions.id
         INNER JOIN ticks ON tickState.tick_id = ticks.id
WHERE ticks.type = 2
  AND (tickState.date_updated between '2024-11-04' AND '2024-12-20')
  AND JSON_EXTRACT(tickState.result, '$.user_prompt') IS NOT NULL
ORDER BY sessionID DESC, tickID, tickStateID;


# ------------------------------------------------------------------------
# ------------------------------------------------------------------------
# https://docs.google.com/spreadsheets/d/1SSApUojyADKW1vDACEj5J1jjMJQbV_5PbIzJ7f53CFQ
# Fields for slider reactions should have name 'rating_score'

# Slider reactions all
SELECT sessions.id                                           AS sessionID,
       sessions.title                                        AS sessionTitle,
       tickState.tick_id                                     AS tickID,
       ticks.alias                                           AS tickAlias,
       JSON_EXTRACT(tickState.result, '$.rating_scoreLabel') AS question,
       JSON_EXTRACT(tickState.result, '$.rating_score')      AS resultValue,
       COUNT(*)                                              AS amount,
       tickState.result                                      AS fullResultObject
FROM tick_user_state tickState
         INNER JOIN step_user_state stepState ON tickState.step_state_id = stepState.id
         INNER JOIN action_user_state actionState ON stepState.action_state_id = actionState.id
         INNER JOIN quest_user_state sessionState ON actionState.quest_state_id = sessionState.id
         INNER JOIN quests sessions ON sessionState.quest_id = sessions.id
         INNER JOIN ticks ON tickState.tick_id = ticks.id
WHERE ticks.type = 2
  AND JSON_EXTRACT(tickState.result, '$.rating_score') IS NOT NULL
GROUP BY JSON_EXTRACT(tickState.result, '$.rating_score'),
         sessions.id,
         tickState.tick_id
ORDER BY sessionID DESC, tickID, resultValue;

# ------------------------------------------------------------------------
# Slider reactions last week
SELECT sessions.id                                           AS sessionID,
       sessions.title                                        AS sessionTitle,
       tickState.tick_id                                     AS tickID,
       ticks.alias                                           AS tickAlias,
       JSON_EXTRACT(tickState.result, '$.rating_scoreLabel') AS question,
       JSON_EXTRACT(tickState.result, '$.rating_score')      AS resultValue,
       COUNT(*)                                              AS amount,
       tickState.result                                      AS fullResultObject
FROM tick_user_state tickState
         INNER JOIN step_user_state stepState ON tickState.step_state_id = stepState.id
         INNER JOIN action_user_state actionState ON stepState.action_state_id = actionState.id
         INNER JOIN quest_user_state sessionState ON actionState.quest_state_id = sessionState.id
         INNER JOIN quests sessions ON sessionState.quest_id = sessions.id
         INNER JOIN ticks ON tickState.tick_id = ticks.id
WHERE ticks.type = 2
  AND (tickState.date_updated between '2024-11-04' AND '2024-12-20')
  AND JSON_EXTRACT(tickState.result, '$.rating_score') IS NOT NULL
GROUP BY JSON_EXTRACT(tickState.result, '$.rating_score'),
         sessions.id,
         tickState.tick_id
ORDER BY sessionID DESC, tickID, resultValue;
