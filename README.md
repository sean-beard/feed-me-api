# Feed Me

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

## Web app

VueJS 2
Maybe upgrade to VueJS 3 once ecosystem matures?

https://materializecss.com/

## API

Phoenix / Elixir

### Endpoints

#### feed

| Route              | Verb | Description                                  |
| ------------------ | ---- | -------------------------------------------- |
| /                  | GET  | Get all sorted feed items from subscriptions |
| /:feed_id          | GET  | Get feed name and corresponding feed items   |
| /:feed_id/:item_id | PUT  | Update a feed item's metadata                |

### subscriptions

| Route     | Verb | Description                                          |
| --------- | ---- | ---------------------------------------------------- |
| /         | GET  | Get all user subscriptions                           |
| /         | POST | Create a subscription and a feed if it doesn't exist |
| /:feed_id | PUT  | Update a subscription                                |

## DB

Postgres

### Tables

feed

- id
- name
- description
- url

subscription_fact

- id
- user_id
- feed_id
- is_subscribed

feed_item

- id
- feed_id (FK)
- title
- link
- description
- pub_date

feed_item_status_fact

- id
- user_id
- feed_item_id
- is_read
- is_flagged
