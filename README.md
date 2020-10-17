# FeedMe

RSS feed management application.

## Features

- Get a chronological, personalized newsfeed that you create
- Users can mark feed items as read/unread
- Grouping
  - All
  - By feed
- Filtering logic similar to native iOS mail application (available per group)
  - All vs unread
  - Flagged (not MVP)
- Users can flag items to save for later (not MVP)

## API Endpoints

| Route                   | Verb | Description                                  |
| ----------------------- | ---- | -------------------------------------------- |
| /feed                   | GET  | Get all sorted feed items from subscriptions |
| /feed/:feed_id          | GET  | Get feed name and corresponding feed items   |
| /feed/:feed_id/:item_id | PUT  | Update a feed item's metadata                |

| Route                  | Verb | Description                                          |
| ---------------------- | ---- | ---------------------------------------------------- |
| /subscription          | GET  | Get all user subscriptions                           |
| /subscription          | POST | Create a subscription and a feed if it doesn't exist |
| /subscription/:feed_id | PUT  | Update a subscription                                |

## Database Tables

`feeds`

- id
- name
- description
- url

`subscriptions`

- id
- user_id
- feed_id
- is_subscribed

`feed_items`

- id
- feed_id (FK)
- title
- url
- description
- pub_date

`feed_item_statuses`

- id
- user_id
- feed_item_id
- is_read
- is_flagged
